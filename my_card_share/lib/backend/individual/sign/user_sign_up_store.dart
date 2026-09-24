import 'package:flutter/foundation.dart';
import '../multiple store/individual_multi_store.dart';

/// UserSignUpStore manages the individual user sign-up workflow
/// and delegates persistent storage to IndividualMultiStore.
class UserSignUpStore {
  UserSignUpStore._internal();
  static final UserSignUpStore instance = UserSignUpStore._internal();

  /// Save new signup user details securely without data loss or leaks across users.
  static IndividualUserRecord saveUserSignUp({
    required String fullName,
    required String email,
    required String password,
    String role = 'individual',
    String provider = 'email',
  }) {
    debugPrint('[UserSignUpStore] Saving individual user signup for: $email');
    return IndividualMultiStore.instance.saveUser(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
      provider: provider,
    );
  }

  /// Retrieve stored individual user signup data by email.
  static IndividualUserRecord? getStoredUser(String email) {
    return IndividualMultiStore.instance.getUser(email);
  }

  /// Update password for a registered user.
  static bool updateUserPassword(String email, String newPassword) {
    return IndividualMultiStore.instance.updatePassword(email, newPassword);
  }

  /// Check if a user with the given email is registered.
  static bool isUserRegistered(String email) {
    return IndividualMultiStore.instance.getUser(email) != null;
  }
}
