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

  /// 1. ADMIN: Fetch live invite link / voucher code for the enterprise workspace
  /// GET /api/enterprise/workspace  → returns workspaceId + voucherCode
  static Future<Map<String, dynamic>?> fetchLiveInviteLink() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(
        Uri.parse("$baseUrl/api/enterprise/workspace"),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final data = json["data"];
        // Build the shareable invite link from workspaceId + voucherCode
        if (data is Map<String, dynamic>) {
          final workspaceId = data['workspaceId'] ?? data['companyId'] ?? '';
          final voucher = data['voucherCode'] ?? data['inviteCode'] ?? '';
          if (workspaceId.isNotEmpty && voucher.isNotEmpty) {
            final link = "$baseUrl/join?workspaceId=$workspaceId&voucher=$voucher";
            return {
              ...data,
              'inviteLink': link,
              'inviteCode': voucher,
            };
          }
          return data;
        }
      }
    } catch (e) {
      debugPrint("[InviteLink] Fetch live link error: $e");
    }
    return null;
  }

  /// 2. ADMIN: Send invite email to a specific employee
  /// POST /api/enterprise/workspace/invite  { email }
  static Future<bool> sendInviteEmail(String email) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/enterprise/workspace/invite"),
        headers: headers,
        body: jsonEncode({"email": email.trim().toLowerCase()}),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("[InviteLink] Send invite email error: $e");
      return false;
    }
  }

  /// 3. EMPLOYEE: Lookup / verify invite code before joining
  /// GET /api/invite/verify?workspaceId=XXX&voucher=YYY
  static Future<Map<String, dynamic>?> lookupCodePreview(String code,
      {String? enterpriseId}) async {
    try {
      final uri = Uri.parse("$baseUrl/api/invite/verify").replace(
        queryParameters: {
          if (enterpriseId != null && enterpriseId.isNotEmpty)
            'workspaceId': enterpriseId,
          'voucher': code.trim().toUpperCase(),
        },
      );
      final res = await http.get(uri, headers: {"Content-Type": "application/json"});
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json["data"] is Map<String, dynamic> ? json["data"] : null;
      }
    } catch (e) {
      debugPrint("[InviteLink] Lookup code error: $e");
    }
    return null;
  }

  /// 4. EMPLOYEE: Instant onboarding with voucher code
  /// POST /api/enterprise/workspace/invite  { action: instant_onboard, ... }
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
        Uri.parse("$baseUrl/api/enterprise/workspace/invite"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "instant_onboard",
          "workspaceId": enterpriseId,
          "voucher": code.trim().toUpperCase(),
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
