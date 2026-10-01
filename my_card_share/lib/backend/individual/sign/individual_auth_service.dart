import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

import '../api_service.dart';
import '../profile/individual_profile_store.dart';
import '../../app view/app_view_auth_gate.dart';

// ─── Shared Google Sign-In instance (mirrors GoogleSignUpService config) ──────
const String _webClientId =
    '943022881240-igar8cpibfem295tuua1lhlkh24n4k4j.apps.googleusercontent.com';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  serverClientId: _webClientId,
  clientId: kIsWeb ? _webClientId : null,
  scopes: <String>['email', 'profile'],
);

/// Result wrapper returned by IndividualAuthService methods.
class IndividualAuthResult {
  final bool isSuccess;
  final String message;
  final User? firebaseUser;

  /// The merged user+card data from the backend (populated on login).
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? cardData;

  const IndividualAuthResult({
    required this.isSuccess,
    required this.message,
    this.firebaseUser,
    this.userData,
    this.cardData,
  });

  factory IndividualAuthResult.error(String message) =>
      IndividualAuthResult(isSuccess: false, message: message);
}

/// Real Firebase Authentication service for Individual users.
/// Implements the full flow described in Individual_Auth_Integration.md.
class IndividualAuthService {
  IndividualAuthService._internal();
  static final IndividualAuthService instance = IndividualAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Sign-Up ─────────────────────────────────────────────────────────────

  /// 1. Creates Firebase Auth user.
  /// 2. Writes `users/{uid}` doc in Firestore (role: individual).
  /// 3. Calls PATCH /api/cards to initialise the MongoDB card document.
  Future<IndividualAuthResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // Step 1 – Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      final uid = user.uid;

      debugPrint('[IndividualAuthService] Firebase user created: $uid');

      // Step 2 – Firestore users/{uid} document
      final slug = IndividualProfileStore.generateCardSlug(fullName);
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email.trim().toLowerCase(),
        'fullName': fullName.trim(),
        'role': 'individual',
        'status': 'active',
        'cardSlug': slug,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[IndividualAuthService] Firestore user doc created: $uid');

      // Hydrate profile store & session state for newly registered user
      await AppViewAuthGate.instance.onUserAuthenticated(user, role: 'individual');

      // Step 3 – Initialise card in MongoDB via Next.js API
      try {
        await IndividualApiService.patch('/api/cards', {
          'fullName': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'cardSlug': slug,
          'userStatus': 'Actively Networking',
          'cardStatus': 'Published',
          'themeColor': '#0A84FF',
        });
        debugPrint('[IndividualAuthService] MongoDB card initialised via API');
      } catch (apiErr) {
        // Non-blocking: Firebase user already created — log but continue
        debugPrint('[IndividualAuthService] API card init skipped (backend may not be running): $apiErr');
      }

