import 'package:flutter/material.dart';

class SettingsWorkspaceCard extends StatelessWidget {
  final VoidCallback? onCompanyProfileTap;
  final VoidCallback? onCustomDomainTap;
  final VoidCallback? onEmployeeLimitTap;

  const SettingsWorkspaceCard({
    super.key,
    this.onCompanyProfileTap,
    this.onCustomDomainTap,
    this.onEmployeeLimitTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "WORKSPACE",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingRow(
                icon: Icons.domain_rounded,
                iconColor: const Color(0xFF0052FF),
                iconBg: const Color(0xFFEFF4FF),
                title: "Company Profile",
                onTap: onCompanyProfileTap,
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSettingRow(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconBg: const Color(0xFFF3E8FF),
                title: "Custom Domain",
                trailingText: "Not set",
                onTap: onCustomDomainTap,
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSettingRow(
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFF0D9488),
                iconBg: const Color(0xFFCCFBF1),
                title: "Employee Limit",
                trailingText: "34 / 50 used",
                onTap: onEmployeeLimitTap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 6),
            ],
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
