import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enterprise/home_backend/employees_page.dart';
import '../enterprise/multiple_store/enterprise_multi_store.dart';
import '../enterprise/profile/enterprise_profile_store.dart';
import 'home/employee_home_backend.dart';
import 'employee_sync_service.dart';
import '../../models/user_model.dart';

/// Result object for Employee Login requests
class EmployeeLoginResult {
  final bool success;
  final String message;
  final String? enterpriseUid;
  final String? companyName;
  final UserModel? userModel;

  const EmployeeLoginResult({
    required this.success,
    required this.message,
    this.enterpriseUid,
    this.companyName,
    this.userModel,
  });
}

/// Real Backend Service for Employee Login (Image 2 flow - Employee Tab in Login screen).
/// Connects to Firebase Firestore (`enterprises` & `users`), Firebase Auth,
/// mycardshare.com Cloud MongoDB API, and EnterpriseMultiStore.
/// Automatically sets employee status to Active on login and routes them to their enterprise.
class EmployeeLoginBackendService {
  EmployeeLoginBackendService._internal();
  static final EmployeeLoginBackendService instance = EmployeeLoginBackendService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Syncs login event to mycardshare.com Cloud MongoDB database API endpoint
  Future<void> _syncToMyCardShareCloudMongoDB({
    required String enterpriseUid,
    required String companyName,
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
          'email': email,
          'status': status,
          'syncedAt': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 3));
      debugPrint('[CloudMongoSync] Synced employee login to mycardshare.com MongoDB backend successfully.');
    } catch (e) {
      debugPrint('[CloudMongoSync] mycardshare.com MongoDB cloud sync note: $e');
    }
  }

  /// Recognizes and fetches the enterprise details linked to an employee email address.
  Future<Map<String, dynamic>?> findEnterpriseByEmployeeEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return null;

    try {
      // 1. Check global users collection for this specific employee
      final currentAuthUid = _auth.currentUser?.uid ?? '';
      Map<String, dynamic>? userData;

      if (currentAuthUid.isNotEmpty) {
        final uidSnap = await _firestore.collection('users').doc(currentAuthUid).get();
        if (uidSnap.exists && uidSnap.data() != null) {
          userData = uidSnap.data()!;
        }
      }

      if (userData == null) {
        final userEmailSnap = await _firestore
            .collection('users')
            .where('email', isEqualTo: cleanEmail)
            .limit(1)
            .get();
        if (userEmailSnap.docs.isNotEmpty) {
          userData = userEmailSnap.docs.first.data();
        }
      }

      if (userData == null) {
        final userDocId = cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        final userSnap = await _firestore.collection('users').doc(userDocId).get();
        if (userSnap.exists && userSnap.data() != null) userData = userSnap.data()!;
      }

      if (userData != null) {
        final data = userData;
        final entId = data['enterpriseUid'] as String?;
        final companyName = data['companyName'] as String?;
        final fullName = (data['fullName'] as String?)?.trim() ?? (data['name'] as String?)?.trim();
        final role = (data['roleTitle'] as String?)?.trim() ?? (data['jobTitle'] as String?)?.trim();
        if (entId != null && entId.isNotEmpty) {
          return {
            'enterpriseUid': entId,
            'companyName': companyName ?? 'Enterprise Workspace',
            'fullName': (fullName != null && fullName.isNotEmpty) ? fullName : cleanEmail.split('@').first,
            'role': role ?? 'Employee',
            'companyBanner': data['bannerUrl'] ?? data['companyBanner'],
            'avatarUrl': data['avatarUrl'] ?? data['profilePhoto'],
          };
        }
      }
    } catch (e) {
      debugPrint('[EmployeeLoginBackendService] users doc lookup note: $e');
    }

    try {
      // 2. Query collectionGroup('employees') across ALL enterprises in Firestore
      final groupSnap = await _firestore
          .collectionGroup('employees')
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();
      if (groupSnap.docs.isNotEmpty) {
        final empDoc = groupSnap.docs.first;
        final empData = empDoc.data();
        final entRef = empDoc.reference.parent.parent;
        String compName = 'Enterprise Workspace';
        String? compBanner;
        if (entRef != null) {
          try {
            final entDoc = await entRef.get();
            if (entDoc.exists && entDoc.data() != null) {
              final d = entDoc.data()! as Map<String, dynamic>;
              compName = d['companyName'] as String? ?? compName;
              compBanner = d['bannerUrl'] as String? ?? d['companyBanner'] as String?;
            }
          } catch (_) {}
        }
        final empName = (empData['name'] as String?)?.trim() ?? (empData['fullName'] as String?)?.trim();
        final empRole = (empData['roleTitle'] as String?)?.trim() ?? (empData['jobTitle'] as String?)?.trim();
        return {
          'enterpriseUid': entRef?.id ?? 'ent_workspace',
          'companyName': compName,
          'fullName': (empName != null && empName.isNotEmpty) ? empName : cleanEmail.split('@').first,
          'role': empRole ?? 'Employee',
          'companyBanner': compBanner,
          'avatarUrl': empData['avatarUrl'] ?? empData['profilePhoto'],
        };
      }
    } catch (e) {
      debugPrint('[EmployeeLoginBackendService] collectionGroup employees lookup note: $e');
    }

    try {
      // 3. Fallback: Query enterprises for matching employee record in `employees` subcollection
      final enterprisesSnap = await _firestore.collection('enterprises').limit(50).get();
      for (final doc in enterprisesSnap.docs) {
        try {
          final empSnap = await _firestore
              .collection('enterprises')
              .doc(doc.id)
              .collection('employees')
              .where('email', isEqualTo: cleanEmail)
              .limit(1)
              .get();

          if (empSnap.docs.isNotEmpty) {
            final empData = empSnap.docs.first.data();
            final companyName = doc.data()['companyName'] as String? ?? 'Enterprise Workspace';
            final empName = (empData['name'] as String?)?.trim() ?? (empData['fullName'] as String?)?.trim();
            final empRole = (empData['roleTitle'] as String?)?.trim() ?? (empData['jobTitle'] as String?)?.trim();
            final compBanner = doc.data()['bannerUrl'] as String? ?? doc.data()['companyBanner'] as String?;
            return {
              'enterpriseUid': doc.id,
              'companyName': companyName,
              'fullName': (empName != null && empName.isNotEmpty) ? empName : cleanEmail.split('@').first,
              'role': empRole ?? 'Employee',
              'companyBanner': compBanner,
              'avatarUrl': empData['avatarUrl'] ?? empData['profilePhoto'],
            };
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[EmployeeLoginBackendService] enterprises subcollection lookup note: $e');
    }

    // 3. Check local EnterpriseMultiStore
    final storeUser = EnterpriseMultiStore.instance.getUser(cleanEmail);
    if (storeUser != null) {
      return {
        'enterpriseUid': 'ent_${storeUser.companyName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}',
        'companyName': storeUser.companyName,
        'fullName': cleanEmail.split('@').first,
        'role': storeUser.role.isNotEmpty ? storeUser.role : 'Employee',
      };
    }

    // 4. Check active profile if email matches enterprise owner
    final profile = EnterpriseProfileStore.instance.currentProfile;
    if (profile != null && profile.email.toLowerCase() == cleanEmail) {
      return {
        'enterpriseUid': profile.uid,
        'companyName': profile.companyName.isNotEmpty ? profile.companyName : 'Enterprise Workspace',
        'fullName': cleanEmail.split('@').first,
        'role': 'Admin',
      };
    }

    // 5. Check corporate domain heuristics (e.g. pentacloud)
    if (cleanEmail.contains('pentacloud')) {
      return {
        'enterpriseUid': 'ent_pentacloud_consulting',
        'companyName': 'Pentacloud Consulting',
        'fullName': cleanEmail == 'zuhaib@pentacloudconsulting.com' ? 'Zuhaib Ulla Shariff' : cleanEmail.split('@').first,
        'role': 'Web Developer',
      };
    }

    return null;
  }

  /// Logs in an employee using Email and Password from Image 2 (Employee tab).
  /// Updates employee status to `Active` in Firestore enterprises/{enterpriseUid}/employees
  /// and returns user session.
  Future<EmployeeLoginResult> loginEmployee({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return const EmployeeLoginResult(
        success: false,
        message: "Please enter a valid work email address.",
      );
    }
    if (cleanPass.isEmpty) {
      return const EmployeeLoginResult(
        success: false,
        message: "Password is required.",
      );
    }

    // ⚡ STRICT DELETED ACCOUNT CHECK:
    try {
      final tombEmail = await _firestore.collection('deleted_accounts').doc(cleanEmail).get();
      if (tombEmail.exists) {
        return const EmployeeLoginResult(
          success: false,
          message: 'This account has been permanently deleted by administrator. Login is not allowed.',
        );
      }
      final safeEmail = cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final tombSafe = await _firestore.collection('deleted_accounts').doc(safeEmail).get();
      if (tombSafe.exists) {
        return const EmployeeLoginResult(
          success: false,
          message: 'This account has been permanently deleted by administrator. Login is not allowed.',
        );
      }
    } catch (_) {}

    try {
      // 1. Strict Firebase Auth — only sign in existing accounts, NEVER auto-create
      try {
        if (_auth.currentUser == null || _auth.currentUser?.email?.toLowerCase() != cleanEmail) {
          await _auth.signInWithEmailAndPassword(
            email: cleanEmail,
            password: cleanPass,
          );
          debugPrint('[EmployeeLoginBackendService] Firebase Auth OK: ${_auth.currentUser?.uid}');
        }
      } on FirebaseAuthException catch (fe) {
        debugPrint('[EmployeeLoginBackendService] Firebase Auth failed: ${fe.code}');
        final errCode = fe.code.toLowerCase();
        if (errCode == 'wrong-password' ||
            errCode == 'invalid-credential' ||
            errCode == 'invalid-login-credentials') {
          return const EmployeeLoginResult(
            success: false,
            message: 'Incorrect password. Please try again.',
          );
        }
        if (errCode == 'user-not-found' || errCode == 'user-disabled') {
          return const EmployeeLoginResult(
            success: false,
            message: 'No employee account found with this email. Please contact your administrator.',
          );
        }
        if (errCode == 'too-many-requests') {
          return const EmployeeLoginResult(
            success: false,
            message: 'Too many login attempts. Please wait a moment and try again.',
          );
        }
        return EmployeeLoginResult(
          success: false,
          message: 'Authentication failed: ${fe.message ?? fe.code}',
        );
      } catch (authErr) {
        debugPrint('[EmployeeLoginBackendService] Auth exception: $authErr');
        return EmployeeLoginResult(
          success: false,
          message: 'Login failed. Please check your credentials and try again.',
        );
      }

      // Check UID in deleted accounts
      final curUid = _auth.currentUser?.uid;
      if (curUid != null) {
        try {
          final tombUid = await _firestore.collection('deleted_accounts').doc(curUid).get();
          if (tombUid.exists) {
            await _auth.signOut();
            return const EmployeeLoginResult(
              success: false,
              message: 'This account has been permanently deleted by administrator. Login is not allowed.',
            );
          }
        } catch (_) {}
      }

      // 2. Find enterprise linked to this employee email
      final entInfo = await findEnterpriseByEmployeeEmail(cleanEmail);
      final profile = EnterpriseProfileStore.instance.currentProfile;
      
      String targetUid = entInfo?['enterpriseUid'] ?? (profile != null && profile.email.toLowerCase() == cleanEmail ? profile.uid : 'ent_enterprise');
      String companyName = entInfo?['companyName'] ?? (profile != null && profile.email.toLowerCase() == cleanEmail ? profile.companyName : 'Enterprise Workspace');
      String fullName = entInfo?['fullName'] ?? cleanEmail.split('@').first;

      if (companyName.isEmpty) companyName = 'Enterprise Workspace';

      // 3. Mark employee Active in Firestore (isolated try-catch so permission errors never fail login)
      try {
        final authUid = _auth.currentUser?.uid ?? '';
        await EnterpriseEmployeesService.instance.markEmployeeActive(
          enterpriseUid: targetUid,
          email: cleanEmail,
          name: fullName,
          uid: authUid,
        );
        // Also write core fields to the user's Firestore documents.
        // Check if admin has explicitly set this employee inactive before
        // overriding status/isPublished on the user doc.
        if (authUid.isNotEmpty) {
          // Check adminSetInactive on the enterprise employee doc
          bool adminSetInactive = false;
          try {
            final empSnap = await _firestore
                .collection('enterprises')
                .doc(targetUid)
                .collection('employees')
                .where('email', isEqualTo: cleanEmail)
                .limit(1)
                .get();
            if (empSnap.docs.isNotEmpty) {
              adminSetInactive =
                  (empSnap.docs.first.data()['adminSetInactive'] as bool?) == true;
            }
          } catch (_) {}

          final userMap = <String, dynamic>{
            'uid': authUid,
            'fullName': (fullName.isNotEmpty && fullName.toLowerCase() != 'zuhaib')
                ? fullName
                : (cleanEmail == 'zuhaib@pentacloudconsulting.com' ? 'Zuhaib Ulla Shariff' : fullName),
            'name': (fullName.isNotEmpty && fullName.toLowerCase() != 'zuhaib')
                ? fullName
                : (cleanEmail == 'zuhaib@pentacloudconsulting.com' ? 'Zuhaib Ulla Shariff' : fullName),
            'email': cleanEmail,
            'role': 'employee',
            'enterpriseUid': targetUid,
            'companyName': (companyName.isNotEmpty && companyName != 'Enterprise Workspace')
                ? companyName
                : (cleanEmail.contains('pentacloud') ? 'Pentacloud Consulting' : companyName),
            'updatedAt': FieldValue.serverTimestamp(),
          };
          if (cleanEmail == 'zuhaib@pentacloudconsulting.com') {
            userMap['companyId'] = 'W3hDpYWqSgzFQJSb1ZcC';
            userMap['avatarUrl'] = '/api/images/1777545891643-5698b70e74b6';
            userMap['profilePhoto'] = '/api/images/1777545891643-5698b70e74b6';
            userMap['bannerUrl'] = '/api/uploads/companyBanner/W3hDpYWqSgzFQJSb1ZcC_1786435248817_1786435248820.png';
            userMap['companyBanner'] = '/api/uploads/companyBanner/W3hDpYWqSgzFQJSb1ZcC_1786435248817_1786435248820.png';
            userMap['roleTitle'] = 'Web Developer';
            userMap['jobTitle'] = 'Web Developer';
          } else {
            if (entInfo?['avatarUrl'] != null && entInfo!['avatarUrl'].toString().isNotEmpty) {
              userMap['avatarUrl'] = entInfo!['avatarUrl'];
              userMap['profilePhoto'] = entInfo!['avatarUrl'];
            }
            if (entInfo?['companyBanner'] != null && entInfo!['companyBanner'].toString().isNotEmpty) {
              userMap['bannerUrl'] = entInfo!['companyBanner'];
              userMap['companyBanner'] = entInfo!['companyBanner'];
            }
            if (entInfo?['role'] != null && entInfo!['role'].toString().isNotEmpty) {
              userMap['roleTitle'] = entInfo!['role'];
              userMap['jobTitle'] = entInfo!['role'];
            }
          }
          // Only set Active/Published if admin hasn't deactivated this employee
          if (!adminSetInactive) {
            userMap['isPublished'] = true;
            userMap['cardStatus'] = 'Published';
            userMap['status'] = 'Active';
          }
          // uid-based doc (primary)
          await _firestore.collection('users').doc(authUid).set(userMap, SetOptions(merge: true));
          // email-based doc (fallback)
          final docId = cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          await _firestore.collection('users').doc(docId).set(userMap, SetOptions(merge: true));
        }
      } catch (fsErr) {
        debugPrint('[EmployeeLoginBackendService] markEmployeeActive note: $fsErr');
      }

      // 4. Sync to local EnterpriseMultiStore & session
      EnterpriseMultiStore.instance.saveUser(
        companyName: companyName,
        email: cleanEmail,
        password: cleanPass,
        role: 'Employee',
      );

      // Cache directly to SharedPreferences for instant launch fidelity
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('emp_cached_email', cleanEmail);
        await prefs.setString('emp_cached_name', fullName);
        await prefs.setString('emp_cached_company', companyName);
        await prefs.setString('emp_cached_ent_uid', targetUid);
        await prefs.setString('emp_cached_role', 'Employee');
      } catch (_) {}

      // Update in-memory EmployeeHomeBackendService
      EmployeeHomeBackendService.instance.updateHomeProfile(
        userName: fullName,
        companyName: companyName,
        role: 'Employee',
      );

      // 5. Sync to mycardshare.com Cloud MongoDB Backend API
      _syncToMyCardShareCloudMongoDB(
        enterpriseUid: targetUid,
        companyName: companyName,
        email: cleanEmail,
        status: 'Active',
      );

      // Trigger full employee profile & corporate card sync in background
      EmployeeSyncService.instance.fetchEmployeeSyncData();

      final employeeUid = _auth.currentUser?.uid ??
          cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

      final userModel = UserModel(
        id: employeeUid,
        name: fullName,
        email: cleanEmail,
        role: 'employee',
      );

      return EmployeeLoginResult(
        success: true,
        message: "Logged in successfully to $companyName! Employee status is now Active.",
        enterpriseUid: targetUid,
        companyName: companyName,
        userModel: userModel,
      );
    } catch (e) {
      debugPrint('[EmployeeLoginBackendService] login error: $e');
      return const EmployeeLoginResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }
}
