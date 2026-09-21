import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionChip(
                icon: Icons.person_add_outlined,
                label: "Invite Employee",
                bgColor: const Color(0xFFEFF4FF),
                borderColor: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF0052FF),
                onTap: () => context.go('/enterprise-onboarding'),
              ),
              const SizedBox(width: 10),
              _buildActionChip(
                icon: Icons.campaign_outlined,
                label: "New Campaign",
                bgColor: const Color(0xFFF3E8FF),
                borderColor: const Color(0xFFE9D5FF),
                iconColor: const Color(0xFF7C3AED),
                onTap: () => context.go('/enterprise/campaign'),
              ),
              const SizedBox(width: 10),
              _buildActionChip(
                icon: Icons.extension_outlined,
                label: "Connect CRM",
                bgColor: const Color(0xFFCCFBF1),
                borderColor: const Color(0xFF99F6E4),
                iconColor: const Color(0xFF0D9488),
                onTap: () => context.push('/enterprise/connectors'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
