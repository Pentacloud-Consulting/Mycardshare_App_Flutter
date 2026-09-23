import 'package:flutter/material.dart';
import 'widgets/individuals_stat_chips_section.dart';
import 'widgets/individuals_search_bar_section.dart';
import 'widgets/individuals_filter_chips_section.dart';
import 'widgets/individuals_list_section.dart';

class MasterAdminIndividualsScreen extends StatefulWidget {
  const MasterAdminIndividualsScreen({super.key});

  @override
  State<MasterAdminIndividualsScreen> createState() =>
      _MasterAdminIndividualsScreenState();
}

class _MasterAdminIndividualsScreenState
    extends State<MasterAdminIndividualsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _showFilterChips = true;

  @override
  Widget build(BuildContext context) {
    // Real-time filtering logic
    final filteredUsers = IndividualsListSection.defaultUsers.where((user) {
      // 1. Search Query Filter
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);

      if (!matchesSearch) return false;

      // 2. Chip Category Filter
      if (_selectedFilter == "All") return true;
      if (_selectedFilter == "Free") return user.plan == "Free";
      if (_selectedFilter == "Pro") return user.plan == "Pro";
      if (_selectedFilter == "Deactivated") return user.isDeactivated;

      return true;
    }).toList();

    return Stack(
      children: [
        // Soft baby-blue gradient blob top-right corner
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFDBEAFE).withValues(alpha: 0.7),
                  const Color(0xFFEFF6FF).withValues(alpha: 0.2),
                  const Color(0xFFF8FAFD).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // Main scrollable content
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Stat Chips Row
              const IndividualsStatChipsSection(),
              const SizedBox(height: 16),

              // 2. Search Bar + Filter Icon
              IndividualsSearchBarSection(
                isFilterActive: _showFilterChips,
                onSearchChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                onFilterTap: () {
                  setState(() {
                    _showFilterChips = !_showFilterChips;
                  });
                },
              ),
              const SizedBox(height: 14),

              // 3. Filter Chips Row (All, Free, Pro, Deactivated) - Animated Toggle
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: _showFilterChips
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: IndividualsFilterChipsSection(
                          selectedFilter: _selectedFilter,
                          onFilterSelected: (filter) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // 4. User Directory Card List
              IndividualsListSection(
                users: filteredUsers,
                onUserTap: (user) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Selected user: ${user.name}"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onMenuTap: (user) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Actions for ${user.name}"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
