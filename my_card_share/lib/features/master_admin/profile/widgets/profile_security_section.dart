import 'package:flutter/material.dart';

class ProfileSecuritySection extends StatefulWidget {
  final VoidCallback? onChangePasswordTap;
  final ValueChanged<bool>? onTwoFactorChanged;
  final VoidCallback? onActiveSessionsTap;
  final bool isTwoFactorEnabled;

  const ProfileSecuritySection({
    super.key,
    this.onChangePasswordTap,
    this.onTwoFactorChanged,
    this.onActiveSessionsTap,
    this.isTwoFactorEnabled = true,
  });

  @override
  State<ProfileSecuritySection> createState() => _ProfileSecuritySectionState();
}

class _ProfileSecuritySectionState extends State<ProfileSecuritySection> {
  late bool _twoFactorOn;

  @override
  void initState() {
    super.initState();
    _twoFactorOn = widget.isTwoFactorEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        const Text(
          "Security",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
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
              // Row 1: Change Password
              InkWell(
                onTap: widget.onChangePasswordTap,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF0F172A),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Row 2: Two-Factor Authentication
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF2563EB),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Two-Factor Authentication",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Switch(
                      value: _twoFactorOn,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF22C55E), // Green toggle
                      onChanged: (val) {
                        setState(() {
                          _twoFactorOn = val;
                        });
                        widget.onTwoFactorChanged?.call(val);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Row 3: Active Sessions
              InkWell(
                onTap: widget.onActiveSessionsTap,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFFD97706),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Active Sessions",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const Text(
                        "3 devices",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
