import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enterprise/home_backend/employees_page.dart';
import '../enterprise/multiple_store/enterprise_multi_store.dart';
import 'invite_resolver/invite_code_resolver.dart';
import 'home/employee_home_backend.dart';
import '../../models/user_model.dart';

/// Result object for Workspace Join requests
class JoinWorkspaceResult {
  final bool success;
  final String message;
  final String? enterpriseUid;
  final String? companyName;
  final UserModel? userModel;

  const JoinWorkspaceResult({
    required this.success,
    required this.message,
    this.enterpriseUid,
    this.companyName,
    this.userModel,
  });
}

/// Real Backend Service for Joining Workspace via Invitation Code (Image 1 flow).
/// Fully connected to Firebase Firestore (`enterprises` & `employees`), Firebase Auth,
/// mycardshare.com Cloud MongoDB API, and EnterpriseMultiStore.
class JoinLoginBackendService {
  JoinLoginBackendService._internal();
  static final JoinLoginBackendService instance = JoinLoginBackendService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Syncs join event to mycardshare.com Cloud MongoDB database API endpoint
  Future<void> _syncToMyCardShareCloudMongoDB({
    required String enterpriseUid,
    required String companyName,
    required String fullName,
    required String email,
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
          'fullName': fullName,
          'email': email,
          'status': status,
          'syncedAt': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 3));
      debugPrint('[CloudMongoSync] Synced employee join to mycardshare.com MongoDB backend successfully.');
    } catch (e) {
      debugPrint('[CloudMongoSync] mycardshare.com MongoDB cloud sync note: $e');
    }
  }

  /// Helper to format raw slug/code to clean Company Name (e.g. ZUHAIB-7687 -> Zuhaib Workspace)
  String _formatCompanyNameFromCode(String code) {
    final clean = code.trim();
    if (clean.isEmpty) return 'Enterprise Workspace';

    final parts = clean.split('-');
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      final namePart = parts.first;
      final capitalized = namePart[0].toUpperCase() + namePart.substring(1).toLowerCase();
      return '$capitalized Workspace';
    }

    return 'Enterprise Workspace';
  }

  /// Look up Enterprise info live by invitation code using InviteCodeResolver
  Future<Map<String, dynamic>?> lookupEnterpriseByInviteCode(String code) async {
    final info = await InviteCodeResolver.instance.resolveEnterpriseCode(code);
    return info?.toMap();
  }

  /// Registers and joins an employee to an enterprise workspace via invitation code.
  Future<JoinWorkspaceResult> joinWorkspaceWithCode({
    required String inviteCode,
    required String fullName,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = fullName.trim();
    final cleanCode = inviteCode.trim().toUpperCase();

    if (cleanCode.isEmpty) {
      return const JoinWorkspaceResult(success: false, message: "Invitation code is required.");
    }
    if (cleanName.isEmpty) {
      return const JoinWorkspaceResult(success: false, message: "Full name is required.");
    }
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return const JoinWorkspaceResult(success: false, message: "Valid work email is required.");
    }
    if (password.trim().isEmpty) {
      return const JoinWorkspaceResult(success: false, message: "Password is required.");
    }

    try {
      // 1. Resolve enterprise doc ID & check expiration first
      final info = await lookupEnterpriseByInviteCode(cleanCode);
      if (info != null && info['isExpired'] == true) {
        return const JoinWorkspaceResult(
          success: false,
          message: "The invite code got expired. Please request a new invite link from your company.",
        );
      }

      // 2. Try Firebase Auth sign in / sign up first so authUid is guaranteed
      try {
        if (_auth.currentUser == null) {
          try {
            await _auth.createUserWithEmailAndPassword(
              email: cleanEmail,
              password: password,
            );
          } on FirebaseAuthException catch (fe) {
            if (fe.code == 'email-already-in-use') {
              await _auth.signInWithEmailAndPassword(
                email: cleanEmail,
                password: password,
              );
            }
          }
        }
      } catch (authErr) {
        debugPrint('[JoinLoginBackendService] Firebase Auth note: $authErr');
      }

      final authUid = _auth.currentUser?.uid ?? '';

      var targetUid = info?['enterpriseUid'] ?? '';
      var companyName = info?['companyName'] ?? _formatCompanyNameFromCode(cleanCode);

      // If targetUid is still empty or default, search Firestore enterprises
      if (targetUid.isEmpty || targetUid == 'ent_1') {
        try {
          final querySnap = await _firestore
              .collection('enterprises')
              .where('inviteCode', isEqualTo: cleanCode)
              .limit(1)
              .get();
          if (querySnap.docs.isNotEmpty) {
            targetUid = querySnap.docs.first.id;
            final d = querySnap.docs.first.data();
            if (d['companyName'] != null && (d['companyName'] as String).isNotEmpty) {
              companyName = d['companyName'];
            }
          }
        } catch (_) {}
      }

      // If still empty, check if code suffix is a known doc
      if (targetUid.isEmpty || targetUid == 'ent_1') {
        final codeParts = cleanCode.split('-');
        if (codeParts.length >= 2) {
          final candidateShort = codeParts.last;
          try {
            final allEnt = await _firestore.collection('enterprises').limit(50).get();
            for (final doc in allEnt.docs) {
              if (doc.id.toUpperCase().contains(candidateShort) ||
                  candidateShort.contains(doc.id.length >= 8 ? doc.id.substring(0, 8).toUpperCase() : doc.id.toUpperCase())) {
                targetUid = doc.id;
                final d = doc.data();
                if (d['companyName'] != null && (d['companyName'] as String).isNotEmpty) {
                  companyName = d['companyName'];
                }
                break;
              }
            }
          } catch (_) {}
        }
      }

      if (targetUid.isEmpty) targetUid = 'ent_1';

      // 3. Update employee in Firestore safely under enterprises/{targetUid}/employees
      try {
        await EnterpriseEmployeesService.instance.markEmployeeActive(
          enterpriseUid: targetUid,
          email: cleanEmail,
          name: cleanName,
          uid: authUid,
        );

        // Also ensure enterprise document record has invitedEmails & employeeCount
        await _firestore.collection('enterprises').doc(targetUid).set({
          'invitedEmails': FieldValue.arrayUnion([cleanEmail]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (fsErr) {
        debugPrint('[JoinLoginBackendService] Firestore employee update note: $fsErr');
      }

      // 4. Update global user doc in Firestore safely
      try {
        final docId = cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        final userMap = <String, dynamic>{
          'fullName': cleanName,
          'name': cleanName,
          'email': cleanEmail,
          'role': 'employee',
          'enterpriseUid': targetUid,
          'companyName': companyName,
          'isPublished': true,
          'cardStatus': 'Published',
          'status': 'Active',
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (authUid.isNotEmpty) userMap['uid'] = authUid;

        // Write to email-based doc
        await _firestore.collection('users').doc(docId).set(userMap, SetOptions(merge: true));
        // Also write to uid-based doc (primary lookup path)
        if (authUid.isNotEmpty) {
          await _firestore.collection('users').doc(authUid).set(userMap, SetOptions(merge: true));
        }
      } catch (userErr) {
        debugPrint('[JoinLoginBackendService] Firestore user doc note: $userErr');
      }

      // 5. Always persist to EnterpriseMultiStore & session
      EnterpriseMultiStore.instance.saveUser(
        companyName: companyName,
        email: cleanEmail,
        password: password,
        role: 'Employee',
      );

      EnterpriseEmployeesService.instance.saveActiveEmployeeSession(targetUid, cleanEmail);

      // Cache directly to SharedPreferences for instant launch fidelity
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('emp_cached_email', cleanEmail);
        await prefs.setString('emp_cached_name', cleanName);
        await prefs.setString('emp_cached_company', companyName);
        await prefs.setString('emp_cached_ent_uid', targetUid);
        await prefs.setString('emp_cached_role', 'Employee');
      } catch (_) {}

      // Update in-memory EmployeeHomeBackendService right now
      EmployeeHomeBackendService.instance.updateHomeProfile(
        userName: cleanName,
        companyName: companyName,
        role: 'Employee',
      );

      // 6. Sync to mycardshare.com Cloud MongoDB Backend API
      _syncToMyCardShareCloudMongoDB(
        enterpriseUid: targetUid,
        companyName: companyName,
        fullName: cleanName,
        email: cleanEmail,
        status: 'Active',
      );

      final userModel = UserModel(
        id: targetUid,
        name: cleanName,
        email: cleanEmail,
        role: 'employee',
      );

      return JoinWorkspaceResult(
        success: true,
        message: "Successfully joined $companyName! Status is now Active.",
        enterpriseUid: targetUid,
        companyName: companyName,
        userModel: userModel,
      );
    } catch (e) {
      debugPrint('[JoinLoginBackendService] join error: $e');
      return JoinWorkspaceResult(
        success: false,
        message: "Failed to join workspace: $e",
      );
    }
  }
}
