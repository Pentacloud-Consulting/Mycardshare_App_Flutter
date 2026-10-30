import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../backend/individual/wallet/apple_wallet.dart';

/// ═══════════════════════════════════════════════════════════════
/// iOS Wallet Service
///
/// Platform behaviour:
///   iOS   → Apple Wallet (Coming Soon dialog) + card URL fallback
///   Android → Handled by existing Google Wallet / Samsung Wallet
///
/// Apple Wallet (.pkpass) requires:
///   1. Apple Developer Pass Type ID certificate
///   2. Backend to sign & generate .pkpass file
///   → Currently shows "Coming Soon" dialog until backend is ready.
/// ═══════════════════════════════════════════════════════════════
class IOSWalletService {
  IOSWalletService._internal();
  static final IOSWalletService instance = IOSWalletService._internal();

  /// Call this from any Wallet button on iOS.
  /// Shows "Coming Soon" dialog with Apple branding.
  Future<void> handleAddToWallet({
    required BuildContext context,
    String? cardSlug,
  }) async {
    if (kIsWeb || !Platform.isIOS) {
      debugPrint('[IOSWalletService] Not iOS — should use Android wallet instead.');
      return;
    }

    // Apple Wallet is Coming Soon — show the styled dialog
    await AppleWalletService.instance.showAppleWalletComingSoon(context);
  }

  /// Fallback: opens the card URL in Safari if Apple Wallet not available.
  static Future<void> openCardInSafari(String cardSlug) async {
    final url = 'https://digitalbusinesscloudcard.com/card/$cardSlug';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

/// ═══════════════════════════════════════════════════════════════
/// iOS Wallet Button Widget — Renders Apple Wallet button on iOS,
/// completely invisible on Android (zero pixels, no build cost).
/// ═══════════════════════════════════════════════════════════════
class IOSAppleWalletButton extends StatelessWidget {
  final String? cardSlug;
  final VoidCallback? onTap;

  const IOSAppleWalletButton({
    super.key,
    this.cardSlug,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ONLY render on iOS — Android sees nothing
    if (kIsWeb || !Platform.isIOS) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap ??
          () => IOSWalletService.instance.handleAddToWallet(
                context: context,
                cardSlug: cardSlug,
              ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apple_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add to',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
                const Text(
                  'Apple Wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500).withAlpha(50),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF9500).withAlpha(120)),
              ),
              child: const Text(
                'SOON',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF9500),
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
