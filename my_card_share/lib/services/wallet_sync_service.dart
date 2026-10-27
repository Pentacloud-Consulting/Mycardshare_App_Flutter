import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class WalletSyncService {
  // ⚡ Live backend server domain
  static const String baseUrl = "https://digitalbusinesscloudcard.com";

  /// 1. Add to Google Wallet or Samsung Wallet
  /// [walletType]: "google" | "samsung" | "apple"
  static Future<Map<String, dynamic>> addToWallet({
    required String walletType, // "google" or "samsung"
    required Map<String, dynamic> cardData,
  }) async {
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      // ⚡ Step 1: Call Backend Sync Wallet API
      final response = await http.post(
        Uri.parse("$baseUrl/api/sync/wallet"),
        headers: {
          "Content-Type": "application/json",
          if (idToken != null) "Authorization": "Bearer $idToken",
        },
        body: jsonEncode({
          "walletType": walletType.toLowerCase(),
          "cardData": {
            "userId": cardData['userId'] ?? FirebaseAuth.instance.currentUser?.uid ?? "",
            "fullName": cardData['fullName'] ?? cardData['name'] ?? "",
            "jobTitle": cardData['jobTitle'] ?? cardData['title'] ?? "",
            "companyName": cardData['companyName'] ?? cardData['company'] ?? "",
            "workEmail": cardData['workEmail'] ?? cardData['email'] ?? "",
            "workPhone": cardData['workPhone'] ?? cardData['phone'] ?? "",
            "website": cardData['website'] ?? "",
            "avatarUrl": cardData['avatarUrl'] ?? "",
            "bannerUrl": cardData['bannerUrl'] ?? "",
            "cardSlug": cardData['cardSlug'] ?? cardData['slug'] ?? "",
            "themeColor": cardData['themeColor'] ?? "#0A84FF",
          },
        }),
      );

      final Map<String, dynamic> resData = jsonDecode(response.body);
      if (response.statusCode == 200 && resData['success'] == true) {
        final data = resData['data'];

        // ⚡ Step 2: Extract official wallet link
        // Google: https://pay.google.com/gp/v/save/...
        // Samsung: https://a.swallet.link/atw/v3/...
        final String? targetUrl = data['saveUrl'] ?? data['addToWalletUrl'] ?? data['deepLink'];
        final String? vcfUrl = data['vcfUrl'];
        final String cardSlug = cardData['cardSlug'] ?? cardData['slug'] ?? '';

        // ⚡ Step 3: CRITICAL - Launch native wallet or contact intent
        if (targetUrl != null && targetUrl.isNotEmpty) {
          try {
            final uri = Uri.parse(targetUrl);
            final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (launched) return {'success': true, 'url': targetUrl};
          } catch (_) {}

          try {
            final uri = Uri.parse(targetUrl);
            final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
            if (launched) return {'success': true, 'url': targetUrl};
          } catch (_) {}
        }

        // ⚡ Step 4: Fallback to direct Device & Google/Samsung Account Contact Pass (.vcf)
        if (vcfUrl != null && vcfUrl.isNotEmpty) {
          try {
            final uri = Uri.parse(vcfUrl);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return {'success': true, 'url': vcfUrl};
          } catch (_) {}
        } else if (cardSlug.isNotEmpty) {
          await saveContactToDevice(cardSlug: cardSlug);
          return {'success': true, 'url': 'contact_saved'};
        }

        return {'success': false, 'error': 'Could not open wallet URL on this device'};
      } else {
        return {
          'success': false,
          'error': resData['error'] ?? 'Wallet pass generation failed (${response.statusCode})',
        };
      }
    } catch (e) {
      debugPrint("Wallet Sync Error: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 2. Save Contact Directly to Phonebook (vCard RFC 6350)
  /// ⚡ Dialer khulne ki jagah seedha native Phonebook "Save Contact" screen khulta hai!
  static Future<void> saveContactToDevice({required String cardSlug}) async {
    try {
      final vcfUrl = Uri.parse("$baseUrl/api/sync/save-contact?cardSlug=$cardSlug&download=true");
      // Launch externally so Android/iOS Contacts app intercepts the .vcf file directly!
      if (await canLaunchUrl(vcfUrl)) {
        await launchUrl(vcfUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Save Contact Error: $e");
    }
  }
}
