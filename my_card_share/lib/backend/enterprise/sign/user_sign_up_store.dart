import 'package:flutter/foundation.dart';
import '../multiple store/enterprise_multi_store.dart';

/// EnterpriseUserSignUpStore manages the Enterprise user sign-up workflow
/// and delegates persistent storage to EnterpriseMultiStore.
class EnterpriseUserSignUpStore {
  EnterpriseUserSignUpStore._internal();
  static final EnterpriseUserSignUpStore instance = EnterpriseUserSignUpStore._internal();

  /// Save new enterprise signup user details securely without data loss or leaks.
  static EnterpriseUserRecord saveUserSignUp({
    required String companyName,
    required String email,
    required String password,
    String role = 'enterprise',
    String provider = 'email',
  }) {
    debugPrint('[EnterpriseUserSignUpStore] Saving enterprise user signup for: $email');
    return EnterpriseMultiStore.instance.saveUser(
      companyName: companyName,
      email: email,
      password: password,
      role: role,
      provider: provider,
    );
  }

  /// Retrieve stored enterprise user data by email.
  static EnterpriseUserRecord? getStoredUser(String email) {
    return EnterpriseMultiStore.instance.getUser(email);
  }

  /// Update password for a registered enterprise user.
  static bool updateUserPassword(String email, String newPassword) {
    return EnterpriseMultiStore.instance.updatePassword(email, newPassword);
  }

  /// Check if an enterprise user with the given email is registered.
  static bool isUserRegistered(String email) {
    return EnterpriseMultiStore.instance.getUser(email) != null;
  }
}
