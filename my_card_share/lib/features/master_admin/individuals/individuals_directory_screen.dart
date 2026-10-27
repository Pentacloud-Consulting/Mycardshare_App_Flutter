import 'package:flutter/material.dart';
import '../../../backend/master_admin/individuals/individuals_directory_store.dart';
import '../../../backend/master_admin/individuals/models/master_individual_model.dart';
import '../../../backend/master_admin/individuals/delete/individual_delete_service.dart';
import '../../../backend/master_admin/master_individuals_service.dart';
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
  final Set<String> _locallyDeletedIds = {};
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _showFilterChips = true;
  bool _isLoading = false;
  MasterIndividualsResponse? _backendData;

  late final Stream<List<Map<String, dynamic>>> _deletionsStream;
  late final Stream<List<MasterIndividualModel>> _individualsStream;

  @override
  void initState() {
    super.initState();
    _deletionsStream = IndividualDeleteService.streamPendingDeletions();
    _individualsStream = IndividualsDirectoryStore.instance.streamIndividuals();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final token = await MasterIndividualsService.getAuthToken();
      final result = await MasterIndividualsService.fetchIndividuals(
        token: token,
        filter: 'all',
        search: _searchQuery,
      );
      if (mounted) {
        setState(() {
          _backendData = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[MasterAdminIndividualsScreen] Load backend data notice: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _deletionsStream,
      builder: (context, deletionSnap) {
        final rawDeletions = deletionSnap.data ?? [];
        final pendingDeletions = rawDeletions.where((d) {
          final reqId = (d['requestId'] ?? d['id'] ?? '').toString();
          final uId = (d['userId'] ?? '').toString();
          return !_locallyDeletedIds.contains(reqId) && !_locallyDeletedIds.contains(uId);
        }).toList();

        return StreamBuilder<List<MasterIndividualModel>>(
          stream: _individualsStream,
          builder: (context, snapshot) {
            final storeUsers = snapshot.data ?? IndividualsDirectoryStore.instance.users;

            // Merge storeUsers (Firestore real-time & merged deletions) with backendData
            final Map<String, MasterIndividualModel> mergedUsersMap = {};
            for (final u in storeUsers) {
              if (!_locallyDeletedIds.contains(u.id)) {
                mergedUsersMap[u.id] = u;
              }
            }
            if (_backendData != null && _backendData!.individuals.isNotEmpty) {
              for (final u in _backendData!.individuals) {
                if (_locallyDeletedIds.contains(u.userId)) continue;
                final model = MasterIndividualModel.fromIndividualUserModel(u);
                if (mergedUsersMap.containsKey(model.id) && mergedUsersMap[model.id]!.isDeactivated) {
                  continue; // Preserve deactivated & deletion pending state
                }
                mergedUsersMap[model.id] = model;
              }
            }
            List<MasterIndividualModel> displayUsers = mergedUsersMap.values
                .where((u) => !_locallyDeletedIds.contains(u.id))
                .toList();

            // Ensure any users in pending deletions are marked as Deactivated / Deletion Pending
            final pendingIds = pendingDeletions.map((d) => (d['userId'] ?? d['id'] ?? '').toString()).toSet();
            for (int i = 0; i < displayUsers.length; i++) {
              final user = displayUsers[i];
              if (pendingIds.contains(user.id)) {
                final dData = pendingDeletions.firstWhere(
                  (d) => (d['userId'] ?? d['id']) == user.id,
                  orElse: () => <String, dynamic>{},
                );
                displayUsers[i] = MasterIndividualModel(
                  id: user.id,
                  name: user.name,
                  email: user.email,
                  phone: user.phone,
                  avatarUrl: user.avatarUrl,
                  plan: 'Deactivated',
                  status: 'DELETION_PENDING',
                  cardSlug: user.cardSlug,
                  views: user.views,
                  isDeactivated: true,
                  deletionReason: dData['reason'] ?? user.deletionReason ?? 'User requested account deletion',
                  deletionRequest: dData.isNotEmpty ? dData : user.deletionRequest,
                  createdAt: user.createdAt,
                );
              }
            }

            // Also append any pending deletions that might not be in the backend list
            final existingIds = displayUsers.map((u) => u.id).toSet();
            for (final d in pendingDeletions) {
              final dId = (d['userId'] ?? d['id'] ?? '').toString();
              if (dId.isNotEmpty && !existingIds.contains(dId)) {
                displayUsers.add(
                  MasterIndividualModel(
                    id: dId,
                    name: (d['userName'] ?? 'User').toString(),
                    email: (d['userEmail'] ?? '').toString(),
                    plan: 'Deactivated',
                    status: 'DELETION_PENDING',
                    cardSlug: dId,
                    views: 0,
                    isDeactivated: true,
                    deletionReason: d['reason'] ?? 'User requested account deletion',
                    deletionRequest: d,
                  ),
                );
              }
            }

            // Calculate live metric badges with guaranteed real-time accuracy
            final realDeactivatedCount = displayUsers.where((u) => u.isDeactivated || u.status == 'DELETION_PENDING').length +
                pendingDeletions.where((d) => !displayUsers.any((u) => u.id == (d['userId'] ?? d['id']))).length;
            final deactivatedCount = realDeactivatedCount > 0
                ? realDeactivatedCount
                : (_backendData?.deactivated ?? 0);
            final activeCount = displayUsers.where((u) => !u.isDeactivated && u.status != 'DELETION_PENDING').length;
            final totalCount = activeCount + deactivatedCount;

            // Real-time filtering logic
            final filteredUsers = displayUsers.where((user) {
              final query = _searchQuery.toLowerCase().trim();
              final matchesSearch = query.isEmpty ||
                  user.name.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query) ||
                  user.phone.toLowerCase().contains(query) ||
                  user.cardSlug.toLowerCase().contains(query);

              if (!matchesSearch) return false;

              if (_selectedFilter == "All") return true;
              if (_selectedFilter == "Free") return user.plan.toLowerCase() == "free";
              if (_selectedFilter == "Pro") return user.plan.toLowerCase() == "pro";
              if (_selectedFilter == "Deactivated") {
                return user.isDeactivated ||
                    user.status == 'DELETION_PENDING' ||
                    user.status.toLowerCase().contains('deact') ||
                    user.status.toLowerCase().contains('del') ||
                    user.deletionRequest != null;
              }

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
                RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFF0052FF),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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

                        // 3. Filter Chips Row (All, Free, Pro, Deactivated, Deletion Requests)
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
                                        _showDeletionRequestsBottomSheet(context, displayUsers: displayUsers),
                                    deletionRequestsCount: realDeactivatedCount > 0 ? realDeactivatedCount : pendingDeletions.length,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        // Loading Indicator if fetching
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: LinearProgressIndicator(
                              color: Color(0xFF0052FF),
                              backgroundColor: Color(0xFFEFF6FF),
                            ),
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
                if (user.deletionReason != null && user.deletionReason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Text(
                      "Deletion Request Reason:\n\"${user.deletionReason}\"",
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Permanent Delete Action
                if (user.isDeactivated || user.status == 'DELETION_PENDING')
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626)),
                    title: const Text(
                      "Permanently Delete Account",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await MasterIndividualsService.confirmDeleteIndividual(userId: user.id);
                        await IndividualDeleteService.confirmDeleteUser(
                          requestId: user.id,
                          targetUserId: user.id,
                        );
                        _loadData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("User ${user.name} permanently deleted"),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint('[MasterAdminIndividuals] Delete error: $e');
                      }
                    },
                  ),

                // Reactivate / Deactivate Toggle
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
                    _loadData();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeletionRequestsBottomSheet(
    BuildContext context, {
    List<MasterIndividualModel>? displayUsers,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _deletionsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 250,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final rawList = List<Map<String, dynamic>>.from(snapshot.data ?? []);
                final requests = rawList.where((r) {
                  final reqId = (r["requestId"] ?? r["id"] ?? "").toString();
                  final uId = (r["userId"] ?? "").toString();
                  return !_locallyDeletedIds.contains(reqId) && !_locallyDeletedIds.contains(uId);
                }).toList();

                // Fallback: If stream returned empty, check displayUsers for any accounts marked deletion_pending or deactivated
                if (requests.isEmpty && displayUsers != null && displayUsers.isNotEmpty) {
                  for (final u in displayUsers) {
                    if (!_locallyDeletedIds.contains(u.id) &&
                        (u.isDeactivated || u.status == 'DELETION_PENDING' || u.deletionRequest != null)) {
                      requests.add({
                        "requestId": u.id,
                        "userId": u.id,
                        "userName": u.name,
                        "userEmail": u.email,
                        "reason": u.deletionReason ?? "User requested account deletion",
                        "feedback": "",
                        "status": "pending",
                        "createdAt": u.createdAt ?? DateTime.now(),
                      });
                    }
                  }
                }

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
                                          // ⚡ CRITICAL: Optimistically remove card immediately!
                                          setModalState(() {
                                            _locallyDeletedIds.add(requestId);
                                            if (targetUserId.isNotEmpty) _locallyDeletedIds.add(targetUserId);
                                            requests.removeWhere((r) =>
                                              r['requestId'] == requestId || r['id'] == requestId || r['userId'] == targetUserId
                                            );
                                          });
                                          setState(() {});

                                          final messenger = ScaffoldMessenger.of(context);
                                          IndividualDeleteService.rejectDeletion(
                                            requestId: requestId,
                                            targetUserId: targetUserId,
                                          );
                                          _loadData();

                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text("Deletion request for $name rejected"),
                                              behavior: SnackBarBehavior.floating,
                                              duration: const Duration(milliseconds: 1500),
                                            ),
                                          );
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
                                          // ⚡ CRITICAL: Optimistically remove card immediately!
                                          setModalState(() {
                                            _locallyDeletedIds.add(requestId);
                                            if (targetUserId.isNotEmpty) _locallyDeletedIds.add(targetUserId);
                                            requests.removeWhere((r) =>
                                              r['requestId'] == requestId || r['id'] == requestId || r['userId'] == targetUserId
                                            );
                                          });
                                          setState(() {});

                                          final messenger = ScaffoldMessenger.of(context);
                                          try {
                                            MasterIndividualsService.confirmDeleteIndividual(
                                              userId: targetUserId.isNotEmpty ? targetUserId : requestId,
                                            );
                                          } catch (_) {}
                                          IndividualDeleteService.confirmDeleteUser(
                                            requestId: requestId,
                                            targetUserId: targetUserId.isNotEmpty ? targetUserId : requestId,
                                          );
                                          _loadData();

                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text("User $name permanently deleted"),
                                              backgroundColor: const Color(0xFFEF4444),
                                              behavior: SnackBarBehavior.floating,
                                              duration: const Duration(milliseconds: 1500),
                                            ),
                                          );
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
      },
    );
  }
}
