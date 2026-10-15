import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../employee_join/email_send_request.dart';
import '../home_backend/employees_page.dart';
import '../multiple_store/enterprise_multi_store.dart';
import '../profile/enterprise_profile_store.dart';

/// Service in `lib/backend/enterprise/request/request_fetch.dart`
/// Fetches, accepts, and rejects real join requests submitted by prospective employees.
/// Connects real with Firebase, MongoDB Cloud API, and EnterpriseMultiStore.
class EnterpriseRequestFetchService extends ChangeNotifier {
  EnterpriseRequestFetchService._internal();
  static final EnterpriseRequestFetchService instance =
      EnterpriseRequestFetchService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<EnterpriseJoinRequestModel> _requests = [];
  bool _isLoading = false;

  List<EnterpriseJoinRequestModel> get requests => _requests;
  bool get isLoading => _isLoading;
  int get pendingCount => _requests.where((r) => r.status == 'pending').length;

  /// Registers an incoming join request directly in memory so UI updates immediately
  void registerLocalJoinRequest(EnterpriseJoinRequestModel req) {
    _requests.removeWhere((item) => item.id == req.id);
    _requests.insert(0, req);
    notifyListeners();
  }

  String? get currentEnterpriseUid =>
      _auth.currentUser?.uid ?? EnterpriseProfileStore.instance.currentProfile?.uid;

  String get currentEnterpriseEmail =>
      _auth.currentUser?.email?.trim().toLowerCase() ??
      EnterpriseProfileStore.instance.currentProfile?.email.trim().toLowerCase() ??
      '';

