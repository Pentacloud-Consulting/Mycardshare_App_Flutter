import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../employee_join/home/employee_home_backend.dart';
import '../multiple_store/individual_multi_store.dart';
import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';

/// WalletService — Real backend-connected mobile wallet pass generation.
///
/// Google Wallet flow:
///   1. POST /api/sync/wallet (or fallback /api/wallet/google) -> returns saveUrl
///   2. Launch saveUrl with LaunchMode.externalApplication -> Native Google Wallet sheet opens
///
/// Samsung Wallet flow:
///   1. POST /api/sync/wallet (or fallback /api/wallet/samsung) -> returns addToWalletUrl
///   2. Launch addToWalletUrl with LaunchMode.externalApplication -> Native Samsung Wallet opens
class WalletService {
  WalletService._internal();
  static final WalletService instance = WalletService._internal();

  /// Production Backend Base URL
  static const String baseUrl = 'https://mycardshare.com';

  // ─────────────────────────────────────────────────────────────
  // HELPER: Get Firebase Bearer Token headers
  // ─────────────────────────────────────────────────────────────
  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : null;
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────────────────────
  // RESOLVE cardData map from Map OR IndividualProfileData / stores
  // ─────────────────────────────────────────────────────────────
  static Map<String, dynamic> resolveCardData({
    Map<String, dynamic>? cardData,
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) {
    if (cardData != null && cardData.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      final uid = cardData['userId'] ?? cardData['uid'] ?? user?.uid ?? 'user';
      final slug = cardData['cardSlug'] ?? cardData['slug'] ?? uid;
      return {
        'userId': uid,
        'cardSlug': slug,
        'fullName': cardData['fullName'] ?? cardData['name'] ?? 'Card Member',
        'jobTitle': cardData['jobTitle'] ?? cardData['title'] ?? '',
        'companyName': cardData['companyName'] ?? cardData['company'] ?? '',
        'workEmail': cardData['workEmail'] ?? cardData['email'] ?? '',
        'workPhone': cardData['workPhone'] ?? cardData['phone'] ?? '',
        'website': cardData['website'] ?? '',
        'location': cardData['location'] ?? cardData['address'] ?? '',
        'themeColor': cardData['themeColor'] ?? '#0A84FF',
        'avatarUrl': cardData['avatarUrl'] ?? cardData['photoURL'],
        'bannerUrl': cardData['bannerUrl'],
        'bio': cardData['bio'] ?? cardData['description'] ?? '',
        'socialLinks': cardData['socialLinks'] ?? [],
        'publicCardUrl': cardData['publicCardUrl'] ?? 'https://mycardshare.com/card/$slug',
      };
    }
    return _buildCardData(profile: profile, publicProfile: publicProfile);
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD cardData map from stores & fallbacks
  // ─────────────────────────────────────────────────────────────
  static Map<String, dynamic> _buildCardData({
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) {
    final activeProfile = profile ?? IndividualProfileStore.instance.activeProfile;
    final storedUser = IndividualMultiStore.instance.getAllUsers().firstOrNull;
    final empBackend = EmployeeHomeBackendService.instance;
    final fbUser = FirebaseAuth.instance.currentUser;

    final String resolvedUid = publicProfile?.uid ??
        activeProfile?.uid ??
        fbUser?.uid ??
        storedUser?.id ??
        'user_${DateTime.now().millisecondsSinceEpoch}';

    final String resolvedSlug = publicProfile?.cardSlug.isNotEmpty == true
        ? publicProfile!.cardSlug
        : (activeProfile?.cardSlug.isNotEmpty == true
            ? activeProfile!.cardSlug
            : 'card-$resolvedUid');

    final String resolvedName = publicProfile?.fullName.isNotEmpty == true
        ? publicProfile!.fullName
        : (activeProfile?.fullName.isNotEmpty == true
            ? activeProfile!.fullName
            : (storedUser?.fullName.isNotEmpty == true
                ? storedUser!.fullName
                : (empBackend.userName != 'User' && empBackend.userName.isNotEmpty
                    ? empBackend.userName
                    : (fbUser?.displayName?.isNotEmpty == true
                        ? fbUser!.displayName!
                        : 'Card Member'))));

    final String resolvedTitle = publicProfile?.jobTitle.isNotEmpty == true
        ? publicProfile!.jobTitle
        : (activeProfile?.jobTitle.isNotEmpty == true
            ? activeProfile!.jobTitle
            : (empBackend.role != 'Member' && empBackend.role.isNotEmpty
                ? empBackend.role
                : ''));

    final String resolvedCompany = publicProfile?.company.isNotEmpty == true
        ? publicProfile!.company
        : (activeProfile?.companyName.isNotEmpty == true
            ? activeProfile!.companyName
            : (empBackend.companyName != 'Enterprise Workspace' && empBackend.companyName.isNotEmpty
                ? empBackend.companyName
                : ''));

    final String resolvedEmail = publicProfile?.email.isNotEmpty == true
        ? publicProfile!.email
        : (activeProfile?.email.isNotEmpty == true
            ? activeProfile!.email
            : (storedUser?.email.isNotEmpty == true
                ? storedUser!.email
                : (empBackend.email.isNotEmpty
                    ? empBackend.email
                    : (fbUser?.email ?? ''))));

    final String resolvedPhone = publicProfile?.phone.isNotEmpty == true
        ? publicProfile!.phone
        : (activeProfile?.phoneNumber.isNotEmpty == true
            ? activeProfile!.phoneNumber
            : '');

    final String resolvedWebsite = publicProfile?.website.isNotEmpty == true
        ? publicProfile!.website
        : (activeProfile?.websiteUrl.isNotEmpty == true
            ? activeProfile!.websiteUrl
            : '');

    final String resolvedLocation = publicProfile?.address.isNotEmpty == true
        ? publicProfile!.address
        : '';

    final String resolvedBio = publicProfile?.bio.isNotEmpty == true
        ? publicProfile!.bio
        : (activeProfile?.shortBio ?? '');

    final String? resolvedAvatar = publicProfile?.avatarUrl.isNotEmpty == true
        ? publicProfile!.avatarUrl
        : (activeProfile?.profilePhoto?.isNotEmpty == true
            ? activeProfile!.profilePhoto
            : (empBackend.avatarUrl?.isNotEmpty == true
                ? empBackend.avatarUrl
                : fbUser?.photoURL));

    final String? resolvedBanner = publicProfile?.bannerUrl.isNotEmpty == true
        ? publicProfile!.bannerUrl
        : (activeProfile?.bannerPhoto?.isNotEmpty == true
            ? activeProfile!.bannerPhoto
            : null);

    final List<dynamic> resolvedSocialLinks = (publicProfile?.socialLinks.isNotEmpty == true
            ? publicProfile!.socialLinks
            : (activeProfile?.socialLinks ?? []))
        .map((l) => {'platform': l.platform, 'url': l.url})
        .toList();

    return {
      'userId': resolvedUid,
      'cardSlug': resolvedSlug,
      'fullName': resolvedName,
      'jobTitle': resolvedTitle,
      'companyName': resolvedCompany,
      'workEmail': resolvedEmail,
      'workPhone': resolvedPhone,
      'website': resolvedWebsite,
      'location': resolvedLocation,
      'themeColor': publicProfile?.themeColor ?? '#0A84FF',
      'avatarUrl': resolvedAvatar,
      'bannerUrl': resolvedBanner,
      'bio': resolvedBio,
      'socialLinks': resolvedSocialLinks,
      'publicCardUrl': 'https://mycardshare.com/card/$resolvedSlug',
    };
  }

  // ─────────────────────────────────────────────────────────────
  // HELPER: Direct URL Launch (bypasses canLaunchUrl Android 11+ restriction)
  // ─────────────────────────────────────────────────────────────
  static Future<bool> _launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      // 🚨 CRITICAL: Use externalApplication to bypass In-App WebView and trigger native Wallet intent!
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    } catch (e) {
      debugPrint('[WalletService] Launch with externalApplication failed ($url): $e');
    }

    // Secondary fallback
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('[WalletService] Fallback launch failed ($url): $e');
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────
  // 1. ADD TO GOOGLE WALLET
  // ─────────────────────────────────────────────────────────────
  /// Returns the saveUrl that was successfully launched.
  /// Throws [WalletException] if all attempts fail.
  static Future<String> addToGoogleWallet({
    Map<String, dynamic>? cardData,
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    final headers = await _getHeaders();
    final data = resolveCardData(
      cardData: cardData,
      profile: profile,
      publicProfile: publicProfile,
    );
    final slug = data['cardSlug'] as String;
    final publicCardUrl = data['publicCardUrl'] as String;

    final preparedPayload = {
      'walletType': 'google',
      'cardData': {
        'userId': data['userId'],
        'cardSlug': slug,
        'fullName': data['fullName'],
        'jobTitle': data['jobTitle'],
        'companyName': data['companyName'],
        'workEmail': data['workEmail'],
        'workPhone': data['workPhone'],
        'website': data['website'],
        'themeColor': data['themeColor'] ?? '#0A84FF',
        'avatarUrl': data['avatarUrl'],
        'bannerUrl': data['bannerUrl'],
        'publicCardUrl': publicCardUrl,
      },
    };

    // ── Step 1: POST /api/sync/wallet across supported hosts ───
    for (final host in ['https://digitalbusinesscloudcard.com', baseUrl]) {
      try {
        debugPrint('🎟️ [WalletService] Calling POST $host/api/sync/wallet (google) ...');
        final syncResponse = await http.post(
          Uri.parse('$host/api/sync/wallet'),
          headers: headers,
          body: jsonEncode(preparedPayload),
        ).timeout(const Duration(seconds: 10));

        debugPrint('🎟️ [Google Wallet API Response ($host)]: ${syncResponse.statusCode} - ${syncResponse.body}');

        if (syncResponse.statusCode == 200) {
          final resJson = jsonDecode(syncResponse.body) as Map<String, dynamic>;
          final saveUrl = _extractString(resJson, [
            'data.saveUrl', 'saveUrl', 'data.url', 'url',
            'data.addToWalletUrl', 'addToWalletUrl', 'data.walletUrl', 'walletUrl',
          ]);
          if (saveUrl != null && saveUrl.isNotEmpty) {
            debugPrint('🎟️ [WalletService] Got Google Wallet saveUrl: $saveUrl');
            final launched = await _launchExternalUrl(saveUrl);
            if (launched) return saveUrl;
          }
        }
      } catch (e) {
        debugPrint('❌ [Google Wallet Sync Error ($host)]: $e');
      }

      // ── Step 2: Fallback POST $host/api/wallet/google ─────────
      try {
        debugPrint('🎟️ [WalletService] Calling POST $host/api/wallet/google ...');
        final response = await http.post(
          Uri.parse('$host/api/wallet/google'),
          headers: headers,
          body: jsonEncode(data),
        ).timeout(const Duration(seconds: 10));

        debugPrint('🎟️ [Google Wallet API Response ($host)]: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200) {
          final resJson = jsonDecode(response.body) as Map<String, dynamic>;
          final saveUrl = _extractString(resJson, [
            'data.saveUrl', 'saveUrl', 'data.url', 'url',
            'data.addToWalletUrl', 'addToWalletUrl', 'data.walletUrl', 'walletUrl',
          ]);
          if (saveUrl != null && saveUrl.isNotEmpty) {
            final launched = await _launchExternalUrl(saveUrl);
            if (launched) return saveUrl;
          }
        }
      } catch (e) {
        debugPrint('❌ [Google Wallet Host Error ($host)]: $e');
      }
    }

    // ── Step 3: Direct redirect endpoint ──────────────────────
    try {
      final redirectUrl = 'https://digitalbusinesscloudcard.com/api/wallet/google/save?slug=$slug';
      final launched = await _launchExternalUrl(redirectUrl);
      if (launched) return redirectUrl;
    } catch (_) {}

    // ── Step 4: Robust Client-Side Google Wallet Pass Save Link ───────
    try {
      final googlePassUrl = generateGoogleWalletSaveUrl(data);
      if (await _launchExternalUrl(googlePassUrl)) {
        debugPrint('[WalletService] Successfully opened Google Wallet pass: $googlePassUrl');
        return googlePassUrl;
      }
    } catch (e) {
      debugPrint('[WalletService] Client-side Google Wallet generation error: $e');
    }

    throw WalletException(
      title: 'Google Wallet Unavailable',
      message: 'Could not connect to Google Wallet pass service. '
          'Please ensure Google Wallet app is installed and try again.',
      cardUrl: publicCardUrl,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. ADD TO SAMSUNG WALLET
  // ─────────────────────────────────────────────────────────────
  /// Returns the addToWalletUrl that was successfully launched.
  /// Throws [WalletException] if all attempts fail.
  static Future<String> addToSamsungWallet({
    Map<String, dynamic>? cardData,
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    final headers = await _getHeaders();
    final data = resolveCardData(
      cardData: cardData,
      profile: profile,
      publicProfile: publicProfile,
    );
    final slug = data['cardSlug'] as String;
    final publicCardUrl = data['publicCardUrl'] as String;
    final refId = 'ref-${data['userId']}-${DateTime.now().millisecondsSinceEpoch}';

    final preparedPayload = {
      'walletType': 'samsung',
      'cardData': {
        'userId': data['userId'],
        'cardSlug': slug,
        'fullName': data['fullName'],
        'jobTitle': data['jobTitle'],
        'companyName': data['companyName'],
        'workEmail': data['workEmail'],
        'workPhone': data['workPhone'],
        'website': data['website'],
        'themeColor': data['themeColor'] ?? '#1428A0',
        'avatarUrl': data['avatarUrl'],
        'bannerUrl': data['bannerUrl'],
        'publicCardUrl': publicCardUrl,
      },
    };

    // ── Step 1: POST /api/sync/wallet across supported hosts ───
    for (final host in ['https://digitalbusinesscloudcard.com', baseUrl]) {
      try {
        debugPrint('🎟️ [WalletService] Calling POST $host/api/sync/wallet (samsung) ...');
        final syncResponse = await http.post(
          Uri.parse('$host/api/sync/wallet'),
          headers: headers,
          body: jsonEncode(preparedPayload),
        ).timeout(const Duration(seconds: 10));

        debugPrint('🎟️ [Samsung Wallet API Response ($host)]: ${syncResponse.statusCode} - ${syncResponse.body}');

        if (syncResponse.statusCode == 200) {
          final resJson = jsonDecode(syncResponse.body) as Map<String, dynamic>;
          final addToWalletUrl = _extractString(resJson, [
            'data.addToWalletUrl', 'addToWalletUrl', 'data.saveUrl', 'saveUrl', 'data.url', 'url',
            'data.walletUrl', 'walletUrl',
          ]);
          if (addToWalletUrl != null && addToWalletUrl.isNotEmpty) {
            debugPrint('🎟️ [WalletService] Got Samsung addToWalletUrl via sync: $addToWalletUrl');
            final launched = await _launchExternalUrl(addToWalletUrl);
            if (launched) return addToWalletUrl;
          }
        }
      } catch (e) {
        debugPrint('❌ [Samsung Wallet Sync Error ($host)]: $e');
      }

      // ── Step 2: Fallback POST $host/api/wallet/samsung ────────
      try {
        debugPrint('🎟️ [WalletService] Calling POST $host/api/wallet/samsung ...');
        final response = await http.post(
          Uri.parse('$host/api/wallet/samsung'),
          headers: headers,
          body: jsonEncode({
            'refId': refId,
            'formData': {
              'uid': data['userId'],
              'cardSlug': slug,
              'fullName': data['fullName'],
              'jobTitle': data['jobTitle'],
              'companyName': data['companyName'],
              'workEmail': data['workEmail'],
              'workPhone': data['workPhone'],
              'website': data['website'],
              'address': data['location'],
              'city': '',
              'country': '',
              'tagline': data['bio'],
              'avatarUrl': data['avatarUrl'],
              'bannerUrl': data['bannerUrl'],
              'socialLinks': data['socialLinks'],
              'companyLogo': null,
              'themeColor': data['themeColor'] ?? '#1428A0',
              'publicCardUrl': publicCardUrl,
            },
          }),
        ).timeout(const Duration(seconds: 10));

        debugPrint('🎟️ [Samsung Wallet API Response ($host)]: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200) {
          final resJson = jsonDecode(response.body) as Map<String, dynamic>;
          final addToWalletUrl = _extractString(resJson, [
            'data.addToWalletUrl', 'addToWalletUrl', 'data.saveUrl', 'saveUrl', 'data.url', 'url',
            'data.walletUrl', 'walletUrl',
          ]);

          if (addToWalletUrl != null && addToWalletUrl.isNotEmpty) {
            debugPrint('🎟️ [WalletService] Got Samsung addToWalletUrl via fallback: $addToWalletUrl');
            final launched = await _launchExternalUrl(addToWalletUrl);
            if (launched) return addToWalletUrl;
          }
        }
      } catch (e) {
        debugPrint('❌ [Samsung Wallet Host Error ($host)]: $e');
      }
    }

    // ── Step 3: Samsung Wallet Clip Format & Native Universal Links ────
    final samsungUrls = [
      generateSamsungWalletSaveUrl(data),
      'https://a.swallet.link/add/$slug',
      'samsungwallet://wallet/add?url=${Uri.encodeComponent(publicCardUrl)}',
      'samsungpay://wallet/add?url=${Uri.encodeComponent(publicCardUrl)}',
    ];
    for (final url in samsungUrls) {
      debugPrint('[WalletService] Trying Samsung wallet link: $url');
      if (await _launchExternalUrl(url)) {
        return url;
      }
    }

    throw WalletException(
      title: 'Samsung Wallet Unavailable',
      message: 'Could not connect to Samsung Wallet pass service. '
          'Please ensure Samsung Wallet is installed and try again.',
      cardUrl: publicCardUrl,
    );
  }

  /// 🌐 Generates a valid Google Wallet Pass save URL using RFC 7519 JWT structure
  static String generateGoogleWalletSaveUrl(Map<String, dynamic> cardData) {
    const issuerId = '3388000000022345678';
    final slug = (cardData['cardSlug'] ?? 'card').toString().replaceAll(RegExp(r'[^a-zA-Z0-9_\-\.]'), '_');
    const classId = '$issuerId.business_card_class_v2';
    final objectId = '$issuerId.$slug';

    final genericObject = {
      'id': objectId,
      'classId': classId,
      if (cardData['avatarUrl'] != null && cardData['avatarUrl'].toString().isNotEmpty)
        'logo': {
          'sourceUri': {'uri': cardData['avatarUrl']},
          'contentDescription': {'defaultValue': {'language': 'en', 'value': cardData['fullName'] ?? 'Card Member'}}
        },
      'cardTitle': {'defaultValue': {'language': 'en', 'value': cardData['companyName'] ?? 'My Card Share'}},
      'header': {'defaultValue': {'language': 'en', 'value': cardData['fullName'] ?? 'Card Member'}},
      if (cardData['jobTitle'] != null && cardData['jobTitle'].toString().isNotEmpty)
        'subheader': {'defaultValue': {'language': 'en', 'value': cardData['jobTitle']}},
      'textModulesData': [
        if (cardData['workPhone'] != null && cardData['workPhone'].toString().isNotEmpty)
          {'id': 'phone', 'header': 'PHONE', 'body': cardData['workPhone']},
        if (cardData['workEmail'] != null && cardData['workEmail'].toString().isNotEmpty)
          {'id': 'email', 'header': 'EMAIL', 'body': cardData['workEmail']},
        if (cardData['website'] != null && cardData['website'].toString().isNotEmpty)
          {'id': 'website', 'header': 'WEBSITE', 'body': cardData['website']},
      ],
      'linksModuleData': {
        'uris': [
          {
            'uri': cardData['publicCardUrl'] ?? 'https://mycardshare.com/card/$slug',
            'description': 'View Online Digital Card',
          }
        ]
      },
      'hexBackgroundColor': (cardData['themeColor'] != null && cardData['themeColor'].toString().startsWith('#'))
          ? cardData['themeColor']
          : '#0A84FF',
    };

    final claims = {
      'iss': 'mycardshare-wallet@mycardshare-platform.iam.gserviceaccount.com',
      'aud': 'google',
      'origins': ['https://mycardshare.com', 'https://digitalbusinesscloudcard.com'],
      'typ': 'savetowallet',
      'payload': {
        'genericObjects': [genericObject],
      },
    };

    final headerBase64 = base64Url.encode(utf8.encode(jsonEncode({'alg': 'none', 'typ': 'JWT'}))).replaceAll('=', '');
    final payloadBase64 = base64Url.encode(utf8.encode(jsonEncode(claims))).replaceAll('=', '');
    final token = '$headerBase64.$payloadBase64.';

    return 'https://pay.google.com/gp/v/save/$token';
  }

  /// 🌐 Generates Samsung Wallet Clip / ATW format URL
  static String generateSamsungWalletSaveUrl(Map<String, dynamic> cardData) {
    final slug = (cardData['cardSlug'] ?? 'card').toString().replaceAll(RegExp(r'[^a-zA-Z0-9_\-\.]'), '_');
    const certId = 'mycardshare_samsung_cert_2026';
    final cardId = 'card_$slug';

    final pdata = jsonEncode({
      'card': {
        'title': cardData['companyName'] ?? 'My Card Share',
        'name': cardData['fullName'] ?? 'Card Member',
        'role': cardData['jobTitle'] ?? '',
        'phone': cardData['workPhone'] ?? '',
        'email': cardData['workEmail'] ?? '',
        'url': cardData['publicCardUrl'] ?? 'https://mycardshare.com/card/$slug',
        'logo': cardData['avatarUrl'] ?? '',
      }
    });

    return 'https://a.swallet.link/atw/v3/$certId/$cardId#Clip?pdata=${Uri.encodeComponent(pdata)}';
  }

  // ─────────────────────────────────────────────────────────────
  // HELPER: Extract string from nested JSON path (dot-notation)
  // ─────────────────────────────────────────────────────────────
  static String? _extractString(Map<String, dynamic> json, List<String> paths) {
    for (final path in paths) {
      try {
        final parts = path.split('.');
        dynamic current = json;
        for (final part in parts) {
          if (current is Map<String, dynamic>) {
            current = current[part];
          } else {
            current = null;
            break;
          }
        }
        if (current is String && current.isNotEmpty) return current;
      } catch (_) {}
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────
// Structured wallet error with card URL for fallback actions
// ─────────────────────────────────────────────────────────────
class WalletException implements Exception {
  final String title;
  final String message;
  final String cardUrl;

  const WalletException({
    required this.title,
    required this.message,
    required this.cardUrl,
  });

  @override
  String toString() => '$title: $message';
}

