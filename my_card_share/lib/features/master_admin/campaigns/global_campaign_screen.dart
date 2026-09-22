import 'package:flutter/material.dart';

import 'widgets/campaign_stats_row.dart';
import 'widgets/campaign_search_filter.dart';
import 'widgets/global_campaign_list.dart';

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
              // 1. Stat Chips Row (Total 1,240, Active 892, This Month 156)
              CampaignStatsRow(
                totalCount: "1,240",
                activeCount: "892",
                thisMonthCount: "156",
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
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
