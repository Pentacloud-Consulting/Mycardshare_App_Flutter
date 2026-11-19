import 'package:firebase_auth/firebase_auth.dart';
import '../reset_passowrd.dart';

class EmployeeResetPassword {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sends real password reset email to Corporate Employee
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

  /// Securely updates Employee password
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
