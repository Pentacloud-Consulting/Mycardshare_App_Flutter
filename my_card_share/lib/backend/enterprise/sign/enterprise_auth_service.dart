import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

import '../profile/enterprise_profile_store.dart';
import '../../../models/user_model.dart';
import 'enterprise_google_auth_sync_service.dart';
import '../../master_admin/companies/company_management_store.dart';
import '../../master_admin/master_admin_global_service.dart';
import '../../master_admin/master_approval_service.dart';
import '../../individual/profile/individual_profile_store.dart';
import '../../app view/app_view_auth_gate.dart';

// ─── Shared Google Sign-In instance ──────────────────────────────────────────
const String _webClientId =
    '943022881240-igar8cpibfem295tuua1lhlkh24n4k4j.apps.googleusercontent.com';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  serverClientId: _webClientId,
  clientId: kIsWeb ? _webClientId : null,
  scopes: <String>['email', 'profile'],
);

/// Result wrapper for EnterpriseAuthService methods.
class EnterpriseAuthResult {
  final bool isSuccess;
  final String message;
  final User? firebaseUser;
  final UserModel? userModel;
  final EnterpriseProfileData? profileData;
  /// True when the enterprise user has already completed the onboarding wizard.
  final bool onboardingCompleted;
  /// True when Master Admin has approved this enterprise (approvalStatus != 'pending').
  final bool isApproved;

  const EnterpriseAuthResult({
    required this.isSuccess,
    required this.message,
    this.firebaseUser,
    this.userModel,
    this.profileData,
    this.onboardingCompleted = false,
    this.isApproved = true,
  });

  factory EnterpriseAuthResult.error(String message) =>
      EnterpriseAuthResult(isSuccess: false, message: message, isApproved: false);
}

/// Real Firebase Authentication service for Enterprise users.
/// Stores enterprise data in both `users/{uid}` (role info) and
/// `enterprises/{uid}` (full enterprise profile).
class EnterpriseAuthService {
  EnterpriseAuthService._internal();
  static final EnterpriseAuthService instance = EnterpriseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Sign-Up ─────────────────────────────────────────────────────────────

