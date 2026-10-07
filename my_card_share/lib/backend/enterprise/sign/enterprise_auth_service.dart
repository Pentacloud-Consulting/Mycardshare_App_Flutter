import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

import '../profile/enterprise_profile_store.dart';
import '../../../models/user_model.dart';

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

  const EnterpriseAuthResult({
    required this.isSuccess,
    required this.message,
    this.firebaseUser,
    this.userModel,
    this.profileData,
    this.onboardingCompleted = false,
  });

  factory EnterpriseAuthResult.error(String message) =>
      EnterpriseAuthResult(isSuccess: false, message: message);
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
        'status': 'active',
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

      await _firestore
          .collection('enterprises')
          .doc(uid)
          .set(profileData.toFirestore());

      EnterpriseProfileStore.instance.setCurrentProfile(profileData);

      debugPrint(
          '[EnterpriseAuthService] Firestore enterprise docs created for $uid');

      final userModel = UserModel(
        id: uid,
        name: companyName.trim(),
        email: email.trim().toLowerCase(),
        role: 'enterprise',
      );

      return EnterpriseAuthResult(
        isSuccess: true,
        message: 'Enterprise account created successfully!',
        firebaseUser: user,
        userModel: userModel,
        profileData: profileData,
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
    try {
      debugPrint('[EnterpriseAuthService] Starting Google Sign-In...');

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return EnterpriseAuthResult.error('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final oauthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final credential = await _auth.signInWithCredential(oauthCredential);
      final user = credential.user!;
      final uid = user.uid;
      final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;

      final resolvedCompany = defaultCompanyName?.trim().isNotEmpty == true
          ? defaultCompanyName!.trim()
          : (user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : user.email?.split('@').first ?? 'My Company');

      if (isNewUser) {
        final slug = EnterpriseProfileData.generateCardSlug(resolvedCompany);

        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': user.email ?? googleUser.email,
          'companyName': resolvedCompany,
          'fullName': resolvedCompany,
          'role': 'enterprise',
          'status': 'active',
          'cardSlug': slug,
          'plan': 'free',
          'avatarUrl': user.photoURL ?? googleUser.photoUrl,
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final profileData = EnterpriseProfileData(
          uid: uid,
          companyName: resolvedCompany,
          email: user.email ?? googleUser.email,
          logoUrl: user.photoURL ?? googleUser.photoUrl,
          cardSlug: slug,
          plan: 'free',
        );

        await _firestore
            .collection('enterprises')
            .doc(uid)
            .set(profileData.toFirestore());
      }

      debugPrint(
          '[EnterpriseAuthService] Google Sign-In OK: $uid (new=$isNewUser)');
      return await _postLoginSync(user);
    } on FirebaseAuthException catch (e) {
      return EnterpriseAuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      debugPrint('[EnterpriseAuthService] Google sign-in exception: $e');
      return EnterpriseAuthResult.error('Google sign-in failed: $e');
    }
  }

  // ─── Post-Login Sync ──────────────────────────────────────────────────────

  /// Loads enterprise profile from Firestore after any successful auth.
  /// Also checks whether the onboarding wizard was already completed.
  Future<EnterpriseAuthResult> _postLoginSync(User user) async {
    // Determine company name from Firestore or display name
    String companyName = user.displayName ?? 'My Company';
    bool onboardingCompleted = false;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final uData = userDoc.data()!;
        companyName = uData['companyName'] ?? uData['fullName'] ?? companyName;
        if (uData['onboardingCompleted'] == true) {
          onboardingCompleted = true;
        }
      }
    } catch (_) {}

    // Check enterprises collection for onboardingCompleted flag or completed profile
    try {
      final enterpriseDoc =
          await _firestore.collection('enterprises').doc(user.uid).get();
      if (enterpriseDoc.exists && enterpriseDoc.data() != null) {
        final eData = enterpriseDoc.data()!;
        if (eData['onboardingCompleted'] == true ||
            (eData['companyName'] != null && (eData['companyName'] as String).isNotEmpty && eData['address'] != null)) {
          onboardingCompleted = true;
        }
      }
    } catch (_) {}

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
        '[EnterpriseAuthService] onboardingCompleted=$onboardingCompleted for ${user.uid}');

    return EnterpriseAuthResult(
      isSuccess: true,
      message: 'Enterprise login successful!',
      firebaseUser: user,
      userModel: userModel,
      profileData: profile,
      onboardingCompleted: onboardingCompleted,
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
    await _googleSignIn.signOut();
    await _auth.signOut();
    EnterpriseProfileStore.instance.clearProfile();
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



