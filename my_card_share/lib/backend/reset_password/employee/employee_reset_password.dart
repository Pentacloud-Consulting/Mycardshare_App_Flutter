import 'dart:convert';
import 'package:http/http.dart' as http;
import '../reset_passowrd.dart';

class EmployeeResetPassword {
  static const String baseUrl = "https://mycardshare.com";

  /// Sends real password reset email to Corporate Employee
  static Future<bool> sendResetLink(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": normalizedEmail,
          "role": "employee",
        }),
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final token = json['data']?['resetToken'] ??
            'token_${DateTime.now().millisecondsSinceEpoch}';
        ResetPasswordStore.recordResetRequest(normalizedEmail, token: token);
        return true;
      }
      return false;
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
      final res = await http.patch(
        Uri.parse("$baseUrl/api/sync/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": normalizedEmail,
          "newPassword": newPassword,
        }),
      );
      if (res.statusCode == 200) {
        ResetPasswordStore.saveResetPasswordRecord(normalizedEmail, newPassword);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
