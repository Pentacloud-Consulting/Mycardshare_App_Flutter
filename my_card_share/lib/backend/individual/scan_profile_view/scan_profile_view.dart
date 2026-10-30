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

  /// Universal parser to extract social platforms from any data shape:
  /// (List of Maps, List of Strings, Map<String, dynamic>, top-level keys, etc.)
  static List<SocialLinkItem> parseSocialLinks(dynamic rawData, [Map<String, dynamic>? parentMap]) {
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

    // 1. If rawData is List
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

    // 2. If rawData is Map
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

    // 3. Check parentMap for alternative collections / top-level keys
    if (parentMap != null) {
      final altKeys = ['socials', 'social_links', 'socialMedia', 'links', 'social_media'];
      for (final alt in altKeys) {
        if (parentMap[alt] != null && parentMap[alt] != rawData) {
          final extra = parseSocialLinks(parentMap[alt]);
          for (final l in extra) {
            addLink(l.platform, l.url);
          }
        }
      }

      // Check common direct fields
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

  factory PublicProfileData.fromMap(Map<String, dynamic> map, String docId) {
    final parsedLinks = parseSocialLinks(map['socialLinks'], map);
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
      socialLinks: parsedLinks,
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

  /// Clean raw QR string or deep link into standard slug
  static String extractCleanSlug(String rawSlug) {
    var s = rawSlug.trim();
    if (s.isEmpty) return '';

    // Handle full URLs (http, https, mycardshare://)
    if (s.startsWith('http://') || s.startsWith('https://') || s.startsWith('mycardshare://')) {
      try {
        final uri = Uri.parse(s);
        final segments = uri.pathSegments.where((p) => p.trim().isNotEmpty).toList();
        if (segments.isNotEmpty) {
          s = segments.last.trim();
        } else if (uri.host.isNotEmpty && uri.host != 'card') {
          s = uri.host.trim();
        }
      } catch (_) {
        s = s.split('?').first.split('#').first;
        if (s.contains('/')) {
          s = s.split('/').lastWhere((part) => part.trim().isNotEmpty, orElse: () => s);
        }
      }
    } else {
      s = s.split('?').first.split('#').first;
      if (s.contains('/')) {
        s = s.split('/').lastWhere((part) => part.trim().isNotEmpty, orElse: () => s);
      }
    }
    return s.trim();
  }

  /// Fetches profile by card slug or URL from backend API / Firestore
  Future<PublicProfileData> fetchProfileBySlug(String rawSlug) async {
    final cleanSlug = extractCleanSlug(rawSlug);

    debugPrint('[ScanProfileViewService] Fetching real profile for card slug: $cleanSlug (raw: $rawSlug)');

    // 1. Check local active profile first if it matches
    final active = IndividualProfileStore.instance.activeProfile;
    if (active != null &&
        (active.cardSlug.toLowerCase() == cleanSlug.toLowerCase() ||
         active.uid.toLowerCase() == cleanSlug.toLowerCase() ||
         active.email.toLowerCase() == cleanSlug.toLowerCase())) {
      UsersViewService.instance.recordProfileView(targetUid: active.uid, source: 'qr_scan');
      return PublicProfileData.fromProfileModel(active);
    }

    // 2. Query Next.js Backend API GET /api/cards/public/[slug]
    try {
      final apiRes = await IndividualApiService.getPublic('/api/cards/public/$cleanSlug');
      if (apiRes['success'] == true && apiRes['data'] != null) {
        final card = apiRes['data']['card'] ?? apiRes['data'];
        if (card != null && card is Map<String, dynamic>) {
          final profile = PublicProfileData.fromMap(card, (card['userId'] ?? card['_id'] ?? cleanSlug).toString());
          await UsersViewService.instance.recordProfileView(targetUid: profile.uid, source: 'qr_scan');
          debugPrint('[ScanProfileViewService] Fetched real card from backend API for: ${profile.fullName} with ${profile.socialLinks.length} social links');
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

      // Query by email if slug looks like email
      if (cleanSlug.contains('@')) {
        final emailQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: cleanSlug)
            .limit(1)
            .get();
        if (emailQuery.docs.isNotEmpty) {
          final doc = emailQuery.docs.first;
          final profile = PublicProfileData.fromMap(doc.data(), doc.id);
          await UsersViewService.instance.recordProfileView(targetUid: profile.uid, source: 'qr_scan');
          return profile;
        }
      }
    } catch (e) {
      debugPrint('[ScanProfileViewService] Firestore lookup notice: $e');
    }

    // 4. Query enterprise employee subcollections across enterprises
    try {
      final empQuery = await FirebaseFirestore.instance
          .collectionGroup('employees')
          .where('cardSlug', isEqualTo: cleanSlug)
          .limit(1)
          .get();
      if (empQuery.docs.isNotEmpty) {
        final doc = empQuery.docs.first;
        final profile = PublicProfileData.fromMap(doc.data(), doc.id);
        await UsersViewService.instance.recordProfileView(targetUid: profile.uid, source: 'qr_scan');
        debugPrint('[ScanProfileViewService] Fetched card from enterprise employee: ${profile.fullName}');
        return profile;
      }
    } catch (e) {
      debugPrint('[ScanProfileViewService] Employee collection group notice: $e');
    }

    // 5. Query root cards collection if present
    try {
      final cardDoc = await FirebaseFirestore.instance.collection('cards').doc(cleanSlug).get();
      if (cardDoc.exists && cardDoc.data() != null) {
        final profile = PublicProfileData.fromMap(cardDoc.data()!, cardDoc.id);
        await UsersViewService.instance.recordProfileView(targetUid: profile.uid, source: 'qr_scan');
        return profile;
      }
    } catch (_) {}

    // 6. Return fallback profile if no card exists yet for this slug
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
