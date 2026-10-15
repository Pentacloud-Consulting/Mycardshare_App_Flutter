import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ConnectorsSyncService {
  static const String baseUrl = "https://mycardshare.com";

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. FETCH ACTIVE INTEGRATIONS (Zapier, HubSpot, Webhooks)
  static Future<Map<String, dynamic>> fetchConnectors() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse("$baseUrl/api/sync/individual-connectors"), headers: headers);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json["data"] is Map<String, dynamic> ? json["data"] : {};
      }
    } catch (e) {
      debugPrint("[ConnectorsSyncService] Fetch connectors error: $e");
    }
    return {};
  }

  /// 2. SAVE WEBHOOK OR CRM CONFIG
  static Future<bool> saveConnectorConfig({
    required String connectorId, // "zapier" | "hubspot" | "custom_webhook"
    required Map<String, dynamic> config,
    bool? autoSyncNewLeads,
  }) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/individual-connectors"),
        headers: headers,
        body: jsonEncode({
          "connectorId": connectorId,
          "config": config,
          ...?((autoSyncNewLeads != null) ? {"autoSyncNewLeads": autoSyncNewLeads} : null),
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("[ConnectorsSyncService] Save connector error: $e");
      return false;
    }
  }
}
