import 'package:flutter/material.dart';
import '../../../backend/master_admin/dashboard/master_admin_dashboard_store.dart';
import 'widgets/dashboard_summary_card.dart';
import 'widgets/dashboard_stats_grid.dart';
import 'widgets/dashboard_quick_actions.dart';
import 'widgets/dashboard_revenue_trend.dart';
import 'widgets/dashboard_recent_signups.dart';


class MasterAdminDashboardScreen extends StatefulWidget {
  const MasterAdminDashboardScreen({super.key});

  @override
  State<MasterAdminDashboardScreen> createState() => _MasterAdminDashboardScreenState();
}

class _MasterAdminDashboardScreenState extends State<MasterAdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    MasterAdminDashboardStore.instance.fetchDashboardMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MasterAdminDashboardStore.instance,
      builder: (context, _) {
        final store = MasterAdminDashboardStore.instance;

        return RefreshIndicator(
          onRefresh: () => store.fetchDashboardMetrics(),
          child: Stack(
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
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Summary Card Section with Live Counts
                    DashboardSummaryCard(
                      companyCount: store.totalCompanies.toString(),
                      userCount: store.totalIndividuals.toString(),
                    ),

                    const SizedBox(height: 20),

                    // 2. 2x2 Grid of Stat Cards Section
                    DashboardStatsGrid(
                      totalCompanies: store.totalCompanies.toString(),
                      totalIndividuals: store.totalIndividuals.toString(),
                      totalLeads: store.totalLeads.toString(),
                      pendingApprovals: store.pendingApprovals.toString(),
                    ),

                    const SizedBox(height: 24),

                    // 3. Quick Actions Section
                    const DashboardQuickActions(),

                    const SizedBox(height: 24),

                    // 4. Revenue Trend Section
                    const DashboardRevenueTrend(),

                    const SizedBox(height: 24),

                    // 5. Recent Company Signups Section (Live Firestore Stream)
                    const DashboardRecentSignups(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



