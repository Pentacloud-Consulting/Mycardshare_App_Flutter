import 'package:flutter/material.dart';
import '../../../../backend/individual/wallet/wallet_service.dart';
import '../../../../backend/individual/wallet/apple_wallet.dart';

/// Digital Wallet Section for Individual Home Dashboard
/// Matches Web IndividualDashboard.jsx wallet section (Apple, Google, Samsung tiles)
class IndividualDashboardDigitalWallet extends StatelessWidget {
  const IndividualDashboardDigitalWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.wallet_rounded, size: 18, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text(
              "Digital Wallet",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // 1. Google Wallet
              _buildWalletCard(
                title: "Google Wallet",
                subtitle: "Add to Android",
                icon: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.account_balance_wallet_rounded,
                        color: Color(0xFF0052FF), size: 22),
                  ),
                ),
                onTap: () => WalletService.addToGoogleWallet(context: context),
              ),
              const SizedBox(width: 12),

              // 2. Apple Wallet
              _buildWalletCard(
                title: "Apple Wallet",
                subtitle: "Add to iOS",
                icon: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.apple_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
                onTap: () =>
                    AppleWalletService.instance.showAppleWalletComingSoon(context),
              ),
              const SizedBox(width: 12),

              // 3. Samsung Wallet
              _buildWalletCard(
                title: "Samsung Wallet",
                subtitle: "Add to Galaxy",
                icon: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1428A0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.phone_android_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
                onTap: () =>
                    WalletService.addToSamsungWallet(context: context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard({
    required String title,
    required String subtitle,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
