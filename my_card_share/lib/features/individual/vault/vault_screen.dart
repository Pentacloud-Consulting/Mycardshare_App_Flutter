import 'package:flutter/material.dart';
import 'widgets/vault_category.dart';
import 'widgets/vault_contact_card.dart';
import 'widgets/vault_search_bar.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _searchQuery = '';

  final List<Map<String, String>> _allContacts = [
    {
      'name': 'James Miller',
      'role': 'CEO & Founder',
      'company': 'TechNova Solutions',
      'dateAdded': '2 days ago',
      'tag': 'OCR',
    },
    {
      'name': 'Priya Sharma',
      'role': 'Marketing Manager',
      'company': 'GrowthNest Media',
      'dateAdded': '3 days ago',
      'tag': 'Voice',
      'initials': 'PS',
    },
    {
      'name': 'Daniel Kim',
      'role': 'Investment Analyst',
      'company': 'Skyline Ventures',
      'dateAdded': '5 days ago',
      'tag': 'Manual',
    },
    {
      'name': 'Sophia Lee',
      'role': 'Business Development',
      'company': 'Acme Realty Group',
      'dateAdded': '1 week ago',
      'tag': 'OCR',
    },
    {
      'name': 'Rahul Jain',
      'role': 'Product Manager',
      'company': 'FlowSync Technologies',
      'dateAdded': '1 week ago',
      'tag': 'Voice',
      'initials': 'RJ',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _allContacts.where((contact) {
      final tagMatch = _selectedFilter == 'all' ||
          contact['tag']!.toLowerCase() == _selectedFilter.toLowerCase();
      final queryMatch = _searchQuery.isEmpty ||
          contact['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          contact['company']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          contact['role']!.toLowerCase().contains(_searchQuery.toLowerCase());

      return tagMatch && queryMatch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              VaultSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
              ),

              const SizedBox(height: 14),

              // Category Pills Row (Image 1: All, AI Scan, Voice, Manual)
              VaultCategory(
                selectedFilter: _selectedFilter,
                onFilterSelected: (filterId) {
                  setState(() {
                    _selectedFilter = filterId;
                  });
                },
              ),

              const SizedBox(height: 18),

              // Contact Cards List
              if (filteredContacts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "No contacts found in vault",
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
                  itemCount: filteredContacts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredContacts[index];
                    return VaultContactCard(
                      name: item['name']!,
                      role: item['role']!,
                      company: item['company']!,
                      dateAdded: item['dateAdded']!,
                      tag: item['tag']!,
                      initials: item['initials'],
                    );
                  },
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
