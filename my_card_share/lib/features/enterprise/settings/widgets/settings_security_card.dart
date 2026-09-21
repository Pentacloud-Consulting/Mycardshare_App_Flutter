import 'package:flutter/material.dart';

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
  bool _ssoEnabled = false;

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
              // Row 1: SSO Integration with Toggle Switch (OFF/gray by default)
              Padding(
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
                        setState(() {
                          _ssoEnabled = val;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val
                                ? "SSO Authentication Enabled"
                                : "SSO Authentication Disabled"),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Row 2: API Access
              _buildSettingRow(
                icon: Icons.key_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconBg: const Color(0xFFF3E8FF),
                title: "API Access",
                onTap: widget.onApiAccessTap,
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Row 3: Admin Roles
              _buildSettingRow(
                icon: Icons.admin_panel_settings_rounded,
                iconColor: const Color(0xFF0052FF),
                iconBg: const Color(0xFFEFF4FF),
                title: "Admin Roles",
                onTap: widget.onAdminRolesTap,
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
