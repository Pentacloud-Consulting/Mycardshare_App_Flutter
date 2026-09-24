import 'package:flutter/foundation.dart';

/// ResetPasswordStore maintains password reset records and tokens.
class ResetPasswordStore {
  ResetPasswordStore._internal();
  static final ResetPasswordStore instance = ResetPasswordStore._internal();

  static final Map<String, String> _resetTokens = {};
  static final Map<String, String> _latestPasswords = {};

  /// Record a new password reset request email.
  static void recordResetRequest(String email) {
    final normalized = email.trim().toLowerCase();
    final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
    _resetTokens[normalized] = token;
    debugPrint('[ResetPasswordStore] Recorded reset request for $normalized (Token: $token)');
  }

  /// Store updated password safely.
  static void saveResetPasswordRecord(String email, String newPassword) {
    final normalized = email.trim().toLowerCase();
    _latestPasswords[normalized] = newPassword;
    debugPrint('[ResetPasswordStore] Saved updated password record for $normalized');
  }

  /// Retrieve latest reset password.
  static String? getLatestPassword(String email) {
    return _latestPasswords[email.trim().toLowerCase()];
  }
}
