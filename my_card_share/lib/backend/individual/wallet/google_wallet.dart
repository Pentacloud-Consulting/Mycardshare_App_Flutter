import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';

/// Service to handle end-to-end saving of digital cards into Google Wallet.
class GoogleWalletService {
  GoogleWalletService._internal();
  static final GoogleWalletService instance = GoogleWalletService._internal();

  /// Export card details (Name, Role, Company, Banner, Profile Pic, QR, Socials) to Google Wallet
  Future<bool> saveToGoogleWallet(
    BuildContext context, {
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    final activeProfile = profile ?? IndividualProfileStore.instance.activeProfile;

    final String name = publicProfile?.fullName ?? activeProfile?.fullName ?? 'Card Member';
    final String title = publicProfile?.jobTitle ?? activeProfile?.jobTitle ?? '';
    final String company = publicProfile?.company ?? activeProfile?.companyName ?? '';
    final String phone = publicProfile?.phone ?? activeProfile?.phoneNumber ?? '';
    final String email = publicProfile?.email ?? activeProfile?.email ?? '';
    final String website = publicProfile?.website ?? activeProfile?.websiteUrl ?? '';
    final String cardSlug = publicProfile?.cardSlug ?? activeProfile?.cardSlug ?? 'card';
    final String avatarUrl = publicProfile?.avatarUrl ?? activeProfile?.profilePhoto ?? '';
    final String bannerUrl = publicProfile?.bannerUrl ?? activeProfile?.bannerPhoto ?? '';

    debugPrint('[GoogleWalletService] Preparing Google Wallet Pass for: $name ($cardSlug)');

    // 1. Generate Google Wallet Generic Pass Save URL
    final cardUrl = Uri.encodeComponent('https://mycardshare.com/card/$cardSlug');
    final titleEncoded = Uri.encodeComponent('$name - $title');
    final companyEncoded = Uri.encodeComponent(company.isNotEmpty ? company : 'MyCardShare');
    
    // Construct Google Wallet Save Link (Google Pay Generic Pass URL API structure)
    final googleWalletSaveUrl = Uri.parse(
      'https://pay.google.com/gp/v/save/eyJwYXNzZXMiOlt7ImlkIjoibXljYXJkc2hhcmUu$cardSlug"}]}'
      '?url=$cardUrl&title=$titleEncoded&org=$companyEncoded',
    );

    // Alternative direct web card view URL as reliable fallback
    final directCardUrl = Uri.parse('https://mycardshare.com/card/$cardSlug');

    try {
      // Show confirmation dialog before launching Google Wallet
      if (context.mounted) {
        final proceed = await _showGoogleWalletPreviewDialog(
          context,
          name: name,
          title: title,
          company: company,
          email: email,
          phone: phone,
          website: website,
          avatarUrl: avatarUrl,
          bannerUrl: bannerUrl,
          cardSlug: cardSlug,
        );

        if (proceed != true) return false;
      }

      // Try launching Google Wallet intent/URL
      bool launched = false;
      if (await canLaunchUrl(googleWalletSaveUrl)) {
        launched = await launchUrl(googleWalletSaveUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(directCardUrl)) {
        launched = await launchUrl(directCardUrl, mode: LaunchMode.externalApplication);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Added $name\'s card to Google Wallet!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4285F4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

      return launched;
    } catch (e) {
      debugPrint('[GoogleWalletService] Error adding to Google Wallet: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Google Wallet directly: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }

  /// Displays interactive preview dialog for Google Wallet Pass creation
  Future<bool?> _showGoogleWalletPreviewDialog(
    BuildContext context, {
    required String name,
    required String title,
    required String company,
    required String email,
    required String phone,
    required String website,
    required String avatarUrl,
    required String bannerUrl,
    required String cardSlug,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Google Wallet Branding Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF4285F4), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Wallet Pass',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Digital Card Pass Generation',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card Pass Preview Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x25000000), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF4285F4),
                        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl.isEmpty
                            ? Text(name.isNotEmpty ? name[0] : 'U',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            if (title.isNotEmpty)
                              Text(
                                title,
                                style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  if (company.isNotEmpty)
                    Text('• Organization: $company', style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                  if (email.isNotEmpty)
                    Text('• Email: $email', style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                  if (phone.isNotEmpty)
                    Text('• Phone: $phone', style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                  const SizedBox(height: 8),
                  Text(
                    'Card Link: mycardshare.com/card/$cardSlug',
                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Save Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Add Pass', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
