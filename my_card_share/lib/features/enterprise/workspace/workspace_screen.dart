import 'package:flutter/material.dart';
import '../../../backend/enterprise/home_backend/employees_page.dart';
import '../../../backend/enterprise/invite_employee/invite.dart';
import 'widgets/workspace_search_filter.dart';
import 'widgets/workspace_filter_chips.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 4),
        child: EnterpriseInviteButton(
          onTap: () => showEnterpriseInviteModal(context),
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
                  // 1. Dynamic Stat Pills Row (Image 4: Total, Active, Pending)
                  EnterpriseStatsPillsWidget(
                    selectedFilter: _selectedFilter,
                    onFilterSelected: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
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

                  // 4. Real Employee List Card (Image 5)
                  EnterpriseEmployeeListBackend(
                    searchQuery: _searchQuery,
                    selectedFilter: _selectedFilter,
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


