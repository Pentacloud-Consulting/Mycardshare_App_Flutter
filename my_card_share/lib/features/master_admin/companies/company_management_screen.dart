import 'package:flutter/material.dart';

import 'widgets/company_stats_row.dart';
import 'widgets/company_search_filter_bar.dart';
import 'widgets/company_list_card.dart';

class MasterAdminCompanyScreen extends StatefulWidget {
  const MasterAdminCompanyScreen({super.key});

  @override
  State<MasterAdminCompanyScreen> createState() => _MasterAdminCompanyScreenState();
}

class _MasterAdminCompanyScreenState extends State<MasterAdminCompanyScreen> {
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

        // Main Company Management Content
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Stat Chips Row (Total 248, Active 231, Suspended 4)
              CompanyStatsRow(
                totalCount: 248,
                activeCount: 231,
                suspendedCount: 4,
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),

              const SizedBox(height: 16),

              // 2. Search Bar & Filter Chips (All, Active, Pending, Suspended)
              CompanySearchFilterBar(
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

              // 3. Vertical Company List Card (filtered in real-time)
              CompanyListCard(
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
