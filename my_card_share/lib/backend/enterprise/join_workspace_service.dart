// lib/backend/enterprise/join_workspace_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../individual/api_service.dart';

class JoinWorkspaceService {
  static String get endpoint => '${IndividualApiService.baseUrl}/api/sync/enterprise-invite-link';

  /// Verifies employee invite or voucher code with strict enterprise binding
  static Future<Map<String, dynamic>> verifyJoinCode({
    required String code,
    String? enterpriseId,
  }) async {
    final url = Uri.parse(endpoint);
    final payload = <String, dynamic>{
      'action': 'lookup_code',
      'code': code.trim(),
    };
    if (enterpriseId != null && enterpriseId.isNotEmpty) {
      payload['enterpriseId'] = enterpriseId;
    }
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      // Returns exact matched company name & branding (prevents collision!)
      return (data['data'] is Map<String, dynamic>)
          ? data['data'] as Map<String, dynamic>
          : <String, dynamic>{};
    } else {
      throw Exception(data['error']?['message'] ?? data['error'] ?? 'Invalid invite code');
    }
  }
}
