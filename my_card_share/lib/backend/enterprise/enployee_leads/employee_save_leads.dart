import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile/enterprise_profile_store.dart';
import '../../employee_join/home/employee_home_backend.dart';
import '../../employee_join/home/employee_stats_backend.dart';
import '../../individual/previews/individual_metrics_store.dart';

/// Data model representing a saved lead for a particular enterprise employee.
class EmployeeSavedLeadItem {
  final String id;
  final String enterpriseUid;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String notes;
  final String status; // 'New', 'Synced', 'Contacted', 'Qualified', 'Lost'
  final String source; // 'via Manual', 'via Scanner', 'via QR', 'via Public Card', etc.
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? avatarUrl;

  const EmployeeSavedLeadItem({
    required this.id,
    required this.enterpriseUid,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    this.notes = '',
    this.status = 'New',
    this.source = 'via Manual',
    required this.createdAt,
    this.updatedAt,
    this.avatarUrl,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'LD';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory EmployeeSavedLeadItem.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    DateTime dt = DateTime.now();
    if (data['createdAt'] is Timestamp) {
      dt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      dt = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
    } else if (data['timestamp'] is Timestamp) {
      dt = (data['timestamp'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      dt = DateTime.tryParse(data['date']) ?? DateTime.now();
    }

    DateTime? upDt;
    if (data['updatedAt'] is Timestamp) {
      upDt = (data['updatedAt'] as Timestamp).toDate();
    } else if (data['updatedAt'] is String) {
      upDt = DateTime.tryParse(data['updatedAt']);
    }

    return EmployeeSavedLeadItem(
      id: id,
      enterpriseUid: data['enterpriseUid'] ?? '',
      employeeId: data['employeeId'] ?? data['assignedTo'] ?? '',
      employeeName:
          data['employeeName'] ?? data['capturedBy'] ?? 'Team Member',
      employeeEmail: data['employeeEmail'] ?? '',
      name: data['name'] ?? data['fullName'] ?? 'Lead Contact',
      email: data['email'] ?? '',
      phone: data['phone'] ?? data['mobile'] ?? '',
      company: data['company'] ?? 'Independent',
      notes: data['notes'] ?? '',
      status: data['status'] ?? 'New',
      source: data['source'] ?? data['capturedVia'] ?? 'via Manual',
      createdAt: dt,
      updatedAt: upDt,
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'enterpriseUid': enterpriseUid,
        'employeeId': employeeId,
        'employeeName': employeeName,
        'employeeEmail': employeeEmail,
        'capturedBy': employeeName,
        'name': name,
        'email': email,
        'phone': phone,
        'company': company,
        'notes': notes,
        'status': status,
        'source': source,
        'avatarUrl': avatarUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

/// Summary statistics of leads carried by a particular employee.
class EmployeeLeadSummary {
  final String employeeId;
  final String employeeName;
  final int totalLeads;
  final int newLeads;
  final int contactedLeads;
  final int qualifiedLeads;

  const EmployeeLeadSummary({
    required this.employeeId,
    required this.employeeName,
    required this.totalLeads,
    this.newLeads = 0,
    this.contactedLeads = 0,
    this.qualifiedLeads = 0,
  });
}

/// Accurate Backend Service for saving, managing, and synchronizing
/// particular enterprise employee leads.
///
/// Features:
///  - Saves leads directly under `enterprises/{enterpriseUid}/employees/{employeeId}/leads`
///  - Mirrors leads to `enterprises/{enterpriseUid}/leads` and `users/{employeeUid}/leads`
///  - Directly increments & updates the `leads` counter on that particular employee doc
///    so it immediately displays on the Top Performers leaderboard (Image 1 board view).
///  - Supports fuzzy matching by employee name (e.g. Zuhaib, Tushti, Fatima, Waseem),
///    email, UID, or document ID.
///  - Provides real-time streaming and syncing for accurate employee lead counts.
class EnterpriseEmployeeSaveLeadsService extends ChangeNotifier {
  EnterpriseEmployeeSaveLeadsService._internal();
  static final EnterpriseEmployeeSaveLeadsService instance =
      EnterpriseEmployeeSaveLeadsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Resolves the most accurate enterprise UID across session, stores, and auth.
  Future<String?> resolveEnterpriseUid([String? explicitUid]) async {
    if (explicitUid != null && explicitUid.trim().isNotEmpty) {
      return explicitUid.trim();
    }

    // 1. Check EmployeeHomeBackendService session
    final sessionEntUid = EmployeeHomeBackendService.instance.enterpriseUid;
    if (sessionEntUid != null && sessionEntUid.isNotEmpty) {
      return sessionEntUid;
    }

    // 2. Check active EnterpriseProfileStore
    final profileUid = EnterpriseProfileStore.instance.currentProfile?.uid;
    if (profileUid != null && profileUid.isNotEmpty) {
      return profileUid;
    }

    // 3. Fallback to FirebaseAuth currentUser UID
    final authUid = currentUid;
    if (authUid != null && authUid.isNotEmpty) {
      // Check if this UID exists as an enterprise doc
      try {
        final entDoc =
            await _firestore.collection('enterprises').doc(authUid).get();
        if (entDoc.exists) return authUid;
      } catch (_) {}
    }

    // 4. Query users doc to see if enterpriseUid is specified
    if (authUid != null && authUid.isNotEmpty) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(authUid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final entUid = userDoc.data()?['enterpriseUid'] as String?;
          if (entUid != null && entUid.isNotEmpty) return entUid;
        }
      } catch (_) {}
    }

    return authUid;
  }

  /// Locates the specific employee doc under `enterprises/{enterpriseUid}/employees`
  /// using employeeId, UID, email, or name (case-insensitive fuzzy match).
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> findEmployeeDoc({
    required String enterpriseUid,
    required String employeeIdentifier,
    String? employeeEmail,
    String? employeeName,
  }) async {
    if (enterpriseUid.isEmpty) return null;

    final employeesRef = _firestore
        .collection('enterprises')
        .doc(enterpriseUid)
        .collection('employees');

    // 1. Direct document ID lookup
    if (employeeIdentifier.isNotEmpty) {
      final docById = await employeesRef.doc(employeeIdentifier).get();
      if (docById.exists && docById.data() != null) {
        final snap = await employeesRef
            .where(FieldPath.documentId, isEqualTo: employeeIdentifier)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) return snap.docs.first;
      }
    }

    // Fetch all employees to allow robust matching
    final allEmpSnap = await employeesRef.get();
    if (allEmpSnap.docs.isEmpty) return null;

    final targetId = employeeIdentifier.trim().toLowerCase();
    final targetEmail = (employeeEmail ?? '').trim().toLowerCase();
    final targetName = (employeeName ?? '').trim().toLowerCase();

    // 2. Match by UID or id field
    for (final doc in allEmpSnap.docs) {
      final data = doc.data();
      final uid = (data['uid'] ?? '').toString().trim().toLowerCase();
      final id = (data['id'] ?? doc.id).toString().trim().toLowerCase();
      if (targetId.isNotEmpty && (uid == targetId || id == targetId)) {
        return doc;
      }
    }

    // 3. Match by email
    if (targetEmail.isNotEmpty || targetId.contains('@')) {
      final searchEmail =
          targetEmail.isNotEmpty ? targetEmail : targetId;
      for (final doc in allEmpSnap.docs) {
        final email = (doc.data()['email'] ?? '').toString().trim().toLowerCase();
        if (email.isNotEmpty && email == searchEmail) {
          return doc;
        }
      }
    }

    // 4. Match by name (e.g. Zuhaib, Tushti, Fatima, Waseem)
    final searchName =
        targetName.isNotEmpty ? targetName : targetId;
    if (searchName.isNotEmpty) {
      for (final doc in allEmpSnap.docs) {
        final name = (doc.data()['name'] ?? doc.data()['fullName'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        if (name.isNotEmpty &&
            (name == searchName ||
                name.contains(searchName) ||
                searchName.contains(name))) {
          return doc;
        }
      }
    }

    return null;
  }

  /// Accurately saves a lead for a particular enterprise employee.
  ///
  /// Steps performed:
  ///  1. Identifies the specific employee document in `enterprises/{enterpriseUid}/employees`
  ///  2. Writes lead to `enterprises/{enterpriseUid}/employees/{empDocId}/leads/{leadId}`
  ///  3. Writes lead to `enterprises/{enterpriseUid}/leads/{leadId}`
  ///  4. Writes lead to `users/{employeeUid}/leads/{leadId}` if employee has a user UID
  ///  5. Atomically increments and updates `leads` on the employee document
  ///  6. Refreshes local reactive metrics so Image 1 board view updates instantly
  Future<bool> saveLeadForEmployee({
    String? enterpriseUid,
    required String employeeId,
    String? employeeName,
    String? employeeEmail,
    required String leadName,
    String leadEmail = '',
    String leadPhone = '',
    String leadCompany = 'Independent',
    String notes = '',
    String status = 'New',
    String source = 'via Manual',
    String? avatarUrl,
    String? existingLeadId, // If provided, skip dedup and use this ID directly
  }) async {
    try {
      final entUid = await resolveEnterpriseUid(enterpriseUid);
      if (entUid == null || entUid.isEmpty) {
        debugPrint(
            '[EnterpriseEmployeeSaveLeadsService] Error: Unable to resolve enterpriseUid.');
        return false;
      }

      // 1. Locate specific employee document
      final empDoc = await findEmployeeDoc(
        enterpriseUid: entUid,
        employeeIdentifier: employeeId,
        employeeEmail: employeeEmail,
        employeeName: employeeName,
      );

      final String resolvedEmpDocId;
      final String resolvedEmpName;
      final String resolvedEmpEmail;
      final String resolvedEmpUid;

      if (empDoc != null) {
        resolvedEmpDocId = empDoc.id;
        final d = empDoc.data();
        resolvedEmpName = (d['name'] ?? d['fullName'] ?? employeeName ?? 'Team Member').toString().trim();
        resolvedEmpEmail = (d['email'] ?? employeeEmail ?? '').toString().trim();
        resolvedEmpUid = (d['uid'] ?? '').toString().trim();
      } else {
        // Fallback: use passed parameters or docId
        resolvedEmpDocId = employeeId.trim().isNotEmpty ? employeeId.trim() : 'emp_${DateTime.now().millisecondsSinceEpoch}';
        resolvedEmpName = (employeeName ?? 'Team Member').trim();
        resolvedEmpEmail = (employeeEmail ?? '').trim();
        resolvedEmpUid = employeeId.trim();
      }

      // If caller already resolved a deduped leadId, use it directly (skip dedup query)
      String leadId = (existingLeadId != null && existingLeadId.isNotEmpty)
          ? existingLeadId
          : 'lead_${DateTime.now().millisecondsSinceEpoch}';
      final cleanLeadEmail = leadEmail.trim().toLowerCase();
      final cleanLeadPhone = leadPhone.replaceAll(RegExp(r'\D'), '');

      // Deduplication check: check if a lead with same email or phone already exists
      // (only run if no existingLeadId was passed in)
      try {
        if (existingLeadId == null && cleanLeadEmail.isNotEmpty) {
          final existing = await _firestore
              .collection('enterprises')
              .doc(entUid)
              .collection('employees')
              .doc(resolvedEmpDocId)
              .collection('leads')
              .where('email', isEqualTo: cleanLeadEmail)
              .limit(1)
              .get();
          if (existing.docs.isNotEmpty) {
            leadId = existing.docs.first.id;
            debugPrint('[EnterpriseEmployeeSaveLeadsService] Found existing lead with email $cleanLeadEmail: $leadId. Updating.');
          }
        }
        if (leadId.startsWith('lead_') &&
            existingLeadId == null &&
            cleanLeadPhone.isNotEmpty && cleanLeadPhone.length >= 7) {
          final existingPhone = await _firestore
              .collection('enterprises')
              .doc(entUid)
              .collection('employees')
              .doc(resolvedEmpDocId)
              .collection('leads')
              .where('phone', isEqualTo: leadPhone.trim())
              .limit(1)
              .get();
          if (existingPhone.docs.isNotEmpty) {
            leadId = existingPhone.docs.first.id;
            debugPrint('[EnterpriseEmployeeSaveLeadsService] Found existing lead with phone $cleanLeadPhone: $leadId. Updating.');
          }
        }
      } catch (_) {}

      final leadItem = EmployeeSavedLeadItem(
        id: leadId,
        enterpriseUid: entUid,
        employeeId: resolvedEmpDocId,
        employeeName: resolvedEmpName,
        employeeEmail: resolvedEmpEmail,
        name: leadName.trim(),
        email: leadEmail.trim(),
        phone: leadPhone.trim(),
        company: leadCompany.trim().isNotEmpty ? leadCompany.trim() : 'Independent',
        notes: notes.trim(),
        status: status.trim().isNotEmpty ? status.trim() : 'New',
        source: source.trim().isNotEmpty ? source.trim() : 'via Manual',
        createdAt: DateTime.now(),
        avatarUrl: avatarUrl,
      );

      final leadDataMap = leadItem.toFirestore();

      // 2. Save in enterprises/{entUid}/employees/{empDocId}/leads
      final empLeadsRef = _firestore
          .collection('enterprises')
          .doc(entUid)
          .collection('employees')
          .doc(resolvedEmpDocId)
          .collection('leads')
          .doc(leadId);
      await empLeadsRef.set(leadDataMap, SetOptions(merge: true));

      // 3. Save in enterprises/{entUid}/leads for enterprise-wide records
      final entLeadsRef = _firestore
          .collection('enterprises')
          .doc(entUid)
          .collection('leads')
          .doc(leadId);
      await entLeadsRef.set(leadDataMap, SetOptions(merge: true));

      // 4. Save in users/{empUid}/leads if user UID is available
      final effectiveUserUid = resolvedEmpUid.isNotEmpty
          ? resolvedEmpUid
          : (resolvedEmpEmail.isNotEmpty
              ? resolvedEmpEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
              : '');
      if (effectiveUserUid.isNotEmpty) {
        try {
          await _firestore
              .collection('users')
              .doc(effectiveUserUid)
              .collection('leads')
              .doc(leadId)
              .set(leadDataMap, SetOptions(merge: true));
        } catch (_) {}
      }

      // 5. Accurately update leads count on the employee document
      final empDocRef = _firestore
          .collection('enterprises')
          .doc(entUid)
          .collection('employees')
          .doc(resolvedEmpDocId);

      // Count total actual leads in this employee's leads subcollection
      final currentLeadsSnap = await _firestore
          .collection('enterprises')
          .doc(entUid)
          .collection('employees')
          .doc(resolvedEmpDocId)
          .collection('leads')
          .get();

      final actualTotalLeads = currentLeadsSnap.docs.length;

      await empDocRef.set({
        'leads': actualTotalLeads,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint(
          '[EnterpriseEmployeeSaveLeadsService] Saved lead "$leadName" for $resolvedEmpName (ID: $resolvedEmpDocId). Total leads now: $actualTotalLeads');

      // 6. Update reactive stores if current user matches this employee
      final currentUserEmail = _auth.currentUser?.email?.toLowerCase() ?? '';
      final currentUserName = _auth.currentUser?.displayName?.toLowerCase() ?? '';
      if ((resolvedEmpUid.isNotEmpty && resolvedEmpUid == currentUid) ||
          (currentUserEmail.isNotEmpty && resolvedEmpEmail.toLowerCase() == currentUserEmail) ||
          (currentUserName.isNotEmpty && resolvedEmpName.toLowerCase() == currentUserName)) {
        try {
          if (currentUid != null && currentUid!.isNotEmpty) {
            await IndividualMetricsStore.instance.incrementLeads(currentUid!);
          }
          await EmployeeStatsBackendService.instance.loadEmployeeStats();
        } catch (_) {}
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[EnterpriseEmployeeSaveLeadsService] saveLeadForEmployee error: $e');
      return false;
    }
  }

  /// Recalculates and updates accurate lead counts for ALL employees in the enterprise.
  /// Scans employee subcollections, enterprise leads, and user leads.
  Future<Map<String, int>> syncAndRecalculateEmployeeLeads([String? enterpriseUid]) async {
    final Map<String, int> resultMap = {};
    try {
      final entUid = await resolveEnterpriseUid(enterpriseUid);
      if (entUid == null || entUid.isEmpty) return resultMap;

      final empSnap = await _firestore
          .collection('enterprises')
          .doc(entUid)
          .collection('employees')
          .get();

      if (empSnap.docs.isEmpty) return resultMap;

      // Also get enterprise-wide leads
      final entLeadsSnap = await _firestore
          .collection('enterprises')
          .doc(entUid)
          .collection('leads')
          .get();

      final entLeads = entLeadsSnap.docs.map((d) => d.data()).toList();

      for (final doc in empSnap.docs) {
        final empDocId = doc.id;
        final data = doc.data();
        final empName = (data['name'] ?? data['fullName'] ?? '').toString().trim().toLowerCase();
        final empEmail = (data['email'] ?? '').toString().trim().toLowerCase();
        final empUid = (data['uid'] ?? '').toString().trim();
        final currentLeadsCount = (data['leads'] as num?)?.toInt() ?? 0;

        // 1. Count from enterprises/{entUid}/employees/{empDocId}/leads
        int subcollectionCount = 0;
        try {
          final subSnap = await _firestore
              .collection('enterprises')
              .doc(entUid)
              .collection('employees')
              .doc(empDocId)
              .collection('leads')
              .get();
          subcollectionCount = subSnap.docs.length;
        } catch (_) {}

        // 2. Count from enterprises/{entUid}/leads matching this employee
        int entMatchingCount = 0;
        for (final l in entLeads) {
          final cId = (l['employeeId'] ?? l['assignedTo'] ?? '').toString().trim();
          final cEmail = (l['employeeEmail'] ?? l['email'] ?? '').toString().trim().toLowerCase();
          final cName = (l['employeeName'] ?? l['capturedBy'] ?? '').toString().trim().toLowerCase();

          if ((cId.isNotEmpty && (cId == empDocId || cId == empUid)) ||
              (empEmail.isNotEmpty && cEmail == empEmail) ||
              (empName.isNotEmpty && (cName == empName || cName.contains(empName)))) {
            entMatchingCount++;
          }
        }

        // 3. Count from users/{empUid}/leads if exists
        int userLeadsCount = 0;
        final candidateUids = <String>{};
        if (empUid.isNotEmpty) candidateUids.add(empUid);
        if (empEmail.isNotEmpty) {
          candidateUids.add(empEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_'));
        }
        for (final uId in candidateUids) {
          try {
            final uSnap = await _firestore
                .collection('users')
                .doc(uId)
                .collection('leads')
                .get();
            if (uSnap.docs.length > userLeadsCount) {
              userLeadsCount = uSnap.docs.length;
            }
          } catch (_) {}
        }

        final accurateLeads = [
          currentLeadsCount,
          subcollectionCount,
          entMatchingCount,
          userLeadsCount,
        ].reduce((a, b) => a > b ? a : b);

        resultMap[empDocId] = accurateLeads;

        // Update employee doc in Firestore if needed
        if (accurateLeads != currentLeadsCount) {
          await _firestore
              .collection('enterprises')
              .doc(entUid)
              .collection('employees')
              .doc(empDocId)
              .set({
            'leads': accurateLeads,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          debugPrint(
              '[EnterpriseEmployeeSaveLeadsService] Synced employee ${data['name']} -> $accurateLeads leads');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('[EnterpriseEmployeeSaveLeadsService] syncAndRecalculateEmployeeLeads error: $e');
    }
    return resultMap;
  }

  /// Real-time stream of leads saved for a particular employee.
  Stream<List<EmployeeSavedLeadItem>> streamEmployeeLeads({
    String? enterpriseUid,
    required String employeeId,
  }) async* {
    final entUid = await resolveEnterpriseUid(enterpriseUid);
    if (entUid == null || entUid.isEmpty) {
      yield const [];
      return;
    }

    final empDoc = await findEmployeeDoc(
      enterpriseUid: entUid,
      employeeIdentifier: employeeId,
    );
    final targetDocId = empDoc != null ? empDoc.id : employeeId;

    yield* _firestore
        .collection('enterprises')
        .doc(entUid)
        .collection('employees')
        .doc(targetDocId)
        .collection('leads')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => EmployeeSavedLeadItem.fromFirestore(d.id, d.data()))
          .toList();
    });
  }

  /// Real-time stream of all leads under the enterprise.
  Stream<List<EmployeeSavedLeadItem>> streamAllEnterpriseLeads([String? enterpriseUid]) async* {
    final entUid = await resolveEnterpriseUid(enterpriseUid);
    if (entUid == null || entUid.isEmpty) {
      yield const [];
      return;
    }

    yield* _firestore
        .collection('enterprises')
        .doc(entUid)
        .collection('leads')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => EmployeeSavedLeadItem.fromFirestore(d.id, d.data()))
          .toList();
    });
  }

  /// Deletes a lead and decrements / recalculates the employee's lead count.
  Future<bool> deleteLeadForEmployee({
    String? enterpriseUid,
    required String employeeId,
    required String leadId,
  }) async {
    try {
      final entUid = await resolveEnterpriseUid(enterpriseUid);
      if (entUid == null || entUid.isEmpty) return false;

      final empDoc = await findEmployeeDoc(
        enterpriseUid: entUid,
        employeeIdentifier: employeeId,
      );
      final targetDocId = empDoc != null ? empDoc.id : employeeId;

      // 1. Delete from employee subcollection
      await _firestore
          .collection('enterprises')
          .doc(entUid)
          .collection('employees')
          .doc(targetDocId)
          .collection('leads')
          .doc(leadId)
          .delete();

      // 2. Delete from enterprise leads
      await _firestore
          .collection('enterprises')
          .doc(entUid)
          .collection('leads')
          .doc(leadId)
          .delete();

      // 3. Recalculate remaining leads
      final remSnap = await _firestore
          .collection('enterprises')
          .doc(entUid)
          .collection('employees')
          .doc(targetDocId)
          .collection('leads')
          .get();

      final newCount = remSnap.docs.length;
      await _firestore
          .collection('enterprises')
          .doc(entUid)
          .collection('employees')
          .doc(targetDocId)
          .set({
        'leads': newCount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[EnterpriseEmployeeSaveLeadsService] deleteLeadForEmployee error: $e');
      return false;
    }
  }
}

/// Convenient alias for cleaner global imports
typedef EmployeeSaveLeadsService = EnterpriseEmployeeSaveLeadsService;
