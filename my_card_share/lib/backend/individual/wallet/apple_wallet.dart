import 'package:flutter/material.dart';

/// Service for Apple Wallet pass management and Coming Soon modal preview.
class AppleWalletService {
  AppleWalletService._internal();
  static final AppleWalletService instance = AppleWalletService._internal();

  /// Displays high-end "Apple Wallet Integration - Coming Soon" iOS modal dialog
  Future<void> showAppleWalletComingSoon(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Apple Wallet Badge Header
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF3A3A3C), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Color(0x60000000), blurRadius: 16, offset: Offset(0, 6)),
                ],
              ),
              child: const Icon(Icons.apple_rounded, color: Colors.white, size: 36),
            ),

            const SizedBox(height: 18),

            const Text(
              'Apple Wallet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500).withAlpha(40),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF9500).withAlpha(100)),
              ),
              child: const Text(
                'COMING SOON FOR iOS',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF9500),
                  letterSpacing: 0.8,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Native Apple Wallet (.pkpass) integration is coming in the next update. You can currently add your digital business card to Google Wallet and Samsung Wallet!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFFA1A1AA),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text(
                  'Got It',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
