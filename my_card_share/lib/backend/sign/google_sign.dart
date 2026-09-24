import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../individual/sign/user_sign_up_store.dart';
import '../enterprise/sign/user_sign_up_store.dart';
import '../reset_password/reset_passowrd.dart';

/// Response model for Google Sign-Up backend operations.
class GoogleSignUpResponse {
  final bool isSuccess;
  final String message;
  final UserModel? userModel;
  final String? idToken;
  final Map<String, dynamic>? firestoreUserData;

  GoogleSignUpResponse({
    required this.isSuccess,
    required this.message,
    this.userModel,
    this.idToken,
    this.firestoreUserData,
  });
}

/// Real Google Sign-Up Service using Firebase Auth + google_sign_in.
class GoogleSignUpService {
  GoogleSignUpService._internal();
  static final GoogleSignUpService instance = GoogleSignUpService._internal();

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

  /// Triggers the real OS-level Google Account chooser, then signs up
  /// the user via Firebase Auth and saves their data to Firestore + local stores.
  static Future<GoogleSignUpResponse> signUpWithGoogle({
    required String role,
    String? companyId,
  }) async {
    try {
      debugPrint('[GoogleSignUpService] Starting real Google Sign-Up for role: $role');

      // Trigger OS native Google Sign-In picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return GoogleSignUpResponse(
          isSuccess: false,
          message: 'Google Sign-In was cancelled.',
        );
      }

      debugPrint('[GoogleSignUpService] Google account selected: ${googleUser.email}');

      // Obtain Google Auth Details (idToken & accessToken)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return GoogleSignUpResponse(
          isSuccess: false,
          message: 'Firebase authentication failed.',
        );
      }

      final String uid = firebaseUser.uid;
      final String email = googleUser.email.toLowerCase().trim();
      final String fullName =
          googleUser.displayName?.isNotEmpty == true ? googleUser.displayName! : email;
      final String normalizedRole = role.trim().toLowerCase();
      final String createdAt = DateTime.now().toIso8601String();
      final String idToken = await firebaseUser.getIdToken() ?? '';

      debugPrint('[GoogleSignUpService] Firebase UID: $uid, email: $email');

      // Save to Firestore users collection
      final Map<String, dynamic> firestoreData = {
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'role': normalizedRole,
        'companyId': companyId ??
            (normalizedRole == 'enterprise'
                ? 'comp_${DateTime.now().millisecondsSinceEpoch}'
                : null),
        'status': 'active',
        'createdAt': createdAt,
        'provider': 'google',
        'photoUrl': googleUser.photoUrl,
      };

      await _firestore.collection('users').doc(uid).set(
            firestoreData,
            SetOptions(merge: true),
          );

      debugPrint('[GoogleSignUpService] Firestore document saved for $email');

      // Save to local multi-store for offline support
      UserModel userModel;

      if (normalizedRole == 'enterprise') {
        final entRecord = EnterpriseUserSignUpStore.saveUserSignUp(
          companyName: fullName,
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
          fullName: fullName,
          email: email,
          password: 'GOOGLE_OAUTH_PROTECTED',
          role: normalizedRole,
          provider: 'google',
        );
        userModel = UserModel(
          id: uid,
          name: indRecord.fullName,
          email: indRecord.email,
          role: normalizedRole,
        );
      }

      ResetPasswordStore.saveResetPasswordRecord(email, 'GOOGLE_OAUTH_PROTECTED');

      debugPrint('[GoogleSignUpService] ✅ Google Sign-Up complete for $email');

      return GoogleSignUpResponse(
        isSuccess: true,
        message: 'Google Sign-Up successful! Welcome, $fullName.',
        userModel: userModel,
        idToken: idToken,
        firestoreUserData: firestoreData,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[GoogleSignUpService] FirebaseAuthException: ${e.code}');
      return GoogleSignUpResponse(
        isSuccess: false,
        message: _mapFirebaseError(e.code),
      );
    } catch (e) {
      debugPrint('[GoogleSignUpService] Error: $e');
      return GoogleSignUpResponse(
        isSuccess: false,
        message: 'Google Sign-Up failed. Please try again.',
      );
    }
  }

  static String _mapFirebaseError(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email. Try logging in instead.';
      case 'invalid-credential':
        return 'Invalid Google credentials. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Google Sign-Up failed ($code). Please try again.';
    }
  }
}