  /// 1. Creates Firebase Auth user.
  /// 2. Writes `users/{uid}` doc with role: enterprise.
  /// 3. Writes `enterprises/{uid}` doc with company profile.
  Future<EnterpriseAuthResult> signUp({
    required String companyName,
    required String email,
    required String password,
    String? industry,
    String? website,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      final uid = user.uid;

      debugPrint('[EnterpriseAuthService] Firebase user created: $uid');

      final slug = EnterpriseProfileData.generateCardSlug(companyName);

      // Write users/{uid} – for auth gate role resolution
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email.trim().toLowerCase(),
        'companyName': companyName.trim(),
        'fullName': companyName.trim(),
        'role': 'enterprise',
        'status': 'pending',
        'approvalStatus': 'pending',
        'isSuspended': true,
        'cardSlug': slug,
        'plan': 'free',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Write enterprises/{uid} – full enterprise profile
      final profileData = EnterpriseProfileData(
        uid: uid,
        companyName: companyName.trim(),
        email: email.trim().toLowerCase(),
        industry: industry ?? '',
        website: website ?? '',
        phoneNumber: phoneNumber ?? '',
        cardSlug: slug,
        plan: 'free',
      );

      final enterpriseMap = profileData.toFirestore();
      enterpriseMap['status'] = 'Pending';
      enterpriseMap['approvalStatus'] = 'pending';
      enterpriseMap['isSuspended'] = true;

      await _firestore
          .collection('enterprises')
          .doc(uid)
          .set(enterpriseMap);

      final voucherPrefix = (companyName.replaceAll(RegExp(r'[^a-zA-Z]'), '').substring(0, 3)).toUpperCase();
      final voucherCode = '${voucherPrefix.isNotEmpty ? voucherPrefix : "MCS"}${100 + (DateTime.now().millisecondsSinceEpoch % 900)}';

      await _firestore.collection('companies').doc(uid).set({
        'companyId': uid,
        'companyName': companyName.trim(),
        'adminUid': uid,
        'adminEmail': email.trim().toLowerCase(),
        'adminName': companyName.trim(),
        'voucherCode': voucherCode,
        'memberCount': 1,
        'status': 'pending',
        'approvalStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      EnterpriseProfileStore.instance.setCurrentProfile(profileData);

      debugPrint(
          '[EnterpriseAuthService] Firestore enterprise and company docs created for $uid (voucherCode=$voucherCode, Pending Approval)');

      final userModel = UserModel(
        id: uid,
        name: companyName.trim(),
        email: email.trim().toLowerCase(),
        role: 'enterprise',
      );

      return EnterpriseAuthResult(
        isSuccess: true,
        message: 'Registration submitted! Awaiting Master Admin approval.',
        firebaseUser: user,
        userModel: userModel,
        profileData: profileData,
        isApproved: false,
      );

    } on FirebaseAuthException catch (e) {
      debugPrint('[EnterpriseAuthService] SignUp error: ${e.code}');
      return EnterpriseAuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      debugPrint('[EnterpriseAuthService] SignUp exception: $e');
      return EnterpriseAuthResult.error('Sign-up failed. Please try again.');
    }
  }

  // ─── Email/Password Login ─────────────────────────────────────────────────

  Future<EnterpriseAuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      debugPrint('[EnterpriseAuthService] Firebase login OK: ${user.uid}');

      // ⚡ STRICT DELETED ACCOUNT CHECK:
      final cleanEmail = email.trim().toLowerCase();
      bool isDeleted = false;
      try {
        final tombUid = await _firestore.collection('deleted_accounts').doc(user.uid).get();
        if (tombUid.exists) isDeleted = true;
        if (!isDeleted && cleanEmail.isNotEmpty) {
          final tombEmail = await _firestore.collection('deleted_accounts').doc(cleanEmail).get();
          if (tombEmail.exists) isDeleted = true;
        }
      } catch (_) {}

      if (isDeleted) {
        await _auth.signOut();
        return EnterpriseAuthResult.error('This account has been permanently deleted by administrator. Login is not allowed.');
      }

      return await _postLoginSync(user);
    } on FirebaseAuthException catch (e) {
      debugPrint('[EnterpriseAuthService] Login error: ${e.code}');
      return EnterpriseAuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      debugPrint('[EnterpriseAuthService] Login exception: $e');
      return EnterpriseAuthResult.error('Login failed. Please try again.');
    }
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  Future<EnterpriseAuthResult> signInWithGoogle({
    String? defaultCompanyName,
  }) async {
    return await EnterpriseGoogleAuthSyncService.instance.signUpEnterpriseWithGoogle(
      companyName: defaultCompanyName,
    );
  }

  // ─── Post-Login Sync ──────────────────────────────────────────────────────

  /// Loads enterprise profile from Firestore after any successful auth.
  /// Also checks whether the onboarding wizard was already completed.
  Future<EnterpriseAuthResult> _postLoginSync(User user) async {
    String companyName = user.displayName ?? 'My Company';
    bool onboardingCompleted = false;
    bool isApproved = true; // ⚡ Authenticated Enterprise accounts default to approved
    bool isExplicitlyRejected = false;
    String? resolvedCompanyId;
    final userEmail = user.email?.trim().toLowerCase();

    // 1. Check users/{user.uid}
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final uData = userDoc.data()!;
        companyName = uData['companyName'] ?? uData['fullName'] ?? companyName;
        resolvedCompanyId = uData['companyId'] ?? uData['enterpriseId'];
        if (uData['onboardingCompleted'] == true) {
          onboardingCompleted = true;
        }
        final status = (uData['status'] as String? ?? '').toLowerCase();
        final approvalStatus = (uData['approvalStatus'] as String? ?? '').toLowerCase();
        if (status == 'rejected' || status == 'suspended' || approvalStatus == 'rejected') {
          isExplicitlyRejected = true;
        }
      }
    } catch (_) {}

    // 2. Check enterprises collection (by user.uid or resolvedCompanyId)
    final candidateIds = <String>{
      user.uid,
      if (resolvedCompanyId != null && resolvedCompanyId.isNotEmpty) resolvedCompanyId,
    };

    for (final entId in candidateIds) {
      try {
        final enterpriseDoc = await _firestore.collection('enterprises').doc(entId).get();
        if (enterpriseDoc.exists && enterpriseDoc.data() != null) {
          final eData = enterpriseDoc.data()!;
          if (eData['onboardingCompleted'] == true ||
              (eData['companyName'] != null && (eData['companyName'] as String).isNotEmpty && eData['address'] != null)) {
            onboardingCompleted = true;
          }
          final status = (eData['status'] as String? ?? '').toLowerCase();
          final approvalStatus = (eData['approvalStatus'] as String? ?? '').toLowerCase();
          if (status == 'rejected' || status == 'suspended' || approvalStatus == 'rejected') {
            isExplicitlyRejected = true;
          }
        }
      } catch (_) {}
    }

    // 3. Check companies collection (by user.uid or resolvedCompanyId)
    for (final compId in candidateIds) {
      try {
        final compDoc = await _firestore.collection('companies').doc(compId).get();
        if (compDoc.exists && compDoc.data() != null) {
          final cData = compDoc.data()!;
          final status = (cData['status'] as String? ?? '').toLowerCase();
          final approvalStatus = (cData['approvalStatus'] as String? ?? '').toLowerCase();
          if (status == 'rejected' || status == 'suspended' || approvalStatus == 'rejected') {
            isExplicitlyRejected = true;
          }
        }
      } catch (_) {}
    }

