import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardQuickActions extends StatelessWidget {
  final VoidCallback? onScanCardTap;
  final VoidCallback? onVoiceAddTap;
  final VoidCallback? onAnalyticsTap;
  final VoidCallback? onVaultTap;

  const DashboardQuickActions({
    super.key,
    this.onScanCardTap,
    this.onVoiceAddTap,
    this.onAnalyticsTap,
    this.onVaultTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.camera_alt_rounded,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF0284C7),
                title: "Scan Card",
                subtitle: "Scan a QR or NFC card",
                onTap: onScanCardTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Opening Scanner...")),
                      );
                    },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                icon: Icons.mic_rounded,
                iconBg: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF9333EA),
                title: "Voice Add",
                subtitle: "Add contact by voice",
                onTap: onVoiceAddTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Listening for voice contact...")),
                      );
                    },
              ),
            ),
          ],
        ),
        const SizedBox(width: 12, height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.bar_chart_rounded,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF059669),
                title: "Analytics",
                subtitle: "View detailed insights",
                onTap: onAnalyticsTap ?? () => context.go('/portal/analytics'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                icon: Icons.people_alt_rounded,
                iconBg: const Color(0xFFFFF7ED),
                iconColor: const Color(0xFFEA580C),
                title: "Contact Vault",
                subtitle: "Manage your contacts",
                onTap: onVaultTap ?? () => context.go('/portal/vault'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
