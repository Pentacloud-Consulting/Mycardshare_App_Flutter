import 'package:flutter/material.dart';

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
            children: const [
              // 1. Header Card (Logo, Name, Enterprise Pro badge, Active status, Since Jan 2026)
              CompanyDetailHeader(
                companyName: "Acme Realty Group",
                planName: "Enterprise Pro",
                statusText: "Active",
                sinceText: "Since Jan 2026",
                logoInitials: "AR",
              ),

              SizedBox(height: 18),

              // 2. 2x2 Stat Tiles Grid (Employees 34/50 with progress bar, Leads, Views, Plan Value)
              CompanyDetailStatsGrid(
                activeEmployees: 34,
                maxEmployees: 50,
                totalLeads: "312",
                cardViews: "8,420",
                planValue: "\$299/mo",
              ),

              SizedBox(height: 22),

              // 3. Subscription Section (Enterprise Pro, Expires: Dec 31, 2027, Extend Subscription button)
              CompanyDetailSubscriptionCard(
                planName: "Enterprise Pro",
                expiryDate: "Expires: Dec 31, 2027",
              ),

              SizedBox(height: 22),

              // 4. Admin Contact Section (Avatar, John Smith, Email/Phone, Message button)
              CompanyDetailAdminContact(
                adminName: "John Smith",
                adminEmail: "john.smith@acme.com",
                adminPhone: "+1 (555) 019-2834",
                avatarInitials: "JS",
              ),

              SizedBox(height: 24),

              // 5. Danger Zone (Suspend Company & Delete Company buttons)
              CompanyDetailDangerZone(),

              SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }
}
