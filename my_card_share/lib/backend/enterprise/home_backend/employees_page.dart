import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile/enterprise_profile_store.dart';
import '../lock_banner/lock_banner.dart';
import '../multiple_store/enterprise_multi_store.dart';

/// Data model representing an Enterprise Employee.
class EnterpriseEmployeeModel {
  final String id;
  final String name;
  final String email;
  final String roleTitle;
  final String role; // 'Admin' or 'Employee'
  final String status; // 'Active', 'Pending', or 'Deactivated'
  final String? avatarUrl;
  final int views;
  final int leads;
  final bool isBannerLocked;
  final String? lockedBannerUrl;
  final DateTime createdAt;

  EnterpriseEmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roleTitle,
    required this.role,
    required this.status,
    this.avatarUrl,
    this.views = 0,
    this.leads = 0,
    this.isBannerLocked = false,
    this.lockedBannerUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'EM';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory EnterpriseEmployeeModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return EnterpriseEmployeeModel(
      id: id,
      name: data['name'] ?? data['fullName'] ?? 'Team Member',
      email: data['email'] ?? '',
      roleTitle: data['roleTitle'] ?? data['jobTitle'] ?? 'Employee',
      role: data['role'] ?? 'Employee',
      status: data['status'] ?? 'Active',
      avatarUrl: data['avatarUrl'] as String?,
      views: (data['views'] as num?)?.toInt() ?? 0,
      leads: (data['leads'] as num?)?.toInt() ?? 0,
      isBannerLocked: data['isBannerLocked'] ?? false,
      lockedBannerUrl: data['lockedBannerUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'roleTitle': roleTitle,
        'role': role,
        'status': status,
        'avatarUrl': avatarUrl,
        'views': views,
        'leads': leads,
        'isBannerLocked': isBannerLocked,
        'lockedBannerUrl': lockedBannerUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

/// Statistics summary for employee status tabs (Image 4).
class EmployeeStats {
  final int totalCount;
  final int activeCount;
  final int pendingCount;

  const EmployeeStats({
    required this.totalCount,
    required this.activeCount,
    required this.pendingCount,
  });

  factory EmployeeStats.fromList(List<EnterpriseEmployeeModel> employees) {
    int active = 0;
    int pending = 0;
    for (final emp in employees) {
      if (emp.status.toLowerCase() == 'pending' ||
          emp.status.toLowerCase() == 'pending invite') {
        pending++;
      } else {
        active++;
      }
    }
    return EmployeeStats(
      totalCount: employees.length,
      activeCount: active,
      pendingCount: pending,
    );
  }
}

/// Real backend service connecting employees page with lock_banner, multi store, profile, and auth sign.
class EnterpriseEmployeesService {
  EnterpriseEmployeesService._internal();
  static final EnterpriseEmployeesService instance =
      EnterpriseEmployeesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Stream of real employees for the enterprise.
  Stream<List<EnterpriseEmployeeModel>> streamEmployees([
    String? uid,
    String selectedFilter = 'All',
    String searchQuery = '',
  ]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const []);
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('employees')
        .snapshots()
        .asyncMap((snapshot) async {
      List<EnterpriseEmployeeModel> list = snapshot.docs
          .map((doc) => EnterpriseEmployeeModel.fromFirestore(doc.id, doc.data()))
          .toList();

      // If subcollection is empty, check enterprises/{uid} for invitedEmails array
      if (list.isEmpty) {
        try {
          final entDoc = await _firestore.collection('enterprises').doc(targetUid).get();
          if (entDoc.exists && entDoc.data() != null) {
            final data = entDoc.data()!;
            final invitedEmails = (data['invitedEmails'] as List<dynamic>?) ?? [];
            for (int i = 0; i < invitedEmails.length; i++) {
              final em = invitedEmails[i].toString().trim();
              if (em.isNotEmpty) {
                final prefix = em.split('@').first;
                final name = prefix.isNotEmpty
                    ? prefix[0].toUpperCase() + prefix.substring(1)
                    : 'Invited Member';
                list.add(EnterpriseEmployeeModel(
                  id: 'invited_$i',
                  name: name,
                  email: em,
                  roleTitle: 'Team Member',
                  role: 'Employee',
                  status: 'Pending Invite',
                ));
              }
            }
          }
        } catch (e) {
          debugPrint('[EnterpriseEmployeesService] Error loading invitedEmails: $e');
        }
      }

      // Apply Search Filter
      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        list = list.where((emp) {
          return emp.name.toLowerCase().contains(query) ||
              emp.email.toLowerCase().contains(query) ||
              emp.roleTitle.toLowerCase().contains(query);
        }).toList();
      }

      // Apply Category Filter (All, Admins, Employees, Pending)
      if (selectedFilter == 'Admins') {
        list = list.where((emp) => emp.role.toLowerCase() == 'admin').toList();
      } else if (selectedFilter == 'Employees') {
        list = list
            .where((emp) => emp.role.toLowerCase() == 'employee')
            .toList();
      } else if (selectedFilter == 'Pending' || selectedFilter == 'Pending Invite') {
        list = list
            .where((emp) =>
                emp.status.toLowerCase() == 'pending' ||
                emp.status.toLowerCase() == 'pending invite')
            .toList();
      } else if (selectedFilter == 'Active') {
        list = list.where((emp) => emp.status.toLowerCase() == 'active').toList();
      }

      return list;
    });
  }

  /// Stream of employee counts (Total, Active, Pending) for Image 4.
  Stream<EmployeeStats> streamEmployeeStats([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const EmployeeStats(
        totalCount: 0,
        activeCount: 0,
        pendingCount: 0,
      ));
    }

    return streamEmployees(targetUid, 'All', '').map((employees) {
      return EmployeeStats.fromList(employees);
    });
  }

