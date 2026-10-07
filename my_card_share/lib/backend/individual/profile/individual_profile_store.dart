import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api_service.dart';

class SocialLinkItem {
  String platform;
  String url;

  SocialLinkItem({required this.platform, required this.url});

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'url': url,
      };

  factory SocialLinkItem.fromJson(Map<String, dynamic> json) => SocialLinkItem(
        platform: json['platform'] ?? 'Website',
        url: json['url'] ?? '',
      );
}

class IndividualProfileData {
  final String uid;
  final String fullName;
  final String email;
  final String cardSlug;
  final String? profilePhoto;
  final String? bannerPhoto;
  final String jobTitle;
  final String phoneNumber;
  final String websiteUrl;
  final String templateStyle;
  final List<SocialLinkItem> socialLinks;
  final String companyName;
  final String shortBio;
  final String networkingStatus;
  final DateTime updatedAt;

  IndividualProfileData({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.cardSlug,
    this.profilePhoto,
    this.bannerPhoto,
    required this.jobTitle,
    required this.phoneNumber,
    this.websiteUrl = '',
    required this.templateStyle,
    required this.socialLinks,
    required this.companyName,
    required this.shortBio,
    required this.networkingStatus,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  IndividualProfileData copyWith({
    String? fullName,
    String? email,
    String? cardSlug,
    String? profilePhoto,
    String? bannerPhoto,
    String? jobTitle,
    String? phoneNumber,
    String? websiteUrl,
    String? templateStyle,
    List<SocialLinkItem>? socialLinks,
    String? companyName,
    String? shortBio,
    String? networkingStatus,
    DateTime? updatedAt,
  }) {
    return IndividualProfileData(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      cardSlug: cardSlug ?? this.cardSlug,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      bannerPhoto: bannerPhoto ?? this.bannerPhoto,
      jobTitle: jobTitle ?? this.jobTitle,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      templateStyle: templateStyle ?? this.templateStyle,
      socialLinks: socialLinks ?? this.socialLinks,
      companyName: companyName ?? this.companyName,
      shortBio: shortBio ?? this.shortBio,
      networkingStatus: networkingStatus ?? this.networkingStatus,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'cardSlug': cardSlug,
        'profilePhoto': profilePhoto,
        'bannerPhoto': bannerPhoto,
        'jobTitle': jobTitle,
        'phoneNumber': phoneNumber,
        'websiteUrl': websiteUrl,
        'templateStyle': templateStyle,
        'socialLinks': socialLinks.map((l) => l.toJson()).toList(),
        'companyName': companyName,
        'shortBio': shortBio,
        'networkingStatus': networkingStatus,
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// Reactive store managing active Individual User Profile data
class IndividualProfileStore extends ChangeNotifier {
  IndividualProfileStore._internal();
  static final IndividualProfileStore instance = IndividualProfileStore._internal();

  IndividualProfileData? _activeProfile;

  IndividualProfileData? get activeProfile => _activeProfile;

  bool get hasCompletedOnboarding => _activeProfile != null && _activeProfile!.jobTitle.isNotEmpty;

  /// Helper to generate card slug from Full Name
  static String generateCardSlug(String name) {
    final clean = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-').replaceAll(RegExp(r'-+'), '-').trim();
    final slug = clean.startsWith('-') ? clean.substring(1) : clean;
    final finalSlug = slug.endsWith('-') ? slug.substring(0, slug.length - 1) : slug;
    return finalSlug.isEmpty ? 'user-${DateTime.now().millisecondsSinceEpoch % 10000}' : finalSlug;
  }

  /// Helper to get template index integer (0-4) from templateStyle string
  static int getTemplateIndex(String? style) {
    if (style == null || style.isEmpty) return 0;
    final parsed = int.tryParse(style);
    if (parsed != null && parsed >= 0 && parsed <= 4) return parsed;
    if (style.contains('Purple') || style.contains('Pink') || style == '1') return 1;
    if (style.contains('Teal') || style.contains('Green') || style == '2') return 2;
    if (style.contains('Dark') || style.contains('Slate') || style.contains('Charcoal') || style == '3') return 3;
    if (style.contains('Light') || style.contains('Minimal') || style == '4') return 4;
    return 0;
  }

  /// Update and persist profile data locally and to Firestore
  Future<void> saveProfile({
    required String uid,
    required String fullName,
    required String email,
    String? customSlug,
    String? profilePhoto,
    String? bannerPhoto,
    required String jobTitle,
    required String phoneNumber,
    String websiteUrl = '',
    required String templateStyle,
    required List<SocialLinkItem> socialLinks,
    String companyName = '',
    String shortBio = '',
    required String networkingStatus,
  }) async {
    final slug = (customSlug != null && customSlug.trim().isNotEmpty)
        ? generateCardSlug(customSlug)
        : generateCardSlug(fullName);

    final cleanSocialLinks = socialLinks.where((l) => l.url.trim().isNotEmpty).toList();

    _activeProfile = IndividualProfileData(
      uid: uid,
      fullName: fullName,
      email: email,
      cardSlug: slug,
      profilePhoto: profilePhoto ?? _activeProfile?.profilePhoto,
      bannerPhoto: bannerPhoto ?? _activeProfile?.bannerPhoto,
      jobTitle: jobTitle,
      phoneNumber: phoneNumber,
      websiteUrl: websiteUrl,
      templateStyle: templateStyle,
      socialLinks: cleanSocialLinks,
      companyName: companyName,
      shortBio: shortBio,
      networkingStatus: networkingStatus,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
    debugPrint('[IndividualProfileStore] Saved profile for $fullName ($email, slug: $slug)');

    // Sync to Firestore in background
    try {
      if (uid.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'fullName': fullName,
            'email': email,
            'cardSlug': slug,
            'profilePhoto': profilePhoto ?? _activeProfile?.profilePhoto,
            'bannerPhoto': bannerPhoto ?? _activeProfile?.bannerPhoto,
            'jobTitle': jobTitle,
            'phoneNumber': phoneNumber,
            'websiteUrl': websiteUrl,
            'templateStyle': templateStyle,
            'socialLinks': cleanSocialLinks.map((l) => l.toJson()).toList(),
            'companyName': companyName,
            'shortBio': shortBio,
            'networkingStatus': networkingStatus,
            'onboardingCompleted': true,
            'updatedAt': DateTime.now().toIso8601String(),
          },
          SetOptions(merge: true),
        );
        debugPrint('[IndividualProfileStore] Synced profile to Firestore for UID: $uid');
      }
    } catch (e) {
      debugPrint('[IndividualProfileStore] Firestore sync notice: $e');
    }

    // Dual-write: also patch the MongoDB card via Next.js API (non-blocking)
    // This keeps the web dashboard in sync per Individual_Auth_Integration.md §6
    _syncToApiBackground(
      fullName: fullName,
      email: email,
      slug: slug,
      profilePhoto: profilePhoto ?? _activeProfile?.profilePhoto,
      bannerPhoto: bannerPhoto ?? _activeProfile?.bannerPhoto,
      jobTitle: jobTitle,
      phoneNumber: phoneNumber,
      websiteUrl: websiteUrl,
      templateStyle: templateStyle,
      socialLinks: cleanSocialLinks,
      companyName: companyName,
      shortBio: shortBio,
      networkingStatus: networkingStatus,
    );
  }

  /// Load profile from Next.js API (/api/cards) or Firestore
  Future<void> loadProfile(String uid, String email, String fullName) async {
    try {
      // 1. Try fetching synced profile from Next.js API /api/cards
      try {
        final apiRes = await IndividualApiService.get('/api/cards');
        if (apiRes['success'] == true && apiRes['data'] != null) {
          final card = apiRes['data']['card'] ?? apiRes['data'];
          if (card != null && card is Map<String, dynamic>) {
            final rawLinks = (card['socialLinks'] as List<dynamic>?) ?? [];
            _activeProfile = IndividualProfileData(
              uid: uid,
              fullName: card['fullName'] ?? card['name'] ?? fullName,
              email: card['email'] ?? email,
              cardSlug: card['cardSlug'] ?? generateCardSlug(fullName),
              profilePhoto: card['avatarUrl'] ?? card['profilePhoto'] ?? card['photoUrl'],
              bannerPhoto: card['bannerUrl'] ?? card['bannerPhoto'] ?? card['coverImage'],
              jobTitle: card['jobTitle'] ?? card['role'] ?? '',
              phoneNumber: card['phone'] ?? card['phoneNumber'] ?? '',
              websiteUrl: card['website'] ?? card['websiteUrl'] ?? '',
              templateStyle: card['templateStyle'] ?? card['themeColor'] ?? '0',
              socialLinks: rawLinks
                  .map((l) => SocialLinkItem.fromJson(Map<String, dynamic>.from(l)))
                  .toList(),
              companyName: card['companyName'] ?? card['company'] ?? '',
              shortBio: card['bio'] ?? card['shortBio'] ?? '',
              networkingStatus: card['userStatus'] ?? card['networkingStatus'] ?? 'Actively Networking',
            );
            notifyListeners();
            debugPrint('[IndividualProfileStore] Loaded profile from API /api/cards for: ${_activeProfile!.fullName}');
            return;
          }
        }
      } catch (apiErr) {
        debugPrint('[IndividualProfileStore] API /api/cards load notice: $apiErr');
      }

      // 2. Fallback to Firestore users/{uid} document
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final rawLinks = (data['socialLinks'] as List<dynamic>?) ?? [];
        final photo = data['profilePhoto'] ?? data['avatarUrl'] ?? data['photoUrl'];
        _activeProfile = IndividualProfileData(
          uid: uid,
          fullName: data['fullName'] ?? data['name'] ?? fullName,
          email: data['email'] ?? email,
          cardSlug: data['cardSlug'] ?? generateCardSlug(fullName),
          profilePhoto: photo,
          bannerPhoto: data['bannerPhoto'] ?? data['bannerUrl'] ?? data['coverImage'],
          jobTitle: data['jobTitle'] ?? data['role'] ?? '',
          phoneNumber: data['phoneNumber'] ?? data['phone'] ?? '',
          websiteUrl: data['websiteUrl'] ?? data['website'] ?? '',
          templateStyle: data['templateStyle'] ?? '0',
          socialLinks: rawLinks
              .map((l) => SocialLinkItem.fromJson(Map<String, dynamic>.from(l)))
              .toList(),
          companyName: data['companyName'] ?? data['company'] ?? '',
          shortBio: data['shortBio'] ?? data['bio'] ?? '',
          networkingStatus: data['networkingStatus'] ?? data['userStatus'] ?? 'Actively Networking',
        );
        notifyListeners();
        debugPrint('[IndividualProfileStore] Loaded profile from Firestore users/$uid');
        return;
      }
    } catch (e) {
      debugPrint('[IndividualProfileStore] Load error: $e');
    }
  }

  /// Fire-and-forget: push card data to Next.js API (MongoDB) in background.
  /// Errors are non-fatal — Firestore remains the primary source of truth.
  void _syncToApiBackground({
    required String fullName,
    required String email,
    required String slug,
    String? profilePhoto,
    String? bannerPhoto,
    required String jobTitle,
    required String phoneNumber,
    required String websiteUrl,
    required String templateStyle,
    required List<SocialLinkItem> socialLinks,
    required String companyName,
    required String shortBio,
    required String networkingStatus,
  }) {
    IndividualApiService.patch('/api/cards', {
      'fullName': fullName,
      'email': email,
      'cardSlug': slug,
      'jobTitle': jobTitle,
      'phone': phoneNumber,
      'website': websiteUrl,
      'bio': shortBio,
      'companyName': companyName,
      'templateStyle': templateStyle,
      'userStatus': networkingStatus,
      'avatarUrl': profilePhoto ?? '',
      'bannerUrl': bannerPhoto ?? '',
      'cardStatus': 'Published',
      'socialLinks': socialLinks
          .map((l) => {'platform': l.platform, 'url': l.url})
          .toList(),
    }).then((_) {
      debugPrint('[IndividualProfileStore] API card sync successful');
    }).catchError((e) {
      debugPrint('[IndividualProfileStore] API card sync skipped (offline/no backend): $e');
    });
  }
}


