import 'package:flutter/material.dart';

import 'widgets/lead_audit_stats_row.dart';
import 'widgets/lead_audit_search_filter.dart';
import 'widgets/lead_audit_log_list.dart';

class MasterAdminLeadsScreen extends StatefulWidget {
  const MasterAdminLeadsScreen({super.key});

  @override
  State<MasterAdminLeadsScreen> createState() => _MasterAdminLeadsScreenState();
}

class _MasterAdminLeadsScreenState extends State<MasterAdminLeadsScreen> {
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

        // Main Lead Audit Logs Scrollable Content
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Stat Chips Row (Total 18,204, Delivered 17,890, Failed 314)
              LeadAuditStatsRow(
                totalCount: "18,204",
                deliveredCount: "17,890",
                failedCount: "314",
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),

              const SizedBox(height: 16),

              // 2. Search Bar & Filter Chips (All, Delivered, Failed, Retrying)
              LeadAuditSearchFilter(
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

              // 3. Vertical Log List Card (filtered dynamically)
              LeadAuditLogList(
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
