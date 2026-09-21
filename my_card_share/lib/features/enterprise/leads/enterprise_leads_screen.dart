import 'package:flutter/material.dart';

import 'widgets/leads_stats_row.dart';
import 'widgets/leads_search_filter.dart';
import 'widgets/leads_filter_chips.dart';
import 'widgets/leads_list_cards.dart';
import 'widgets/retry_sync_button.dart';

class EnterpriseLeadsScreen extends StatefulWidget {
  const EnterpriseLeadsScreen({super.key});

  @override
  State<EnterpriseLeadsScreen> createState() => _EnterpriseLeadsScreenState();
}

class _EnterpriseLeadsScreenState extends State<EnterpriseLeadsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleRetrySync([Map<String, dynamic>? lead]) {
    final leadName = lead != null ? lead["name"] : "failed CRM leads";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Retrying CRM sync for $leadName..."),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleLeadTap(Map<String, dynamic> lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lead["name"] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: lead["status"] == "Synced"
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lead["status"] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: lead["status"] == "Synced"
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Company: ${lead["company"]}",
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Text(
                "Captured by ${lead["capturedBy"]} on ${lead["date"]}",
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleRetrySync(lead);
                  },
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  label: const Text("Push to Enterprise CRM"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 4),
        child: RetrySyncButton(
          onTap: () => _handleRetrySync(),
        ),
      ),
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

          // Main Screen Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Stat Chips Row (Total 312, This Week 28, Sync Failed 2)
                  const LeadsStatsRow(
                    totalCount: 312,
                    thisWeekCount: 28,
                    syncFailedCount: 2,
                  ),

                  const SizedBox(height: 16),

                  // 2. Search Bar + Calendar Date Filter
                  LeadsSearchFilter(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    onCalendarTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Date range filter opened"),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // 3. Horizontal Scrollable Filter Chips (All, By Employee, New, CRM Synced, Failed)
                  LeadsFilterChips(
                    selectedFilter: _selectedFilter,
                    onSelected: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // 4. Enterprise Lead Cards List (with Captured By Attribution)
                  LeadsListCards(
                    searchQuery: _searchQuery,
                    selectedFilter: _selectedFilter,
                    onLeadTap: _handleLeadTap,
                    onRetrySync: _handleRetrySync,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
