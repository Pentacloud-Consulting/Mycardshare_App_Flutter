import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcCardItem {
  final String tagUid;
  final String cardSlug;
  final String cardholderName;
  final bool isBrandLocked;
  final bool isWritable;
  final int tapCount;
  final String status;
  final String? lastTappedAt;

  NfcCardItem({
    required this.tagUid,
    required this.cardSlug,
    required this.cardholderName,
    this.isBrandLocked = false,
    this.isWritable = true,
    this.tapCount = 0,
    this.status = 'active',
    this.lastTappedAt,
  });

  factory NfcCardItem.fromJson(Map<String, dynamic> json) {
    return NfcCardItem(
      tagUid: json['tagUid'] ?? '',
      cardSlug: json['cardSlug'] ?? '',
      cardholderName: json['cardholderName'] ?? '',
      isBrandLocked: json['isBrandLocked'] ?? false,
      isWritable: json['isWritable'] ?? true,
      tapCount: json['tapCount'] ?? 0,
      status: json['status'] ?? 'active',
      lastTappedAt: json['lastTappedAt'],
    );
  }
}

class NfcSyncService {
  NfcSyncService._internal();
  static final NfcSyncService instance = NfcSyncService._internal();

  static const String baseUrl = "https://mycardshare.com";

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. WRITE & ACTIVATE PHYSICAL NFC CARD
  static Future<bool> startNfcCardActivation({
    required String cardSlug,
    required String cardholderName,
    bool isBrandLocked = false,
    Function(String status)? onProgress,
  }) async {
    // iOS does not support NFC tag emulation (phone-to-phone write).
    // NFC reading works on iOS 14+, but writing NdefRecord to physical chip
    // requires background tag reading entitlement — show QR fallback instead.
    if (!kIsWeb && Platform.isIOS) {
      onProgress?.call(
        'NFC card writing is not supported on iPhone via emulation. '
        'Please use QR Code sharing instead to share your card.',
      );
      return false;
    }

    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      onProgress?.call("NFC is not supported or turned off on this device.");
      return false;
    }

    onProgress?.call("Hold your NFC card near the back of your phone...");

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          // Extract chip identifier
          final tagData = tag.data;
          String tagUid = "";

          if (tagData['nfca'] != null && tagData['nfca']['identifier'] != null) {
            tagUid = (tagData['nfca']['identifier'] as List)
                .map((e) => (e as int).toRadixString(16).padLeft(2, '0'))
                .join(':');
          } else {
            tagUid = "nfc-${DateTime.now().millisecondsSinceEpoch}";
          }

          // Step A: Register in Backend
          final headers = await _getHeaders();
          final res = await http.post(
            Uri.parse("$baseUrl/api/sync/nfc"),
            headers: headers,
            body: jsonEncode({
              "action": "activate",
              "tagUid": tagUid,
              "cardSlug": cardSlug,
              "cardholderName": cardholderName,
              "isBrandLocked": isBrandLocked,
            }),
          );

          if (res.statusCode == 200) {
            final json = jsonDecode(res.body);
            final writeUrl = json["data"]?["ndefPayload"]?["uri"] ??
                "https://mycardshare.com/card/$cardSlug";

            // Step B: Write NDEF URI to Chip
            final ndef = Ndef.from(tag);
            if (ndef != null && ndef.isWritable) {
              final message = NdefMessage([
                NdefRecord.createUri(Uri.parse(writeUrl)),
              ]);
              await ndef.write(message);
              onProgress?.call("🎉 NFC Card successfully activated & written!");
            } else {
              onProgress?.call("Card registered in cloud, but chip is locked or not writable.");
            }
          } else {
            onProgress?.call("Activation error: ${res.statusCode}");
          }
          await NfcManager.instance.stopSession();
        } catch (e) {
          onProgress?.call("Failed to write to NFC card: $e");
          await NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
    );
    return true;
  }

  /// 2. GET USER'S LINKED NFC HARDWARE CARDS
  static Future<List<NfcCardItem>> fetchLinkedNfcCards() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse("$baseUrl/api/sync/nfc"), headers: headers);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final list = (json["data"]?["tags"] ?? json["tags"] ?? []) as List;
        return list.map((item) => NfcCardItem.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint("[NfcSyncService] Fetch NFC Cards Error: $e");
    }
    return [];
  }

  /// 3. DEACTIVATE LOST OR OFFBOARDED CARD
  static Future<bool> deactivateCard(String tagUid) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/nfc"),
        headers: headers,
        body: jsonEncode({
          "action": "deactivate",
          "tagUid": tagUid,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("[NfcSyncService] Deactivate NFC Error: $e");
      return false;
    }
  }

  /// 4. VERIFY TAP TELEMETRY
  static Future<Map<String, dynamic>?> verifyTap(String tagUid) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/nfc"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "verify_tap",
          "tagUid": tagUid,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("[NfcSyncService] Verify Tap Error: $e");
    }
    return null;
  }
}
