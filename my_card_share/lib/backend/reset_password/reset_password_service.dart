import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordService {
  static const String baseUrl = "https://mycardshare.com";

  /// 1. UNIFIED BACKEND + FIREBASE NATIVE FALLBACK
  static Future<Map<String, dynamic>> sendResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();

    // STEP 1: Try Firebase Native FIRST (most reliable — directly checks Firebase Auth)
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: cleanEmail,
        actionCodeSettings: ActionCodeSettings(
          url: "https://mycardshare.com/reset-password",
          handleCodeInApp: false,
          androidPackageName: "com_pentacloud.mycarshare",
          androidInstallApp: true,
          androidMinimumVersion: "1",
        ),
      );

      // Also try backend sync in background (don't block on it)
      _syncResetWithBackend(cleanEmail);

      return {
        "success": true,
        "message": "Reset link sent! Please check your Inbox and Spam folder.",
      };
    } on FirebaseAuthException catch (e) {
      String errMsg = "Failed to send reset link.";
      if (e.code == 'user-not-found') {
        errMsg = "No account found with this email. Please sign up first.";
      } else if (e.code == 'invalid-email') {
        errMsg = "Invalid email format.";
      } else if (e.code == 'too-many-requests') {
        errMsg = "Too many requests. Please wait a few minutes and try again.";
      }
      return {"success": false, "error": errMsg};
    } catch (e) {
      return {"success": false, "error": "An unexpected error occurred. Try again later."};
    }
  }

  /// Background sync with backend (fire-and-forget)
  static void _syncResetWithBackend(String email) {
    http.post(
      Uri.parse("$baseUrl/api/sync/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "role": "auto"}),
    ).catchError((_) => http.Response('', 500));
  }
}
