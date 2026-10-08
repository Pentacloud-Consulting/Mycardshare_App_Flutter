import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile/enterprise_profile_store.dart';

/// Data model representing an Admin role user in the Enterprise workspace.
class AdminRoleMember {
  final String id;
  final String name;
  final String email;
  final String roleTitle; // 'Workspace Owner', 'Super Admin', 'Admin', 'Billing Manager'
  final String role; // 'Owner', 'Admin', 'Employee'
  final List<String> permissions;
  final String? avatarUrl;
  final String status;
  final bool isOwner;

  const AdminRoleMember({
    required this.id,
    required this.name,
    required this.email,
    required this.roleTitle,
    required this.role,
    this.permissions = const ['Manage Team', 'Card Editor', 'Analytics'],
    this.avatarUrl,
    this.status = 'Active',
    this.isOwner = false,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'AD';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory AdminRoleMember.fromFirestore(String id, Map<String, dynamic> data, {bool isOwner = false}) {
    final rawRole = data['role'] as String? ?? 'Admin';
    final roleTitle = isOwner
        ? 'Workspace Owner'
        : (data['roleTitle'] as String? ?? (rawRole == 'Admin' ? 'Super Admin' : rawRole));

    final rawPerms = (data['permissions'] as List<dynamic>?)?.map((e) => e.toString()).toList();

    return AdminRoleMember(
      id: id,
      name: data['name'] as String? ?? data['companyName'] as String? ?? 'Admin Member',
      email: data['email'] as String? ?? '',
      roleTitle: roleTitle,
      role: isOwner ? 'Owner' : rawRole,
      permissions: rawPerms ?? (isOwner
          ? const ['Full Control', 'Billing & Subscriptions', 'Team & Roles', 'Security & Domain']
          : const ['Manage Team', 'Card Editor', 'Analytics']),
      avatarUrl: data['avatarUrl'] as String? ?? data['logoUrl'] as String?,
      status: data['status'] as String? ?? 'Active',
      isOwner: isOwner,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'roleTitle': roleTitle,
        'role': role,
        'permissions': permissions,
        'avatarUrl': avatarUrl,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

/// Real backend service connecting Enterprise Admin Roles & Security Permissions with Firestore.
class EnterpriseAdminRolesService {
  EnterpriseAdminRolesService._internal();
  static final EnterpriseAdminRolesService instance = EnterpriseAdminRolesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Streams list of all Admin users for the enterprise (Owner + Admins from employees subcollection).
  Stream<List<AdminRoleMember>> streamAdmins([String? uid, String searchQuery = '']) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const []);
    }

    // 1. Fetch main enterprise doc to get workspace owner
    final entStream = _firestore.collection('enterprises').doc(targetUid).snapshots();

    return entStream.asyncMap((entSnap) async {
      final list = <AdminRoleMember>[];

      // Add Primary Workspace Owner
      final profile = EnterpriseProfileStore.instance.currentProfile;
      final entData = entSnap.data();
      final ownerEmail = entData?['email'] as String? ?? profile?.email ?? _auth.currentUser?.email ?? '';
      final ownerName = entData?['companyName'] as String? ?? profile?.companyName ?? 'Workspace Owner';

      list.add(AdminRoleMember(
        id: 'owner_$targetUid',
        name: ownerName,
        email: ownerEmail,
        roleTitle: 'Workspace Owner',
        role: 'Owner',
        permissions: const ['Full Control', 'Billing & Subscriptions', 'Team & Roles', 'Custom Domain'],
        avatarUrl: entData?['logoUrl'] as String? ?? profile?.logoUrl,
        status: 'Active',
        isOwner: true,
      ));

      // Fetch employees with admin role
      final empQuery = await _firestore
          .collection('enterprises')
          .doc(targetUid)
          .collection('employees')
          .get();

      for (final doc in empQuery.docs) {
        final data = doc.data();
        final role = (data['role'] as String? ?? '').toLowerCase();
        if (role == 'admin') {
          list.add(AdminRoleMember.fromFirestore(doc.id, data));
        }
      }

      // Filter by search query if provided
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        return list.where((m) {
          return m.name.toLowerCase().contains(q) ||
              m.email.toLowerCase().contains(q) ||
              m.roleTitle.toLowerCase().contains(q);
        }).toList();
      }

      return list;
    });
  }

  /// Assigns or promotes a user to Admin role in Firestore `enterprises/{uid}/employees`.
  Future<bool> assignAdminRole({
    required String uid,
    required String email,
    required String name,
    required String roleTitle,
    List<String>? permissions,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final docId = 'admin_${DateTime.now().millisecondsSinceEpoch}';

      final defaultPerms = permissions ?? const ['Manage Team', 'Card Editor', 'Analytics'];

      final adminMember = AdminRoleMember(
        id: docId,
        name: name.trim().isNotEmpty ? name.trim() : cleanEmail.split('@').first,
        email: cleanEmail,
        roleTitle: roleTitle.trim().isNotEmpty ? roleTitle.trim() : 'Super Admin',
        role: 'Admin',
        permissions: defaultPerms,
        status: 'Active',
      );

      await _firestore
          .collection('enterprises')
          .doc(uid)
          .collection('employees')
          .doc(docId)
          .set(adminMember.toFirestore());

      return true;
    } catch (e) {
      debugPrint('[EnterpriseAdminRolesService] assignAdminRole error: $e');
      return false;
    }
  }

  /// Updates existing Admin member permissions or role title.
  Future<bool> updateAdminPermissions({
    required String uid,
    required String employeeId,
    required String roleTitle,
    required List<String> permissions,
  }) async {
    try {
      await _firestore
          .collection('enterprises')
          .doc(uid)
          .collection('employees')
          .doc(employeeId)
          .update({
        'roleTitle': roleTitle,
        'permissions': permissions,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('[EnterpriseAdminRolesService] updateAdminPermissions error: $e');
      return false;
    }
  }

  /// Revokes admin access for an employee (sets role back to 'Employee').
  Future<bool> revokeAdminRole({
    required String uid,
    required String employeeId,
  }) async {
    try {
      await _firestore
          .collection('enterprises')
          .doc(uid)
          .collection('employees')
          .doc(employeeId)
          .update({
        'role': 'Employee',
        'roleTitle': 'Team Member',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('[EnterpriseAdminRolesService] revokeAdminRole error: $e');
      return false;
    }
  }
}
