import 'package:flutter/material.dart';

class WalletCredentialsSection extends StatelessWidget {
  final VoidCallback? onAppleWalletTap;
  final VoidCallback? onGoogleWalletTap;
  final VoidCallback? onSamsungWalletTap;

  const WalletCredentialsSection({
    super.key,
    this.onAppleWalletTap,
    this.onGoogleWalletTap,
    this.onSamsungWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        const Text(
          "DIGITAL WALLET CREDENTIALS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        // Grouped List Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Row 1: Apple Wallet
              _buildWalletRow(
                icon: Icons.apple_rounded,
                iconColor: const Color(0xFF0F172A),
                iconBgColor: const Color(0xFFF1F5F9),
                title: "Apple Wallet (PassKit)",
                onTap: onAppleWalletTap,
                isTop: true,
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Row 2: Google Wallet
              _buildWalletRow(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBgColor: const Color(0xFFEFF6FF),
                title: "Google Wallet",
                onTap: onGoogleWalletTap,
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Row 3: Samsung Wallet
              _buildWalletRow(
                icon: Icons.credit_card_rounded,
                iconColor: const Color(0xFF0F172A),
                iconBgColor: const Color(0xFFF8FAFC),
                title: "Samsung Wallet",
                onTap: onSamsungWalletTap,
                isBottom: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    VoidCallback? onTap,
    bool isTop = false,
    bool isBottom = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isTop ? const Radius.circular(16) : Radius.zero,
        bottom: isBottom ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Text(
              "Configured",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
