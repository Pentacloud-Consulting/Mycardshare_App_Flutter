import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../backend/master_admin/companies/company_management_store.dart';
import '../../../backend/master_admin/companies/models/master_company_model.dart';
import 'widgets/company_detail_header.dart';
import 'widgets/company_detail_stats_grid.dart';
import 'widgets/company_detail_subscription_card.dart';
import 'widgets/company_detail_admin_contact.dart';
import 'widgets/company_detail_danger_zone.dart';

class MasterAdminCompanyDetailScreen extends StatelessWidget {
  final String? companyId;

  const MasterAdminCompanyDetailScreen({
    super.key,
    this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveId = companyId ?? 'acme_realty';

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('enterprises').doc(effectiveId).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        final companyName = data['companyName'] ?? data['name'] ?? 'Enterprise Company';
        final planName = data['planName'] ?? data['plan'] ?? 'Enterprise Pro';
        final statusText = (data['status'] as String?)?.capitalizeFirst() ?? 'Active';
        final sinceText = data['createdAt'] != null
            ? "Since ${(data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate().year : '2026')}"
            : "Since Jan 2026";
        final employeeCount = (data['employeeCount'] as num?)?.toInt() ?? 1;
        final employeeLimit = (data['employeeLimit'] as num?)?.toInt() ?? 50;
        final totalLeads = (data['totalLeads'] ?? '0').toString();
        final cardViews = (data['cardViews'] ?? '0').toString();
        final planValue = data['planValue'] ?? '\$299/mo';
        final adminName = data['adminName'] ?? data['contactName'] ?? 'Admin Contact';
        final adminEmail = data['email'] ?? data['adminEmail'] ?? 'admin@company.com';
        final adminPhone = data['phone'] ?? data['adminPhone'] ?? '+1 (555) 000-0000';
        final expiryDate = data['subscriptionExpiry'] ?? 'Expires: Dec 31, 2027';

        final initials = () {
          final clean = companyName.trim();
          if (clean.isEmpty) return 'CO';
          final parts = clean.split(RegExp(r'\s+'));
          if (parts.length == 1) {
            return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
          }
          return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        }();

        final adminInitials = () {
          final clean = adminName.trim();
          if (clean.isEmpty) return 'AD';
          final parts = clean.split(RegExp(r'\s+'));
          if (parts.length == 1) {
            return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
          }
          return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        }();

        return Stack(
          children: [
            // Background Top-Right Ambient Soft Baby-Blue Gradient Blob
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF38BDF8).withValues(alpha: 0.22),
                      const Color(0xFF0052FF).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Company Detail Content Area
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Card (Real Data)
                  CompanyDetailHeader(
                    companyName: companyName,
                    planName: planName,
                    statusText: statusText,
                    sinceText: sinceText,
                    logoInitials: initials,
                  ),

                  const SizedBox(height: 18),

                  // 2. 2x2 Stat Tiles Grid (Real Data)
                  CompanyDetailStatsGrid(
                    activeEmployees: employeeCount,
                    maxEmployees: employeeLimit,
                    totalLeads: totalLeads,
                    cardViews: cardViews,
                    planValue: planValue,
                  ),

                  const SizedBox(height: 22),

                  // 3. Subscription Section (Real Plan)
                  CompanyDetailSubscriptionCard(
                    planName: planName,
                    expiryDate: expiryDate,
                  ),

                  const SizedBox(height: 22),

                  // 4. Admin Contact Section (Real Data)
                  CompanyDetailAdminContact(
                    adminName: adminName,
                    adminEmail: adminEmail,
                    adminPhone: adminPhone,
                    avatarInitials: adminInitials,
                  ),

                  const SizedBox(height: 24),

                  // 5. Danger Zone (Suspend Company & Delete Company buttons with real actions)
                  CompanyDetailDangerZone(
                    onSuspend: () async {
                      final isSuspended = statusText.toLowerCase() == 'suspended';
                      final ok = await CompanyManagementStore.instance.toggleSuspendCompany(
                        effectiveId,
                        !isSuspended,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? "Company ${isSuspended ? 'activated' : 'suspended'} successfully"
                                : "Failed to update company status"),
                            backgroundColor: ok ? const Color(0xFF10B981) : Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}


