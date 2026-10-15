import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class GlobalAuthSyncService {
  static const String baseUrl = "https://mycardshare.com";

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. APP LOGIN HOTE HI ROLE RESOLVE KAREIN (Individual vs Employee vs Enterprise vs Master Admin)
  static Future<Map<String, dynamic>?> resolveUserRoleOnLogin() async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/global-directory"),
        headers: headers,
        body: jsonEncode({"action": "resolve_user_role"}),
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final roleData = json["data"];

        // Also register mobile session presence
        await syncMobileHeartbeat();

        return roleData is Map<String, dynamic> ? roleData : null;
      }
    } catch (e) {
      debugPrint("[GlobalAuthSyncService] Role resolve error: $e");
    }
    return null;
  }

  /// 2. SEND MOBILE PRESENCE TO WEB DATABASE
  static Future<void> syncMobileHeartbeat() async {
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse("$baseUrl/api/sync/global-directory"),
        headers: headers,
        body: jsonEncode({
          "action": "app_session_heartbeat",
          "deviceModel": "Flutter Mobile",
          "platform": "android",
        }),
      );
    } catch (e) {
      debugPrint("[GlobalAuthSyncService] Heartbeat failed: $e");
    }
  }

  /// 3. MASTER ADMIN / ENTERPRISE KE LIYE: FETCH ALL REGISTERED USERS (WEB + APP)
  static Future<Map<String, dynamic>> fetchAllGlobalUsers({String role = "all", String query = ""}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse("$baseUrl/api/sync/global-directory?role=$role&query=$query");
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return {
          "counts": json["data"]?["counts"] ?? {},
          "users": json["data"]?["users"] ?? [],
        };
      }
    } catch (e) {
      debugPrint("[GlobalAuthSyncService] Fetch directory error: $e");
    }
    return {"counts": {}, "users": []};
  }
}
