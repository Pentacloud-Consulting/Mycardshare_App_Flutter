import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class EnterpriseProfileMenuHub extends StatelessWidget {
  const EnterpriseProfileMenuHub({super.key});

  void _copyInviteLink(BuildContext context) {
    Clipboard.setData(
      const ClipboardData(text: "https://mycardshare.com/join-workspace?code=ACME-2026-XYZ"),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Workspace invite link copied to clipboard!"),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ENTERPRISE MANAGEMENT HUB",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),

        // Enterprise Analytics
        _buildMenuItem(
          context: context,
          icon: Icons.bar_chart_rounded,
          iconColor: const Color(0xFF7C3AED),
          bgColor: const Color(0xFFF3E8FF),
          title: "Enterprise Analytics",
          subtitle: "View company-wide card performance & conversion metrics",
          onTap: () => context.push('/enterprise/analytics'),
        ),
        const SizedBox(height: 10),

        // CRM Connectors
        _buildMenuItem(
          context: context,
          icon: Icons.extension_outlined,
          iconColor: const Color(0xFF0D9488),
          bgColor: const Color(0xFFCCFBF1),
          title: "CRM Connectors",
          subtitle: "Sync leads automatically with Salesforce, HubSpot & Zoho",
          onTap: () => context.push('/enterprise/connectors'),
        ),
        const SizedBox(height: 10),

        // Enterprise Settings & Billing
        _buildMenuItem(
          context: context,
          icon: Icons.tune_rounded,
          iconColor: const Color(0xFF0052FF),
          bgColor: const Color(0xFFEFF4FF),
          title: "Settings & Billing",
          subtitle: "Manage Enterprise Pro plan, workspace domain & security",
          onTap: () => context.push('/enterprise/settings'),
        ),

        const SizedBox(height: 24),

        const Text(
          "TEAM & WORKSPACE ACCESS",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),

        // Reusable Workspace Invite Link
        _buildMenuItem(
          context: context,
          icon: Icons.link_rounded,
          iconColor: const Color(0xFFD97706),
          bgColor: const Color(0xFFFEF3C7),
          title: "Copy Workspace Invite Link",
          subtitle: "Share join link with new employees to onboard instantly",
          onTap: () => _copyInviteLink(context),
        ),
        const SizedBox(height: 10),

        // Security & Domain Verification
        _buildMenuItem(
          context: context,
          icon: Icons.verified_user_outlined,
          iconColor: const Color(0xFF059669),
          bgColor: const Color(0xFFECFDF5),
          title: "Security & Access Control",
          subtitle: "Enforce SSO authentication and domain lock policies",
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Enterprise SSO & Domain Lock is active"),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        ),
        const SizedBox(height: 10),

        // Log Out
        _buildMenuItem(
          context: context,
          icon: Icons.logout_rounded,
          iconColor: const Color(0xFFEF4444),
          bgColor: const Color(0xFFFEE2E2),
          title: "Log Out of Enterprise",
          subtitle: "Sign out of Admin Session",
          onTap: () => context.go('/login'),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
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
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
