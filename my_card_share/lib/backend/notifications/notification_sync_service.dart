import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationSyncService {
  NotificationSyncService._internal();
  static final NotificationSyncService instance = NotificationSyncService._internal();

  static const String baseUrl = "https://mycardshare.com";

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. APP START PAR FCM TOKEN BACKEND ME REGISTER KAREIN
  static Future<void> registerDeviceToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      // Request permission for iOS & Android 13+
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final fcmToken = await messaging.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          final headers = await _getHeaders();
          final deviceType = defaultTargetPlatform == TargetPlatform.iOS ? "ios" : "android";

          await http.post(
            Uri.parse("$baseUrl/api/sync/notifications"),
            headers: headers,
            body: jsonEncode({
              "action": "register_token",
              "fcmToken": fcmToken,
              "deviceType": deviceType,
            }),
          );
          debugPrint("[NotificationSync] FCM Token registered with backend: ${fcmToken.substring(0, 15)}...");
        }
      }
    } catch (e) {
      debugPrint("[NotificationSync] Token registration notice: $e");
    }
  }

  /// 2. USER NOTIFICATION FEED FETCH KAREIN (Unread Badge & List)
  static Future<Map<String, dynamic>> fetchNotifications({bool unreadOnly = false}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse("$baseUrl/api/sync/notifications?unreadOnly=$unreadOnly&limit=30");
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return {
          "unreadCount": json["data"]?["unreadCount"] ?? 0,
          "notifications": json["data"]?["notifications"] ?? [],
        };
      }
    } catch (e) {
      debugPrint("[NotificationSync] Fetch error: $e");
    }
    return {"unreadCount": 0, "notifications": []};
  }

  /// 3. NOTIFICATION READ MARK KAREIN
  static Future<void> markAsRead({String? notificationId, bool markAll = false}) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{
        "action": "mark_read",
        "markAll": markAll,
      };
      if (notificationId != null) {
        body["notificationId"] = notificationId;
      }
      await http.post(
        Uri.parse("$baseUrl/api/sync/notifications"),
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e) {
      debugPrint("[NotificationSync] Mark read error: $e");
    }
  }

  /// 4. JAB KOI CARD SCAN HO YA LEAD AAVE TOH INSTANT ALERT DISPATCH KAREIN
  static Future<void> triggerAlert({
    required String targetUserId,
    required String title,
    required String body,
    String type = "card_view", // "card_view" | "lead_capture" | "team_invite" | "security"
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse("$baseUrl/api/sync/notifications"),
        headers: headers,
        body: jsonEncode({
          "action": "send_alert",
          "targetUserId": targetUserId,
          "title": title,
          "body": body,
          "type": type,
          "data": data ?? {},
        }),
      );
      debugPrint("[NotificationSync] Triggered real alert '$title' for user: $targetUserId");
    } catch (e) {
      debugPrint("[NotificationSync] Trigger alert notice: $e");
    }
  }

  /// 5. SETUP FOREGROUND NOTIFICATION LISTENER
  static void setupForegroundListener({Function(RemoteMessage)? onNotificationReceived}) {
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("[NotificationSync] Foreground message received: ${message.notification?.title}");
        if (onNotificationReceived != null) {
          onNotificationReceived(message);
        }
      });
    } catch (e) {
      debugPrint("[NotificationSync] Foreground listener notice: $e");
    }
  }
}
