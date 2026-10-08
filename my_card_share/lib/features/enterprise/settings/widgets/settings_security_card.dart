import 'package:flutter/material.dart';
import 'settings_sso_integration.dart';
import 'settings_api_access.dart';
import 'settings_admin_roles.dart';

class SettingsSecurityCard extends StatefulWidget {
  final VoidCallback? onApiAccessTap;
  final VoidCallback? onAdminRolesTap;

  const SettingsSecurityCard({
    super.key,
    this.onApiAccessTap,
    this.onAdminRolesTap,
  });

  @override
  State<SettingsSecurityCard> createState() => _SettingsSecurityCardState();
}

class _SettingsSecurityCardState extends State<SettingsSecurityCard> {
  final bool _ssoEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SECURITY",
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
              // Row 1: SSO Integration (Opens coming soon modal on tap or toggle)
              InkWell(
                onTap: () => showSsoComingSoonPopup(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF059669),
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "SSO Integration",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Switch(
                        value: _ssoEnabled,
                        activeThumbColor: const Color(0xFF0052FF),
                        activeTrackColor: const Color(0xFFDBEAFE),
                        onChanged: (val) {
                          showSsoComingSoonPopup(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Row 2: API Access (Opens coming soon modal)
              InkWell(
                onTap: widget.onApiAccessTap ?? () => showApiAccessComingSoonPopup(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                        child: const Icon(Icons.key_rounded, color: Color(0xFF7C3AED), size: 17),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "API Access",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Row 3: Admin Roles (Streamed real admin count & management page)
              SettingsAdminRolesRow(
                onTap: widget.onAdminRolesTap ?? () => showAdminRolesPage(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
