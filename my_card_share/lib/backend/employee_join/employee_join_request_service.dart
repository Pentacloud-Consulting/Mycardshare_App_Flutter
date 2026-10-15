import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeJoinRequestService {
  static const String baseUrl = "https://mycardshare.com";

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. BINA INVITE CODE KE SIGNUP: SUBMIT COMPANY WORK EMAIL FOR APPROVAL
  static Future<Map<String, dynamic>> submitWorkEmailJoinRequest({
    required String workEmail,
    required String fullName,
    required String jobTitle,
    String? phone,
  }) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/employee-join-request"),
        headers: headers,
        body: jsonEncode({
          "action": "submit_join_request",
          "workEmail": workEmail.trim().toLowerCase(),
          "fullName": fullName.trim(),
          "jobTitle": jobTitle.trim(),
          "phone": phone ?? "",
        }),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return json["data"] is Map<String, dynamic> ? json["data"] : {};
      } else {
        return {"error": json["error"] ?? "Failed to match company domain."};
      }
    } catch (e) {
      debugPrint("[JoinRequest] Error: $e");
      return {"error": e.toString()};
    }
  }

  /// 2. CHECK STATUS (Agar Pending screen par user khada hai)
  static Future<Map<String, dynamic>> checkMyJoinStatus() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(
        Uri.parse("$baseUrl/api/sync/employee-join-request"),
        headers: headers,
      );
      if (res.statusCode == 200) {
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
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/employee-join-request"),
        headers: headers,
        body: jsonEncode({
          "action": "approve_request",
          "requestId": requestId,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("[ApproveEmployee] Error: $e");
      return false;
    }
  }

  /// 4. ENTERPRISE ADMIN ACTION: REJECT PENDING EMPLOYEE
  static Future<bool> rejectEmployeeRequest(String requestId) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/employee-join-request"),
        headers: headers,
        body: jsonEncode({
          "action": "reject_request",
          "requestId": requestId,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("[RejectEmployee] Error: $e");
      return false;
    }
  }
}
