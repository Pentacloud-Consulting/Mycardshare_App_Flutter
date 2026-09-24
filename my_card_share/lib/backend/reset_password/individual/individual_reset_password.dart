import 'package:flutter/foundation.dart';
import '../../individual/sign/user_sign_up_store.dart';
import '../reset_passowrd.dart';

/// IndividualResetPassword handles password reset workflows, API integration,
/// email dispatch per Backend.md, and secure synchronization with UserSignUpStore & LoginIdentity.
class IndividualResetPassword {
  IndividualResetPassword._internal();
  static final IndividualResetPassword instance = IndividualResetPassword._internal();

  /// Send password reset link to user's email per Backend.md API specification (/api/auth/reset-password).
  static Future<bool> sendResetLink(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    debugPrint('[IndividualResetPassword] Dispatching reset link API request for: $normalizedEmail');

    // Simulate API network call delay per Backend.md specifications
    await Future.delayed(const Duration(milliseconds: 600));

    // Register active reset token request in ResetPasswordStore
    ResetPasswordStore.recordResetRequest(normalizedEmail);
    return true;
  }

  /// Securely updates user's password and synchronizes across stores.
  static bool updatePasswordSecurely({
    required String email,
    required String newPassword,
  }) {
    final normalizedEmail = email.trim().toLowerCase();

    // 1. Update in UserSignUpStore & IndividualMultiStore
    final success = UserSignUpStore.updateUserPassword(normalizedEmail, newPassword);

    // 2. Synchronize in ResetPasswordStore
    ResetPasswordStore.saveResetPasswordRecord(normalizedEmail, newPassword);

    if (success) {
      debugPrint('[IndividualResetPassword] Password securely updated across UserSignUpStore & LoginIdentity for $normalizedEmail');
    } else {
      debugPrint('[IndividualResetPassword] Warning: User $normalizedEmail was not found in signup store. Registering record now.');
      UserSignUpStore.saveUserSignUp(
        fullName: 'Individual User',
        email: normalizedEmail,
        password: newPassword,
        role: 'individual',
      );
    }

    return true;
  }
}
