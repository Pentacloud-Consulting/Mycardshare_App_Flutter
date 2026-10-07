import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api_service.dart';
import '../profile/individual_profile_store.dart';
import '../previews/users_view.dart';

class PublicProfileData {
  final String uid;
  final String fullName;
  final String jobTitle;
  final String company;
  final String email;
  final String phone;
  final String website;
  final String address;
  final String bio;
  final String avatarUrl;
  final String bannerUrl;
  final String cardSlug;
  final String userStatus;
  final String themeColor;
  final List<SocialLinkItem> socialLinks;

  PublicProfileData({
    required this.uid,
    required this.fullName,
    required this.jobTitle,
    required this.company,
    required this.email,
    required this.phone,
    this.website = '',
    this.address = '',
    this.bio = '',
    this.avatarUrl = '',
    this.bannerUrl = '',
    required this.cardSlug,
    this.userStatus = 'Actively Networking',
    this.themeColor = '#0052FF',
    this.socialLinks = const [],
  });

  factory PublicProfileData.fromMap(Map<String, dynamic> map, String docId) {
    final rawLinks = (map['socialLinks'] as List<dynamic>?) ?? [];
    return PublicProfileData(
      uid: docId,
      fullName: map['fullName'] ?? map['name'] ?? 'User Profile',
      jobTitle: map['jobTitle'] ?? map['role'] ?? '',
      company: map['companyName'] ?? map['company'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? map['phoneNumber'] ?? '',
      website: map['website'] ?? map['websiteUrl'] ?? '',
      address: map['address'] ?? '',
      bio: map['bio'] ?? map['shortBio'] ?? map['quote'] ?? '',
      avatarUrl: map['avatarUrl'] ?? map['profilePhoto'] ?? map['photoUrl'] ?? '',
      bannerUrl: map['bannerUrl'] ?? map['bannerPhoto'] ?? map['coverImage'] ?? '',
      cardSlug: map['cardSlug'] ?? docId,
      userStatus: map['userStatus'] ?? map['networkingStatus'] ?? 'Actively Networking',
      themeColor: map['themeColor'] ?? '#0052FF',
      socialLinks: rawLinks
          .map((l) => SocialLinkItem.fromJson(Map<String, dynamic>.from(l)))
          .toList(),
    );
  }

  factory PublicProfileData.fromProfileModel(IndividualProfileData profile) {
    return PublicProfileData(
      uid: profile.uid,
      fullName: profile.fullName,
      jobTitle: profile.jobTitle,
      company: profile.companyName,
      email: profile.email,
      phone: profile.phoneNumber,
      website: profile.websiteUrl,
      address: '',
      bio: profile.shortBio,
      avatarUrl: profile.profilePhoto ?? '',
      bannerUrl: profile.bannerPhoto ?? '',
      cardSlug: profile.cardSlug,
      userStatus: profile.networkingStatus,
      socialLinks: profile.socialLinks,
    );
  }
}

/// Service to resolve public card profiles by slug or UID across mobile scans.
class ScanProfileViewService extends ChangeNotifier {
  ScanProfileViewService._internal();
  static final ScanProfileViewService instance = ScanProfileViewService._internal();

  /// Fetches profile by card slug or URL from backend API / Firestore
  Future<PublicProfileData> fetchProfileBySlug(String rawSlug) async {
    final cleanSlug = rawSlug.contains('/card/') 
        ? rawSlug.split('/card/').last.trim() 
        : rawSlug.trim();

    debugPrint('[ScanProfileViewService] Fetching real profile for card slug: $cleanSlug');

    // 1. Check local active profile first if it matches
    final active = IndividualProfileStore.instance.activeProfile;
    if (active != null && (active.cardSlug == cleanSlug || active.uid == cleanSlug)) {
      UsersViewService.instance.recordProfileView(targetUid: active.uid, source: 'qr_scan');
      return PublicProfileData.fromProfileModel(active);
    }

    // 2. Query Next.js Backend API GET /api/cards/public/[slug]
    try {
      final apiRes = await IndividualApiService.getPublic('/api/cards/public/$cleanSlug');
      if (apiRes['success'] == true && apiRes['data'] != null) {
        final card = apiRes['data']['card'] ?? apiRes['data'];
        if (card != null && card is Map<String, dynamic>) {
          final profile = PublicProfileData.fromMap(card, card['userId'] ?? card['_id'] ?? cleanSlug);
          await UsersViewService.instance.recordProfileView(targetUid: profile.uid, source: 'qr_scan');
          debugPrint('[ScanProfileViewService] Fetched real card from backend API for: ${profile.fullName}');
          return profile;
        }
      }
    } catch (apiErr) {
      debugPrint('[ScanProfileViewService] Backend API lookup notice: $apiErr');
    }

    // 3. Query Firestore users collection by cardSlug or document UID
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('cardSlug', isEqualTo: cleanSlug)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final profile = PublicProfileData.fromMap(doc.data(), doc.id);
        await UsersViewService.instance.recordProfileView(targetUid: profile.uid, source: 'qr_scan');
        debugPrint('[ScanProfileViewService] Fetched real card from Firestore users by slug: ${profile.fullName}');
        return profile;
      }

      // Query by UID directly
      final docById = await FirebaseFirestore.instance.collection('users').doc(cleanSlug).get();
      if (docById.exists && docById.data() != null) {
        final profile = PublicProfileData.fromMap(docById.data()!, docById.id);
        await UsersViewService.instance.recordProfileView(targetUid: profile.uid, source: 'qr_scan');
        debugPrint('[ScanProfileViewService] Fetched real card from Firestore users by UID: ${profile.fullName}');
        return profile;
      }
    } catch (e) {
      debugPrint('[ScanProfileViewService] Firestore lookup notice: $e');
    }

    // 4. Return fallback profile if no card exists yet for this slug
    final fallbackUid = 'user_${cleanSlug.hashCode}';
    await UsersViewService.instance.recordProfileView(targetUid: fallbackUid, source: 'qr_scan');

    return PublicProfileData(
      uid: fallbackUid,
      fullName: cleanSlug.startsWith('user') ? cleanSlug : cleanSlug,
      jobTitle: "Card Member",
      company: "MyCardShare Member",
      email: "",
      phone: "",
      bio: "Networking on MyCardShare",
      cardSlug: cleanSlug,
    );
  }
}


