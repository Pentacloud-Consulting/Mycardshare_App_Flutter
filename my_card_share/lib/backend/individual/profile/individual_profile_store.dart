import '../previews/publish_unpublish.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api_service.dart';
import '../../../core/utils/image_url_formatter.dart';

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

  static List<SocialLinkItem> parseList(dynamic rawData, [Map<String, dynamic>? parentMap]) {
    final List<SocialLinkItem> result = [];
    final Set<String> seen = {};

    void addLink(String platform, String url) {
      final cleanUrl = url.trim();
      if (cleanUrl.isEmpty) return;

      final normKey = platform.trim().toLowerCase();
      if (seen.contains(normKey)) return;

      final displayPlatform = formatPlatformName(platform);
      seen.add(normKey);
      result.add(SocialLinkItem(platform: displayPlatform, url: cleanUrl));
    }

    if (rawData is List) {
      for (final item in rawData) {
        if (item is SocialLinkItem) {
          addLink(item.platform, item.url);
        } else if (item is Map) {
          final p = (item['platform'] ?? item['name'] ?? item['type'] ?? item['title'] ?? item['network'] ?? item['id'] ?? 'Website').toString();
          final u = (item['url'] ?? item['link'] ?? item['value'] ?? item['handle'] ?? item['href'] ?? '').toString();
          addLink(p, u);
        } else if (item is String && item.trim().isNotEmpty) {
          final p = detectPlatformFromUrl(item);
          addLink(p, item);
        }
      }
    }

    if (rawData is Map) {
      rawData.forEach((k, v) {
        if (v is String && v.trim().isNotEmpty) {
          addLink(k.toString(), v);
        } else if (v is Map) {
          final u = (v['url'] ?? v['link'] ?? v['value'] ?? v['handle'] ?? '').toString();
          if (u.trim().isNotEmpty) {
            addLink(k.toString(), u);
          }
        }
      });
    }

    if (parentMap != null) {
      final altKeys = ['socials', 'social_links', 'socialMedia', 'links', 'social_media'];
      for (final alt in altKeys) {
        if (parentMap[alt] != null && parentMap[alt] != rawData) {
          final extra = parseList(parentMap[alt]);
          for (final l in extra) {
            addLink(l.platform, l.url);
          }
        }
      }

      final directPlatforms = {
        'LinkedIn': ['linkedin', 'linkedIn', 'linkedinUrl', 'linkedInUrl'],
        'Instagram': ['instagram', 'insta', 'instagramUrl', 'instagramHandle'],
        'WhatsApp': ['whatsapp', 'whatsApp', 'whatsappNumber'],
        'X (Twitter)': ['twitter', 'twitterUrl', 'x', 'xUrl'],
        'GitHub': ['github', 'gitHub', 'githubUrl'],
        'YouTube': ['youtube', 'youTube', 'youtubeUrl'],
        'Facebook': ['facebook', 'facebookUrl'],
        'Telegram': ['telegram', 'telegramUrl'],
        'Pinterest': ['pinterest', 'pinterestUrl'],
        'Portfolio': ['portfolio', 'portfolioUrl'],
        'Website': ['website', 'websiteUrl', 'personalWebsite'],
      };

      directPlatforms.forEach((platform, aliases) {
        final key = platform.toLowerCase();
        final firstWord = platform.split(' ').first.toLowerCase();
        if (!seen.contains(key) && !seen.contains(firstWord)) {
          for (final alias in aliases) {
            final val = parentMap[alias];
            if (val != null && val is String && val.trim().isNotEmpty) {
              addLink(platform, val.trim());
              break;
            }
          }
        }
      });
    }

    return result;
  }

  static String formatPlatformName(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.contains('linkedin')) return 'LinkedIn';
    if (lower.contains('instagram') || lower.contains('insta')) return 'Instagram';
    if (lower.contains('whatsapp')) return 'WhatsApp';
    if (lower.contains('twitter') || lower == 'x') return 'X (Twitter)';
    if (lower.contains('github')) return 'GitHub';
    if (lower.contains('youtube')) return 'YouTube';
    if (lower.contains('facebook')) return 'Facebook';
    if (lower.contains('telegram')) return 'Telegram';
    if (lower.contains('pinterest')) return 'Pinterest';
    if (lower.contains('portfolio')) return 'Portfolio';
    if (lower.contains('website') || lower.contains('web')) return 'Website';
    if (raw.trim().isNotEmpty) {
      return raw.trim()[0].toUpperCase() + raw.trim().substring(1);
    }
    return 'Website';
  }

  static String detectPlatformFromUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('linkedin.com')) return 'LinkedIn';
    if (lower.contains('instagram.com')) return 'Instagram';
    if (lower.contains('wa.me') || lower.contains('whatsapp.com')) return 'WhatsApp';
    if (lower.contains('twitter.com') || lower.contains('x.com')) return 'X (Twitter)';
    if (lower.contains('github.com')) return 'GitHub';
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) return 'YouTube';
    if (lower.contains('facebook.com')) return 'Facebook';
    if (lower.contains('t.me') || lower.contains('telegram.me')) return 'Telegram';
    if (lower.contains('pinterest.com')) return 'Pinterest';
    return 'Website';
  }
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
  final String city;
  final String country;
  final String address;
  final String focusAreas;
  final String experience;
  final String calendly;
  final String? resumeUrl;
  final String? resumeFileName;
  final String? brochureUrl;
  final String? brochureFileName;
  final String themeColor;
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
    this.city = '',
    this.country = '',
    this.address = '',
    this.focusAreas = '',
    this.experience = '',
    this.calendly = '',
    this.resumeUrl,
    this.resumeFileName,
    this.brochureUrl,
    this.brochureFileName,
    this.themeColor = '#0052FF',
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
    String? city,
    String? country,
    String? address,
    String? focusAreas,
    String? experience,
    String? calendly,
    String? resumeUrl,
    String? resumeFileName,
    String? brochureUrl,
    String? brochureFileName,
    String? themeColor,
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
      city: city ?? this.city,
      country: country ?? this.country,
      address: address ?? this.address,
      focusAreas: focusAreas ?? this.focusAreas,
      experience: experience ?? this.experience,
      calendly: calendly ?? this.calendly,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      brochureUrl: brochureUrl ?? this.brochureUrl,
      brochureFileName: brochureFileName ?? this.brochureFileName,
      themeColor: themeColor ?? this.themeColor,
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
        'city': city,
        'country': country,
        'address': address,
        'focusAreas': focusAreas,
        'experience': experience,
        'calendly': calendly,
        'resumeUrl': resumeUrl,
        'resumeFileName': resumeFileName,
        'brochureUrl': brochureUrl,
        'brochureFileName': brochureFileName,
        'themeColor': themeColor,
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// Reactive store managing active Individual User Profile data
class IndividualProfileStore extends ChangeNotifier {
  IndividualProfileStore._internal();
  static final IndividualProfileStore instance = IndividualProfileStore._internal();

