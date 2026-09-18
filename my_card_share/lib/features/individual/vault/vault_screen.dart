import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/vault_provider.dart';
import 'widgets/vault_category.dart';
import 'widgets/vault_contact_card.dart';
import 'widgets/vault_search_bar.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allContacts = ref.watch(vaultNotifierProvider);

    final filteredContacts = allContacts.where((contact) {
      final tagMatch = _selectedFilter == 'all' ||
          contact['tag']!.toLowerCase() == _selectedFilter.toLowerCase() ||
          (_selectedFilter.toLowerCase() == 'ocr' && contact['tag']!.toLowerCase() == 'ocr') ||
          (_selectedFilter.toLowerCase() == 'ai scan' && contact['tag']!.toLowerCase() == 'ocr');

      final queryMatch = _searchQuery.isEmpty ||
          contact['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          contact['company']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (contact['role'] != null && contact['role']!.toLowerCase().contains(_searchQuery.toLowerCase()));

      return tagMatch && queryMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
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

              // Category Pills Row (All, AI Scan, Voice, Manual)
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
                      role: item['role'] ?? '',
                      company: item['company']!,
                      dateAdded: item['dateAdded'] ?? 'Just now',
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
