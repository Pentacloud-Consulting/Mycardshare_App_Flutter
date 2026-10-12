import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
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
    if (user == null) throw Exception('User is not logged in.');
    final token = await user.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD cardData map from IndividualProfileData or PublicProfileData
  // ─────────────────────────────────────────────────────────────
  static Map<String, dynamic> _buildCardData({
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) {
    final activeProfile = profile ?? IndividualProfileStore.instance.activeProfile;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return {
      'userId': uid,
      'cardSlug': publicProfile?.cardSlug ?? activeProfile?.cardSlug ?? uid,
      'fullName': publicProfile?.fullName ?? activeProfile?.fullName ?? '',
      'jobTitle': publicProfile?.jobTitle ?? activeProfile?.jobTitle ?? '',
      'companyName': publicProfile?.company ?? activeProfile?.companyName ?? '',
      'workEmail': publicProfile?.email ?? activeProfile?.email ?? '',
      'workPhone': publicProfile?.phone ?? activeProfile?.phoneNumber ?? '',
      'website': publicProfile?.website ?? activeProfile?.websiteUrl ?? '',
      'themeColor': '#0A84FF',
      'avatarUrl': publicProfile?.avatarUrl ?? activeProfile?.profilePhoto,
      'bannerUrl': publicProfile?.bannerUrl ?? activeProfile?.bannerPhoto,
      'bio': activeProfile?.shortBio ?? '',
      'publicCardUrl':
          'https://mycardshare.com/card/${publicProfile?.cardSlug ?? activeProfile?.cardSlug ?? uid}',
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
        'themeColor': cardData['themeColor'],
        'avatarUrl': cardData['avatarUrl'],
        'bannerUrl': cardData['bannerUrl'],
        'publicCardUrl': cardData['publicCardUrl'],
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final saveUrl = json['data']?['saveUrl'] as String?;

      if (saveUrl != null && saveUrl.isNotEmpty) {
        final uri = Uri.parse(saveUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not open Google Wallet URL.');
        }
      } else {
        throw Exception('Invalid saveUrl received from server.');
      }
    } else {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        errorJson['error'] ?? 'Google Wallet pass creation failed.',
      );
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
    final user = FirebaseAuth.instance.currentUser!;
    final cardData = _buildCardData(profile: profile, publicProfile: publicProfile);
    final refId = 'ref-${user.uid}-${DateTime.now().millisecondsSinceEpoch}';

    final response = await http.post(
      Uri.parse('$_baseUrl/api/wallet/samsung'),
      headers: headers,
      body: jsonEncode({
        'refId': refId,
        'formData': {
          'uid': user.uid,
          'cardSlug': cardData['cardSlug'],
          'fullName': cardData['fullName'],
          'jobTitle': cardData['jobTitle'],
          'companyName': cardData['companyName'],
          'workEmail': cardData['workEmail'],
          'workPhone': cardData['workPhone'],
          'website': cardData['website'],
          'address': '',
          'city': '',
          'country': '',
          'tagline': cardData['bio'],
          'avatarUrl': cardData['avatarUrl'],
          'bannerUrl': cardData['bannerUrl'],
          'companyLogo': null,
          'themeColor': '#1428A0',
          'publicCardUrl': cardData['publicCardUrl'],
        },
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final addToWalletUrl = json['data']?['addToWalletUrl'] as String?;

      if (addToWalletUrl != null && addToWalletUrl.isNotEmpty) {
        final uri = Uri.parse(addToWalletUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not open Samsung Wallet URL.');
        }
      } else {
        throw Exception('Invalid addToWalletUrl received from server.');
      }
    } else {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        errorJson['error'] ?? 'Samsung Wallet pass creation failed.',
      );
    }
  }
}