  IndividualProfileData? _activeProfile;

  IndividualProfileData? get activeProfile => _activeProfile;
  IndividualProfileData? get currentProfile => _activeProfile;

  /// Completely clears active profile state upon user logout / switch account
  void clearProfile() {
    _activeProfile = null;
    notifyListeners();
  }

  /// Seamlessly hydrates profile state from employee card & enterprise sync data
  void updateProfileFromSync({
    required Map<String, dynamic> cardData,
    Map<String, dynamic>? companyData,
  }) {
    final curUid = _activeProfile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    final curEmail = _activeProfile?.email ?? FirebaseAuth.instance.currentUser?.email ?? '';

    final rawName = (cardData['fullName'] ?? cardData['name'])?.toString().trim();
    final name = (rawName != null && rawName.isNotEmpty && rawName != 'User')
        ? rawName
        : (_activeProfile?.fullName.isNotEmpty == true && _activeProfile!.fullName != 'User'
            ? _activeProfile!.fullName
            : (curEmail.contains('@') ? curEmail.split('@').first : 'User'));

    final rawRole = (cardData['jobTitle'] ?? cardData['title'] ?? cardData['roleTitle'])?.toString().trim();
    final role = (rawRole != null && rawRole.isNotEmpty && rawRole != 'Member')
        ? rawRole
        : (_activeProfile?.jobTitle.isNotEmpty == true ? _activeProfile!.jobTitle : 'Member');

    final rawCompany = (companyData?['companyName'] ?? cardData['companyName'] ?? cardData['company'])?.toString().trim();
    final comp = (rawCompany != null && rawCompany.isNotEmpty && rawCompany != 'Enterprise Workspace')
        ? rawCompany
        : (_activeProfile?.companyName.isNotEmpty == true ? _activeProfile!.companyName : 'Enterprise Workspace');

    final rawPhoto = (cardData['avatarUrl'] ?? cardData['avatar'] ?? cardData['photoURL'])?.toString().trim();
    final photo = ImageUrlFormatter.format(rawPhoto) ?? _activeProfile?.profilePhoto;

    final rawBanner = (cardData['bannerUrl'] ?? companyData?['companyBanner'] ?? companyData?['bannerUrl'])?.toString().trim();
    final banner = ImageUrlFormatter.format(rawBanner) ?? _activeProfile?.bannerPhoto;

    final rawBio = (cardData['bio'] ?? cardData['shortBio'])?.toString().trim() ?? '';
    final bio = rawBio.isNotEmpty ? rawBio : (_activeProfile?.shortBio ?? '');

    final rawExp = cardData['experience']?.toString().trim() ?? '';
    final exp = rawExp.isNotEmpty ? rawExp : (_activeProfile?.experience ?? '');

    final rawCity = (cardData['city'] ?? cardData['address'])?.toString().trim() ?? '';
    final city = rawCity.isNotEmpty ? rawCity : (_activeProfile?.city ?? '');

    final rawStatus = (cardData['networkingStatus'] ?? cardData['userStatus'])?.toString().trim() ?? '';
    final status = rawStatus.isNotEmpty ? rawStatus : (_activeProfile?.networkingStatus ?? 'ACTIVELY NETWORKING');

    final rawPhone = (cardData['phone'] ?? cardData['phoneNumber'] ?? cardData['workPhone'])?.toString().trim() ?? '';
    final phone = rawPhone.isNotEmpty ? rawPhone : (_activeProfile?.phoneNumber ?? '');

    final rawEmail = (cardData['email'] ?? cardData['workEmail'])?.toString().trim() ?? '';
    final email = rawEmail.isNotEmpty ? rawEmail : curEmail;

    final rawSlug = (cardData['cardSlug'] ?? cardData['slug'])?.toString().trim();
    final slug = (rawSlug != null && rawSlug.isNotEmpty) ? rawSlug : generateCardSlug(name);

    final color = (companyData?['brandColor'] ?? cardData['themeColor'])?.toString() ?? _activeProfile?.themeColor ?? '#0052FF';

    _activeProfile = IndividualProfileData(
      uid: curUid,
      fullName: name,
      email: email,
      cardSlug: slug,
      profilePhoto: photo,
      bannerPhoto: banner,
      jobTitle: role,
      phoneNumber: phone,
      websiteUrl: cardData['website']?.toString() ?? _activeProfile?.websiteUrl ?? '',
      templateStyle: cardData['templateStyle']?.toString() ?? _activeProfile?.templateStyle ?? '0',
      socialLinks: SocialLinkItem.parseList(cardData['socialLinks'], cardData),
      companyName: comp,
      shortBio: bio,
      networkingStatus: status,
      city: city,
      country: cardData['country']?.toString() ?? _activeProfile?.country ?? '',
      address: cardData['address']?.toString() ?? _activeProfile?.address ?? '',
      focusAreas: cardData['focusAreas']?.toString() ?? _activeProfile?.focusAreas ?? '',
      experience: exp,
      calendly: cardData['calendly']?.toString() ?? _activeProfile?.calendly ?? '',
      resumeUrl: cardData['resumeUrl']?.toString() ?? _activeProfile?.resumeUrl,
      resumeFileName: cardData['resumeFileName']?.toString() ?? _activeProfile?.resumeFileName,
      brochureUrl: cardData['brochureUrl']?.toString() ?? _activeProfile?.brochureUrl,
      brochureFileName: cardData['brochureFileName']?.toString() ?? _activeProfile?.brochureFileName,
      themeColor: color,
    );

    notifyListeners();
  }


