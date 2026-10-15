import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../employee_join/home/employee_home_backend.dart';
import '../multiple_store/individual_multi_store.dart';
import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';
import '../social_redirect/social_redirect_service.dart';
import 'wallet_card_helpers.dart';
import 'wallet_service.dart';

/// SamsungWalletService — UI layer for Samsung Wallet integration.
///
/// Delegates API call to WalletService.addToSamsungWallet() which calls
/// the backend POST /api/wallet/samsung and opens the returned addToWalletUrl.
/// Samsung Galaxy devices intercept a.swallet.link and show native Wallet sheet.
class SamsungWalletService {
  SamsungWalletService._internal();
  static final SamsungWalletService instance = SamsungWalletService._internal();

  Future<bool> saveToSamsungWallet(
    BuildContext context, {
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    final activeProfile = profile ?? IndividualProfileStore.instance.activeProfile;
    final storedUser = IndividualMultiStore.instance.getAllUsers().firstOrNull;
    final empBackend = EmployeeHomeBackendService.instance;
    final fbUser = FirebaseAuth.instance.currentUser;

    final String name = publicProfile?.fullName.isNotEmpty == true
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

    final String title = publicProfile?.jobTitle.isNotEmpty == true
        ? publicProfile!.jobTitle
        : (activeProfile?.jobTitle.isNotEmpty == true
            ? activeProfile!.jobTitle
            : (empBackend.role != 'Member' && empBackend.role.isNotEmpty
                ? empBackend.role
                : ''));

    final String company = publicProfile?.company.isNotEmpty == true
        ? publicProfile!.company
        : (activeProfile?.companyName.isNotEmpty == true
            ? activeProfile!.companyName
            : (empBackend.companyName != 'Enterprise Workspace' && empBackend.companyName.isNotEmpty
                ? empBackend.companyName
                : ''));

    final String email = publicProfile?.email.isNotEmpty == true
        ? publicProfile!.email
        : (activeProfile?.email.isNotEmpty == true
            ? activeProfile!.email
            : (storedUser?.email.isNotEmpty == true
                ? storedUser!.email
                : (empBackend.email.isNotEmpty
                    ? empBackend.email
                    : (fbUser?.email ?? ''))));

    final String phone = publicProfile?.phone.isNotEmpty == true
        ? publicProfile!.phone
        : (activeProfile?.phoneNumber.isNotEmpty == true
            ? activeProfile!.phoneNumber
            : '');

    final String cardSlug = publicProfile?.cardSlug.isNotEmpty == true
        ? publicProfile!.cardSlug
        : (activeProfile?.cardSlug.isNotEmpty == true
            ? activeProfile!.cardSlug
            : (fbUser?.uid ?? 'user-card'));

    final String avatarUrl = publicProfile?.avatarUrl.isNotEmpty == true
        ? publicProfile!.avatarUrl
        : (activeProfile?.profilePhoto?.isNotEmpty == true
            ? activeProfile!.profilePhoto!
            : (empBackend.avatarUrl?.isNotEmpty == true
                ? empBackend.avatarUrl!
                : (fbUser?.photoURL ?? '')));

    final String bannerUrl = publicProfile?.bannerUrl.isNotEmpty == true
        ? publicProfile!.bannerUrl
        : (activeProfile?.bannerPhoto?.isNotEmpty == true
            ? activeProfile!.bannerPhoto!
            : '');

    final String bio = publicProfile?.bio.isNotEmpty == true
        ? publicProfile!.bio
        : (activeProfile?.shortBio ?? '');

    final String website = publicProfile?.website.isNotEmpty == true
        ? publicProfile!.website
        : (activeProfile?.websiteUrl ?? '');

    final String location = publicProfile?.address.isNotEmpty == true
        ? publicProfile!.address
        : '';

    final List<SocialLinkItem> socialLinks = (publicProfile?.socialLinks.isNotEmpty == true
            ? publicProfile!.socialLinks
            : (activeProfile?.socialLinks ?? []))
        .where((l) => l.url.trim().isNotEmpty)
        .toList();

    // Show preview dialog first
    final proceed = await _showPreviewDialog(
      context,
      name: name,
      title: title,
      company: company,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      bannerUrl: bannerUrl,
      cardSlug: cardSlug,
      bio: bio,
      website: website,
      location: location,
      socialLinks: socialLinks,
    );

    if (proceed != true || !context.mounted) return false;

    // Show loading snackbar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Generating Samsung Wallet pass...'),
            ],
          ),
          backgroundColor: const Color(0xFF1428A0),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 10),
        ),
      );
    }

    try {
      final addToWalletUrl = await WalletService.addToSamsungWallet(
        profile: profile,
        publicProfile: publicProfile,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Samsung Wallet pass saved for $name!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1428A0),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      debugPrint('[SamsungWalletService] Successfully launched: $addToWalletUrl');
      return true;
    } on WalletException catch (e) {
      debugPrint('[SamsungWalletService] WalletException: ${e.title}: ${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        await _showWalletErrorDialog(context, error: e, cardUrl: e.cardUrl);
      }
      return false;
    } catch (e) {
      debugPrint('[SamsungWalletService] Unexpected error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.toString().replaceFirst('Exception: ', ''),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return false;
    }
  }

  Future<bool?> _showPreviewDialog(
    BuildContext context, {
    required String name,
    required String title,
    required String company,
    required String email,
    required String phone,
    required String avatarUrl,
    required String bannerUrl,
    required String cardSlug,
    required String bio,
    required String website,
    required String location,
    required List<SocialLinkItem> socialLinks,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1428A0).withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.wallet_rounded,
                        color: Color(0xFF1428A0),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Samsung Wallet',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Save your digital business card',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Card Preview (Samsung signature navy blue theme)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B175B), Color(0xFF1428A0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Color(0x351428A0), blurRadius: 14, offset: Offset(0, 5)),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner section if available
                      if (bannerUrl.isNotEmpty)
                        SizedBox(
                          height: 70,
                          width: double.infinity,
                          child: buildWalletImageWidget(
                            bannerUrl,
                            fallback: Container(
                              color: const Color(0xFF0F172A),
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.white24, size: 28),
                              ),
                            ),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile row with robust image decoder
                            Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 6),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: buildWalletImageWidget(
                                    avatarUrl,
                                    fallback: Container(
                                      color: const Color(0xFF1D4ED8),
                                      alignment: Alignment.center,
                                      child: Text(
                                        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (title.isNotEmpty)
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            color: Color(0xFF93C5FD),
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Bio / Description
                            if (bio.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                bio,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFE0E7FF),
                                  fontSize: 11.5,
                                  height: 1.3,
                                ),
                              ),
                            ],

                            const Divider(color: Colors.white24, height: 20),

                            // Contact details list
                            if (company.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text('• $company',
                                    style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                              ),
                            if (phone.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text('• $phone',
                                    style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                              ),
                            if (email.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text('• $email',
                                    style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                              ),
                            if (website.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text('• $website',
                                    style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                              ),
                            if (location.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text('• $location',
                                    style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                              ),

                            // Social platforms redirection chips
                            if (socialLinks.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: socialLinks
                                    .map((item) => buildWalletSocialChip(
                                          context: ctx,
                                          item: item,
                                        ))
                                    .toList(),
                              ),
                            ],

                            const SizedBox(height: 10),

                            // Slug with live redirection tap
                            InkWell(
                              onTap: () {
                                SocialRedirectService.launchGenericUrl(
                                  'https://mycardshare.com/card/$cardSlug',
                                  context: ctx,
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.link_rounded,
                                        color: Color(0xFF93C5FD), size: 14),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'mycardshare.com/card/$cardSlug',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF93C5FD),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFF93C5FD),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Info note
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA5B4FC)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFF4338CA), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'A branded pass will be generated and saved directly in your Samsung Wallet app.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF3730A3)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Action Buttons: Fixed single-line layout & proper button styling
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 7,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1428A0),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wallet_rounded, size: 17),
                              SizedBox(width: 6),
                              Text(
                                'Add to Samsung Wallet',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showWalletErrorDialog(
    BuildContext context, {
    required WalletException error,
    required String cardUrl,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.wallet_rounded,
                  color: Color(0xFF1428A0), size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              error.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final uri = Uri.parse(cardUrl);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                label: const Text('Open Card in Browser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1428A0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                child: const Text('Dismiss',
                    style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
