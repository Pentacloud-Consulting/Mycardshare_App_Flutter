import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../backend/individual/previews/user_leads.dart';
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          "No leads match the filter",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF94A3B8),
                          ),
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
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


