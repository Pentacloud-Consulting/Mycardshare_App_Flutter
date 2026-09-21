import 'package:flutter/material.dart';

import 'widgets/dashboard_welcome_card.dart';
import 'widgets/dashboard_stats_grid.dart';
import 'widgets/dashboard_quick_actions.dart';
import 'widgets/dashboard_top_performers.dart';

class EnterpriseDashboardScreen extends StatelessWidget {
  const EnterpriseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Top-Right Ambient Baby-Blue Gradient Blob
        Positioned(
          top: -70,
          right: -70,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF38BDF8).withValues(alpha: 0.20),
                  const Color(0xFF0052FF).withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Main Dashboard Content Area
        const SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Welcome Summary Card Section
              DashboardWelcomeCard(
                adminName: "Admin",
                activeCardsCount: 34,
              ),

              SizedBox(height: 24),

              // 2. 2x2 Grid of Stat Cards Section
              DashboardStatsGrid(
                activeEmployees: "34",
                totalCardViews: "8,420",
                totalLeads: "312",
                convRate: "5.2%",
              ),

              SizedBox(height: 24),

              // 3. Quick Actions Section
              DashboardQuickActions(),

              SizedBox(height: 24),

              // 4. Top Performers Section
              DashboardTopPerformers(),

              SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
