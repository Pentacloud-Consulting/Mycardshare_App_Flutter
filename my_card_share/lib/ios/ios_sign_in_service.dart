import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../backend/app view/app_view_auth_gate.dart';
import '../models/user_model.dart';

/// ═══════════════════════════════════════════════════════════════
/// Sign In with Apple Service
///
/// Required by Apple App Store Review Guidelines 4.8:
/// "Apps that include Sign in with a third-party service (e.g., Google)
/// MUST also offer Sign in with Apple."
///
/// Prerequisites:
///   1. Apple Developer → Sign In with Apple capability enabled
///   2. Add to Xcode → Signing & Capabilities → Sign In with Apple
///   3. Add package: sign_in_with_apple: ^6.1.2 to pubspec.yaml
///   4. Firebase Auth → Enable Apple as Sign-In provider
///
/// Current State: sign_in_with_apple: ^6.1.2 is in pubspec.yaml ✅
/// Next step: Enable Apple capability in Xcode on Mac, then uncomment imports below.
/// ═══════════════════════════════════════════════════════════════
class IOSSignInWithAppleService {
  IOSSignInWithAppleService._internal();
  static final IOSSignInWithAppleService instance =
      IOSSignInWithAppleService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns true if Sign In with Apple is available on this device.
  /// Available on iOS 13+.
  static bool get isAvailable {
    if (kIsWeb) return false;
    if (!Platform.isIOS) return false;
    return true; // All iOS 13+ devices support it
  }

  /// Performs Sign In with Apple flow.
  ///
  /// STEP 1 — Add to pubspec.yaml:
  ///   sign_in_with_apple: ^6.1.2
  ///
  /// STEP 2 — Uncomment the imports and implementation below.
  ///
  /// STEP 3 — In Firebase Console:
  ///   Authentication → Sign-in method → Apple → Enable
  ///   Add your Apple Service ID and configure redirect URL
  ///
  Future<IOSSignInResult> signInWithApple() async {
    if (!isAvailable) {
      return IOSSignInResult.error(
        'Sign In with Apple is only available on iOS 13+.',
      );
    }

    try {
      // ─── UNCOMMENT WHEN sign_in_with_apple PACKAGE IS ADDED ───────────
      //
      // import 'package:sign_in_with_apple/sign_in_with_apple.dart';
      // import 'package:crypto/crypto.dart';
      // import 'dart:convert';
      //
      // // Generate a nonce for security
      // final rawNonce = _generateNonce();
      // final nonce = _sha256ofString(rawNonce);
      //
      // // Trigger Apple Sign In dialog
      // final appleCredential = await SignInWithApple.getAppleIDCredential(
      //   scopes: [
      //     AppleIDAuthorizationScopes.email,
      //     AppleIDAuthorizationScopes.fullName,
      //   ],
      //   nonce: nonce,
      // );
      //
      // // Build Firebase credential
      // final oauthCredential = OAuthProvider('apple.com').credential(
      //   idToken: appleCredential.identityToken,
      //   rawNonce: rawNonce,
      // );
      //
      // final credential = await _auth.signInWithCredential(oauthCredential);
      // final user = credential.user!;
      //
      // // Apple only provides name on FIRST sign-in
      // final fullName = [
      //   appleCredential.givenName ?? '',
      //   appleCredential.familyName ?? '',
      // ].where((s) => s.isNotEmpty).join(' ');
      //
      // final resolvedName = fullName.isNotEmpty
      //     ? fullName
      //     : (user.displayName ?? user.email?.split('@').first ?? 'Apple User');
      //
      // // Write to Firestore
      // await _firestore.collection('users').doc(user.uid).set({
      //   'uid': user.uid,
      //   'fullName': resolvedName,
      //   'name': resolvedName,
      //   'email': user.email ?? appleCredential.email ?? '',
      //   'role': 'individual',
      //   'authProvider': 'apple',
      //   'status': 'Active',
      //   'createdAt': FieldValue.serverTimestamp(),
      //   'updatedAt': FieldValue.serverTimestamp(),
      // }, SetOptions(merge: true));
      //
      // return IOSSignInResult(
      //   isSuccess: true,
      //   message: 'Signed in with Apple successfully!',
      //   firebaseUser: user,
      //   userData: {'fullName': resolvedName, 'email': user.email ?? ''},
      // );
      // ──────────────────────────────────────────────────────────────────

      // Temporary: Package not yet added — show instructions
      return IOSSignInResult.error(
        'Sign In with Apple setup is pending. '
        'Add sign_in_with_apple package to pubspec.yaml and enable in Firebase Console.',
      );
    } catch (e) {
      debugPrint('[IOSSignInWithAppleService] Error: $e');
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        return IOSSignInResult.error('Apple Sign-In was cancelled.');
      }
      return IOSSignInResult.error('Apple Sign-In failed. Please try again.');
    }
  }

  /// Signs out from Apple Sign-In (clears Firebase session).
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await AppViewAuthGate.instance.clearPersistentSession();
    } catch (e) {
      debugPrint('[IOSSignInWithAppleService] SignOut error: $e');
    }
  }
}

/// Result wrapper for Apple Sign-In operations.
class IOSSignInResult {
  final bool isSuccess;
  final String message;
  final User? firebaseUser;
  final Map<String, dynamic>? userData;

  const IOSSignInResult({
    required this.isSuccess,
    required this.message,
    this.firebaseUser,
    this.userData,
  });

  factory IOSSignInResult.error(String message) =>
      IOSSignInResult(isSuccess: false, message: message);
}

/// ═══════════════════════════════════════════════════════════════
/// Sign In with Apple Button Widget
/// Renders the official black Apple button on iOS only.
/// Completely invisible (SizedBox.shrink) on Android.
/// ═══════════════════════════════════════════════════════════════
class IOSSignInWithAppleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const IOSSignInWithAppleButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // ONLY show on iOS
    if (kIsWeb || !Platform.isIOS) return const SizedBox.shrink();

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Sign in with Apple',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
