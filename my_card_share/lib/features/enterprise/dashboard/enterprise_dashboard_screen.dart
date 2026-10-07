import 'package:flutter/material.dart';

import '../../../backend/enterprise/home_backend/overall.dart';
import '../../../backend/enterprise/home_backend/top_performance.dart';
import 'widgets/dashboard_quick_actions.dart';

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
              // 1. Welcome Summary Card Section (Image 2)
              EnterpriseWelcomeCardBackend(),

              SizedBox(height: 24),

              // 2. 2x2 Grid of Stat Cards Section (Image 2)
              EnterpriseStatsGridBackend(),

              SizedBox(height: 24),

              // 3. Quick Actions Section
              DashboardQuickActions(),

              SizedBox(height: 24),

              // 4. Top Performers Section (Image 3)
              EnterpriseTopPerformersBackend(),

              SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}


