import 'package:flutter/material.dart';
import '../../../../../backend/individual/wallet/wallet_service.dart';
import '../../../../../backend/individual/wallet/apple_wallet.dart';

/// Digital Wallet Section matching Web Employee Dashboard (Image 2)
class DashboardDigitalWallet extends StatelessWidget {
  const DashboardDigitalWallet({super.key});

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
                    child: Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF0052FF), size: 22),
                  ),
                ),
                onTap: () {
                  WalletService.addToGoogleWallet(context: context);
                },
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
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.apple_rounded, color: Colors.white, size: 24),
                  ),
                ),
                onTap: () {
                  AppleWalletService.instance.showAppleWalletComingSoon(context);
                },
              ),
              const SizedBox(width: 12),

              // 3. Samsung Wallet (Coming Soon)
              _buildWalletCard(
                title: "Samsung Wallet",
                subtitle: "For Galaxy Devices",
                badge: "Coming Soon",
                icon: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.credit_card_rounded, color: Colors.white, size: 22),
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Samsung Wallet pass support is coming soon!"),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
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
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 175,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                icon,
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