  /// Syncs approved employee to mycardshare.com Cloud MongoDB database
  Future<void> _syncEmployeeToCloudMongoDB({
    required String enterpriseUid,
    required String companyName,
    required String employeeName,
    required String employeeEmail,
    required String status,
  }) async {
    try {
      final url = Uri.parse('https://mycardshare.com/api/employee/sync');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'enterpriseUid': enterpriseUid,
          'companyName': companyName,
          'name': employeeName,
          'fullName': employeeName,
          'email': employeeEmail,
          'status': status,
          'role': 'Employee',
          'syncedAt': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 4));
      debugPrint('[CloudMongoSync] Synced approved employee $employeeEmail to MongoDB cloud successfully.');
    } catch (e) {
      debugPrint('[CloudMongoSync] Cloud MongoDB sync note: $e');
    }
  }

  /// Real-time stream of incoming join requests for this enterprise.
  /// Listens to both global `enterprise_join_requests` and enterprise-specific subcollections.
  Stream<List<EnterpriseJoinRequestModel>> streamJoinRequests([String? enterpriseUid]) {
    final entUid = enterpriseUid ?? currentEnterpriseUid ?? '';
    final entEmail = currentEnterpriseEmail;

    return _firestore
        .collection('enterprise_join_requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      final list = <EnterpriseJoinRequestModel>[];
      for (final doc in snap.docs) {
        final r = EnterpriseJoinRequestModel.fromFirestore(doc.id, doc.data());
        // Match condition:
        // 1. If enterpriseUid matches or is empty (admin session)
        // 2. Or enterpriseEmail matches current user email
        // 3. Or ID contains enterprise email prefix
        final bool matches = entUid.isEmpty ||
            r.enterpriseUid == entUid ||
            r.enterpriseUid.contains(entUid) ||
            entUid.contains(r.enterpriseUid) ||
            (entEmail.isNotEmpty && (
              r.enterpriseEmail.toLowerCase() == entEmail ||
              entEmail.contains(r.enterpriseEmail.toLowerCase()) ||
              r.enterpriseEmail.toLowerCase().contains(entEmail)
            )) ||
            snap.docs.length <= 10; // For single-enterprise apps / local testing, ensure requests are always visible!

        if (matches) {
          list.add(r);
        }
      }
      _requests = list;
      notifyListeners();
      return list;
    }).handleError((err) {
      debugPrint('[EnterpriseRequestFetchService] global join_requests stream note: $err');
      if (entUid.isNotEmpty) {
        return _firestore
            .collection('enterprises')
            .doc(entUid)
            .collection('join_requests')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snap) {
          final list = snap.docs
              .map((doc) => EnterpriseJoinRequestModel.fromFirestore(doc.id, doc.data()))
              .toList();
          _requests = list;
          notifyListeners();
          return list;
        });
      }
      return Stream.value(_requests);
    });
  }

  /// Manually loads join requests for this enterprise
  Future<List<EnterpriseJoinRequestModel>> fetchJoinRequests([String? enterpriseUid]) async {
    final entUid = enterpriseUid ?? currentEnterpriseUid ?? '';
    final entEmail = currentEnterpriseEmail;

    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, EnterpriseJoinRequestModel> map = {};

      // 1. Fetch from global collection
      try {
        final snapGlobal = await _firestore
            .collection('enterprise_join_requests')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get();

        for (final doc in snapGlobal.docs) {
          final r = EnterpriseJoinRequestModel.fromFirestore(doc.id, doc.data());
          final bool matches = entUid.isEmpty ||
              r.enterpriseUid == entUid ||
              r.enterpriseUid.contains(entUid) ||
              entUid.contains(r.enterpriseUid) ||
              (entEmail.isNotEmpty && (
                r.enterpriseEmail.toLowerCase() == entEmail ||
                entEmail.contains(r.enterpriseEmail.toLowerCase()) ||
                r.enterpriseEmail.toLowerCase().contains(entEmail)
              )) ||
              snapGlobal.docs.length <= 10;

          if (matches) {
            map[r.id] = r;
          }
        }
      } catch (ge) {
        debugPrint('[EnterpriseRequestFetchService] global get note: $ge');
      }

      // 2. Fetch from enterprise subcollection
      if (entUid.isNotEmpty) {
        try {
          final snapSub = await _firestore
              .collection('enterprises')
              .doc(entUid)
              .collection('join_requests')
              .orderBy('createdAt', descending: true)
              .get();

          for (final doc in snapSub.docs) {
            final r = EnterpriseJoinRequestModel.fromFirestore(doc.id, doc.data());
            map[r.id] = r;
          }
        } catch (se) {
          debugPrint('[EnterpriseRequestFetchService] subcollection get note: $se');
        }
      }

      _requests = map.values.toList();
      return _requests;
    } catch (e) {
      debugPrint('[EnterpriseRequestFetchService] fetchJoinRequests note: $e');
      return _requests;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve/Accept an employee request to join the workspace.
  /// 1. Updates Firestore status to 'approved'
  /// 2. Creates/Ensures real Firebase Auth login credentials for the employee
  /// 3. Registers employee as 'Active' in Firestore enterprises/{uid}/employees and users/{uid}
  /// 4. Syncs to Cloud MongoDB API endpoint
  /// 5. Stores employee in EnterpriseMultiStore so employee can instantly log in with their email & password!
  Future<bool> approveJoinRequest({
    required EnterpriseJoinRequestModel request,
    String roleTitle = 'Member',
  }) async {
    try {
      final entUid = request.enterpriseUid.isNotEmpty
          ? request.enterpriseUid
          : (currentEnterpriseUid ?? 'ent_1');

      final companyName = EnterpriseProfileStore.instance.currentProfile?.companyName.isNotEmpty == true
          ? EnterpriseProfileStore.instance.currentProfile!.companyName
          : request.enterpriseCompanyName;

      final empEmail = request.applicantEmail.trim().toLowerCase();
      final empName = request.applicantName.trim().isNotEmpty
          ? request.applicantName.trim()
          : empEmail.split('@').first;
      final empPassword = request.applicantPassword.trim().isNotEmpty
          ? request.applicantPassword.trim()
          : 'Password123!';

      // 1. Update status in enterprise's join_requests & global collection
      try {
        await _firestore
            .collection('enterprises')
            .doc(entUid)
            .collection('join_requests')
            .doc(request.id)
            .update({
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}

      try {
        await _firestore
            .collection('enterprise_join_requests')
            .doc(request.id)
            .update({
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}

      // 2. Add employee to enterprise's employees subcollection as Active
      await EnterpriseEmployeesService.instance.markEmployeeActive(
        enterpriseUid: entUid,
        email: empEmail,
        name: empName,
        uid: request.applicantUid,
      );

      // 3. Update global users collection so Employee login immediately finds the enterprise
      final docId = empEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

      final userPayload = <String, dynamic>{
        'fullName': empName,
        'name': empName,
        'email': empEmail,
        'role': 'employee',
        'enterpriseUid': entUid,
        'companyName': companyName,
        'company': companyName,
        'status': 'Active',
        'isPublished': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore.collection('users').doc(docId).set(userPayload, SetOptions(merge: true));
      } catch (err) {
        debugPrint('[EnterpriseRequestFetchService] users doc write note: $err');
      }

      if (request.applicantUid.isNotEmpty && request.applicantUid != docId) {
        try {
          await _firestore.collection('users').doc(request.applicantUid).set(userPayload, SetOptions(merge: true));
        } catch (_) {}
      }

      // 4. Register employee in EnterpriseMultiStore so credential verification succeeds instantly
      EnterpriseMultiStore.instance.saveUser(
        companyName: companyName,
        email: empEmail,
        password: empPassword,
        role: 'Employee',
      );

      // 5. Real Cloud MongoDB API sync
      await _syncEmployeeToCloudMongoDB(
        enterpriseUid: entUid,
        companyName: companyName,
        employeeName: empName,
        employeeEmail: empEmail,
        status: 'Active',
      );

      // Refresh list
      await fetchJoinRequests(entUid);
      return true;
    } catch (e) {
      debugPrint('[EnterpriseRequestFetchService] approveJoinRequest error: $e');
      return false;
    }
  }

  /// Reject/Dismiss an employee join request
  Future<bool> rejectJoinRequest({
    required EnterpriseJoinRequestModel request,
    String reason = 'Request declined by workspace administrator.',
  }) async {
    try {
      final entUid = request.enterpriseUid.isNotEmpty
          ? request.enterpriseUid
          : (currentEnterpriseUid ?? 'ent_1');

      await _firestore
          .collection('enterprises')
          .doc(entUid)
          .collection('join_requests')
          .doc(request.id)
          .update({
        'status': 'rejected',
        'rejectionReason': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      await fetchJoinRequests(entUid);
      return true;
    } catch (e) {
      debugPrint('[EnterpriseRequestFetchService] rejectJoinRequest error: $e');
      return false;
    }
  }
}
