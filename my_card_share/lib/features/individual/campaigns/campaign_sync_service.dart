import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/campaign_model.dart';

class CampaignSyncService {
  static const String baseUrl = 'https://digitalbusinesscloudcard.com/api/sync/campaign-tracker';
  static const String fallbackUrl = 'https://mycardshare.com/api/sync/individual-campaigns';

  static Future<Map<String, String>> _getHeaders([String? token]) async {
    String authToken = token ?? '';
    if (authToken.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      authToken = user != null ? (await user.getIdToken() ?? '') : '';
    }
    return {
      'Content-Type': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };
  }

  /// Live Fetch from Next.js Web
  static Future<List<CampaignModel>> fetchCampaigns([String? token]) async {
    try {
      final headers = await _getHeaders(token);
      final res = await http.get(Uri.parse(baseUrl), headers: headers).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final rawList = (decoded['data']?['campaigns'] ?? decoded['campaigns'] ?? []) as List;
        return rawList.asMap().entries.map((entry) {
          return CampaignModel.fromJson(entry.value is Map<String, dynamic> ? entry.value : {}, entry.key);
        }).toList();
      }
    } catch (e) {
      debugPrint('[CampaignSyncService] Primary endpoint note: $e');
    }

    // Fallback to individual-campaigns endpoint
    try {
      final headers = await _getHeaders(token);
      final res = await http.get(Uri.parse(fallbackUrl), headers: headers).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final rawList = (decoded['data']?['campaigns'] ?? decoded['campaigns'] ?? []) as List;
        return rawList.asMap().entries.map((entry) {
          return CampaignModel.fromJson(entry.value is Map<String, dynamic> ? entry.value : {}, entry.key);
        }).toList();
      }
    } catch (e) {
      debugPrint('[CampaignSyncService] Fallback endpoint note: $e');
    }

    return [];
  }

  /// Create Campaign with guaranteed real title
  static Future<CampaignModel> createCampaign({
    String? token,
    required String campaignName,
    String? targetSlug,
    String? cardSlug,
    String utmSource = 'print_flyer',
    String utmMedium = 'qr_code',
  }) async {
    final headers = await _getHeaders(token);
    final payload = {
      'name': campaignName.trim(),
      'title': campaignName.trim(),
      'label': campaignName.trim(),
      'campaignName': campaignName.trim(),
      'targetCardSlug': targetSlug ?? cardSlug,
      'utmSource': utmSource,
      'utmMedium': utmMedium,
    };

    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = json.decode(res.body);
        final campData = decoded['data']?['campaign'] ?? decoded['campaign'] ?? decoded['data'];
        if (campData is Map<String, dynamic>) {
          return CampaignModel.fromJson(campData, 0);
        }
      }
    } catch (e) {
      debugPrint('[CampaignSyncService] Create primary error: $e');
    }

    // Fallback endpoint
    try {
      final res = await http.post(
        Uri.parse(fallbackUrl),
        headers: headers,
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = json.decode(res.body);
        final campData = decoded['data']?['campaign'] ?? decoded['campaign'];
        if (campData is Map<String, dynamic>) {
          return CampaignModel.fromJson(campData, 0);
        }
      }
    } catch (e) {
      debugPrint('[CampaignSyncService] Create fallback error: $e');
    }

    // Safe fallback model
    return CampaignModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: campaignName.trim(),
      scans: 0,
      leadsWon: 0,
      qrCodeUrl: '',
      status: 'active',
      targetUrl: '',
    );
  }
}
