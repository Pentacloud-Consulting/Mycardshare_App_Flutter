import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../employee_join/home/employee_home_backend.dart';
import '../multiple_store/individual_multi_store.dart';
import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';

/// WalletService — Real backend-connected wallet pass generation.
///
/// Google Wallet flow:
///   1. POST /api/wallet/google → backend signs JWT → returns saveUrl
///   2. App launches saveUrl → Android opens native Google Wallet sheet
///
/// Samsung Wallet flow:
///   1. POST /api/wallet/samsung → backend registers pass → returns addToWalletUrl
///   2. App launches addToWalletUrl → Samsung Galaxy intercepts a.swallet.link
///
/// Both flows have graceful fallback chains if backend is unavailable.
class WalletService {
  WalletService._internal();
  static final WalletService instance = WalletService._internal();

  static const String _baseUrl = 'https://mycardshare.com';

  // ─────────────────────────────────────────────────────────────
  // Wallet app package name (for Play Store redirect / deep links if needed)
  // ─────────────────────────────────────────────────────────────
  static const String _googleWalletPkg = 'com.google.android.apps.walletnfcrel';

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
  // BUILD cardData map from all available stores & fallbacks
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
  // HELPER: Launch URL — tries multiple modes in order
  // Returns the URL that was successfully launched, or null.
  // ─────────────────────────────────────────────────────────────
  static Future<bool> _tryLaunch(String url,
      {LaunchMode mode = LaunchMode.externalApplication}) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: mode);
      }
    } catch (e) {
      debugPrint('[WalletService] Launch failed ($url): $e');
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────
  // 1. ADD TO GOOGLE WALLET
  // ─────────────────────────────────────────────────────────────
  /// Returns the saveUrl string that was successfully obtained and launched.
  /// Throws [WalletException] with a human-readable message if all attempts fail.
  ///
  /// Fallback order:
  ///   1. Backend POST /api/wallet/google → saveUrl (JWT-signed Google Wallet pass)
  ///   2. GET  /api/wallet/google/redirect?slug=... (simple redirect endpoint)
  ///   3. Open Google Wallet app home screen directly
  static Future<String> addToGoogleWallet({
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    final headers = await _getHeaders();
    final cardData = _buildCardData(profile: profile, publicProfile: publicProfile);
    final slug = cardData['cardSlug'] as String;
    final publicCardUrl = cardData['publicCardUrl'] as String;

    // ── Step 1: Backend POST /api/sync/wallet → JWT-signed saveUrl ───────
    try {
      debugPrint('[WalletService] Calling POST /api/sync/wallet (google) ...');
      final syncResponse = await http.post(
        Uri.parse('$_baseUrl/api/sync/wallet'),
        headers: headers,
        body: jsonEncode({
          'walletType': 'google',
          'cardData': cardData,
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint('[WalletService] Sync Response ${syncResponse.statusCode}: ${syncResponse.body.substring(0, syncResponse.body.length.clamp(0, 300))}');

      if (syncResponse.statusCode == 200) {
        final json = jsonDecode(syncResponse.body) as Map<String, dynamic>;
        final saveUrl = _extractString(json, [
          'data.saveUrl', 'saveUrl', 'data.url', 'url',
          'data.addToWalletUrl', 'addToWalletUrl',
          'data.walletUrl', 'walletUrl',
        ]);
        if (saveUrl != null && saveUrl.isNotEmpty) {
          debugPrint('[WalletService] Got saveUrl via /api/sync/wallet: $saveUrl');
          // Launch as externalApplication so Google Play Services / Google Wallet catches it natively!
          if (await _tryLaunch(saveUrl, mode: LaunchMode.externalApplication)) {
            return saveUrl;
          }
        }
      }

      // Legacy fallback: /api/wallet/google
      debugPrint('[WalletService] Calling fallback POST /api/wallet/google ...');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/wallet/google'),
        headers: headers,
        body: jsonEncode({
          'userId': cardData['userId'],
          'fullName': cardData['fullName'],
          'jobTitle': cardData['jobTitle'],
          'companyName': cardData['companyName'],
          'workEmail': cardData['workEmail'],
          'workPhone': cardData['workPhone'],
          'website': cardData['website'],
          'location': cardData['location'],
          'description': cardData['bio'],
          'themeColor': cardData['themeColor'],
          'avatarUrl': cardData['avatarUrl'],
          'bannerUrl': cardData['bannerUrl'],
          'cardSlug': slug,
          'socialLinks': cardData['socialLinks'],
          'publicCardUrl': publicCardUrl,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final saveUrl = _extractString(json, [
          'data.saveUrl', 'saveUrl', 'data.url', 'url',
          'data.addToWalletUrl', 'addToWalletUrl',
          'data.walletUrl', 'walletUrl',
        ]);
        if (saveUrl != null && saveUrl.isNotEmpty) {
          if (await _tryLaunch(saveUrl, mode: LaunchMode.externalApplication)) {
            return saveUrl;
          }
        }
      }
    } catch (e) {
      debugPrint('[WalletService] Google Wallet backend error: $e');
    }

    // ── Step 2: GET redirect endpoint ─────────────────────────
    try {
      final redirectUrl = '$_baseUrl/api/wallet/google/save?slug=$slug';
      debugPrint('[WalletService] Trying redirect endpoint: $redirectUrl');
      final response = await http.get(
        Uri.parse(redirectUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 302) {
        final location = response.headers['location'];
        final saveUrl = location ?? redirectUrl;
        if (await _tryLaunch(saveUrl, mode: LaunchMode.externalNonBrowserApplication)) {
          return saveUrl;
        }
        if (await _tryLaunch(saveUrl, mode: LaunchMode.externalApplication)) {
          return saveUrl;
        }
      }
    } catch (e) {
      debugPrint('[WalletService] Google Wallet redirect error: $e');
    }

    // ── Step 3: Open Google Wallet app home directly ──────────
    // This at least opens the wallet app so the user is in the right place
    final walletAppUrls = [
      'https://pay.google.com/payments/home',  // Wallet web — Chrome → Wallet app
      'market://details?id=$_googleWalletPkg', // Play Store if not installed
    ];
    for (final url in walletAppUrls) {
      if (await _tryLaunch(url, mode: LaunchMode.externalApplication)) {
        // Return empty string to signal "app opened but no pass generated"
        throw WalletException(
          title: 'Backend Not Ready',
          message: 'The wallet pass generation server is not configured yet. '
              'Google Wallet has been opened — please set up the backend API to enable '
              'automatic pass creation.',
          cardUrl: publicCardUrl,
        );
      }
    }

    // ── Step 4: Nothing worked ────────────────────────────────
    throw WalletException(
      title: 'Google Wallet Unavailable',
      message: 'Could not connect to the wallet pass server. '
          'Please check your internet connection and try again.',
      cardUrl: publicCardUrl,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. ADD TO SAMSUNG WALLET
  // ─────────────────────────────────────────────────────────────
  static Future<String> addToSamsungWallet({
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    final headers = await _getHeaders();
    final cardData = _buildCardData(profile: profile, publicProfile: publicProfile);
    final refId = 'ref-${cardData['userId']}-${DateTime.now().millisecondsSinceEpoch}';
    final slug = cardData['cardSlug'] as String;
    final publicCardUrl = cardData['publicCardUrl'] as String;

    // ── Step 1: Backend POST /api/sync/wallet (samsung) ────────
    try {
      debugPrint('[WalletService] Calling POST /api/sync/wallet (samsung) ...');
      final syncResponse = await http.post(
        Uri.parse('$_baseUrl/api/sync/wallet'),
        headers: headers,
        body: jsonEncode({
          'walletType': 'samsung',
          'cardData': cardData,
        }),
      ).timeout(const Duration(seconds: 15));

      if (syncResponse.statusCode == 200) {
        final json = jsonDecode(syncResponse.body) as Map<String, dynamic>;
        final addToWalletUrl = _extractString(json, [
          'data.addToWalletUrl', 'addToWalletUrl', 'data.url', 'url',
          'data.saveUrl', 'saveUrl', 'data.walletUrl', 'walletUrl',
        ]);
        if (addToWalletUrl != null && addToWalletUrl.isNotEmpty) {
          debugPrint('[WalletService] Got addToWalletUrl via /api/sync/wallet: $addToWalletUrl');
          if (await _tryLaunch(addToWalletUrl, mode: LaunchMode.externalApplication)) {
            return addToWalletUrl;
          }
        }
      }

      // Legacy fallback: /api/wallet/samsung
      debugPrint('[WalletService] Calling fallback POST /api/wallet/samsung ...');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/wallet/samsung'),
        headers: headers,
        body: jsonEncode({
          'refId': refId,
          'formData': {
            'uid': cardData['userId'],
            'cardSlug': slug,
            'fullName': cardData['fullName'],
            'jobTitle': cardData['jobTitle'],
            'companyName': cardData['companyName'],
            'workEmail': cardData['workEmail'],
            'workPhone': cardData['workPhone'],
            'website': cardData['website'],
            'address': cardData['location'],
            'city': '',
            'country': '',
            'tagline': cardData['bio'],
            'avatarUrl': cardData['avatarUrl'],
            'bannerUrl': cardData['bannerUrl'],
            'socialLinks': cardData['socialLinks'],
            'companyLogo': null,
            'themeColor': '#1428A0',
            'publicCardUrl': publicCardUrl,
          },
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final addToWalletUrl = _extractString(json, [
          'data.addToWalletUrl', 'addToWalletUrl', 'data.url', 'url',
          'data.saveUrl', 'saveUrl', 'data.walletUrl', 'walletUrl',
        ]);

        if (addToWalletUrl != null && addToWalletUrl.isNotEmpty) {
          if (await _tryLaunch(addToWalletUrl, mode: LaunchMode.externalApplication)) {
            return addToWalletUrl;
          }
        }
      }
    } catch (e) {
      debugPrint('[WalletService] Samsung Wallet backend error: $e');
    }

    // ── Step 2: Samsung universal link (a.swallet.link) ──────
    // Samsung Galaxy devices intercept this domain and open Samsung Wallet
    final samsungFallbacks = [
      'https://a.swallet.link/add/$slug',
      'samsungwallet://wallet/add?url=${Uri.encodeComponent(publicCardUrl)}',
      'samsungpay://wallet/add?url=${Uri.encodeComponent(publicCardUrl)}',
    ];
    for (final url in samsungFallbacks) {
      debugPrint('[WalletService] Trying Samsung URL: $url');
      if (await _tryLaunch(url, mode: LaunchMode.externalNonBrowserApplication)) {
        throw WalletException(
          title: 'Backend Not Ready',
          message: 'The Samsung Wallet pass server is not configured. '
              'Samsung Wallet has been opened — please set up the backend API.',
          cardUrl: publicCardUrl,
        );
      }
      if (await _tryLaunch(url, mode: LaunchMode.externalApplication)) {
        throw WalletException(
          title: 'Backend Not Ready',
          message: 'The Samsung Wallet pass server is not configured. '
              'Samsung Wallet has been opened — please set up the backend API.',
          cardUrl: publicCardUrl,
        );
      }
    }

    throw WalletException(
      title: 'Samsung Wallet Unavailable',
      message: 'Could not connect to the Samsung Wallet pass server. '
          'Please check your internet connection and try again.',
      cardUrl: publicCardUrl,
    );
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
