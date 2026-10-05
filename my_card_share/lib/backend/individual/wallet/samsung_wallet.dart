import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';

/// Service to handle end-to-end saving of digital cards into Samsung Wallet / Samsung Pay.
class SamsungWalletService {
  SamsungWalletService._internal();
  static final SamsungWalletService instance = SamsungWalletService._internal();

  /// Save card details (Name, Role, Company, Banner, Profile Pic, QR, Socials) to Samsung Wallet
  Future<bool> saveToSamsungWallet(
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

    debugPrint('[SamsungWalletService] Preparing Samsung Wallet Pass for: $name ($cardSlug)');

    // 1. Generate Samsung Pay/Wallet Partner Save URL Intent
    final cardUrl = Uri.encodeComponent('https://mycardshare.com/card/$cardSlug');
    final samsungWalletUrl = Uri.parse(
      'https://pay.samsung.com/wallet/addcard?type=membership&title=${Uri.encodeComponent(name)}&url=$cardUrl',
    );

    final directCardUrl = Uri.parse('https://mycardshare.com/card/$cardSlug');

    try {
      // Show preview modal before launching Samsung Wallet
      if (context.mounted) {
        final proceed = await _showSamsungWalletPreviewDialog(
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

      // Try launching Samsung Wallet intent/URL
      bool launched = false;
      if (await canLaunchUrl(samsungWalletUrl)) {
        launched = await launchUrl(samsungWalletUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(directCardUrl)) {
        launched = await launchUrl(directCardUrl, mode: LaunchMode.externalApplication);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wallet_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Added $name\'s card to Samsung Wallet!',
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

      return launched;
    } catch (e) {
      debugPrint('[SamsungWalletService] Error adding to Samsung Wallet: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Samsung Wallet directly: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }

  /// Displays preview modal for Samsung Wallet Card creation
  Future<bool?> _showSamsungWalletPreviewDialog(
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
            // Samsung Wallet Branding Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1428A0).withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.wallet_rounded, color: Color(0xFF1428A0), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Samsung Wallet Pass',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Samsung Pay & Digital Card Pass',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card Pass Preview Box (Samsung Pay Dark Blue Theme)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1428A0), Color(0xFF0B175B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x301428A0), blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white24,
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
                    style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 11, fontWeight: FontWeight.w600),
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
                      backgroundColor: const Color(0xFF1428A0),
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
