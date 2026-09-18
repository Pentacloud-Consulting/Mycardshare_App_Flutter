import 'package:flutter/material.dart';
import 'widgets/lead_list_tile.dart';
import 'widgets/leads_filter_pills.dart';
import 'widgets/leads_metrics_row.dart';
import 'widgets/leads_search_bar.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _searchQuery = '';

  final List<Map<String, String>> _allLeads = [
    {
      'initials': 'JM',
      'name': 'James Miller',
      'company': 'TechNova Solutions',
      'source': 'via QR scan',
      'date': 'Sept 15',
      'status': 'New',
    },
    {
      'initials': 'PS',
      'name': 'Priya Sharma',
      'company': 'GrowthNest Media',
      'source': 'via Voice',
      'date': 'Sept 14',
      'status': 'Contacted',
    },
    {
      'initials': 'DK',
      'name': 'Daniel Kim',
      'company': 'Skyline Ventures',
      'source': 'via Manual',
      'date': 'Sept 13',
      'status': 'Qualified',
    },
    {
      'initials': 'SL',
      'name': 'Sophia Lee',
      'company': 'Acme Realty Group',
      'source': 'via QR scan',
      'date': 'Sept 12',
      'status': 'New',
    },
    {
      'initials': 'RJ',
      'name': 'Rahul Jain',
      'company': 'FlowSync Technologies',
      'source': 'via QR scan',
      'date': 'Sept 11',
      'status': 'Contacted',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLeads = _allLeads.where((lead) {
      final statusMatch = _selectedFilter == 'all' ||
          lead['status']!.toLowerCase() == _selectedFilter.toLowerCase();
      final queryMatch = _searchQuery.isEmpty ||
          lead['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lead['company']!.toLowerCase().contains(_searchQuery.toLowerCase());

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
              // Metrics Row (Total 46, New 12, This Week 8)
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
                    return LeadListTile(
                      initials: item['initials']!,
                      name: item['name']!,
                      company: item['company']!,
                      source: item['source']!,
                      date: item['date']!,
                      status: item['status']!,
                    );
                  },
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
