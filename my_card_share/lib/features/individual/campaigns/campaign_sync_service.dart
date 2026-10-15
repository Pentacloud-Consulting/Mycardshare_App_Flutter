import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class CampaignSyncService {
  static const String baseUrl = "https://mycardshare.com";

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. FETCH ALL USER CAMPAIGNS & LIVE METRICS
  static Future<Map<String, dynamic>> fetchCampaigns() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse("$baseUrl/api/sync/individual-campaigns"), headers: headers);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json["data"] is Map<String, dynamic> ? json["data"] : {};
      }
    } catch (e) {
      debugPrint("[CampaignSyncService] Fetch campaigns error: $e");
    }
    return {"summary": {}, "campaigns": []};
  }

  /// 2. CREATE NEW TRACKABLE QR CAMPAIGN
  static Future<Map<String, dynamic>?> createCampaign({
    required String name,
    String? cardSlug,
    String utmSource = "print_flyer",
    String utmMedium = "qr_code",
  }) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/individual-campaigns"),
        headers: headers,
        body: jsonEncode({
          "name": name,
          "targetCardSlug": cardSlug,
          "utmSource": utmSource,
          "utmMedium": utmMedium,
        }),
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json["data"]?["campaign"] is Map<String, dynamic> ? json["data"]["campaign"] : null;
      }
    } catch (e) {
      debugPrint("[CampaignSyncService] Create campaign error: $e");
    }
    return null;
  }
}
