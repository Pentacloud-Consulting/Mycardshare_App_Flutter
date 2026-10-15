import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class EnterpriseInviteSyncService {
  static const String baseUrl = "https://mycardshare.com";

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. GET ACTIVE 15-MIN ROTATING CODE & COUNTDOWN TIMER
  static Future<Map<String, dynamic>?> fetchLiveInviteCode() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse("$baseUrl/api/sync/invite-code"), headers: headers);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json["data"] is Map<String, dynamic> ? json["data"] : null;
      }
    } catch (e) {
      debugPrint("[EnterpriseInviteSyncService] Fetch invite code error: $e");
    }
    return null;
  }

  /// 2. SUBMIT SINGLE EMPLOYEE DIRECT ADD (invite.dart Tab 1)
  static Future<bool> addSingleEmployee({
    required String fullName,
    required String workEmail,
    required String jobTitle,
    String role = "employee",
  }) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/invite-code"),
        headers: headers,
        body: jsonEncode({
          "action": "add_single_employee",
          "fullName": fullName,
          "workEmail": workEmail,
          "jobTitle": jobTitle,
          "role": role,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("[EnterpriseInviteSyncService] Add single employee error: $e");
      return false;
    }
  }

  /// 3. SUBMIT BATCH EMAIL INVITES (invite.dart Tab 2)
  static Future<bool> batchInviteEmails(List<String> emails) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/invite-code"),
        headers: headers,
        body: jsonEncode({
          "action": "batch_invite_emails",
          "emails": emails,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("[EnterpriseInviteSyncService] Batch invite error: $e");
      return false;
    }
  }

  /// 4. VERIFY CODE FOR JOINING EMPLOYEE (employee_join/join_login.dart)
  static Future<Map<String, dynamic>?> verifyJoinCode({
    String? enterpriseId,
    String? code,
    String? voucher,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/invite-code"),
        headers: {"Content-Type": "application/json"},
        body: () {
          final payload = <String, dynamic>{"action": "verify_code"};
          if (enterpriseId != null) payload["enterpriseId"] = enterpriseId;
          if (code != null) payload["code"] = code;
          if (voucher != null) payload["voucher"] = voucher;
          return jsonEncode(payload);
        }(),
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json["data"] is Map<String, dynamic> ? json["data"] : null;
      }
    } catch (e) {
      debugPrint("[EnterpriseInviteSyncService] Verify join code error: $e");
    }
    return null;
  }
}
