import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../backend/individual/previews/user_leads.dart';
import 'widgets/lead_add_lead.dart';
import 'widgets/lead_list_tile.dart';
import 'widgets/leads_filter_pills.dart';
import 'widgets/leads_metrics_row.dart';
import 'widgets/leads_search_bar.dart';
import 'widgets/lead_detail_sheet.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    UserLeadsService.instance.fetchUserLeads(uid);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddLeadSheet() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    LeadAddLeadSheet.show(
      context,
      defaultTargetUid: currentUid,
      allowMultiUser: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserLeadsService.instance,
      builder: (context, _) {
        final leadsList = UserLeadsService.instance.leads;

        final filteredLeads = leadsList.where((lead) {
          final statusMatch = _selectedFilter == 'all' ||
              lead.status.toLowerCase() == _selectedFilter.toLowerCase();
          final queryMatch = _searchQuery.isEmpty ||
              lead.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              lead.company.toLowerCase().contains(_searchQuery.toLowerCase());

          return statusMatch && queryMatch;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFD),
          // ── Bottom-Right Floating Action Button for Adding Leads ──
          floatingActionButton: _AddLeadFab(onTap: _openAddLeadSheet),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metrics Row (Total, New, This Week)
                  const LeadsMetricsRow(),

                  const SizedBox(height: 16),

                  // Search Bar + Calendar Date Filter
                  LeadsSearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  // Status Filter Pills (All, New, Contacted, Qualified, Lost)
                  LeadsFilterPills(
                    selectedFilter: _selectedFilter,
                    onFilterSelected: (filterId) {
                      setState(() {
                        _selectedFilter = filterId;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  // Leads List
                  if (filteredLeads.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0052FF).withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.group_outlined,
                                size: 36,
                                color: Color(0xFF0052FF),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "No leads match the filter",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _openAddLeadSheet,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text("Add New Lead"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0052FF),
                                side: const BorderSide(color: Color(0xFF0052FF)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredLeads.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredLeads[index];
                        return GestureDetector(
                          onTap: () => LeadDetailSheet.show(context, item),
                          child: LeadListTile(
                            initials: item.initials,
                            name: item.name,
                            company: item.company,
                            source: item.source,
                            date: 'Sept ${item.createdAt.day}',
                            status: item.status,
                            onMoreTap: () => LeadDetailSheet.show(context, item),
                          ),
                        );
                      },
                    ),

                  // Extra bottom padding so FAB never covers the last card
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium floating "Add Lead" FAB — bottom-right corner of Leads Screen
// ─────────────────────────────────────────────────────────────────────────────
class _AddLeadFab extends StatefulWidget {
  final VoidCallback onTap;
  const _AddLeadFab({required this.onTap});

  @override
  State<_AddLeadFab> createState() => _AddLeadFabState();
}

class _AddLeadFabState extends State<_AddLeadFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF0052FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x500052FF),
                blurRadius: 18,
                spreadRadius: 0,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.person_add_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
