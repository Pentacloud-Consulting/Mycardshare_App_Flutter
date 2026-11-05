import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'master_admin_endpoints.dart';

/// Central HTTP Client for Master Admin API calls with automatic Firebase Auth Token injection
/// and dual-host failover across production domains.
class MasterAdminApiClient {
  MasterAdminApiClient._();

  static const List<String> _hosts = [
    MasterAdminEndpoints.baseUrl,
    'https://digitalbusinesscloudcard.com',
  ];

  static Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (e) {
      debugPrint('[MasterAdminApiClient] Auth token resolution note: $e');
    }

    return headers;
  }

  static Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    for (final host in _hosts) {
      try {
        var uri = Uri.parse('$host$path');
        if (queryParams != null && queryParams.isNotEmpty) {
          uri = uri.replace(queryParameters: queryParams);
        }

        final response = await http
            .get(uri, headers: await _headers())
            .timeout(const Duration(seconds: 8));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonDecode(response.body);
        }
      } catch (e) {
        debugPrint('[MasterAdminApiClient] GET $path on $host note: $e');
      }
    }
    return null;
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    for (final host in _hosts) {
      try {
        final uri = Uri.parse('$host$path');
        final response = await http
            .patch(uri, headers: await _headers(), body: jsonEncode(body))
            .timeout(const Duration(seconds: 8));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonDecode(response.body);
        }
      } catch (e) {
        debugPrint('[MasterAdminApiClient] PATCH $path on $host note: $e');
      }
    }
    return null;
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    for (final host in _hosts) {
      try {
        final uri = Uri.parse('$host$path');
        final response = await http
            .post(uri, headers: await _headers(), body: jsonEncode(body))
            .timeout(const Duration(seconds: 8));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonDecode(response.body);
        }
      } catch (e) {
        debugPrint('[MasterAdminApiClient] POST $path on $host note: $e');
      }
    }
    return null;
  }

  static Future<dynamic> delete(String path) async {
    for (final host in _hosts) {
      try {
        final uri = Uri.parse('$host$path');
        final response = await http
            .delete(uri, headers: await _headers())
            .timeout(const Duration(seconds: 8));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonDecode(response.body);
        }
      } catch (e) {
        debugPrint('[MasterAdminApiClient] DELETE $path on $host note: $e');
      }
    }
    return null;
  }
}
