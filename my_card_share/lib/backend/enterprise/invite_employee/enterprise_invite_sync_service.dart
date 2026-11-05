import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../individual/api_service.dart';

class EnterpriseInviteSyncService {
  static const List<String> _hosts = [
    'https://mycardshare.com',
    'https://digitalbusinesscloudcard.com',
    'https://dbc.celestialedge.in',
  ];

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static Future<http.Response?> _sendResilientRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final finalHeaders = headers ?? await _getHeaders();
    final bodyStr = body != null ? jsonEncode(body) : null;

    for (final host in _hosts) {
      try {
        final uri = Uri.parse('$host$endpoint');
        final res = method == 'POST'
            ? await http
                .post(uri, headers: finalHeaders, body: bodyStr)
                .timeout(const Duration(seconds: 8))
            : await http
                .get(uri, headers: finalHeaders)
                .timeout(const Duration(seconds: 8));

        if (res.statusCode >= 200 && res.statusCode < 300) {
          return res;
        }
      } catch (e) {
        debugPrint('[EnterpriseInviteSyncService] $method $endpoint on $host error: $e');
      }
    }
    return null;
  }

  /// 1. GET ACTIVE 15-MIN ROTATING CODE & COUNTDOWN TIMER
  static Future<Map<String, dynamic>?> fetchLiveInviteCode() async {
    try {
      final res = await _sendResilientRequest('GET', '/api/sync/invite-code');
      if (res != null && res.statusCode == 200) {
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
      // Dispatches official enterprise email invites via Web Next.js Nodemailer
      unawaited(IndividualApiService.post('/api/enterprise/workspace/invite', {
        'email': workEmail.trim().toLowerCase(),
      }).catchError((e) {
        debugPrint("[EnterpriseInviteSyncService] Web workspace invite error: $e");
        return null;
      }));

      final res = await _sendResilientRequest('POST', '/api/sync/invite-code', body: {
        "action": "add_single_employee",
        "fullName": fullName,
        "workEmail": workEmail,
        "jobTitle": jobTitle,
        "role": role,
      });

      return res != null && res.statusCode == 200;
    } catch (e) {
      debugPrint("[EnterpriseInviteSyncService] Add single employee error: $e");
      return false;
    }
  }

  /// 3. SUBMIT BATCH EMAIL INVITES (invite.dart Tab 2)
  static Future<bool> batchInviteEmails(List<String> emails) async {
    try {
      // Dispatches official enterprise email invites via Web Next.js for each email
      for (final email in emails) {
        final clean = email.trim().toLowerCase();
        if (clean.isNotEmpty) {
          unawaited(IndividualApiService.post('/api/enterprise/workspace/invite', {
            'email': clean,
          }).catchError((e) {
            debugPrint("[EnterpriseInviteSyncService] Batch invite error for $clean: $e");
            return null;
          }));
        }
      }

      final res = await _sendResilientRequest('POST', '/api/sync/invite-code', body: {
        "action": "batch_invite_emails",
        "emails": emails,
      });

      return res != null && res.statusCode == 200;
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
      final payload = <String, dynamic>{"action": "verify_code"};
      if (enterpriseId != null) payload["enterpriseId"] = enterpriseId;
      if (code != null) payload["code"] = code;
      if (voucher != null) payload["voucher"] = voucher;

      final res = await _sendResilientRequest(
        'POST',
        '/api/sync/invite-code',
        body: payload,
        headers: {"Content-Type": "application/json"},
      );

      if (res != null && res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json["data"] is Map<String, dynamic> ? json["data"] : json;
      }
    } catch (e) {
      debugPrint("[EnterpriseInviteSyncService] Verify code error: $e");
    }
    return null;
  }
}
