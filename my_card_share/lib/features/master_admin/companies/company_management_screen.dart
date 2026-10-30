import 'package:flutter/material.dart';
import '../../../backend/master_admin/companies/company_management_store.dart';
import '../../../backend/master_admin/companies/models/master_company_model.dart';
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
  late final Stream<List<MasterCompanyModel>> _companiesStream;

  @override
  void initState() {
    super.initState();
    _companiesStream = CompanyManagementStore.instance.streamCompanies();
    CompanyManagementStore.instance.loadGlobalCompanies();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    CompanyManagementStore.instance.loadGlobalCompanies(
      filter: filter.toLowerCase(),
      search: _searchQuery,
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    CompanyManagementStore.instance.loadGlobalCompanies(
      filter: _selectedFilter.toLowerCase(),
      search: query,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MasterCompanyModel>>(
      stream: _companiesStream,
      builder: (context, snapshot) {
        final store = CompanyManagementStore.instance;
        final allCompanies = snapshot.data ?? store.companies;
        final totalCount = allCompanies.isNotEmpty ? allCompanies.length : store.totalCount;
        final activeCount = allCompanies.isNotEmpty ? allCompanies.where((c) => c.status.toLowerCase() == 'active').length : store.activeCount;
        final suspendedCount = allCompanies.isNotEmpty ? allCompanies.where((c) => c.status.toLowerCase() == 'suspended').length : store.suspendedCount;

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
            RefreshIndicator(
              onRefresh: () => CompanyManagementStore.instance.loadGlobalCompanies(
                filter: _selectedFilter.toLowerCase(),
                search: _searchQuery,
              ),
              color: const Color(0xFF0052FF),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Stat Chips Row (Total, Active, Suspended) with real live counts
                    CompanyStatsRow(
                      totalCount: totalCount,
                      activeCount: activeCount,
                      suspendedCount: suspendedCount,
                      selectedFilter: _selectedFilter,
                      onFilterSelected: _onFilterChanged,
                    ),

                    const SizedBox(height: 16),

                    // 2. Search Bar & Filter Chips (All, Active, Pending, Suspended)
                    CompanySearchFilterBar(
                      selectedFilter: _selectedFilter,
                      onSearchChanged: _onSearchChanged,
                      onFilterSelected: _onFilterChanged,
                    ),

                    const SizedBox(height: 18),

                    // 3. Vertical Company List Card (filtered in real-time)
                    CompanyListCard(
                      searchQuery: _searchQuery,
                      selectedFilter: _selectedFilter,
                      companies: allCompanies,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}



