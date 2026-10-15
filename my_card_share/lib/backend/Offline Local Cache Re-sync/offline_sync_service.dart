import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline Local Cache Re-sync (Batch Delta Sync) Service.
/// Stores pending offline actions (scans, leads, contacts, edits) in local SharedPreferences
/// and automatically flushes the queue to Next.js (/api/sync/offline-batch) when internet is available.
class OfflineSyncService {
  OfflineSyncService._internal();
  static final OfflineSyncService instance = OfflineSyncService._internal();

  static const String baseUrl = "https://mycardshare.com";
  static const String _queuePrefKey = "offline_sync_queue";
  static const String _lastSyncPrefKey = "offline_last_sync_timestamp";

  static Timer? _autoSyncTimer;
  static bool _isSyncing = false;

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. CHECK INTERNET AVAILABILITY SAFELY
  static Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('mycardshare.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      try {
        final fallback = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 4));
        return fallback.isNotEmpty && fallback[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  /// 2. ADD ITEM TO LOCAL OFFLINE QUEUE (When offline or opportunistic)
  static Future<void> enqueueOfflineAction({
    required String entityType, // "contact" | "lead" | "profile"
    required String action,     // "create" | "update" | "delete"
    required Map<String, dynamic> payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rawQueue = prefs.getStringList(_queuePrefKey) ?? [];

    final clientSyncId =
        "sync_${DateTime.now().millisecondsSinceEpoch}_${payload['phone'] ?? payload['email'] ?? payload['name'] ?? ''}";

    final item = {
      "clientSyncId": clientSyncId,
      "entityType": entityType,
      "action": action,
      "payload": payload,
      "clientTimestamp": DateTime.now().toIso8601String(),
    };

    rawQueue.add(jsonEncode(item));
    await prefs.setStringList(_queuePrefKey, rawQueue);
    debugPrint("[OfflineSyncService] 📦 Saved to Offline Queue: $clientSyncId (Total: ${rawQueue.length})");

    // Attempt immediate sync in background if online
    triggerSyncIfOnline();
  }

  /// 3. TRIGGER BATCH DELTA SYNC WHEN INTERNET RESUMES
  static Future<void> triggerSyncIfOnline() async {
    if (_isSyncing) return;

    final online = await isOnline();
    if (!online) {
      debugPrint("[OfflineSyncService] 📵 Device is offline, queue remains securely saved locally.");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> rawQueue = prefs.getStringList(_queuePrefKey) ?? [];
    if (rawQueue.isEmpty) return;

    _isSyncing = true;
    try {
      final headers = await _getHeaders();
      List<Map<String, dynamic>> queueObjects = rawQueue
          .map((str) => jsonDecode(str) as Map<String, dynamic>)
          .toList();

      debugPrint("[OfflineSyncService] 🚀 Syncing ${queueObjects.length} offline batch items to Cloud Database...");

      final response = await http.post(
        Uri.parse("$baseUrl/api/sync/offline-batch"),
        headers: headers,
        body: jsonEncode({"queue": queueObjects}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Clear local queue upon confirmed server sync
        await prefs.remove(_queuePrefKey);
        await prefs.setString(_lastSyncPrefKey, DateTime.now().toIso8601String());
        debugPrint("[OfflineSyncService] ✅ Successfully synced ${queueObjects.length} offline items to Cloud Database!");
      } else {
        debugPrint("[OfflineSyncService] Server returned status ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("[OfflineSyncService] Sync retry notice (will re-attempt on next connection window): $e");
    } finally {
      _isSyncing = false;
    }
  }

  /// 4. FETCH SERVER DELTA UPDATES (Records updated after last sync)
  static Future<List<dynamic>> fetchDeltaUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(_lastSyncPrefKey) ?? '';

    try {
      final headers = await _getHeaders();
      final uri = Uri.parse("$baseUrl/api/sync/offline-batch?lastSyncTimestamp=${Uri.encodeComponent(lastSync)}");
      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data["data"]?["updates"] ?? data["updates"] ?? [];
        if (list is List) {
          debugPrint("[OfflineSyncService] Received ${list.length} delta updates from server.");
          return list;
        }
      }
    } catch (e) {
      debugPrint("[OfflineSyncService] Fetch delta error: $e");
    }
    return [];
  }

  /// 5. AUTOMATIC PERIODIC & RESUME LISTENER (Call in main.dart)
  static void initAutoSyncListener() {
    _autoSyncTimer?.cancel();
    // Check and trigger sync every 30 seconds if online
    _autoSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      triggerSyncIfOnline();
    });

    // Run first check right away
    triggerSyncIfOnline();
  }
}
