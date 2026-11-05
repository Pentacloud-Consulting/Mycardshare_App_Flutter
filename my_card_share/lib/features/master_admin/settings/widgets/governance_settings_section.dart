import 'package:flutter/material.dart';
import '../../../../backend/master_admin/settings/platform_settings_store.dart';

class GovernanceSettingsSection extends StatelessWidget {
  const GovernanceSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PlatformSettingsStore.instance;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Row(
            children: [
              Icon(Icons.shield_outlined, size: 20, color: Color(0xFF0052FF)),
              SizedBox(width: 8),
              Text(
                "Governance & Notifications",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Platform Name & Support Email
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Platform Name",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.platformName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Support Email",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.supportEmail,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

          // 1. Self Registration Toggle
          _buildToggleRow(
            title: "Allow Self-Registration Globally",
            subtitle: "Permits new companies and individuals to register self-serve",
            value: store.allowSelfRegistration,
            onChanged: (val) {
              store.updateGovernance(allowSelfRegistration: val);
            },
          ),
          const Divider(height: 16, thickness: 1, color: Color(0xFFF1F5F9)),

          // 2. Email Verification Toggle
          _buildToggleRow(
            title: "Require Email Verification on Signup",
            subtitle: "Mandates OTP / verification link before workspace activation",
            value: store.requireEmailVerification,
            onChanged: (val) {
              store.updateGovernance(requireEmailVerification: val);
            },
          ),
          const Divider(height: 16, thickness: 1, color: Color(0xFFF1F5F9)),

          // 3. New Enterprise Notification
          _buildToggleRow(
            title: "Email Admin on New Enterprise",
            subtitle: "Receive alert when a new company registers and awaits review",
            value: store.notifyNewEnterprise,
            onChanged: (val) {
              store.updateGovernance(notifyNewEnterprise: val);
            },
          ),
          const Divider(height: 16, thickness: 1, color: Color(0xFFF1F5F9)),

          // 4. New Lead Notification
          _buildToggleRow(
            title: "Email Admin on New Lead",
            subtitle: "Receive instant email notification when a lead is captured",
            value: store.notifyNewLead,
            onChanged: (val) {
              store.updateGovernance(notifyNewLead: val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: const Color(0xFF0052FF),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
