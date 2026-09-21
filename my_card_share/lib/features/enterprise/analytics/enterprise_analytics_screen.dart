import 'package:flutter/material.dart';

import 'widgets/analytics_tab_chips.dart';
import 'widgets/analytics_stats_grid.dart';
import 'widgets/analytics_views_chart.dart';
import 'widgets/analytics_employee_leaderboard.dart';
import 'widgets/analytics_template_performance.dart';

class EnterpriseAnalyticsScreen extends StatefulWidget {
  const EnterpriseAnalyticsScreen({super.key});

  @override
  State<EnterpriseAnalyticsScreen> createState() => _EnterpriseAnalyticsScreenState();
}

class _EnterpriseAnalyticsScreenState extends State<EnterpriseAnalyticsScreen> {
  String _selectedTab = "Overview";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Stack(
        children: [
          // Top-Right Soft Baby-Blue Gradient Blob
          Positioned(
            top: -60,
            right: -60,
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

          // Main Scrollable Content Area
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tab Chips Row (Overview, Employees, Geography)
                  AnalyticsTabChips(
                    selectedTab: _selectedTab,
                    onSelected: (tab) {
                      setState(() {
                        _selectedTab = tab;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // 2. 2x2 Grid of Stat Cards (Total Views, QR Scans, Leads Captured, Avg Conv. Rate)
                  const AnalyticsStatsGrid(
                    totalViews: "8,420",
                    qrScans: "2,140",
                    leadsCaptured: "312",
                    avgConvRate: "5.2%",
                  ),

                  const SizedBox(height: 16),

                  // 3. Daily Company Views Bar Chart Card
                  const AnalyticsViewsChart(),

                  const SizedBox(height: 16),

                  // 4. Employee Leaderboard Card with Relative Performance Bars
                  const AnalyticsEmployeeLeaderboard(),

                  const SizedBox(height: 16),

                  // 5. Template Performance Horizontal Progress Bars
                  const AnalyticsTemplatePerformance(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