  /// Add a new employee to the enterprise.
  Future<bool> addEmployee({
    required String uid,
    required String name,
    required String email,
    required String roleTitle,
    required String role,
  }) async {
    try {
      final empId = 'emp_${DateTime.now().millisecondsSinceEpoch}';
      final newEmp = EnterpriseEmployeeModel(
        id: empId,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        roleTitle: roleTitle.trim(),
        role: role,
        status: 'Active',
      );

      await _firestore
          .collection('enterprises')
          .doc(uid)
          .collection('employees')
          .doc(empId)
          .set(newEmp.toFirestore());

      // Sync with MultiStore
      EnterpriseMultiStore.instance.saveUser(
        companyName: EnterpriseProfileStore.instance.currentProfile?.companyName ??
            'My Enterprise',
        email: email.trim().toLowerCase(),
        password: 'Password123!',
        role: role,
      );

      // Increment employee count in EnterpriseProfileStore
      final currentCount =
          EnterpriseProfileStore.instance.currentProfile?.employeeCount ?? 0;
      await EnterpriseProfileStore.instance.updateFields(uid, {
        'employeeCount': currentCount + 1,
      });

      return true;
    } catch (e) {
      debugPrint('[EnterpriseEmployeesService] addEmployee error: $e');
      return false;
    }
  }

  /// Update an existing employee.
  Future<bool> updateEmployee({
    required String enterpriseUid,
    required String employeeId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection('enterprises')
          .doc(enterpriseUid)
          .collection('employees')
          .doc(employeeId)
          .update({...data, 'updatedAt': FieldValue.serverTimestamp()});
      return true;
    } catch (e) {
      debugPrint('[EnterpriseEmployeesService] updateEmployee error: $e');
      return false;
    }
  }

