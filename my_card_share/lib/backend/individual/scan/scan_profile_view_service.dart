import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ScannedCardData {
  final String slug;
  final String profileType; // "individual" | "employee" | "enterprise"
  final String targetScreen;
  final Map<String, dynamic> profile;
  final Map<String, dynamic> actionUrls;

  ScannedCardData({
    required this.slug,
    required this.profileType,
    required this.targetScreen,
    required this.profile,
    required this.actionUrls,
  });

  factory ScannedCardData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return ScannedCardData(
      slug: data['slug'] ?? '',
      profileType: data['profileType'] ?? 'individual',
      targetScreen: data['targetScreen'] ?? 'ScannedProfileViewScreen',
      profile: (data['profile'] is Map<String, dynamic>)
          ? data['profile'] as Map<String, dynamic>
          : {},
      actionUrls: (data['actionUrls'] is Map<String, dynamic>)
          ? data['actionUrls'] as Map<String, dynamic>
          : {},
    );
  }
}

class ScanProfileViewService {
  ScanProfileViewService._internal();
  static final ScanProfileViewService instance =
      ScanProfileViewService._internal();

  static const String baseUrl = "https://mycardshare.com";

  Future<ScannedCardData> fetchScannedProfile(String slug) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/sync/slug/scan?slug=$slug"),
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return ScannedCardData.fromJson(json);
      }
      throw Exception("Card not found or unpublished: ${res.statusCode}");
    } catch (e) {
      debugPrint("[ScanProfileViewService] fetchScannedProfile error: $e");
      rethrow;
    }
  }

  /// Action 3: Exchange Contact / Lead Submission
  static Future<bool> submitLeadExchange({
    required String cardId,
    required String fullName,
    required String email,
    required String phone,
    String note = '',
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/leads/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "cardId": cardId,
          "fullName": fullName,
          "email": email,
          "mobile": phone,
          "notes": note,
        }),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint("[ScanProfileViewService] submitLeadExchange error: $e");
      return false;
    }
  }
}
