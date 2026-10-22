import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/leads_stats_row.dart';
import 'widgets/leads_search_filter.dart';
import 'widgets/leads_filter_chips.dart';
import 'widgets/leads_list_cards.dart';
import 'widgets/retry_sync_button.dart';
import 'widgets/edit_lead.dart';
import 'widgets/add_lead_sheet.dart';
import '../../../backend/enterprise/home_backend/leads_service.dart';

class EnterpriseLeadsScreen extends StatefulWidget {
  const EnterpriseLeadsScreen({super.key});

  @override
  State<EnterpriseLeadsScreen> createState() => _EnterpriseLeadsScreenState();
}

class _EnterpriseLeadsScreenState extends State<EnterpriseLeadsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleCalendarTap() async {
    final now = DateTime.now();
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1, 1),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
      helpText: "Select Date Range for Leads",
      saveText: "Apply",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0052FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0052FF),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateRange = null;
    });
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
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
                  Expanded(
                    child: Text(
                      lead["name"] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      EnterpriseEditLeadSheet.show(
                        context,
                        lead: lead,
                        onLeadUpdated: (updated) {
                          setState(() {});
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0052FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF0052FF).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.edit_rounded, size: 14, color: Color(0xFF0052FF)),
                          SizedBox(width: 4),
                          Text(
                            "Edit",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0052FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        EnterpriseEditLeadSheet.show(
                          context,
                          lead: lead,
                          onLeadUpdated: (updated) {
                            setState(() {});
                          },
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text("Edit Lead"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0052FF),
                        side: const BorderSide(color: Color(0xFF0052FF)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleRetrySync(lead);
                      },
                      icon: const Icon(Icons.sync_rounded, size: 18),
                      label: const Text("Push to CRM"),
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
            ],
          ),
        );
      },
    );
  }

  void _openAddLeadModal() {
    EnterpriseAddLeadSheet.show(
      context,
      onLeadAdded: () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 6),
        child: StreamBuilder<EnterpriseLeadStats>(
          stream: EnterpriseLeadsService.instance.streamLeadStats(uid, _selectedDateRange),
          builder: (context, snapshot) {
            final syncFailed = snapshot.data?.syncFailedCount ?? 0;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Retry Failed Syncs Button (Visible if there are failed leads)
                if (syncFailed > 0) ...[
                  RetrySyncButton(
                    onTap: () => _handleRetrySync(),
                  ),
                  const SizedBox(width: 10),
                ],

                // 2. Primary "+ Add Lead" Floating Action Button
                FloatingActionButton.extended(
                  heroTag: "enterprise_add_lead_fab",
                  backgroundColor: const Color(0xFF0052FF),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text(
                    "Add Lead",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  onPressed: _openAddLeadModal,
                ),
              ],
            );
          },
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
                  // 1. Real Lead Stats Row (Total, This Week, Sync Failed)
                  StreamBuilder<EnterpriseLeadStats>(
                    stream: EnterpriseLeadsService.instance.streamLeadStats(uid, _selectedDateRange),
                    builder: (context, snapshot) {
                      final stats = snapshot.data ??
                          const EnterpriseLeadStats(
                            totalCount: 0,
                            thisWeekCount: 0,
                            syncFailedCount: 0,
                          );

                      return LeadsStatsRow(
                        totalCount: stats.totalCount,
                        thisWeekCount: stats.thisWeekCount,
                        syncFailedCount: stats.syncFailedCount,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // 2. Search Bar + Calendar Date Filter
                  LeadsSearchFilter(
                    controller: _searchController,
                    isDateFiltered: _selectedDateRange != null,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    onCalendarTap: _handleCalendarTap,
                  ),

                  // 2b. Active Date Range Filter Chip
                  if (_selectedDateRange != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.date_range_rounded, size: 16, color: Color(0xFF0052FF)),
                          const SizedBox(width: 8),
                          Text(
                            "${_formatDate(_selectedDateRange!.start)} – ${_formatDate(_selectedDateRange!.end)}",
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0052FF),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _clearDateFilter,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0052FF).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF0052FF)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // 3. Horizontal Scrollable Filter Chips (All, CRM Synced, Failed)
                  LeadsFilterChips(
                    selectedFilter: _selectedFilter,
                    onSelected: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // 4. Real Enterprise Lead Cards List
                  LeadsListCards(
                    searchQuery: _searchQuery,
                    selectedFilter: _selectedFilter,
                    dateRange: _selectedDateRange,
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


