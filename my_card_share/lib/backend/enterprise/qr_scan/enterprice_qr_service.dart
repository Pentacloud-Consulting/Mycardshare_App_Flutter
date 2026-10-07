import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../profile/enterprise_profile_store.dart';
import '../../individual/api_service.dart';

/// Service for generating Enterprise QR Code dynamic share URLs and fetching public enterprise card data by slug
class EnterpriseQRService {
  EnterpriseQRService._internal();
  static final EnterpriseQRService instance = EnterpriseQRService._internal();

  static const String baseUrl = 'https://mycardshare.com/card';

  /// 1. Generate Public Share URL from Card Slug
  static String generateShareUrl(String cardSlug) {
    final cleanSlug = cardSlug.trim().toLowerCase();
    return '$baseUrl/$cleanSlug';
  }

  /// 2. Fetch Public Enterprise Card Profile Data by Card Slug & Increment Views.
  Future<EnterpriseProfileData?> fetchCardBySlug(String cardSlug) async {
    final cleanSlug = cardSlug.trim().toLowerCase();
    if (cleanSlug.isEmpty) return null;

    // ── Try API first (public endpoint — no auth required) ─────────────────
    try {
      final resp = await IndividualApiService.getPublic(
          '/api/cards/public/$cleanSlug');
      final card = (resp['data']?['card'] ?? resp['data']) as Map<String, dynamic>?;
      if (card != null) {
        debugPrint('[EnterpriseQRService] Fetched slug "$cleanSlug" via API');
        return EnterpriseProfileData.fromMap(card, card['userId'] ?? card['uid'] ?? cleanSlug);
      }
    } catch (apiErr) {
      debugPrint('[EnterpriseQRService] API lookup failed, trying Firestore: $apiErr');
    }

    // ── Firestore fallback ──────────────────────────────────────────────────
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('enterprises')
          .where('cardSlug', isEqualTo: cleanSlug)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final uid = doc.id;

        // Increment view count in background
        FirebaseFirestore.instance
            .collection('enterprises')
            .doc(uid)
            .set({
              'views': FieldValue.increment(1),
              'lastViewedAt': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true))
            .catchError((e) {
          debugPrint('[EnterpriseQRService] Error incrementing views: $e');
        });

        debugPrint(
            '[EnterpriseQRService] Fetched enterprise slug "$cleanSlug" via Firestore (UID: $uid)');
        return EnterpriseProfileData.fromMap(data, uid);
      }
    } catch (e) {
      debugPrint('[EnterpriseQRService] Firestore enterprise slug query error: $e');
    }

    // Local active enterprise profile fallback
    final active = EnterpriseProfileStore.instance.currentProfile;
    if (active != null && active.cardSlug.toLowerCase() == cleanSlug) {
      return active;
    }

    return null;
  }
}


