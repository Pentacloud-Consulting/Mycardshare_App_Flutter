import 'package:flutter/material.dart';
import '../../../backend/master_admin/individuals/individuals_directory_store.dart';
import '../../../backend/master_admin/individuals/models/master_individual_model.dart';
import '../../../backend/master_admin/individuals/delete/individual_delete_service.dart';
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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: IndividualDeleteService.streamPendingDeletions(),
      builder: (context, deletionSnap) {
        final pendingDeletions = deletionSnap.data ?? [];

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
                              onDeletionRequestsTap: () =>
                                  _showDeletionRequestsBottomSheet(context),
                              deletionRequestsCount: pendingDeletions.length,
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

  void _showDeletionRequestsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: IndividualDeleteService.streamPendingDeletions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final requests = snapshot.data ?? [];

            if (requests.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF16A34A),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "No Pending Deletions! 🎉",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "All individual user accounts are in good standing.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
                          const SizedBox(width: 8),
                          Text(
                            "Deletion Requests (${requests.length})",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final item = requests[index];
                        final requestId = (item["requestId"] ?? item["id"] ?? "").toString();
                        final targetUserId = (item["userId"] ?? "").toString();
                        final name = (item["userName"] ?? "User").toString();
                        final email = (item["userEmail"] ?? "").toString();
                        final reason = (item["reason"] ?? "No reason specified").toString();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "Pending",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (email.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: Text(
                                  "Reason: \"$reason\"",
                                  style: const TextStyle(
                                    color: Color(0xFFB45309),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      await IndividualDeleteService.rejectDeletion(
                                        requestId: requestId,
                                        targetUserId: targetUserId,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Deletion request for $name rejected"),
                                            behavior: SnackBarBehavior.floating,
                                            duration: const Duration(milliseconds: 1500),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      "Reject",
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF4444),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () async {
                                      await IndividualDeleteService.confirmDeleteUser(
                                        requestId: requestId,
                                        targetUserId: targetUserId,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("User $name permanently deleted"),
                                            backgroundColor: const Color(0xFFEF4444),
                                            behavior: SnackBarBehavior.floating,
                                            duration: const Duration(milliseconds: 1500),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      "Permanently Delete",
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}