      return IndividualAuthResult(
        isSuccess: true,
        message: 'Account created successfully!',
        firebaseUser: user,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[IndividualAuthService] SignUp error: ${e.code}');
      return IndividualAuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      debugPrint('[IndividualAuthService] SignUp exception: $e');
      return IndividualAuthResult.error('Sign-up failed. Please try again.');
    }
  }

  // ─── Email/Password Login ─────────────────────────────────────────────────

  /// 1. Signs into Firebase Auth.
  /// 2. Calls GET /api/user/me (validates role & gets metadata).
  /// 3. Calls GET /api/cards (gets card + QR slug).
  /// 4. Loads IndividualProfileStore from Firestore fallback.
  Future<IndividualAuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      debugPrint('[IndividualAuthService] Firebase login OK: ${user.uid}');

      return await _postLoginSync(user);
    } on FirebaseAuthException catch (e) {
      debugPrint('[IndividualAuthService] Login error: ${e.code}');
      return IndividualAuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      debugPrint('[IndividualAuthService] Login exception: $e');
      return IndividualAuthResult.error('Login failed. Please try again.');
    }
  }

  // ─── Google Sign-In ──────────────────────────────────────────────────────

  Future<IndividualAuthResult> signInWithGoogle() async {
    try {
      debugPrint('[IndividualAuthService] Starting Google Sign-In...');

      // Use the shared instance (has correct clientId + scopes)
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return IndividualAuthResult.error('Google sign-in was cancelled.');
      }

      debugPrint('[IndividualAuthService] Google account: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      final oauthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final credential = await _auth.signInWithCredential(oauthCredential);
      final user = credential.user!;
      final uid = user.uid;
      final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;

      final resolvedName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
          ? user.displayName!.trim()
          : (googleUser.displayName != null && googleUser.displayName!.trim().isNotEmpty)
              ? googleUser.displayName!.trim()
              : (user.email ?? googleUser.email).split('@').first;

      final resolvedPhotoUrl = user.photoURL ?? googleUser.photoUrl;
      final resolvedEmail = user.email ?? googleUser.email;

      // Update Firebase user profile if display name / photoURL are missing on credential
      try {
        if (user.displayName == null || user.displayName!.isEmpty) {
          await user.updateDisplayName(resolvedName);
        }
        if (user.photoURL == null && resolvedPhotoUrl != null && resolvedPhotoUrl.isNotEmpty) {
          await user.updatePhotoURL(resolvedPhotoUrl);
        }
      } catch (e) {
        debugPrint('[IndividualAuthService] Firebase User profile update skipped: $e');
      }

      if (isNewUser) {
        final slug = IndividualProfileStore.generateCardSlug(resolvedName);
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': resolvedEmail,
          'fullName': resolvedName,
          'role': 'individual',
          'status': 'active',
          'cardSlug': slug,
          'avatarUrl': resolvedPhotoUrl,
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        try {
          await IndividualApiService.patch('/api/cards', {
            'fullName': resolvedName,
            'email': resolvedEmail,
            'cardSlug': slug,
            'avatarUrl': resolvedPhotoUrl ?? '',
            'userStatus': 'Actively Networking',
            'cardStatus': 'Published',
            'themeColor': '#0A84FF',
          });
        } catch (e) {
          debugPrint('[IndividualAuthService] Google new user API init skipped: $e');
        }
      }

      debugPrint('[IndividualAuthService] Google Sign-In OK: $uid (new=$isNewUser)');
      return await _postLoginSync(user);
    } on FirebaseAuthException catch (e) {
      debugPrint('[IndividualAuthService] Google FirebaseAuthException: ${e.code}');
      return IndividualAuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      debugPrint('[IndividualAuthService] Google sign-in exception: $e');
      final errorStr = e.toString();
      if (errorStr.contains('10') || errorStr.contains('sign_in_failed')) {
        return IndividualAuthResult.error(
          'Google Sign-In error (Code 10). Please ensure new google-services.json is downloaded from Firebase Console after adding SHA-1.',
        );
      }
      return IndividualAuthResult.error('Google sign-in failed: $e');
    }
  }

  // ─── Post-Login Backend Sync ─────────────────────────────────────────────

  /// Called after any successful authentication.
  /// Fetches user + card data from backend and hydrates IndividualProfileStore.
  Future<IndividualAuthResult> _postLoginSync(User user) async {
    Map<String, dynamic>? userData;
    Map<String, dynamic>? cardData;

    try {
      final userResp = await IndividualApiService.get('/api/user/me');
      userData = userResp['data'] as Map<String, dynamic>?;

      final cardResp = await IndividualApiService.get('/api/cards');
      cardData = (cardResp['data']?['card']) as Map<String, dynamic>?;

      debugPrint('[IndividualAuthService] Backend sync complete for ${user.uid}');
    } catch (e) {
      // API not reachable (dev mode / no backend) — fallback to Firestore
      debugPrint('[IndividualAuthService] Backend sync skipped, using Firestore fallback: $e');
    }

    // Hydrate IndividualProfileStore from API data or Firestore
    if (cardData != null) {
      _hydrateStoreFromCardData(user.uid, user.email ?? '', cardData);
    } else {
      await IndividualProfileStore.instance.loadProfile(
        user.uid,
        user.email ?? '',
        user.displayName ?? '',
      );
    }

    return IndividualAuthResult(
      isSuccess: true,
      message: 'Login successful!',
      firebaseUser: user,
      userData: userData,
      cardData: cardData,
    );
  }

  /// Hydrates IndividualProfileStore with data returned from GET /api/cards.
  void _hydrateStoreFromCardData(
    String uid,
    String email,
    Map<String, dynamic> card,
  ) {
    try {
      final rawLinks = (card['socialLinks'] as List<dynamic>?) ?? [];
      final socialLinks = rawLinks
          .map((l) => SocialLinkItem.fromJson(Map<String, dynamic>.from(l as Map)))
          .toList();

      IndividualProfileStore.instance.saveProfile(
        uid: uid,
        fullName: card['fullName'] ?? '',
        email: card['email'] ?? email,
        customSlug: card['cardSlug'],
        profilePhoto: card['avatarUrl'],
        bannerPhoto: card['bannerUrl'],
        jobTitle: card['jobTitle'] ?? '',
        phoneNumber: card['phone'] ?? '',
        websiteUrl: card['website'] ?? '',
        templateStyle: card['templateStyle'] ?? '0',
        socialLinks: socialLinks,
        companyName: card['companyName'] ?? '',
        shortBio: card['bio'] ?? '',
        networkingStatus: card['userStatus'] ?? 'Actively Networking',
      );
      debugPrint('[IndividualAuthService] ProfileStore hydrated from API card data');
    } catch (e) {
      debugPrint('[IndividualAuthService] ProfileStore hydration error: $e');
    }
  }

  // ─── Sign-Out ────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    debugPrint('[IndividualAuthService] Signed out');
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
        return 'Incorrect password. Please try again.';
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
      case 'operation-not-allowed':
        return 'Sign-in method is not enabled in Firebase Console.';
      default:
        return 'Authentication error ($code). Please try again.';
    }
  }
}
