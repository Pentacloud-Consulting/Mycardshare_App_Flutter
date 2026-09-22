import 'package:flutter/material.dart';

import 'widgets/analytics_tabs_header.dart';
import 'widgets/analytics_stats_grid.dart';
import 'widgets/analytics_growth_chart.dart';
import 'widgets/analytics_ai_engine_split.dart';
import 'widgets/analytics_top_companies.dart';

class MasterAdminAnalyticsScreen extends StatefulWidget {
  const MasterAdminAnalyticsScreen({super.key});

  @override
  State<MasterAdminAnalyticsScreen> createState() => _MasterAdminAnalyticsScreenState();
}

class _MasterAdminAnalyticsScreenState extends State<MasterAdminAnalyticsScreen> {
  String _activeTab = "Overview";

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

        // Main Platform Analytics Content
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Horizontal Scrollable Tab Pills (Overview, AI Usage, Storage)
              AnalyticsTabsHeader(
                activeTab: _activeTab,
                onTabSelected: (tab) {
                  setState(() {
                    _activeTab = tab;
                  });
                },
              ),

              const SizedBox(height: 18),

              // 2. 2x2 Grid of Stat Cards
              AnalyticsStatsGrid(activeTab: _activeTab),

              const SizedBox(height: 20),

              // 3. Platform Growth — Daily Signups Smooth Line Chart Card
              AnalyticsGrowthChart(activeTab: _activeTab),

              const SizedBox(height: 20),

              // 4. AI Engine Usage Split Progress Bars Card
              const AnalyticsAiEngineSplit(),

              const SizedBox(height: 20),

              // 5. Top Companies by Activity Ranked List Card
              const AnalyticsTopCompanies(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
