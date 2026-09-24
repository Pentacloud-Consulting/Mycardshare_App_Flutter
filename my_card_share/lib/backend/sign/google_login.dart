import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../individual/sign/user_sign_up_store.dart';
import '../enterprise/sign/user_sign_up_store.dart';
import '../reset_password/reset_passowrd.dart';

/// Response model for Google Login operations.
class GoogleLoginResponse {
  final bool isSuccess;
  final String message;
  final UserModel? userModel;
  final Map<String, dynamic>? firestoreUserData;

  GoogleLoginResponse({
    required this.isSuccess,
    required this.message,
    this.userModel,
    this.firestoreUserData,
  });
}

/// Real Google Login Service using Firebase Auth + google_sign_in.
class GoogleLoginService {
  GoogleLoginService._internal();
  static final GoogleLoginService instance = GoogleLoginService._internal();

  static const String webClientId =
      '943022881240-igar8cpibfem295tuua1lhlkh24n4k4j.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? webClientId : null,
    scopes: <String>[
      'email',
      'profile',
    ],
  );
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Performs Google Login.
  /// If [autoProvision] is true, registers user locally and in Firestore if they don't exist yet.
  static Future<GoogleLoginResponse> loginWithGoogle({
    String? role,
    String? googleEmail,
    String? googleName,
    bool autoProvision = true,
  }) async {
    try {
      debugPrint('[GoogleLoginService] Starting Google Login...');

      // Trigger OS native Google Sign-In picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return GoogleLoginResponse(
          isSuccess: false,
          message: 'Google Sign-In was cancelled.',
        );
      }

      debugPrint('[GoogleLoginService] Selected account: ${googleUser.email}');

      // Obtain Google Auth Details (idToken & accessToken)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return GoogleLoginResponse(
          isSuccess: false,
          message: 'Firebase authentication failed.',
        );
      }

      final String uid = firebaseUser.uid;
      final String email = googleUser.email.toLowerCase().trim();
      final String displayName =
          googleUser.displayName?.isNotEmpty == true ? googleUser.displayName! : (googleName ?? email);
      final String targetRole = (role ?? 'individual').toLowerCase().trim();

      // Fetch user profile from Firestore to verify account role
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      Map<String, dynamic>? firestoreData;
      String userRole = targetRole;

      if (doc.exists && doc.data() != null) {
        firestoreData = doc.data() as Map<String, dynamic>;
        userRole = firestoreData['role'] ?? targetRole;
      } else if (autoProvision) {
        // First-time user logging in via Google directly -> provision Firestore doc
        firestoreData = {
          'uid': uid,
          'email': email,
          'fullName': displayName,
          'role': targetRole,
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
          'provider': 'google',
          'photoUrl': googleUser.photoUrl,
        };
        await _firestore.collection('users').doc(uid).set(
              firestoreData,
              SetOptions(merge: true),
            );
      }

      // Record active login state locally
      UserModel userModel;
      if (userRole == 'enterprise') {
        final entRecord = EnterpriseUserSignUpStore.saveUserSignUp(
          companyName: displayName,
          email: email,
          password: 'GOOGLE_OAUTH_PROTECTED',
          role: 'enterprise',
          provider: 'google',
        );
        userModel = UserModel(
          id: uid,
          name: entRecord.companyName,
          email: entRecord.email,
          role: 'enterprise',
        );
      } else {
        final indRecord = UserSignUpStore.saveUserSignUp(
          fullName: displayName,
          email: email,
          password: 'GOOGLE_OAUTH_PROTECTED',
          role: userRole,
          provider: 'google',
        );
        userModel = UserModel(
          id: uid,
          name: indRecord.fullName,
          email: indRecord.email,
          role: userRole,
        );
      }

      ResetPasswordStore.saveResetPasswordRecord(email, 'GOOGLE_OAUTH_PROTECTED');

      debugPrint('[GoogleLoginService] ✅ Google Login successful for $email ($userRole)');

      return GoogleLoginResponse(
        isSuccess: true,
        message: 'Welcome back, $displayName!',
        userModel: userModel,
        firestoreUserData: firestoreData,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[GoogleLoginService] FirebaseAuthException: ${e.code}');
      return GoogleLoginResponse(
        isSuccess: false,
        message: _mapFirebaseError(e.code),
      );
    } catch (e) {
      debugPrint('[GoogleLoginService] Error: $e');
      return GoogleLoginResponse(
        isSuccess: false,
        message: 'Google Login failed. Please try again.',
      );
    }
  }

  /// Sign out from Google & Firebase
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      debugPrint('[GoogleLoginService] Signed out successfully.');
    } catch (e) {
      debugPrint('[GoogleLoginService] Error during sign out: $e');
    }
  }

  static String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this Google account.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'invalid-credential':
        return 'Invalid Google credentials.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Google Login failed ($code). Please try again.';
    }
  }
}
