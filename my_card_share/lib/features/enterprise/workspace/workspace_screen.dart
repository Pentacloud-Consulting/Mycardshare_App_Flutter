import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/workspace_stats_row.dart';
import 'widgets/workspace_search_filter.dart';
import 'widgets/workspace_filter_chips.dart';
import 'widgets/workspace_employee_list.dart';

class EnterpriseWorkspaceScreen extends StatefulWidget {
  const EnterpriseWorkspaceScreen({super.key});

  @override
  State<EnterpriseWorkspaceScreen> createState() => _EnterpriseWorkspaceScreenState();
}

class _EnterpriseWorkspaceScreenState extends State<EnterpriseWorkspaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleActionSelected(Map<String, dynamic> employee, String action) {
    if (action == "edit") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Editing details for ${employee["name"]}..."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (action == "resend") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Resent invite email to ${employee["email"]}"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (action == "deactivate") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Deactivated account for ${employee["name"]}"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 4),
        child: GestureDetector(
          onTap: () => context.go('/enterprise-onboarding'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0052FF).withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  "Invite",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Top-right soft baby-blue gradient blob
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.16),
                    const Color(0xFF0052FF).withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content Area
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Stat Chips Row (Total 34, Active 31, Pending 3)
                  const WorkspaceStatsRow(
                    totalCount: 34,
                    activeCount: 31,
                    pendingCount: 3,
                  ),

                  const SizedBox(height: 16),

                  // 2. Search Bar + Filter Icon Button
                  WorkspaceSearchFilter(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    onFilterTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Filter options opened"),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // 3. Horizontal Scrollable Filter Chips (All, Admins, Employees, Pending)
                  WorkspaceFilterChips(
                    selectedFilter: _selectedFilter,
                    onSelected: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // 4. Employee List Card (5 Stacked Rows with Dividers)
                  WorkspaceEmployeeList(
                    searchQuery: _searchQuery,
                    selectedFilter: _selectedFilter,
                    onActionSelected: _handleActionSelected,
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
