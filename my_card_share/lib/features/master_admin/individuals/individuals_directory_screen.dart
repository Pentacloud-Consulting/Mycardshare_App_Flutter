import 'package:flutter/material.dart';
import '../../../backend/master_admin/individuals/individuals_directory_store.dart';
import '../../../backend/master_admin/individuals/models/master_individual_model.dart';
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
    return StreamBuilder<List<MasterIndividualModel>>(
      stream: IndividualsDirectoryStore.instance.streamIndividuals(),
      builder: (context, snapshot) {
        final allUsers = snapshot.data ?? IndividualsDirectoryStore.instance.users;

        final totalCount = allUsers.length;
        final activeCount = allUsers.where((u) => !u.isDeactivated).length;
        final deactivatedCount = allUsers.where((u) => u.isDeactivated).length;

        // Real-time filtering logic
        final filteredUsers = allUsers.where((user) {
          final query = _searchQuery.toLowerCase().trim();
          final matchesSearch = query.isEmpty ||
              user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);

          if (!matchesSearch) return false;

          if (_selectedFilter == "All") return true;
          if (_selectedFilter == "Free") return user.plan.toLowerCase() == "free";
          if (_selectedFilter == "Pro") return user.plan.toLowerCase() == "pro";
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
                  // 1. Stat Chips Row with Live Database Counts
                  IndividualsStatChipsSection(
                    totalCount: totalCount,
                    activeCount: activeCount,
                    deactivatedCount: deactivatedCount,
                  ),
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

                  // 3. Filter Chips Row (All, Free, Pro, Deactivated)
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

                  // 4. Live User Directory Card List
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
                      _showUserActionsSheet(context, user);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUserActionsSheet(BuildContext context, MasterIndividualModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(
                    user.isDeactivated ? Icons.check_circle_rounded : Icons.block_rounded,
                    color: user.isDeactivated ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                  ),
                  title: Text(
                    user.isDeactivated ? "Reactivate User" : "Deactivate User",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: user.isDeactivated ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await IndividualsDirectoryStore.instance.toggleDeactivateUser(
                      user.id,
                      !user.isDeactivated,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



