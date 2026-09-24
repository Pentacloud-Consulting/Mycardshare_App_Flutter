import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      socialLinks: socialLinks,
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
            'socialLinks': socialLinks.map((l) => l.toJson()).toList(),
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
  }

  /// Load profile from Firestore or local defaults
  Future<void> loadProfile(String uid, String email, String fullName) async {
    try {
      if (uid.isNotEmpty) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['onboardingCompleted'] == true) {
            final rawLinks = (data['socialLinks'] as List<dynamic>?) ?? [];
            _activeProfile = IndividualProfileData(
              uid: uid,
              fullName: data['fullName'] ?? fullName,
              email: data['email'] ?? email,
              cardSlug: data['cardSlug'] ?? generateCardSlug(fullName),
              profilePhoto: data['profilePhoto'],
              bannerPhoto: data['bannerPhoto'],
              jobTitle: data['jobTitle'] ?? '',
              phoneNumber: data['phoneNumber'] ?? '',
              websiteUrl: data['websiteUrl'] ?? '',
              templateStyle: data['templateStyle'] ?? 'Modern Glass',
              socialLinks: rawLinks
                  .map((l) => SocialLinkItem.fromJson(Map<String, dynamic>.from(l)))
                  .toList(),
              companyName: data['companyName'] ?? '',
              shortBio: data['shortBio'] ?? '',
              networkingStatus: data['networkingStatus'] ?? 'Actively Networking',
            );
            notifyListeners();
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('[IndividualProfileStore] Load error: $e');
    }
  }
}
