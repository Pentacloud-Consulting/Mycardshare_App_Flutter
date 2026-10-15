import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class SlugCheckResult {
  final String slug;
  final bool isAvailable;
  final bool isReserved;
  final String suggestedSlug;
  final String? resolvedUrl;
  final String? reason;

  SlugCheckResult({
    required this.slug,
    required this.isAvailable,
    required this.isReserved,
    required this.suggestedSlug,
    this.resolvedUrl,
    this.reason,
  });

  factory SlugCheckResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return SlugCheckResult(
      slug: data['slug'] ?? '',
      isAvailable: data['isAvailable'] ?? false,
      isReserved: data['isReserved'] ?? false,
      suggestedSlug: data['suggestedSlug'] ?? '',
      resolvedUrl: data['resolvedUrl'],
      reason: data['reason'],
    );
  }
}

class SlugService {
  static const String baseUrl = "https://mycardshare.com";

  /// 1. Real-time Slug Availability Checker (Live debounce in Profile Editor & Forms)
  static Future<SlugCheckResult> verifySlugAvailability(String candidateSlug) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      final uri = Uri.parse("$baseUrl/api/sync/slug?slug=$candidateSlug&uid=$uid");

      final res = await http.get(uri);
      if (res.statusCode == 200) {
        return SlugCheckResult.fromJson(jsonDecode(res.body));
      }
      return SlugCheckResult(
        slug: candidateSlug,
        isAvailable: false,
        isReserved: false,
        suggestedSlug: "",
        reason: "Server error: ${res.statusCode}",
      );
    } catch (e) {
      debugPrint("[SlugService] verifySlugAvailability error: $e");
      return SlugCheckResult(
        slug: candidateSlug,
        isAvailable: false,
        isReserved: false,
        suggestedSlug: "",
        reason: e.toString(),
      );
    }
  }

  /// 2. Claim & Save Custom Slug
  static Future<String> claimSlug({
    required String fullName,
    String? desiredSlug,
    String? companyName,
    String role = "individual",
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated");
    final token = await user.getIdToken();

    final res = await http.post(
      Uri.parse("$baseUrl/api/sync/slug"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "fullName": fullName,
        "desiredSlug": desiredSlug,
        "companyName": companyName,
        "role": role,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['data']?['cardSlug'] ?? data['cardSlug'] ?? (desiredSlug ?? '');
    }
    throw Exception("Failed to claim slug: ${res.body}");
  }
}
