import 'package:firebase_auth/firebase_auth.dart';
import '../reset_passowrd.dart';

class MasterAdminResetPassword {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Dispatches real password reset email to Super Admin / Master Admin
  static Future<bool> sendResetLink(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      await _auth.sendPasswordResetEmail(email: normalizedEmail);
      ResetPasswordStore.recordResetRequest(normalizedEmail);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Updates Master Admin Password
  static Future<bool> updatePasswordSecurely({
    required String email,
    required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        ResetPasswordStore.saveResetPasswordRecord(normalizedEmail, newPassword);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
