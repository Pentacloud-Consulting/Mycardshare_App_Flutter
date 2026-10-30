import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile/enterprise_profile_store.dart';
import '../lock_banner/lock_banner.dart';
import '../multiple_store/enterprise_multi_store.dart';
import '../../../features/enterprise/workspace/workspace_employee_profile_view.dart';

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
      avatarUrl: (data['avatarUrl'] ?? data['profilePhoto'] ?? data['avatar']) as String?,
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
      final s = emp.status.toLowerCase();
      if (s == 'pending' || s == 'pending invite') {
        pending++;
      } else if (s == 'active') {
        // Only count explicitly 'Active' as active — Inactive/Deactivated are excluded
        active++;
      }
      // 'Inactive' and 'Deactivated' are neither active nor pending
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
    final profile = EnterpriseProfileStore.instance.currentProfile;
    final targetUid = (uid != null && uid.isNotEmpty)
        ? uid
        : (currentUid ?? profile?.uid ?? 'ent_1');

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('employees')
        .snapshots()
        .asyncMap((snapshot) async {
      List<EnterpriseEmployeeModel> list = [];
      for (final doc in snapshot.docs) {
        var emp = EnterpriseEmployeeModel.fromFirestore(doc.id, doc.data());
        
        // Cross-check user's live status ONLY when the enterprise doc says Active.
        // If admin explicitly set Inactive on the employee doc, respect that decision
        // and do NOT let the user's own card published status override it.
        final empDocStatus = emp.status.toLowerCase();
        final isAdminSetInactive = (doc.data()['adminSetInactive'] as bool?) == true;

        if (empDocStatus != 'pending' &&
            empDocStatus != 'pending invite' &&
            empDocStatus != 'inactive' &&
            !isAdminSetInactive) {
          try {
            final empData = doc.data();
            // Prefer the uid field stored on the employee doc, fall back to the doc ID
            final uidCandidate = ((empData['uid'] as String?)?.trim().isNotEmpty == true
                    ? empData['uid'] as String
                    : doc.id)
                .trim();

            DocumentSnapshot<Map<String, dynamic>>? userDoc;

            // Only look up by real Firebase Auth UID (not email-mangled string)
            if (uidCandidate.isNotEmpty) {
              final snap =
                  await _firestore.collection('users').doc(uidCandidate).get();
              if (snap.exists) userDoc = snap;
            }

            if (userDoc != null && userDoc.data() != null) {
              final uData = userDoc.data()!;
              final isPub = uData['isPublished'] as bool?;
              final cStatus = (uData['cardStatus'] as String?)?.toLowerCase();
              final uStatus = (uData['status'] as String?)?.toLowerCase();
              final realAvatar = (uData['avatarUrl'] ?? uData['profilePhoto']) as String?;

              // Mark inactive only if user doc explicitly says so
              final shouldBeInactive = isPub == false ||
                  cStatus == 'unpublished' ||
                  uStatus == 'inactive';

              // Mark active when card is explicitly published and employee doc agrees
              final shouldBeActive = (isPub == true ||
                      cStatus == 'published' ||
                      uStatus == 'active') &&
                  !shouldBeInactive;

              final effectiveAvatar = (realAvatar != null && realAvatar.trim().isNotEmpty)
                  ? realAvatar
                  : emp.avatarUrl;

              if (shouldBeInactive) {
                emp = EnterpriseEmployeeModel(
                  id: emp.id,
                  name: emp.name,
                  email: emp.email,
                  roleTitle: emp.roleTitle,
                  role: emp.role,
                  status: 'Inactive',
                  avatarUrl: effectiveAvatar,
                  views: emp.views,
                  leads: emp.leads,
                  isBannerLocked: emp.isBannerLocked,
                  lockedBannerUrl: emp.lockedBannerUrl,
                  createdAt: emp.createdAt,
                );
              } else if (shouldBeActive && empDocStatus != 'active') {
                emp = EnterpriseEmployeeModel(
                  id: emp.id,
                  name: emp.name,
                  email: emp.email,
                  roleTitle: emp.roleTitle,
                  role: emp.role,
                  status: 'Active',
                  avatarUrl: effectiveAvatar,
                  views: emp.views,
                  leads: emp.leads,
                  isBannerLocked: emp.isBannerLocked,
                  lockedBannerUrl: emp.lockedBannerUrl,
                  createdAt: emp.createdAt,
                );
              } else if (effectiveAvatar != emp.avatarUrl) {
                emp = EnterpriseEmployeeModel(
                  id: emp.id,
                  name: emp.name,
                  email: emp.email,
                  roleTitle: emp.roleTitle,
                  role: emp.role,
                  status: emp.status,
                  avatarUrl: effectiveAvatar,
                  views: emp.views,
                  leads: emp.leads,
                  isBannerLocked: emp.isBannerLocked,
                  lockedBannerUrl: emp.lockedBannerUrl,
                  createdAt: emp.createdAt,
                );
              }
            }
          } catch (_) {}
        }
        list.add(emp);
      }

      // Check users collection where enterpriseUid matches this targetUid (or companyName matches)
      // to guarantee any newly joined employees appear instantly on the team page!
      try {
        final existingEmails = list.map((e) => e.email.toLowerCase().trim()).toSet();
        
        final usersSnap = await _firestore
            .collection('users')
            .where('enterpriseUid', isEqualTo: targetUid)
            .get();

        for (final uDoc in usersSnap.docs) {
          final uData = uDoc.data();
          final uEmail = (uData['email'] as String? ?? '').trim();
          if (uEmail.isNotEmpty && !existingEmails.contains(uEmail.toLowerCase())) {
            existingEmails.add(uEmail.toLowerCase());
            final uName = (uData['fullName'] ?? uData['name'] as String?)?.trim();
            final name = (uName != null && uName.isNotEmpty) ? uName : uEmail.split('@').first;
            final uAvatar = (uData['avatarUrl'] ?? uData['profilePhoto']) as String?;
            final uStatus = (uData['status'] as String?)?.trim() ?? 'Active';
            final uRole = (uData['role'] as String?)?.trim() ?? 'Employee';

            list.add(EnterpriseEmployeeModel(
              id: uDoc.id,
              name: name,
              email: uEmail,
              roleTitle: 'Team Member',
              role: uRole.toLowerCase() == 'admin' ? 'Admin' : 'Employee',
              status: uStatus.isNotEmpty ? uStatus : 'Active',
              avatarUrl: uAvatar,
              views: (uData['views'] as num?)?.toInt() ?? 0,
              leads: (uData['leads'] as num?)?.toInt() ?? 0,
            ));
          }
        }

        // Also query by enterprise companyName if available
        final compName = profile?.companyName.trim();
        if (compName != null && compName.isNotEmpty) {
          final compUsersSnap = await _firestore
              .collection('users')
              .where('companyName', isEqualTo: compName)
              .get();

          for (final uDoc in compUsersSnap.docs) {
            final uData = uDoc.data();
            final uEmail = (uData['email'] as String? ?? '').trim();
            final uRole = (uData['role'] as String? ?? '').trim().toLowerCase();
            if (uEmail.isNotEmpty &&
                uRole == 'employee' &&
                !existingEmails.contains(uEmail.toLowerCase())) {
              existingEmails.add(uEmail.toLowerCase());
              final uName = (uData['fullName'] ?? uData['name'] as String?)?.trim();
              final name = (uName != null && uName.isNotEmpty) ? uName : uEmail.split('@').first;
              final uAvatar = (uData['avatarUrl'] ?? uData['profilePhoto']) as String?;
              final uStatus = (uData['status'] as String?)?.trim() ?? 'Active';

              list.add(EnterpriseEmployeeModel(
                id: uDoc.id,
                name: name,
                email: uEmail,
                roleTitle: 'Team Member',
                role: 'Employee',
                status: uStatus.isNotEmpty ? uStatus : 'Active',
                avatarUrl: uAvatar,
                views: (uData['views'] as num?)?.toInt() ?? 0,
                leads: (uData['leads'] as num?)?.toInt() ?? 0,
              ));
            }
          }
        }
      } catch (uErr) {
        debugPrint('[EnterpriseEmployeesService] Error merging joined users: $uErr');
      }

      // Also check enterprises/{uid} invitedEmails array so pending invites also show up
      try {
        final entDoc = await _firestore.collection('enterprises').doc(targetUid).get();
        if (entDoc.exists && entDoc.data() != null) {
          final data = entDoc.data()!;
          final invitedEmails = (data['invitedEmails'] as List<dynamic>?) ?? [];
          final existingEmails = list.map((e) => e.email.toLowerCase().trim()).toSet();

          for (int i = 0; i < invitedEmails.length; i++) {
            final em = invitedEmails[i].toString().trim();
            if (em.isNotEmpty && !existingEmails.contains(em.toLowerCase())) {
              existingEmails.add(em.toLowerCase());
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

  /// Delete an employee — also writes tombstone so they cannot login again.
  Future<bool> deleteEmployee({
    required String enterpriseUid,
    required String employeeId,
  }) async {
    try {
      // Fetch employee data before deleting so we can write the tombstone
      String empEmail = '';
      String empName = '';
      String empUid = '';
      try {
        final empDoc = await _firestore
            .collection('enterprises')
            .doc(enterpriseUid)
            .collection('employees')
            .doc(employeeId)
            .get();
        if (empDoc.exists) {
          final d = empDoc.data() ?? {};
          empEmail = (d['email'] ?? '').toString().trim().toLowerCase();
          empName = (d['name'] ?? d['fullName'] ?? '').toString().trim();
          empUid = (d['uid'] ?? d['id'] ?? '').toString().trim();
        }
      } catch (_) {}

      // Delete from enterprise employees subcollection
      await _firestore
          .collection('enterprises')
          .doc(enterpriseUid)
          .collection('employees')
          .doc(employeeId)
          .delete();

      // Write tombstone to deleted_accounts so login is blocked
      final tombstoneData = <String, dynamic>{
        'userId': empUid.isNotEmpty ? empUid : employeeId,
        'email': empEmail,
        'userName': empName,
        'status': 'Deleted',
        'isDeleted': true,
        'isDeactivated': true,
        'deleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': 'enterprise_admin',
        'reason': 'Employee removed by workspace administrator',
      };
      try {
        // Write by employee doc ID
        await _firestore.collection('deleted_accounts').doc(employeeId).set(tombstoneData);
        // Write by UID if different
        if (empUid.isNotEmpty && empUid != employeeId) {
          await _firestore.collection('deleted_accounts').doc(empUid).set(tombstoneData);
        }
        // Write by email and safe-email
        if (empEmail.isNotEmpty) {
          await _firestore.collection('deleted_accounts').doc(empEmail).set(tombstoneData);
          final safeEmail = empEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          await _firestore.collection('deleted_accounts').doc(safeEmail).set(tombstoneData);
        }
        debugPrint('[EnterpriseEmployeesService] Tombstone written for employee $employeeId ($empEmail)');
      } catch (tombErr) {
        debugPrint('[EnterpriseEmployeesService] Tombstone write note: $tombErr');
      }

      // Also mark user as deleted in users collection
      try {
        if (empUid.isNotEmpty) {
          await _firestore.collection('users').doc(empUid).set({
            'status': 'Deleted',
            'isDeleted': true,
            'isDeactivated': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        if (empEmail.isNotEmpty) {
          final safeEmail = empEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          await _firestore.collection('users').doc(safeEmail).set({
            'status': 'Deleted',
            'isDeleted': true,
            'isDeactivated': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('[EnterpriseEmployeesService] deleteEmployee error: $e');
      return false;
    }
  }

  // Local state to track logged-in employee session
  String? _activeEnterpriseUid;
  String? _activeEmployeeEmail;

  void saveActiveEmployeeSession(String enterpriseUid, String email) {
    _activeEnterpriseUid = enterpriseUid;
    _activeEmployeeEmail = email.trim().toLowerCase();
  }

  String? get activeEnterpriseUid => _activeEnterpriseUid;
  String? get activeEmployeeEmail => _activeEmployeeEmail;

  /// Marks an employee as Active when they log in / join workspace.
  /// If the employee does not exist in enterprises/{uid}/employees, adds them automatically.
  Future<bool> markEmployeeActive({
    required String enterpriseUid,
    required String email,
    String? name,
    String? uid,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final authUid = uid?.trim().isNotEmpty == true
          ? uid!
          : (_auth.currentUser?.uid ?? '');
      saveActiveEmployeeSession(enterpriseUid, cleanEmail);

      final snap = await _firestore
          .collection('enterprises')
          .doc(enterpriseUid)
          .collection('employees')
          .where('email', isEqualTo: cleanEmail)
          .get();

      if (snap.docs.isNotEmpty) {
        // Employee exists -> persist uid and mark Active ONLY if admin has NOT set them Inactive.
        // If adminSetInactive is true, the enterprise admin explicitly deactivated this employee.
        // In that case, we still store the uid/name but do NOT flip status back to Active.
        final docId = snap.docs.first.id;
        final existingData = snap.docs.first.data();
        final adminSetInactive = (existingData['adminSetInactive'] as bool?) == true;

        final updateMap = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (authUid.isNotEmpty) updateMap['uid'] = authUid;
        if (name != null && name.trim().isNotEmpty) {
          updateMap['name'] = name.trim();
        }

        // Only reset to Active if admin hasn't explicitly inactivated this employee
        if (!adminSetInactive) {
          updateMap['status'] = 'Active';
          updateMap['isPublished'] = true;
        }

        await _firestore
            .collection('enterprises')
            .doc(enterpriseUid)
            .collection('employees')
            .doc(docId)
            .update(updateMap);
      } else {
        // Employee does not exist -> add new employee record automatically
        final empId = authUid.isNotEmpty
            ? authUid
            : 'emp_${DateTime.now().millisecondsSinceEpoch}';
        final newName = (name != null && name.trim().isNotEmpty)
            ? name.trim()
            : cleanEmail.split('@').first;

        // Try to fetch existing avatar from global users collection
        String? existingAvatarUrl;
        String? existingBannerUrl;
        String? existingCardSlug;
        try {
          if (authUid.isNotEmpty) {
            final userDoc = await _firestore.collection('users').doc(authUid).get();
            if (userDoc.exists) {
              final uData = userDoc.data() ?? {};
              existingAvatarUrl = (uData['avatarUrl'] ?? uData['profilePhoto'] ?? uData['photoURL'])?.toString()?.trim();
              existingBannerUrl = (uData['bannerUrl'] ?? uData['bannerPhoto'] ?? uData['coverImage'])?.toString()?.trim();
              existingCardSlug = (uData['cardSlug'] ?? uData['slug'])?.toString()?.trim();
            }
          }
          // Also check email-based doc
          if (existingAvatarUrl == null || existingAvatarUrl!.isEmpty) {
            final emailDocId = cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
            final emailDoc = await _firestore.collection('users').doc(emailDocId).get();
            if (emailDoc.exists) {
              final eData = emailDoc.data() ?? {};
              existingAvatarUrl = (eData['avatarUrl'] ?? eData['profilePhoto'] ?? eData['photoURL'])?.toString()?.trim();
              existingBannerUrl ??= (eData['bannerUrl'] ?? eData['bannerPhoto'])?.toString()?.trim();
              existingCardSlug ??= (eData['cardSlug'] ?? eData['slug'])?.toString()?.trim();
            }
          }
        } catch (_) {}

        final generatedSlug = existingCardSlug?.isNotEmpty == true
            ? existingCardSlug!
            : '${newName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-')}-${DateTime.now().millisecondsSinceEpoch % 10000}';

        final newEmp = <String, dynamic>{
          'id': empId,
          'uid': authUid,
          'name': newName,
          'fullName': newName,
          'email': cleanEmail,
          'roleTitle': 'Team Member',
          'role': 'Employee',
          'status': 'Active',
          'isPublished': true,
          'views': 0,
          'leads': 0,
          'isBannerLocked': false,
          // Preserve any existing avatar/banner — these will be set after onboarding
          if (existingAvatarUrl != null && existingAvatarUrl!.isNotEmpty)
            'avatarUrl': existingAvatarUrl,
          if (existingBannerUrl != null && existingBannerUrl!.isNotEmpty)
            'bannerUrl': existingBannerUrl,
          'cardSlug': generatedSlug,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('enterprises')
            .doc(enterpriseUid)
            .collection('employees')
            .doc(empId)
            .set(newEmp);

        // Update invitedEmails list on enterprise
        await _firestore.collection('enterprises').doc(enterpriseUid).set({
          'invitedEmails': FieldValue.arrayUnion([cleanEmail]),
        }, SetOptions(merge: true));
      }

      return true;
    } catch (e) {
      debugPrint('[EnterpriseEmployeesService] markEmployeeActive error: $e');
      return false;
    }
  }

  /// Marks an employee as Inactive when they log out.
  Future<bool> markEmployeeInactive({
    String? enterpriseUid,
    String? email,
  }) async {
    try {
      final targetUid = enterpriseUid ?? _activeEnterpriseUid ?? currentUid;
      final targetEmail = (email ?? _activeEmployeeEmail ?? _auth.currentUser?.email ?? '').trim().toLowerCase();

      if (targetUid == null || targetUid.isEmpty || targetEmail.isEmpty) {
        return false;
      }

      final snap = await _firestore
          .collection('enterprises')
          .doc(targetUid)
          .collection('employees')
          .where('email', isEqualTo: targetEmail)
          .get();

      if (snap.docs.isNotEmpty) {
        final docId = snap.docs.first.id;
        await _firestore
            .collection('enterprises')
            .doc(targetUid)
            .collection('employees')
            .doc(docId)
            .update({
          'status': 'Inactive',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _activeEnterpriseUid = null;
      _activeEmployeeEmail = null;
      return true;
    } catch (e) {
      debugPrint('[EnterpriseEmployeesService] markEmployeeInactive error: $e');
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkspaceEmployeeProfileView(
                employee: emp,
                enterpriseUid: enterpriseUid,
              ),
            ),
          );
        },
        child: Padding(
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
              child: Builder(
                builder: (context) {
                  final av = emp.avatarUrl?.trim();
                  Widget? imageWidget;

                  if (av != null && av.isNotEmpty) {
                    if (av.startsWith('data:image')) {
                      try {
                        final commaIdx = av.indexOf(',');
                        final b64 = commaIdx != -1 ? av.substring(commaIdx + 1) : av;
                        imageWidget = Image.memory(
                          base64Decode(b64),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackInitialWidget(emp, isAdmin, isPending),
                        );
                      } catch (_) {}
                    } else if (av.startsWith('http')) {
                      imageWidget = Image.network(
                        av,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackInitialWidget(emp, isAdmin, isPending),
                      );
                    } else if (File(av).existsSync()) {
                      imageWidget = Image.file(
                        File(av),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackInitialWidget(emp, isAdmin, isPending),
                      );
                    }
                  }

                  return imageWidget ?? _buildFallbackInitialWidget(emp, isAdmin, isPending);
                },
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
                    Builder(
                      builder: (context) {
                        final isInactive = emp.status.toLowerCase() == 'inactive' ||
                            emp.status.toLowerCase() == 'deactivated';
                        final statusColor = isPending
                            ? const Color(0xFFD97706)
                            : isInactive
                                ? const Color(0xFF64748B)
                                : const Color(0xFF16A34A);

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              emp.status,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        );
                      },
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

              if (action == 'view_profile') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WorkspaceEmployeeProfileView(
                      employee: emp,
                      enterpriseUid: enterpriseUid,
                    ),
                  ),
                );
                return;
              }

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
              } else if (action == 'toggle_status') {
                // Toggle Active <-> Inactive directly on enterprise employee doc.
                // adminSetInactive flag ensures streamEmployees does NOT override
                // the enterprise admin's explicit decision with the user's card status.
                final isCurrentlyActive = emp.status.toLowerCase() == 'active';
                final newStatus = isCurrentlyActive ? 'Inactive' : 'Active';
                final settingInactive = isCurrentlyActive; // true when going Active -> Inactive

                await EnterpriseEmployeesService.instance.updateEmployee(
                  enterpriseUid: enterpriseUid,
                  employeeId: emp.id,
                  data: {
                    'status': newStatus,
                    'isPublished': !settingInactive,
                    // Guard flag: prevents streamEmployees from re-overriding status
                    'adminSetInactive': settingInactive,
                  },
                );

                // Also sync the status to the user's own Firestore document
                try {
                  final empDoc = await FirebaseFirestore.instance
                      .collection('enterprises')
                      .doc(enterpriseUid)
                      .collection('employees')
                      .doc(emp.id)
                      .get();
                  final empUid = (empDoc.data()?['uid'] as String?)?.trim() ?? '';
                  if (empUid.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(empUid)
                        .set({
                      'status': newStatus,
                      'isPublished': !settingInactive,
                      'cardStatus': settingInactive ? 'Unpublished' : 'Published',
                      'updatedAt': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));
                  }
                } catch (_) {}
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${emp.name} is now $newStatus"),
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
            itemBuilder: (context) {
              final isCurrentlyActive = emp.status.toLowerCase() == 'active';
              return [
              const PopupMenuItem(
                value: 'view_profile',
                child: Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: Color(0xFF0052FF),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "View Profile",
                      style: TextStyle(
                        color: Color(0xFF0052FF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(
                      isCurrentlyActive
                          ? Icons.person_off_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 18,
                      color: isCurrentlyActive
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCurrentlyActive ? "Set Inactive" : "Set Active",
                      style: TextStyle(
                        color: isCurrentlyActive
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF16A34A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
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
            ];
            },
          ),
        ],
      ),
    ),
  ),
);
  }

  static Widget _buildFallbackInitialWidget(
      EnterpriseEmployeeModel emp, bool isAdmin, bool isPending) {
    return Center(
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
    );
  }
}


