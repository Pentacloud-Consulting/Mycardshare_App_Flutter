import 'package:firebase_auth/firebase_auth.dart';
import '../reset_passowrd.dart';

class IndividualResetPassword {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

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
