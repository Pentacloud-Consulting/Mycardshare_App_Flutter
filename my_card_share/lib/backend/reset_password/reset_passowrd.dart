/// ResetPasswordStore maintains password reset records and tokens.
class ResetPasswordStore {
  ResetPasswordStore._internal();
  static final ResetPasswordStore instance = ResetPasswordStore._internal();

  static final Map<String, String> _resetTokens = {};
  static final Map<String, String> _latestPasswords = {};

  /// Record a new password reset request email with optional token.
  static void recordResetRequest(String email, {String? token}) {
    final normalized = email.trim().toLowerCase();
    _resetTokens[normalized] =
        token ?? 'token_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Store updated password safely.
  static void saveResetPasswordRecord(String email, String newPassword) {
    final normalized = email.trim().toLowerCase();
    _latestPasswords[normalized] = newPassword;
  }

  /// Retrieve latest reset password.
  static String? getLatestPassword(String email) {
    return _latestPasswords[email.trim().toLowerCase()];
  }

  /// Retrieve reset token.
  static String? getResetToken(String email) {
    return _resetTokens[email.trim().toLowerCase()];
  }
}