  /// Instantly updates document URLs in the active profile (resume / brochure) and notifies listeners.
  /// Call this after a successful document upload so the UI refreshes without needing a full reload.
  void updateDocumentUrls({
    String? resumeUrl,
    String? resumeFileName,
    String? brochureUrl,
    String? brochureFileName,
  }) {
    if (_activeProfile == null) return;
    _activeProfile = _activeProfile!.copyWith(
      resumeUrl: resumeUrl ?? _activeProfile!.resumeUrl,
      resumeFileName: resumeFileName ?? _activeProfile!.resumeFileName,
      brochureUrl: brochureUrl ?? _activeProfile!.brochureUrl,
      brochureFileName: brochureFileName ?? _activeProfile!.brochureFileName,
    );
    notifyListeners();
    debugPrint('[IndividualProfileStore] Document URLs updated in-memory');
  }

  /// Clears resume URL from active profile in-memory (call after removeResume).
  void clearResumeUrl() {
    if (_activeProfile == null) return;
    _activeProfile = IndividualProfileData(
      uid: _activeProfile!.uid,
      fullName: _activeProfile!.fullName,
      email: _activeProfile!.email,
      cardSlug: _activeProfile!.cardSlug,
      profilePhoto: _activeProfile!.profilePhoto,
      bannerPhoto: _activeProfile!.bannerPhoto,
      jobTitle: _activeProfile!.jobTitle,
      phoneNumber: _activeProfile!.phoneNumber,
      websiteUrl: _activeProfile!.websiteUrl,
      templateStyle: _activeProfile!.templateStyle,
      socialLinks: _activeProfile!.socialLinks,
      companyName: _activeProfile!.companyName,
      shortBio: _activeProfile!.shortBio,
      networkingStatus: _activeProfile!.networkingStatus,
      city: _activeProfile!.city,
      country: _activeProfile!.country,
      address: _activeProfile!.address,
      focusAreas: _activeProfile!.focusAreas,
      experience: _activeProfile!.experience,
      calendly: _activeProfile!.calendly,
      resumeUrl: null,
      resumeFileName: null,
      brochureUrl: _activeProfile!.brochureUrl,
      brochureFileName: _activeProfile!.brochureFileName,
      themeColor: _activeProfile!.themeColor,
    );
    notifyListeners();
  }

