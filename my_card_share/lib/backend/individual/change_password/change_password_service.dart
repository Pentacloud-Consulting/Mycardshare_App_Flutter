import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../multiple_store/individual_multi_store.dart';
import '../notification/password_change_notify.dart';

class ChangePasswordResult {
  final bool isSuccess;
  final String message;

  const ChangePasswordResult({
    required this.isSuccess,
    required this.message,
  });

  factory ChangePasswordResult.success(String message) =>
      ChangePasswordResult(isSuccess: true, message: message);

  factory ChangePasswordResult.error(String message) =>
      ChangePasswordResult(isSuccess: false, message: message);
}

/// Service to handle real user password changes across Firebase Auth & IndividualMultiStore.
class ChangePasswordService {
  ChangePasswordService._internal();
  static final ChangePasswordService instance = ChangePasswordService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Changes the user's password after verifying current credentials.
  Future<ChangePasswordResult> changePassword({
    required String currentPassword,
    required String newPassword,
    BuildContext? context,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return ChangePasswordResult.error("No logged-in user found. Please log in again.");
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      return ChangePasswordResult.error("User email not found.");
    }

    try {
      debugPrint('[ChangePasswordService] Re-authenticating $email...');

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      debugPrint('[ChangePasswordService] Re-authentication successful.');

      // Update password in Firebase Auth
      await user.updatePassword(newPassword);
      debugPrint('[ChangePasswordService] Firebase Auth password updated.');

      // Update password in IndividualMultiStore local memory store
      IndividualMultiStore.instance.updatePassword(email, newPassword);

      // Trigger password update notification & screen alert
      PasswordChangeNotify.instance.notifyPasswordChanged(
        context: (context != null && context.mounted) ? context : null,
        userEmail: email,
      );

      return ChangePasswordResult.success("Password updated successfully!");
    } on FirebaseAuthException catch (e) {
      debugPrint('[ChangePasswordService] FirebaseAuthException: ${e.code}');
      return ChangePasswordResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      debugPrint('[ChangePasswordService] Error: $e');
      return ChangePasswordResult.error("Password update failed. Please verify your current password.");
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Incorrect current password. Please check your password.';
      case 'weak-password':
        return 'New password must be at least 6 characters.';
      case 'requires-recent-login':
        return 'For security, please log out and log in again before changing your password.';
      case 'user-not-found':
        return 'User account not found.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Password update failed ($code). Please try again.';
    }
  }
}


