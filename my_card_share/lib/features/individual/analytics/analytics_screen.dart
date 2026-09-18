import 'package:flutter/material.dart';
import 'widgets/analytics_campaigns_tab.dart';
import 'widgets/analytics_daily_chart.dart';
import 'widgets/analytics_filter_bar.dart';
import 'widgets/analytics_leads_tab.dart';
import 'widgets/analytics_metrics_grid.dart';
import 'widgets/analytics_traffic_sources.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTab = 'overview'; // 'overview', 'leads', 'campaigns'
  String _dateRange = 'Last 30 Days';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Bar (Time Range dropdown + Segmented Pills: Overview | Leads | Campaigns)
              AnalyticsFilterBar(
                selectedTab: _selectedTab,
                dateRange: _dateRange,
                onTabChanged: (tab) => setState(() => _selectedTab = tab),
                onDateRangeChanged: (range) => setState(() => _dateRange = range),
              ),

              const SizedBox(height: 18),

              // Tab Views
              if (_selectedTab == 'overview') ...[
                // 2x2 Metrics Grid (Total Views, QR Scans, Leads Captured, Conv. Rate)
                AnalyticsMetricsGrid(dateRange: _dateRange),
                const SizedBox(height: 18),

                // Views & Leads — Daily Dual Bar Chart
                const AnalyticsDailyChart(),
                const SizedBox(height: 18),

                // Traffic Sources breakdown progress bars
                const AnalyticsTrafficSources(),
                const SizedBox(height: 24),
              ] else if (_selectedTab == 'leads') ...[
                AnalyticsMetricsGrid(dateRange: _dateRange),
                const SizedBox(height: 18),
                const AnalyticsLeadsTab(),
                const SizedBox(height: 24),
              ] else if (_selectedTab == 'campaigns') ...[
                AnalyticsMetricsGrid(dateRange: _dateRange),
                const SizedBox(height: 18),
                const AnalyticsCampaignsTab(),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
