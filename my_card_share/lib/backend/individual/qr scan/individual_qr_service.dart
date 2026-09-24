import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../profile/individual_profile_store.dart';

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

  /// 2. Fetch Public Card Profile Data by Card Slug & Increment Views
  Future<IndividualProfileData?> fetchCardBySlug(String cardSlug) async {
    final cleanSlug = cardSlug.trim().toLowerCase();
    if (cleanSlug.isEmpty) return null;

    try {
      // Query Firestore users collection for matching cardSlug
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('cardSlug', isEqualTo: cleanSlug)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        final uid = doc.id;

        // Increment profile view count in background
        FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'views': FieldValue.increment(1),
            'lastViewedAt': DateTime.now().toIso8601String(),
          },
          SetOptions(merge: true),
        ).catchError((e) {
          debugPrint('[IndividualQRService] Error incrementing views: $e');
        });

        final rawLinks = (data['socialLinks'] as List<dynamic>?) ?? [];
        final socialLinks = rawLinks
            .map((l) => SocialLinkItem.fromJson(Map<String, dynamic>.from(l)))
            .toList();

        final profile = IndividualProfileData(
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

        debugPrint('[IndividualQRService] Fetched profile for slug "$cleanSlug" (UID: $uid)');
        return profile;
      }
    } catch (e) {
      debugPrint('[IndividualQRService] Firestore slug query error: $e');
    }

    // Local Fallback Check
    final active = IndividualProfileStore.instance.activeProfile;
    if (active != null && active.cardSlug.toLowerCase() == cleanSlug) {
      return active;
    }

    return null;
  }
}
