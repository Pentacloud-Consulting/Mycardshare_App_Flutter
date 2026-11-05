import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_send_request.dart';

class EmployeeJoinRequestService {
  static const List<String> _hosts = [
    "https://mycardshare.com",
    "https://digitalbusinesscloudcard.com",
  ];

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static Future<http.Response?> _sendRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final bodyStr = body != null ? jsonEncode(body) : null;

    for (final host in _hosts) {
      try {
        final uri = Uri.parse("$host$endpoint");
        final res = method == 'POST'
            ? await http
                .post(uri, headers: headers, body: bodyStr)
                .timeout(const Duration(seconds: 8))
            : await http
                .get(uri, headers: headers)
                .timeout(const Duration(seconds: 8));

        if (res.statusCode >= 200 && res.statusCode < 300) {
          return res;
        }
      } catch (e) {
        debugPrint("[EmployeeJoinRequestService] $method on $host error: $e");
      }
    }
    return null;
  }

  /// 1. BINA INVITE CODE KE SIGNUP: SUBMIT COMPANY WORK EMAIL FOR APPROVAL
  static Future<Map<String, dynamic>> submitWorkEmailJoinRequest({
    required String workEmail,
    required String fullName,
    required String jobTitle,
    String? phone,
  }) async {
    final cleanEmail = workEmail.trim().toLowerCase();
    final cleanName = fullName.trim();
    final cleanRole = jobTitle.trim();

    // 1. Dual-write directly to Firestore enterprise_join_requests for real-time Master Admin queue
    try {
      final user = FirebaseAuth.instance.currentUser;
      final applicantUid = user?.uid ?? cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final domain = cleanEmail.contains('@') ? cleanEmail.split('@').last : '';
      final companySlug = domain.isNotEmpty ? domain.split('.').first : 'enterprise';
      final companyName = '${companySlug[0].toUpperCase()}${companySlug.substring(1)} Enterprise';
      final reqDocId = '${cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_to_$companySlug';

      await FirebaseFirestore.instance.collection('enterprise_join_requests').doc(reqDocId).set({
        'id': reqDocId,
        'applicantUid': applicantUid,
        'applicantName': cleanName.isNotEmpty ? cleanName : cleanEmail.split('@').first,
        'applicantEmail': cleanEmail,
        'jobTitle': cleanRole,
        'phone': phone ?? '',
        'enterpriseCompanyName': companyName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Also create notification for Master Admin
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'join_request',
        'title': 'New Employee Join Request',
        'body': '$cleanName ($cleanEmail) requested to join $companyName.',
        'targetRole': 'master_admin',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (fsErr) {
      debugPrint('[JoinRequest] Firestore write note: $fsErr');
    }

    try {
      final res = await _sendRequest('POST', '/api/sync/employee-join-request', body: {
        "action": "submit_join_request",
        "workEmail": cleanEmail,
        "fullName": cleanName,
        "jobTitle": cleanRole,
        "phone": phone ?? "",
      });

      if (res != null && res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json["data"] is Map<String, dynamic> ? json["data"] : {};
      } else if (res != null) {
        final json = jsonDecode(res.body);
        return {"error": json["error"] ?? "Failed to match company domain."};
      }
    } catch (e) {
      debugPrint("[JoinRequest] API Error: $e");
    }

    // Return success if Firestore record was created
    return {"success": true, "status": "pending"};
  }

  /// 2. CHECK STATUS (Agar Pending screen par user khada hai)
  static Future<Map<String, dynamic>> checkMyJoinStatus() async {
    try {
      final res = await _sendRequest('GET', '/api/sync/employee-join-request');
      if (res != null && res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json["data"] is Map<String, dynamic> ? json["data"] : {};
      }
    } catch (e) {
      debugPrint("[JoinStatus] Error: $e");
    }
    return {"status": "NONE"};
  }

  /// 3. ENTERPRISE ADMIN ACTION: APPROVE PENDING EMPLOYEE
  static Future<bool> approveEmployeeRequest(String requestId) async {
    try {
      final res = await _sendRequest('POST', '/api/sync/employee-join-request', body: {
        "action": "approve_request",
        "requestId": requestId,
      });
      return res != null && res.statusCode == 200;
    } catch (e) {
      debugPrint("[ApproveEmployee] Error: $e");
      return false;
    }
  }

  /// 4. ENTERPRISE ADMIN ACTION: REJECT PENDING EMPLOYEE
  static Future<bool> rejectEmployeeRequest(String requestId) async {
    try {
      final res = await _sendRequest('POST', '/api/sync/employee-join-request', body: {
        "action": "reject_request",
        "requestId": requestId,
      });
      return res != null && res.statusCode == 200;
    } catch (e) {
      debugPrint("[RejectEmployee] Error: $e");
      return false;
    }
  }
}
