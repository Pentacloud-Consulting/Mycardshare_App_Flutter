import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordService {
  static const String baseUrl = "https://mycardshare.com";

  /// 1. UNIFIED BACKEND + FIREBASE NATIVE FALLBACK
  static Future<Map<String, dynamic>> sendResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();

    // STEP 1: Verify with backend whether this account actually exists
    try {
      final verifyRes = await http.post(
        Uri.parse("$baseUrl/api/sync/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": cleanEmail, "role": "auto", "checkOnly": true}),
      ).timeout(const Duration(seconds: 6));

      if (verifyRes.statusCode == 404) {
        final body = jsonDecode(verifyRes.body);
        if (body["error"]?["code"] == "USER_NOT_FOUND" ||
            body["error"]?["message"]?.toString().contains("No registered account") == true) {
          return {
            "success": false,
            "error": "You have never signed up with this email. Please create an account first.",
          };
        }
      }
    } catch (_) {
      // If network/timeout on check, fall through to Firebase Auth directly
    }

    // STEP 2: Send reset email via Firebase Auth
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: cleanEmail,
      );

      return {
        "success": true,
        "message": "Reset link sent! Please check your Inbox and Spam folder.",
      };
    } on FirebaseAuthException catch (e) {
      String errMsg = "Failed to send reset link.";
      if (e.code == 'user-not-found') {
        errMsg = "You have never signed up with this email. Please create an account first.";
      } else if (e.code == 'invalid-email') {
        errMsg = "Invalid email format.";
      } else if (e.code == 'too-many-requests') {
        errMsg = "Too many requests. Please wait a few minutes and try again.";
      } else if (e.message != null && e.message!.isNotEmpty) {
        errMsg = e.message!;
      }
      return {"success": false, "error": errMsg};
    } catch (e) {
      return {"success": false, "error": "An unexpected error occurred. Try again later."};
    }
  }
}