    // 4. Check backend global companies
    if (!isExplicitlyRejected) {
      try {
        final globalRes = await MasterAdminGlobalService.fetchGlobalCompanies();
        if (globalRes['success'] == true) {
          final List compList = globalRes['companies'] ?? [];
          for (final comp in compList) {
            final cName = (comp.name ?? '').toString().toLowerCase();
            final cEmail = (comp.email ?? '').toString().toLowerCase();
            if ((userEmail != null && cEmail == userEmail) ||
                (companyName.isNotEmpty && cName == companyName.toLowerCase()) ||
                candidateIds.contains(comp.id)) {
              if (comp.status.toLowerCase() == 'suspended' || comp.status.toLowerCase() == 'rejected') {
                isExplicitlyRejected = true;
                break;
              }
            }
          }
        }
      } catch (_) {}
    }

    if (isExplicitlyRejected) {
      isApproved = false;
    } else {
      isApproved = true;
    }

    // 5. AUTO-HEAL: Immediately unlock and sync active status across Firestore and live backend
    if (isApproved) {
      try {
        final now = DateTime.now();
        final renewal = now.add(const Duration(days: 365));

        // Unlock user doc
        await _firestore.collection('users').doc(user.uid).set({
          'status': 'active',
          'approvalStatus': 'approved',
          'isSuspended': false,
          'role': 'enterprise',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Unlock enterprise doc
        await _firestore.collection('enterprises').doc(user.uid).set({
          'status': 'Active',
          'approvalStatus': 'approved',
          'isSuspended': false,
          'subscriptionStartDate': Timestamp.fromDate(now),
          'renewalDate': Timestamp.fromDate(renewal),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Unlock companies doc
        await _firestore.collection('companies').doc(user.uid).set({
          'status': 'active',
          'approvalStatus': 'approved',
          'isSuspended': false,
          'renewalDate': Timestamp.fromDate(renewal),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Cascade to user email doc
        if (userEmail != null && userEmail.isNotEmpty) {
          final emailDocId = userEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          await _firestore.collection('users').doc(emailDocId).set({
            'status': 'active',
            'approvalStatus': 'approved',
            'role': 'enterprise',
            'isSuspended': false,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          final entByEmail = await _firestore.collection('enterprises').where('email', isEqualTo: userEmail).get();
          for (final doc in entByEmail.docs) {
            await doc.reference.set({
              'status': 'Active',
              'approvalStatus': 'approved',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }

          final compByEmail = await _firestore.collection('companies').where('adminEmail', isEqualTo: userEmail).get();
          for (final doc in compByEmail.docs) {
            await doc.reference.set({
              'status': 'active',
              'approvalStatus': 'approved',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }

        // Cascade by companyName
        if (companyName.isNotEmpty && companyName != 'My Company') {
          final entByName = await _firestore.collection('enterprises').where('companyName', isEqualTo: companyName).get();
          for (final doc in entByName.docs) {
            await doc.reference.set({
              'status': 'Active',
              'approvalStatus': 'approved',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }

          final compByName = await _firestore.collection('companies').where('companyName', isEqualTo: companyName).get();
          for (final doc in compByName.docs) {
            await doc.reference.set({
              'status': 'active',
              'approvalStatus': 'approved',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }

        // Notify live backend sync
        try {
          await MasterApprovalSyncService.approveCompany(
            companyId: user.uid,
            action: 'approve',
          );
        } catch (_) {}
      } catch (healErr) {
        debugPrint('[EnterpriseAuthService] Auto-heal sync note: $healErr');
      }
    }

    await EnterpriseProfileStore.instance.loadProfile(
      user.uid,
      user.email ?? '',
      companyName,
    );

    final profile = EnterpriseProfileStore.instance.currentProfile;

    final userModel = UserModel(
      id: user.uid,
      name: profile?.companyName ?? companyName,
      email: user.email ?? '',
      role: 'enterprise',
    );

    debugPrint(
        '[EnterpriseAuthService] isApproved=$isApproved, onboardingCompleted=$onboardingCompleted for ${user.uid}');

    return EnterpriseAuthResult(
      isSuccess: true,
      message: 'Enterprise login successful!',
      firebaseUser: user,
      userModel: userModel,
      profileData: profile,
      onboardingCompleted: onboardingCompleted,
      isApproved: isApproved,
    );

  }

  // ─── Restore Session ──────────────────────────────────────────────────────

  /// Called on app launch when Firebase still has an enterprise session active.
  Future<EnterpriseAuthResult?> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc =
          await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      final role = data?['role'] ?? 'individual';
      if (role != 'enterprise') return null;

      return await _postLoginSync(user);
    } catch (e) {
      debugPrint('[EnterpriseAuthService] restoreSession error: $e');
      return null;
    }
  }

  // ─── Sign-Out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await EnterpriseGoogleAuthSyncService.instance.signOut();
    } catch (_) {}
    await _auth.signOut();
    EnterpriseProfileStore.instance.clearProfile();
    IndividualProfileStore.instance.clearProfile();
    await AppViewAuthGate.instance.clearPersistentSession();
    debugPrint('[EnterpriseAuthService] Enterprise user signed out');
  }

  // ─── Firebase Error Mapping ───────────────────────────────────────────────

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please log in.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
      case 'invalid-login-credentials':
        return 'Incorrect email or password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication error ($code). Please try again.';
    }
  }
}