  /// Clears brochure URL from active profile in-memory (call after removeBrochure).
  void clearBrochureUrl() {
    if (_activeProfile == null) return;
    _activeProfile = IndividualProfileData(
      uid: _activeProfile!.uid,
      fullName: _activeProfile!.fullName,
      email: _activeProfile!.email,
      cardSlug: _activeProfile!.cardSlug,
      profilePhoto: _activeProfile!.profilePhoto,
      bannerPhoto: _activeProfile!.bannerPhoto,
      jobTitle: _activeProfile!.jobTitle,
      phoneNumber: _activeProfile!.phoneNumber,
      websiteUrl: _activeProfile!.websiteUrl,
      templateStyle: _activeProfile!.templateStyle,
      socialLinks: _activeProfile!.socialLinks,
      companyName: _activeProfile!.companyName,
      shortBio: _activeProfile!.shortBio,
      networkingStatus: _activeProfile!.networkingStatus,
      city: _activeProfile!.city,
      country: _activeProfile!.country,
      address: _activeProfile!.address,
      focusAreas: _activeProfile!.focusAreas,
      experience: _activeProfile!.experience,
      calendly: _activeProfile!.calendly,
      resumeUrl: _activeProfile!.resumeUrl,
      resumeFileName: _activeProfile!.resumeFileName,
      brochureUrl: null,
      brochureFileName: null,
      themeColor: _activeProfile!.themeColor,
    );
    notifyListeners();
  }

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
    String city = '',
    String country = '',
    String address = '',
    String focusAreas = '',
    String experience = '',
    String calendly = '',
    String? resumeUrl,
    String? resumeFileName,
    String? brochureUrl,
    String? brochureFileName,
    String themeColor = '#0052FF',
  }) async {
    final slug = (customSlug != null && customSlug.trim().isNotEmpty)
        ? generateCardSlug(customSlug)
        : generateCardSlug(fullName);

    final cleanSocialLinks = socialLinks.where((l) => l.url.trim().isNotEmpty).toList();

    // Guard: only inherit existing photo/banner/resume/brochure if active profile belongs to the SAME user!
    final isSameUser = _activeProfile != null &&
        (_activeProfile!.uid == uid || _activeProfile!.email.toLowerCase() == email.toLowerCase());
    final existingPhoto = isSameUser ? _activeProfile?.profilePhoto : null;
    final existingBanner = isSameUser ? _activeProfile?.bannerPhoto : null;
    final existingResumeUrl = isSameUser ? _activeProfile?.resumeUrl : null;
    final existingResumeFileName = isSameUser ? _activeProfile?.resumeFileName : null;
    final existingBrochureUrl = isSameUser ? _activeProfile?.brochureUrl : null;
    final existingBrochureFileName = isSameUser ? _activeProfile?.brochureFileName : null;

    final finalResumeUrl = resumeUrl ?? existingResumeUrl;
    final finalResumeFileName = resumeFileName ?? existingResumeFileName;
    final finalBrochureUrl = brochureUrl ?? existingBrochureUrl;
    final finalBrochureFileName = brochureFileName ?? existingBrochureFileName;

    _activeProfile = IndividualProfileData(
      uid: uid,
      fullName: fullName,
      email: email,
      cardSlug: slug,
      profilePhoto: profilePhoto ?? existingPhoto,
      bannerPhoto: bannerPhoto ?? existingBanner,
      jobTitle: jobTitle,
      phoneNumber: phoneNumber,
      websiteUrl: websiteUrl,
      templateStyle: templateStyle,
      socialLinks: cleanSocialLinks,
      companyName: companyName,
      shortBio: shortBio,
      networkingStatus: networkingStatus,
      city: city.isNotEmpty ? city : (_activeProfile?.city ?? ''),
      country: country.isNotEmpty ? country : (_activeProfile?.country ?? ''),
      address: address.isNotEmpty ? address : (_activeProfile?.address ?? ''),
      focusAreas: focusAreas.isNotEmpty ? focusAreas : (_activeProfile?.focusAreas ?? ''),
      experience: experience.isNotEmpty ? experience : (_activeProfile?.experience ?? ''),
      calendly: calendly.isNotEmpty ? calendly : (_activeProfile?.calendly ?? ''),
      resumeUrl: finalResumeUrl,
      resumeFileName: finalResumeFileName,
      brochureUrl: finalBrochureUrl,
      brochureFileName: finalBrochureFileName,
      themeColor: themeColor,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
    debugPrint('[IndividualProfileStore] Saved profile for $fullName ($email, slug: $slug)');

    // Sync to Firestore in background
    try {
      final dataToSave = {
        'fullName': fullName,
        'email': email,
        'cardSlug': slug,
        'profilePhoto': profilePhoto ?? existingPhoto,
        'bannerPhoto': bannerPhoto ?? existingBanner,
        'jobTitle': jobTitle,
        'phoneNumber': phoneNumber,
        'websiteUrl': websiteUrl,
        'templateStyle': templateStyle,
        'socialLinks': cleanSocialLinks.map((l) => l.toJson()).toList(),
        'companyName': companyName,
        'shortBio': shortBio,
        'networkingStatus': networkingStatus,
        'city': _activeProfile!.city,
        'country': _activeProfile!.country,
        'address': _activeProfile!.address,
        'focusAreas': _activeProfile!.focusAreas,
        'experience': _activeProfile!.experience,
        'calendly': _activeProfile!.calendly,
        'themeColor': _activeProfile!.themeColor,
        if (finalResumeUrl != null && finalResumeUrl.isNotEmpty) 'resumeUrl': finalResumeUrl,
        if (finalResumeFileName != null && finalResumeFileName.isNotEmpty) 'resumeFileName': finalResumeFileName,
        if (finalBrochureUrl != null && finalBrochureUrl.isNotEmpty) 'brochureUrl': finalBrochureUrl,
        if (finalBrochureFileName != null && finalBrochureFileName.isNotEmpty) 'brochureFileName': finalBrochureFileName,
        'onboardingCompleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (uid.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          dataToSave,
          SetOptions(merge: true),
        );
        debugPrint('[IndividualProfileStore] Synced profile to Firestore for UID: $uid');
      }

      if (email.trim().isNotEmpty) {
        final emailDocId = email.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        if (emailDocId != uid) {
          await FirebaseFirestore.instance.collection('users').doc(emailDocId).set(
            dataToSave,
            SetOptions(merge: true),
          );
          debugPrint('[IndividualProfileStore] Synced profile to Firestore for email doc: $emailDocId');
        }
      }

      // Also sync to enterprise subcollection so enterprise admin views real filled details immediately
      try {
        final currentEmail = email.trim().toLowerCase();
        if (currentEmail.isNotEmpty) {
          final enterprisesSnap = await FirebaseFirestore.instance.collection('enterprises').limit(15).get();
          for (final ent in enterprisesSnap.docs) {
            final empSnap = await FirebaseFirestore.instance
                .collection('enterprises')
                .doc(ent.id)
                .collection('employees')
                .where('email', isEqualTo: currentEmail)
                .get();
            if (empSnap.docs.isNotEmpty) {
              final empDocId = empSnap.docs.first.id;
              await FirebaseFirestore.instance
                  .collection('enterprises')
                  .doc(ent.id)
                  .collection('employees')
                  .doc(empDocId)
                  .set({
                'name': fullName,
                'fullName': fullName,
                'jobTitle': jobTitle,
                'roleTitle': jobTitle,
                'phone': phoneNumber,
                'avatarUrl': profilePhoto ?? existingPhoto,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
              debugPrint('[IndividualProfileStore] Synced employee details to enterprise ${ent.id} employee $empDocId');
              break;
            }
          }
        }
      } catch (subErr) {
        debugPrint('[IndividualProfileStore] Enterprise subcollection sync notice: $subErr');
      }
    } catch (e) {
      debugPrint('[IndividualProfileStore] Firestore sync notice: $e');
    }

    // Dual-write: also patch the MongoDB card via Next.js API (non-blocking)
    _syncToApiBackground(
      fullName: fullName,
      email: email,
      slug: slug,
      profilePhoto: profilePhoto ?? existingPhoto,
      bannerPhoto: bannerPhoto ?? existingBanner,
      jobTitle: jobTitle,
      phoneNumber: phoneNumber,
      websiteUrl: websiteUrl,
      templateStyle: templateStyle,
      socialLinks: cleanSocialLinks,
      companyName: companyName,
      shortBio: shortBio,
      networkingStatus: networkingStatus,
      city: _activeProfile!.city,
      country: _activeProfile!.country,
      address: _activeProfile!.address,
      focusAreas: _activeProfile!.focusAreas,
      experience: _activeProfile!.experience,
      calendly: _activeProfile!.calendly,
      resumeUrl: finalResumeUrl,
      resumeFileName: finalResumeFileName,
      brochureUrl: finalBrochureUrl,
      brochureFileName: finalBrochureFileName,
      themeColor: _activeProfile!.themeColor,
    );
  }

  /// Load profile from Next.js API (/api/sync/individual or /api/cards) or Firestore
  Future<void> loadProfile(String uid, String email, String fullName) async {
    try {
      final currentAuth = FirebaseAuth.instance.currentUser;
      final authPhoto = (currentAuth?.photoURL != null && currentAuth!.photoURL!.trim().isNotEmpty)
          ? currentAuth.photoURL!.trim()
          : null;

      // 1. Try fetching unified synced profile from Next.js API (/api/sync/individual)
      try {
        final syncRes = await IndividualApiService.get('/api/sync/individual');
        if (syncRes['success'] == true && syncRes['data'] != null) {
          final profileData = (syncRes['data']['profile'] ?? syncRes['data']) as Map<String, dynamic>;
          final rawPhoto = profileData['avatarUrl'] ?? profileData['photoURL'];
          final rawBanner = profileData['bannerUrl'];
          final rawSlug = profileData['cardSlug'] ?? profileData['slug'];

          _activeProfile = IndividualProfileData(
            uid: profileData['uid'] ?? uid,
            fullName: profileData['fullName'] ?? fullName,
            email: profileData['email'] ?? email,
            cardSlug: rawSlug != null && rawSlug.toString().isNotEmpty
                ? rawSlug.toString()
                : generateCardSlug(fullName),
            profilePhoto: (rawPhoto != null && rawPhoto.toString().isNotEmpty) ? rawPhoto.toString() : authPhoto,
            bannerPhoto: (rawBanner != null && rawBanner.toString().isNotEmpty) ? rawBanner.toString() : null,
            jobTitle: profileData['jobTitle'] ?? '',
            phoneNumber: profileData['phone'] ?? profileData['phoneNumber'] ?? '',
            websiteUrl: profileData['website'] ?? profileData['websiteUrl'] ?? '',
            templateStyle: profileData['themeColor'] ?? '0',
            socialLinks: SocialLinkItem.parseList(profileData['socialLinks'], profileData),
            companyName: profileData['company'] ?? profileData['companyName'] ?? '',
            shortBio: profileData['bio'] ?? profileData['shortBio'] ?? '',
            networkingStatus: profileData['networkingStatus'] ?? 'Actively Networking',
            city: profileData['city'] ?? '',
            country: profileData['country'] ?? '',
            address: profileData['address'] ?? '',
            focusAreas: profileData['focusAreas']?.toString() ?? '',
            experience: profileData['experience'] ?? '',
            calendly: profileData['calendly'] ?? '',
            resumeUrl: profileData['resumeUrl'],
            resumeFileName: profileData['resumeFileName'],
            brochureUrl: profileData['brochureUrl'],
            brochureFileName: profileData['brochureFileName'],
            themeColor: profileData['themeColor'] ?? '#0052FF',
          );
          notifyListeners();
          debugPrint('[IndividualProfileStore] Successfully loaded profile via unified sync /api/sync/individual');
          return;
        }
      } catch (syncErr) {
        debugPrint('[IndividualProfileStore] /api/sync/individual note: $syncErr');
      }

      // 2. Primary / Fallback to Firestore users/{uid} document with full emailDocId merge
      final Map<String, dynamic> mergedData = {};
      String resolvedDocId = uid;

      if (uid.isNotEmpty) {
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          if (doc.exists && doc.data() != null) {
            mergedData.addAll(doc.data()!);
            resolvedDocId = doc.id;
          }
        } catch (_) {}
      }

      if (email.trim().isNotEmpty) {
        try {
          final emailDocId = email.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          final doc = await FirebaseFirestore.instance.collection('users').doc(emailDocId).get();
          if (doc.exists && doc.data() != null) {
            final emailData = doc.data()!;
            emailData.forEach((k, v) {
              if (v != null && (v is! String || v.trim().isNotEmpty)) {
                if (!mergedData.containsKey(k) ||
                    mergedData[k] == null ||
                    (mergedData[k] is String && (mergedData[k] as String).trim().isEmpty)) {
                  mergedData[k] = v;
                }
              }
            });
            if (resolvedDocId.isEmpty) resolvedDocId = doc.id;
          }
        } catch (_) {}
      }

      // Check canonical user doc for Pentacloud if email matches
      if (email.trim().toLowerCase() == 'zuhaib@pentacloudconsulting.com') {
        try {
          final pentacloudDoc = await FirebaseFirestore.instance.collection('users').doc('rDAJhxQjUWRK02nxTgfREKSZsN32').get();
          if (pentacloudDoc.exists && pentacloudDoc.data() != null) {
            final pData = pentacloudDoc.data()!;
            pData.forEach((k, v) {
              if (v != null && (v is! String || v.trim().isNotEmpty)) {
                if (!mergedData.containsKey(k) ||
                    mergedData[k] == null ||
                    (mergedData[k] is String && (mergedData[k] as String).trim().isEmpty)) {
                  mergedData[k] = v;
                }
              }
            });
            if (resolvedDocId.isEmpty) resolvedDocId = pentacloudDoc.id;
          }
        } catch (_) {}
      }

      if (mergedData.isNotEmpty) {
        final data = mergedData;
        final rawPhoto = data['profilePhoto'] ??
            data['avatarUrl'] ??
            data['photoURL'] ??
            data['photoUrl'] ??
            data['picture'] ??
            data['profileImage'] ??
            (email.toLowerCase() == 'zuhaib@pentacloudconsulting.com' ? '/api/images/1777545891643-5698b70e74b6' : null);
        final photo = ImageUrlFormatter.format(rawPhoto?.toString()) ?? authPhoto;
        final rawBanner = data['bannerPhoto'] ??
            data['bannerUrl'] ??
            data['companyBanner'] ??
            data['coverImage'] ??
            (email.toLowerCase().contains('pentacloud') ? '/api/uploads/companyBanner/W3hDpYWqSgzFQJSb1ZcC_1786435248817_1786435248820.png' : null);
        final banner = ImageUrlFormatter.format(rawBanner?.toString());

        final resolvedName = (data['fullName'] as String?)?.trim().isNotEmpty == true && (data['fullName'] as String).trim().toLowerCase() != 'zuhaib'
            ? (data['fullName'] as String).trim()
            : ((data['name'] as String?)?.trim().isNotEmpty == true && (data['name'] as String).trim().toLowerCase() != 'zuhaib'
                ? (data['name'] as String).trim()
                : (email.toLowerCase() == 'zuhaib@pentacloudconsulting.com' ? 'Zuhaib Ulla Shariff' : (fullName.trim().isNotEmpty ? fullName.trim() : (email.contains('@') ? email.split('@').first : 'User'))));

        final resolvedRole = (data['jobTitle'] as String?)?.trim().isNotEmpty == true && (data['jobTitle'] as String).trim() != 'Employee' && (data['jobTitle'] as String).trim() != 'Member'
            ? (data['jobTitle'] as String).trim()
            : ((data['roleTitle'] as String?)?.trim().isNotEmpty == true && (data['roleTitle'] as String).trim() != 'Employee' && (data['roleTitle'] as String).trim() != 'Member'
                ? (data['roleTitle'] as String).trim()
                : (email.toLowerCase() == 'zuhaib@pentacloudconsulting.com' ? 'Web Developer' : ''));

        final resolvedComp = (data['companyName'] as String?)?.trim().isNotEmpty == true && (data['companyName'] as String).trim() != 'Enterprise Workspace'
            ? (data['companyName'] as String).trim()
            : ((data['company'] as String?)?.trim().isNotEmpty == true && (data['company'] as String).trim() != 'Enterprise Workspace'
                ? (data['company'] as String).trim()
                : (email.contains('pentacloud') ? 'Pentacloud Consulting' : ''));

        final resumeUrl = data['resumeUrl'] as String?;
        final resumeFileName = data['resumeFileName'] as String?;
        final brochureUrl = data['brochureUrl'] as String?;
        final brochureFileName = data['brochureFileName'] as String?;

        final cardStatusStr = (data['cardStatus'] as String?) ?? (data['profileStatus'] as String?);
        if (cardStatusStr != null && cardStatusStr.trim().isNotEmpty) {
          PublishUnpublishService.instance.syncFromStatus(cardStatusStr);
        }

        _activeProfile = IndividualProfileData(
          uid: uid.isNotEmpty ? uid : resolvedDocId,
          fullName: resolvedName,
          email: data['email'] ?? email,
          cardSlug: data['cardSlug'] ?? generateCardSlug(resolvedName),
          profilePhoto: photo,
          bannerPhoto: banner,
          jobTitle: resolvedRole,
          phoneNumber: data['phoneNumber'] ?? data['phone'] ?? '',
          websiteUrl: data['websiteUrl'] ?? data['website'] ?? '',
          templateStyle: data['templateStyle'] ?? '0',
          socialLinks: SocialLinkItem.parseList(data['socialLinks'], data),
          companyName: resolvedComp,
          shortBio: data['shortBio'] ?? data['bio'] ?? '',
          networkingStatus: data['networkingStatus'] ?? data['userStatus'] ?? 'Actively Networking',
          city: (data['city'] as String?) ?? '',
          country: (data['country'] as String?) ?? '',
          address: (data['address'] as String?) ?? '',
          focusAreas: (data['focusAreas'] as String?) ?? '',
          experience: (data['experience'] as String?) ?? '',
          calendly: (data['calendly'] as String?) ?? '',
          resumeUrl: resumeUrl,
          resumeFileName: resumeFileName,
          brochureUrl: brochureUrl,
          brochureFileName: brochureFileName,
          themeColor: (data['themeColor'] as String?) ?? '#0052FF',
        );
        notifyListeners();
        debugPrint('[IndividualProfileStore] Loaded profile from Firestore users/$resolvedDocId: $resolvedName ($resolvedRole @ $resolvedComp)');
        return;
      }

      // 3. Fallback active profile if neither API nor Firestore returned
      if (_activeProfile == null) {
        final resolvedName = fullName.trim().isNotEmpty
            ? fullName.trim()
            : (email.contains('@') ? email.split('@').first : 'User');
        _activeProfile = IndividualProfileData(
          uid: uid,
          fullName: resolvedName,
          email: email,
          cardSlug: generateCardSlug(resolvedName),
          profilePhoto: authPhoto,
          jobTitle: 'Member',
          phoneNumber: '',
          websiteUrl: '',
          templateStyle: '0',
          socialLinks: [],
          companyName: 'MyCardShare Member',
          shortBio: '',
          networkingStatus: 'Actively Networking',
        );
        notifyListeners();
      } else if ((_activeProfile!.profilePhoto == null || _activeProfile!.profilePhoto!.isEmpty) && authPhoto != null) {
        _activeProfile = _activeProfile!.copyWith(profilePhoto: authPhoto);
        notifyListeners();
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
    String city = '',
    String country = '',
    String address = '',
    String focusAreas = '',
    String experience = '',
    String calendly = '',
    String? resumeUrl,
    String? resumeFileName,
    String? brochureUrl,
    String? brochureFileName,
    String themeColor = '#0052FF',
  }) {
    final payload = {
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
      'city': city,
      'country': country,
      'address': address,
      'focusAreas': focusAreas,
      'experience': experience,
      'calendly': calendly,
      'resumeUrl': resumeUrl ?? '',
      'resumeFileName': resumeFileName ?? '',
      'brochureUrl': brochureUrl ?? '',
      'brochureFileName': brochureFileName ?? '',
      'themeColor': themeColor,
      'cardStatus': 'Published',
      'socialLinks': socialLinks
          .map((l) => {'platform': l.platform, 'url': l.url})
          .toList(),
    };

    IndividualApiService.patch('/api/cards', payload).then((_) {
      debugPrint('[IndividualProfileStore] API card sync (/api/cards) successful');
    }).catchError((e) {
      debugPrint('[IndividualProfileStore] API card sync skipped (offline/no backend): $e');
    });

    // Also notify unified sync endpoint /api/sync/individual for dual-DB consistency
    IndividualApiService.patch('/api/sync/individual', {
      'action': 'update_profile',
      'updates': payload,
    }).catchError((_) {});
  }

}


