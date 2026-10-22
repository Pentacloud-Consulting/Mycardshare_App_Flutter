// lib/backend/enterprise/invite_employee/enterprise_invite_link_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class EnterpriseInviteLinkService {
  static const String baseUrl = "https://mycardshare.com";

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. ADMIN: FETCH LIVE 15-MIN ROTATING LINK & CODE (popup_invite.dart)
  static Future<Map<String, dynamic>?> fetchLiveInviteLink() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(
        Uri.parse("$baseUrl/api/sync/enterprise-invite-link"),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json["data"] is Map<String, dynamic> ? json["data"] : null;
      }
    } catch (e) {
      debugPrint("[InviteLink] Fetch live link error: $e");
    }
    return null;
  }

  /// 2. EMPLOYEE: LOOKUP 8-DIGIT CODE PREVIEW (join_workspace.dart as user types)
  static Future<Map<String, dynamic>?> lookupCodePreview(String code, {String? enterpriseId}) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/enterprise-invite-link"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "lookup_code",
          "code": code.trim(),
          "enterpriseId": ?enterpriseId,
        }),
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json["data"] is Map<String, dynamic> ? json["data"] : null;
      }
    } catch (e) {
      debugPrint("[InviteLink] Lookup code error: $e");
    }
    return null;
  }

  /// 3. EMPLOYEE: INSTANT ONBOARDING (join_login.dart -> NO MANUAL APPROVAL NEEDED!)
  static Future<Map<String, dynamic>> instantOnboardWithCode({
    required String enterpriseId,
    required String code,
    required String fullName,
    required String workEmail,
    required String password,
    String jobTitle = "Team Member",
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/enterprise-invite-link"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "instant_onboard",
          "enterpriseId": enterpriseId,
          "code": code.trim(),
          "fullName": fullName,
          "workEmail": workEmail.trim().toLowerCase(),
          "password": password,
          "jobTitle": jobTitle,
        }),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return json["data"] is Map<String, dynamic> ? json["data"] : {};
      } else {
        return {"error": json["error"] ?? "Failed to join workspace."};
      }
    } catch (e) {
      debugPrint("[InviteLink] Instant onboard error: $e");
      return {"error": e.toString()};
    }
  }
}
