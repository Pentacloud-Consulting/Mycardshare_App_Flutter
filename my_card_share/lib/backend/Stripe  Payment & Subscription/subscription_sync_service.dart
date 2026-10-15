import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

/// Subscription & Stripe Payment Sync Service.
/// Interacts with Next.js sync endpoint (/api/sync/subscription) for plan fetching,
/// Stripe Checkout session generation, In-App purchase receipt verification,
/// and subscription cancellation.
class SubscriptionSyncService {
  SubscriptionSyncService._internal();
  static final SubscriptionSyncService instance = SubscriptionSyncService._internal();

  static const String baseUrl = "https://mycardshare.com";

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. GET CURRENT USER SUBSCRIPTION STATUS
  static Future<Map<String, dynamic>> fetchSubscriptionStatus() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(
        Uri.parse("$baseUrl/api/sync/subscription"),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final data = json["data"] ?? json;
        if (data is Map<String, dynamic>) {
          debugPrint("[SubscriptionSyncService] Current Plan: ${data['plan']} (isPro: ${data['isPro']})");
          return data;
        }
      } else {
        debugPrint("[SubscriptionSyncService] Fetch Subscription Status returned ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      debugPrint("[SubscriptionSyncService] Fetch Subscription Error: $e");
    }
    return {"plan": "free", "isPro": false};
  }

  /// 2. LAUNCH STRIPE CHECKOUT IN APP / BROWSER
  static Future<bool> startStripeUpgrade({
    String plan = "pro", // "pro" | "enterprise"
    String cycle = "monthly", // "monthly" | "yearly"
  }) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/subscription"),
        headers: headers,
        body: jsonEncode({
          "action": "create_checkout",
          "plan": plan,
          "billingCycle": cycle,
        }),
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final String? checkoutUrl = json["data"]?["checkoutUrl"] ?? json["checkoutUrl"];
        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          debugPrint("[SubscriptionSyncService] Launching Stripe Checkout: $checkoutUrl");
          return await launchUrl(
            Uri.parse(checkoutUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        debugPrint("[SubscriptionSyncService] Stripe Checkout Error ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      debugPrint("[SubscriptionSyncService] Stripe Checkout Exception: $e");
    }
    return false;
  }

  /// 3. VERIFY NATIVE IN-APP PURCHASE (Google Play / Apple StoreKit)
  static Future<bool> verifyInAppPurchase({
    required String store, // "google_play" or "app_store"
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/subscription"),
        headers: headers,
        body: jsonEncode({
          "action": "verify_in_app_purchase",
          "store": store,
          "productId": productId,
          "purchaseToken": purchaseToken,
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final isVerified = json["data"]?["verified"] == true || json["verified"] == true;
        debugPrint("[SubscriptionSyncService] In-App Purchase Verification Result: $isVerified");
        return isVerified;
      }
    } catch (e) {
      debugPrint("[SubscriptionSyncService] In-app verify error: $e");
    }
    return false;
  }

  /// 4. CANCEL AUTO-RENEWAL SUBSCRIPTION
  static Future<bool> cancelSubscription() async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/subscription"),
        headers: headers,
        body: jsonEncode({
          "action": "cancel_subscription",
        }),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json["data"]?["cancelled"] == true || json["success"] == true;
      }
    } catch (e) {
      debugPrint("[SubscriptionSyncService] Cancel subscription error: $e");
    }
    return false;
  }
}
