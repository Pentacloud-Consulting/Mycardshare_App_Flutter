import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_backend/employees_page.dart';

// -----------------------------------------------------------------------------
// BACKEND SERVICE
// -----------------------------------------------------------------------------

/// Lightweight service to read employee count & preview from Firestore.
class ViewEmployeeService {
  ViewEmployeeService._internal();
  static final ViewEmployeeService instance = ViewEmployeeService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream: total employee count.
  Stream<int> streamEmployeeCount([String? uid]) {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (targetUid == null || targetUid.isEmpty) return Stream.value(0);
    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('employees')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Stream: breakdown total / active / pending.
  Stream<EmployeeStats> streamEmployeeStats([String? uid]) {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(
          const EmployeeStats(totalCount: 0, activeCount: 0, pendingCount: 0));
    }
    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('employees')
        .snapshots()
        .map((snap) {
      final employees = snap.docs
          .map((d) => EnterpriseEmployeeModel.fromFirestore(d.id, d.data()))
          .toList();
      return EmployeeStats.fromList(employees);
    });
  }

  /// Stream: first [limit] employees for preview.
  Stream<List<EnterpriseEmployeeModel>> streamEmployeePreview({
    String? uid,
    int limit = 5,
  }) {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (targetUid == null || targetUid.isEmpty) return Stream.value(const []);
    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('employees')
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => EnterpriseEmployeeModel.fromFirestore(d.id, d.data()))
            .toList());
  }
}

// -----------------------------------------------------------------------------
// UI WIDGET � Team Overview Card (placed after Social section in profile_view)
// -----------------------------------------------------------------------------

class EnterpriseTeamOverviewWidget extends StatelessWidget {
  const EnterpriseTeamOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<EmployeeStats>(
      stream: ViewEmployeeService.instance.streamEmployeeStats(uid),
      builder: (context, statsSnap) {
        final stats = statsSnap.data ??
            const EmployeeStats(totalCount: 0, activeCount: 0, pendingCount: 0);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.group_rounded,
                          color: Color(0xFF0052FF), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Team Members",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFBFDBFE), width: 1),
                    ),
                    child: Text(
                      "${stats.totalCount} Total",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0052FF),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stats Pills Row
              Row(
                children: [
                  _statPill(stats.totalCount, "Total",
                      const Color(0xFF0052FF), const Color(0xFFEFF4FF)),
                  const SizedBox(width: 10),
                  _statPill(stats.activeCount, "Active",
                      const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
                  const SizedBox(width: 10),
                  _statPill(stats.pendingCount, "Pending",
                      const Color(0xFFD97706), const Color(0xFFFEF9C3)),
                ],
              ),

              const SizedBox(height: 16),

              // Employee Preview
              StreamBuilder<List<EnterpriseEmployeeModel>>(
                stream: ViewEmployeeService.instance
                    .streamEmployeePreview(uid: uid, limit: 6),
                builder: (context, empSnap) {
                  final employees = empSnap.data ?? [];

                  if (employees.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: const Center(
                        child: Text(
                          "No team members yet � invite your first member!",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stacked avatars
                      SizedBox(
                        height: 42,
                        child: Stack(
                          children: [
                            ...List.generate(
                              employees.length > 5 ? 5 : employees.length,
                              (i) => Positioned(
                                left: i * 28.0,
                                child: _avatar(employees[i]),
                              ),
                            ),
                            if (stats.totalCount > 5)
                              Positioned(
                                left: 5 * 28.0,
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0052FF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "+${stats.totalCount - 5}",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Member list rows
                      ...employees.take(3).map((e) => _memberRow(e)),

                      if (stats.totalCount > 3) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "${stats.totalCount - 3} more member${stats.totalCount - 3 == 1 ? '' : 's'} in workspace",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0052FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statPill(int count, String label, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              "$count",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(EnterpriseEmployeeModel emp) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        color: const Color(0xFF0052FF),
      ),
      child: emp.avatarUrl != null && emp.avatarUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(emp.avatarUrl!, fit: BoxFit.cover))
          : Center(
              child: Text(
                emp.initials,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  Widget _memberRow(EnterpriseEmployeeModel emp) {
    final isActive = emp.status.toLowerCase() == 'active';
    final statusColor =
        isActive ? const Color(0xFF16A34A) : const Color(0xFFD97706);
    final statusBg =
        isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0052FF).withValues(alpha: 0.12),
            ),
            child: emp.avatarUrl != null && emp.avatarUrl!.isNotEmpty
                ? ClipOval(
                    child:
                        Image.network(emp.avatarUrl!, fit: BoxFit.cover))
                : Center(
                    child: Text(
                      emp.initials,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0052FF),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emp.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  emp.roleTitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              emp.status,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// INLINE COUNT BADGE � Embed on Image 1 header card
// -----------------------------------------------------------------------------

/// Live employee count badge for the header card (Image 1).
class EnterpriseEmployeeCountBadge extends StatelessWidget {
  const EnterpriseEmployeeCountBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return StreamBuilder<int>(
      stream: ViewEmployeeService.instance.streamEmployeeCount(uid),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group_rounded,
                size: 14, color: Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              "$count Member${count == 1 ? '' : 's'}",
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        );
      },
    );
  }
}