  /// Connects with LockBannerService: Toggle banner lock state for a specific employee.
  Future<bool> toggleEmployeeBannerLock({
    required String enterpriseUid,
    required String employeeId,
    required bool locked,
  }) async {
    try {
      final banner = await LockBannerService.instance.fetchBanner(enterpriseUid);

      await _firestore
          .collection('enterprises')
          .doc(enterpriseUid)
          .collection('employees')
          .doc(employeeId)
          .update({
        'isBannerLocked': locked,
        'lockedBannerUrl': locked ? banner?.bannerUrl : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('[EnterpriseEmployeesService] toggleBannerLock error: $e');
      return false;
    }
  }

  /// Delete an employee.
  Future<bool> deleteEmployee({
    required String enterpriseUid,
    required String employeeId,
  }) async {
    try {
      await _firestore
          .collection('enterprises')
          .doc(enterpriseUid)
          .collection('employees')
          .doc(employeeId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('[EnterpriseEmployeesService] deleteEmployee error: $e');
      return false;
    }
  }
}

/// Real UI Widget corresponding to Image 4 (Dynamic Filter Pills: Total, Active, Pending).
class EnterpriseStatsPillsWidget extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String>? onFilterSelected;

  const EnterpriseStatsPillsWidget({
    super.key,
    this.selectedFilter = 'All',
    this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<EmployeeStats>(
      stream: EnterpriseEmployeesService.instance.streamEmployeeStats(uid),
      builder: (context, snapshot) {
        final stats = snapshot.data ??
            const EmployeeStats(
              totalCount: 0,
              activeCount: 0,
              pendingCount: 0,
            );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPill(
                label: "Total",
                count: stats.totalCount,
                isSelected: selectedFilter == 'All',
                bgColor: const Color(0xFFEFF6FF),
                textColor: const Color(0xFF0052FF),
                borderColor: const Color(0xFFBFDBFE),
                onTap: () => onFilterSelected?.call('All'),
              ),
              const SizedBox(width: 10),
              _buildPill(
                label: "Active",
                count: stats.activeCount,
                isSelected: selectedFilter == 'Active' || selectedFilter == 'Employees',
                bgColor: const Color(0xFFDCFCE7),
                textColor: const Color(0xFF166534),
                borderColor: const Color(0xFF86EFAC),
                onTap: () => onFilterSelected?.call('Employees'),
              ),
              const SizedBox(width: 10),
              _buildPill(
                label: "Pending",
                count: stats.pendingCount,
                isSelected: selectedFilter == 'Pending',
                bgColor: const Color(0xFFFEF9C3),
                textColor: const Color(0xFFCA8A04),
                borderColor: const Color(0xFFFDE047),
                onTap: () => onFilterSelected?.call('Pending'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPill({
    required String label,
    required int count,
    required bool isSelected,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? borderColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? textColor.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? textColor : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "$count",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isSelected ? textColor : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Real UI Widget corresponding to Image 5 (Employee List Cards with Popup Actions).
class EnterpriseEmployeeListBackend extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;

  const EnterpriseEmployeeListBackend({
    super.key,
    this.searchQuery = '',
    this.selectedFilter = 'All',
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<List<EnterpriseEmployeeModel>>(
      stream: EnterpriseEmployeesService.instance.streamEmployees(
        uid,
        selectedFilter,
        searchQuery,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: Color(0xFF0052FF)),
            ),
          );
        }

        final employees = snapshot.data ?? [];

        if (employees.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              children: [
                Icon(Icons.person_off_rounded, size: 40, color: Color(0xFF94A3B8)),
                SizedBox(height: 12),
                Text(
                  "No employees found",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Try changing your search or filter options.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: employees.length,
            separatorBuilder: (_, i) => const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF1F5F9),
            ),
            itemBuilder: (context, index) {
              final emp = employees[index];
              return _buildEmployeeRow(context, emp, uid);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmployeeRow(
      BuildContext context, EnterpriseEmployeeModel emp, String? enterpriseUid) {
    final isAdmin = emp.role.toLowerCase() == 'admin';
    final isPending = emp.status.toLowerCase() == 'pending' ||
        emp.status.toLowerCase() == 'pending invite';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Employee Avatar Initials
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isAdmin
                  ? const Color(0xFFF3E8FF)
                  : isPending
                      ? const Color(0xFFFEF9C3)
                      : const Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: emp.avatarUrl != null && emp.avatarUrl!.isNotEmpty
                  ? Image.network(
                      emp.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, _) => Center(
                        child: Text(
                          emp.initials,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isAdmin
                                ? const Color(0xFF9333EA)
                                : isPending
                                    ? const Color(0xFFCA8A04)
                                    : const Color(0xFF0052FF),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        emp.initials,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isAdmin
                              ? const Color(0xFF9333EA)
                              : isPending
                                  ? const Color(0xFFCA8A04)
                                  : const Color(0xFF0052FF),
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Name + Subtitle (Job title + Email snippet)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        emp.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Role Badge (Admin or Employee)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? const Color(0xFFF3E8FF)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        emp.role,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isAdmin
                              ? const Color(0xFF9333EA)
                              : const Color(0xFF0052FF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  "${emp.roleTitle} · ${emp.email}",
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Status Indicator Dot + Text
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isPending
                            ? const Color(0xFFD97706)
                            : const Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      emp.status,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isPending
                            ? const Color(0xFFD97706)
                            : const Color(0xFF16A34A),
                      ),
                    ),
                    if (emp.isBannerLocked) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.lock_rounded,
                          size: 12, color: Color(0xFF0052FF)),
                      const SizedBox(width: 2),
                      const Text(
                        "Banner Locked",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0052FF),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Options Menu Button (PopupMenuButton)
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
            onSelected: (action) async {
              if (enterpriseUid == null || enterpriseUid.isEmpty) return;

              if (action == 'lock_banner') {
                final newLock = !emp.isBannerLocked;
                await EnterpriseEmployeesService.instance.toggleEmployeeBannerLock(
                  enterpriseUid: enterpriseUid,
                  employeeId: emp.id,
                  locked: newLock,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(newLock
                          ? "Brand banner locked for ${emp.name}"
                          : "Brand banner unlocked for ${emp.name}"),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } else if (action == 'toggle_role') {
                final newRole = isAdmin ? 'Employee' : 'Admin';
                await EnterpriseEmployeesService.instance.updateEmployee(
                  enterpriseUid: enterpriseUid,
                  employeeId: emp.id,
                  data: {'role': newRole},
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Role updated to $newRole for ${emp.name}"),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } else if (action == 'resend') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Resent invite email to ${emp.email}"),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              } else if (action == 'delete') {
                await EnterpriseEmployeesService.instance.deleteEmployee(
                  enterpriseUid: enterpriseUid,
                  employeeId: emp.id,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Removed ${emp.name} from team."),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_role',
                child: Row(
                  children: [
                    Icon(
                      isAdmin ? Icons.person_rounded : Icons.shield_rounded,
                      size: 18,
                      color: const Color(0xFF0F172A),
                    ),
                    const SizedBox(width: 8),
                    Text(isAdmin ? "Make Employee" : "Make Admin"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'lock_banner',
                child: Row(
                  children: [
                    Icon(
                      emp.isBannerLocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                      size: 18,
                      color: const Color(0xFF0052FF),
                    ),
                    const SizedBox(width: 8),
                    Text(emp.isBannerLocked ? "Unlock Banner" : "Lock Brand Banner"),
                  ],
                ),
              ),
              if (isPending)
                const PopupMenuItem(
                  value: 'resend',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_unread_rounded,
                          size: 18, color: Color(0xFFD97706)),
                      SizedBox(width: 8),
                      Text("Resend Invite"),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 18, color: Color(0xFFEF4444)),
                    SizedBox(width: 8),
                    Text("Remove Employee",
                        style: TextStyle(color: Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


