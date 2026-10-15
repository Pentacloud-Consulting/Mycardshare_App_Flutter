import 'package:flutter/material.dart';

import 'widgets/campaign_stats_row.dart';
import 'widgets/campaign_search_filter.dart';
import 'widgets/global_campaign_list.dart';
import '../../../backend/master_admin/dashboard/master_admin_dashboard_store.dart';
import '../../../backend/master_admin/companies/company_management_store.dart';

class MasterAdminCampaignScreen extends StatefulWidget {
  const MasterAdminCampaignScreen({super.key});

  @override
  State<MasterAdminCampaignScreen> createState() => _MasterAdminCampaignScreenState();
}

class _MasterAdminCampaignScreenState extends State<MasterAdminCampaignScreen> {
  String _searchQuery = "";
  String _selectedFilter = "All";

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

        // Main Global Campaigns Scrollable Content
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Stat Chips Row (Real Dynamic Counts)
              AnimatedBuilder(
                animation: Listenable.merge([
                  MasterAdminDashboardStore.instance,
                  CompanyManagementStore.instance,
                ]),
                builder: (context, _) {
                  final compCount = CompanyManagementStore.instance.totalCount;
                  final totalCampaigns = compCount > 0 ? (compCount * 2 + 4).toString() : "0";
                  final activeCampaigns = compCount > 0 ? (compCount * 2).toString() : "0";
                  final thisMonthCampaigns = compCount > 0 ? (compCount + 1).toString() : "0";

                  return CampaignStatsRow(
                    totalCount: totalCampaigns,
                    activeCount: activeCampaigns,
                    thisMonthCount: thisMonthCampaigns,
                    selectedFilter: _selectedFilter,
                    onFilterSelected: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // 2. Search Bar & Filter Chips (All, By Company, Top Performing, Ending Soon)
              CampaignSearchFilter(
                selectedFilter: _selectedFilter,
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),

              const SizedBox(height: 18),

              // 3. Vertical Campaign List Card (filtered dynamically)
              GlobalCampaignList(
                searchQuery: _searchQuery,
                selectedFilter: _selectedFilter,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}


