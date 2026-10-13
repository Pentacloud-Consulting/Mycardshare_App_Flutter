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
/// Flow:
/// 1. Flutter calls POST /api/wallet/google or /api/wallet/samsung with Bearer token
/// 2. Backend (Next.js) generates signed pass and returns saveUrl / addToWalletUrl
/// 3. Flutter launches that URL → device native wallet sheet pops up
///
/// This follows the MyCardShare Wallet_Integration_Guide.md exactly.
class WalletService {
  WalletService._internal();
  static final WalletService instance = WalletService._internal();

  static const String _baseUrl = 'https://mycardshare.com';

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
  // 1. ADD TO GOOGLE WALLET
  // ─────────────────────────────────────────────────────────────
  /// Calls backend POST /api/wallet/google → gets saveUrl → launches it.
  /// Android device opens native "Add to Google Wallet" sheet.
  static Future<void> addToGoogleWallet({
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    final headers = await _getHeaders();
    final cardData = _buildCardData(profile: profile, publicProfile: publicProfile);

    try {
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
          'cardSlug': cardData['cardSlug'],
          'socialLinks': cardData['socialLinks'],
          'publicCardUrl': cardData['publicCardUrl'],
        }),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final saveUrl = json['data']?['saveUrl'] as String? ?? json['saveUrl'] as String?;

        if (saveUrl != null && saveUrl.isNotEmpty) {
          final uri = Uri.parse(saveUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('[WalletService] Google Wallet API call warning: $e');
    }

    // Direct Google Pay / Wallet web fallback for passes
    final slug = cardData['cardSlug'];
    final fallbackUri = Uri.parse('https://mycardshare.com/card/$slug?wallet=google');
    if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    } else {
      final publicUri = Uri.parse(cardData['publicCardUrl'] as String);
      await launchUrl(publicUri, mode: LaunchMode.externalApplication);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 2. ADD TO SAMSUNG WALLET
  // ─────────────────────────────────────────────────────────────
  /// Calls backend POST /api/wallet/samsung → gets addToWalletUrl → launches it.
  /// Samsung Galaxy devices intercept a.swallet.link and open Samsung Wallet sheet.
  static Future<void> addToSamsungWallet({
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    final headers = await _getHeaders();
    final cardData = _buildCardData(profile: profile, publicProfile: publicProfile);
    final refId = 'ref-${cardData['userId']}-${DateTime.now().millisecondsSinceEpoch}';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/wallet/samsung'),
        headers: headers,
        body: jsonEncode({
          'refId': refId,
          'formData': {
            'uid': cardData['userId'],
            'cardSlug': cardData['cardSlug'],
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
            'publicCardUrl': cardData['publicCardUrl'],
          },
        }),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final addToWalletUrl = json['data']?['addToWalletUrl'] as String? ?? json['addToWalletUrl'] as String?;

        if (addToWalletUrl != null && addToWalletUrl.isNotEmpty) {
          final uri = Uri.parse(addToWalletUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('[WalletService] Samsung Wallet API call warning: $e');
    }

    // Direct Samsung Wallet web fallback
    final slug = cardData['cardSlug'];
    final fallbackUri = Uri.parse('https://mycardshare.com/card/$slug?wallet=samsung');
    if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    } else {
      final publicUri = Uri.parse(cardData['publicCardUrl'] as String);
      await launchUrl(publicUri, mode: LaunchMode.externalApplication);
    }
  }
}
