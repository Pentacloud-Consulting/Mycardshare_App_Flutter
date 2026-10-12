import 'package:flutter/material.dart';
import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';
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
    final String name = publicProfile?.fullName ?? activeProfile?.fullName ?? 'Card Member';
    final String title = publicProfile?.jobTitle ?? activeProfile?.jobTitle ?? '';
    final String company = publicProfile?.company ?? activeProfile?.companyName ?? '';
    final String email = publicProfile?.email ?? activeProfile?.email ?? '';
    final String phone = publicProfile?.phone ?? activeProfile?.phoneNumber ?? '';
    final String cardSlug = publicProfile?.cardSlug ?? activeProfile?.cardSlug ?? '';
    final String avatarUrl = publicProfile?.avatarUrl ?? activeProfile?.profilePhoto ?? '';
    final String bannerUrl = publicProfile?.bannerUrl ?? activeProfile?.bannerPhoto ?? '';

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
      await WalletService.addToSamsungWallet(
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
                    'Samsung Wallet pass opened for $name!',
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
      return true;
    } catch (e) {
      debugPrint('[SamsungWalletService] Error: $e');
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
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
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
                  child: const Icon(Icons.wallet_rounded,
                      color: Color(0xFF1428A0), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Samsung Wallet',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                      Text('Save your digital business card',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card Preview (Samsung blue theme)
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
                        radius: 22,
                        backgroundColor: Colors.white24,
                        backgroundImage:
                            avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl.isEmpty
                            ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            if (title.isNotEmpty)
                              Text(title,
                                  style: const TextStyle(
                                      color: Color(0xFF93C5FD),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  if (company.isNotEmpty)
                    Text('• $company',
                        style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                  if (email.isNotEmpty)
                    Text('• $email',
                        style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                  if (phone.isNotEmpty)
                    Text('• $phone',
                        style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                  const SizedBox(height: 8),
                  Text(
                    'mycardshare.com/card/$cardSlug',
                    style: const TextStyle(
                        color: Color(0xFF93C5FD),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
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
                  Icon(Icons.info_outline_rounded, color: Color(0xFF4338CA), size: 15),
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

            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.wallet_rounded, size: 18),
                    label: const Text('Add to Samsung Wallet',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1428A0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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
