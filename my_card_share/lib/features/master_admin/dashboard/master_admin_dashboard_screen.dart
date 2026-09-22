import 'package:flutter/material.dart';

import 'widgets/dashboard_summary_card.dart';
import 'widgets/dashboard_stats_grid.dart';
import 'widgets/dashboard_quick_actions.dart';
import 'widgets/dashboard_revenue_trend.dart';
import 'widgets/dashboard_recent_signups.dart';

class MasterAdminDashboardScreen extends StatelessWidget {
  const MasterAdminDashboardScreen({super.key});

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

        // Main Dashboard Scrollable Content Area
        const SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Summary Card Section
              DashboardSummaryCard(
                companyCount: "248",
                userCount: "12,847",
              ),

              SizedBox(height: 20),

              // 2. 2x2 Grid of Stat Cards Section
              DashboardStatsGrid(
                totalCompanies: "248",
                totalIndividuals: "12,847",
                totalLeads: "18,204",
                pendingApprovals: "6",
              ),

              SizedBox(height: 24),

              // 3. Quick Actions Section
              DashboardQuickActions(),

              SizedBox(height: 24),

              // 4. Revenue Trend Section
              DashboardRevenueTrend(),

              SizedBox(height: 24),

              // 5. Recent Company Signups Section
              DashboardRecentSignups(),

              SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
