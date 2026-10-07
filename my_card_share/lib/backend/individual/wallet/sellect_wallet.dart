import 'package:flutter/material.dart';
import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';
import 'google_wallet.dart';
import 'samsung_wallet.dart';
import 'apple_wallet.dart';

/// Modal dialog / bottom sheet component to select target mobile wallet app
class SelectWalletModal extends StatelessWidget {
  final IndividualProfileData? profile;
  final PublicProfileData? publicProfile;

  const SelectWalletModal({
    super.key,
    this.profile,
    this.publicProfile,
  });

  /// Displays interactive wallet selection modal popup
  static Future<void> show(
    BuildContext context, {
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SelectWalletModal(
        profile: profile,
        publicProfile: publicProfile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Header Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF0052FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add to Mobile Wallet',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Select your preferred wallet app to save your card',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Option 1: Google Wallet
          _WalletOptionTile(
            title: 'Google Wallet',
            subtitle: 'Save pass to Android Google Wallet app',
            icon: Icons.account_balance_wallet_rounded,
            brandColor: const Color(0xFF4285F4),
            badgeText: 'RECOMMENDED',
            badgeColor: const Color(0xFF4285F4),
            onTap: () async {
              Navigator.of(context).pop();
              await GoogleWalletService.instance.saveToGoogleWallet(
                context,
                profile: profile,
                publicProfile: publicProfile,
              );
            },
          ),

          const SizedBox(height: 12),

          // Option 2: Samsung Wallet
          _WalletOptionTile(
            title: 'Samsung Wallet',
            subtitle: 'Save pass to Samsung Pay & Wallet',
            icon: Icons.wallet_rounded,
            brandColor: const Color(0xFF1428A0),
            badgeText: 'POPULAR',
            badgeColor: const Color(0xFF1428A0),
            onTap: () async {
              Navigator.of(context).pop();
              await SamsungWalletService.instance.saveToSamsungWallet(
                context,
                profile: profile,
                publicProfile: publicProfile,
              );
            },
          ),

          const SizedBox(height: 12),

          // Option 3: Apple Wallet
          _WalletOptionTile(
            title: 'Apple Wallet',
            subtitle: 'Save PKPass to iOS Apple Wallet',
            icon: Icons.apple_rounded,
            brandColor: const Color(0xFF000000),
            badgeText: 'COMING SOON',
            badgeColor: const Color(0xFFFF9500),
            onTap: () {
              Navigator.of(context).pop();
              AppleWalletService.instance.showAppleWalletComingSoon(context);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _WalletOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color brandColor;
  final String badgeText;
  final Color badgeColor;
  final VoidCallback onTap;

  const _WalletOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.brandColor,
    required this.badgeText,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: brandColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: brandColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF94A3B8),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


