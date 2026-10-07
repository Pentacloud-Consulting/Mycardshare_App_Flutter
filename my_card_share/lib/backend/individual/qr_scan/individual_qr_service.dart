import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../profile/individual_profile_store.dart';
import '../api_service.dart';

/// Service for generating QR Code dynamic share URLs and fetching public card data by slug
class IndividualQRService {
  IndividualQRService._internal();
  static final IndividualQRService instance = IndividualQRService._internal();

  static const String baseUrl = 'https://mycardshare.com/card';

  /// 1. Generate Public Share URL from Card Slug
  static String generateShareUrl(String cardSlug) {
    final cleanSlug = cardSlug.trim().toLowerCase();
    return '$baseUrl/$cleanSlug';
  }

  /// 2. Fetch Public Card Profile Data by Card Slug & Increment Views.
  ///    First tries the Next.js public API (/api/cards/public/[slug]),
  ///    falls back to Firestore direct query if API is unavailable.
  Future<IndividualProfileData?> fetchCardBySlug(String cardSlug) async {
    final cleanSlug = cardSlug.trim().toLowerCase();
    if (cleanSlug.isEmpty) return null;

    // ── Try API first (public endpoint — no auth required) ─────────────────
    try {
      final resp = await IndividualApiService.getPublic(
          '/api/cards/public/$cleanSlug');
      final card = (resp['data']?['card'] ?? resp['data']) as Map<String, dynamic>?;
      if (card != null) {
        debugPrint('[IndividualQRService] Fetched slug "$cleanSlug" via API');
        final rawLinks = (card['socialLinks'] as List<dynamic>?) ?? [];
        final socialLinks = rawLinks
            .map((l) =>
                SocialLinkItem.fromJson(Map<String, dynamic>.from(l as Map)))
            .toList();
        return IndividualProfileData(
          uid: card['userId'] ?? '',
          fullName: card['fullName'] ?? 'User',
          email: card['email'] ?? '',
          cardSlug: card['cardSlug'] ?? cleanSlug,
          profilePhoto: card['avatarUrl'],
          bannerPhoto: card['bannerUrl'],
          jobTitle: card['jobTitle'] ?? '',
          phoneNumber: card['phone'] ?? '',
          websiteUrl: card['website'] ?? '',
          templateStyle: card['templateStyle'] ?? '0',
          socialLinks: socialLinks,
          companyName: card['companyName'] ?? '',
          shortBio: card['bio'] ?? '',
          networkingStatus: card['userStatus'] ?? 'Actively Networking',
        );
      }
    } catch (apiErr) {
      debugPrint('[IndividualQRService] API lookup failed, trying Firestore: $apiErr');
    }

    // ── Firestore fallback ──────────────────────────────────────────────────
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('cardSlug', isEqualTo: cleanSlug)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final uid = doc.id;

        // Increment view count in background
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
              'views': FieldValue.increment(1),
              'lastViewedAt': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true))
            .catchError((e) {
          debugPrint('[IndividualQRService] Error incrementing views: $e');
        });

        final rawLinks = (data['socialLinks'] as List<dynamic>?) ?? [];
        final socialLinks = rawLinks
            .map((l) =>
                SocialLinkItem.fromJson(Map<String, dynamic>.from(l as Map)))
            .toList();

        debugPrint(
            '[IndividualQRService] Fetched slug "$cleanSlug" via Firestore (UID: $uid)');
        return IndividualProfileData(
          uid: uid,
          fullName: data['fullName'] ?? 'User',
          email: data['email'] ?? '',
          cardSlug: data['cardSlug'] ?? cleanSlug,
          profilePhoto: data['profilePhoto'],
          bannerPhoto: data['bannerPhoto'],
          jobTitle: data['jobTitle'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          websiteUrl: data['websiteUrl'] ?? '',
          templateStyle: data['templateStyle'] ?? '0',
          socialLinks: socialLinks,
          companyName: data['companyName'] ?? '',
          shortBio: data['shortBio'] ?? '',
          networkingStatus: data['networkingStatus'] ?? 'Actively Networking',
        );
      }
    } catch (e) {
      debugPrint('[IndividualQRService] Firestore slug query error: $e');
    }

    // Local active profile fallback
    final active = IndividualProfileStore.instance.activeProfile;
    if (active != null && active.cardSlug.toLowerCase() == cleanSlug) {
      return active;
    }

    return null;
  }
}


