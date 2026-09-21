import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/settings_company_summary.dart';
import 'widgets/settings_workspace_card.dart';
import 'widgets/settings_billing_card.dart';
import 'widgets/settings_security_card.dart';
import 'widgets/settings_support_card.dart';
import 'widgets/settings_deactivate_button.dart';

class EnterpriseSettingsScreen extends StatefulWidget {
  const EnterpriseSettingsScreen({super.key});

  @override
  State<EnterpriseSettingsScreen> createState() => _EnterpriseSettingsScreenState();
}

class _EnterpriseSettingsScreenState extends State<EnterpriseSettingsScreen> {
  void _showNotice(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _confirmDeactivateWorkspace() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Deactivate Workspace?"),
        content: const Text(
          "Are you sure you want to deactivate Acme Realty Group workspace? All 34 employee cards and team access will be paused.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showNotice("Workspace deactivation request submitted.");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text("Deactivate"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Stack(
        children: [
          // Top-Left Soft Baby-Blue Gradient Blob
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.18),
                    const Color(0xFF0052FF).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Settings Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Small Company Summary Row Card
                  SettingsCompanySummary(
                    companyName: "Acme Realty Group",
                    employeesText: "34 employees · Enterprise Pro",
                    onEditTap: () => context.push('/enterprise/brand-profile'),
                  ),

                  const SizedBox(height: 20),

                  // 2. Workspace Grouped List Card
                  SettingsWorkspaceCard(
                    onCompanyProfileTap: () => context.push('/enterprise/brand-profile'),
                    onCustomDomainTap: () => _showNotice("Custom Domain Setup"),
                    onEmployeeLimitTap: () => _showNotice("Employee Limit & Upgrades"),
                  ),

                  const SizedBox(height: 20),

                  // 3. Billing Grouped List Card
                  SettingsBillingCard(
                    onSubscriptionPlanTap: () => _showNotice("Subscription Plan Details"),
                    onBillingHistoryTap: () => _showNotice("Invoices & Billing History"),
                    onPaymentMethodTap: () => _showNotice("Manage Payment Method"),
                  ),

                  const SizedBox(height: 20),

                  // 4. Security Grouped List Card
                  SettingsSecurityCard(
                    onApiAccessTap: () => _showNotice("API Keys & Webhooks Access"),
                    onAdminRolesTap: () => _showNotice("Admin Roles & Permissions"),
                  ),

                  const SizedBox(height: 20),

                  // 5. Support Grouped List Card
                  SettingsSupportCard(
                    onHelpSupportTap: () => _showNotice("Opening Help & Support Center..."),
                    onAccountManagerTap: () => _showNotice("Connecting with Account Manager..."),
                  ),

                  const SizedBox(height: 28),

                  // 6. Full-Width Outlined Deactivate Workspace Button
                  SettingsDeactivateButton(
                    onTap: _confirmDeactivateWorkspace,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
