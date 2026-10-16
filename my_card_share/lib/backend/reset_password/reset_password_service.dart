import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordService {
  static const String baseUrl = "https://mycardshare.com";

  /// 1. UNIFIED BACKEND + FIREBASE NATIVE FALLBACK
  static Future<Map<String, dynamic>> sendResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();

    // STEP 1: Try Next.js Unified Sync API (Custom branded email template with role resolution)
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/sync/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": cleanEmail,
          "role": "auto",
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return {
          "success": true,
          "message": "Reset link sent! Please check your Inbox and Spam folder.",
          "role": json["data"]?["role"] ?? "individual",
        };
      } else if (response.statusCode == 404) {
        return {
          "success": false,
          "error": "No account found with this email address. Please sign up.",
        };
      }
    } catch (apiError) {
      debugPrint("[ResetPasswordService] API Reset failed, falling back to Firebase Native: $apiError");
    }

    // STEP 2: NATIVE FIREBASE FALLBACK (Agar server offline ya unreachable ho)
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: cleanEmail,
        actionCodeSettings: ActionCodeSettings(
          url: "https://mycardshare.com/reset-password",
          handleCodeInApp: false,
          androidPackageName: "com.pentacloud.mycardshare",
          androidInstallApp: true,
          androidMinimumVersion: "1",
        ),
      );

      return {
        "success": true,
        "message": "Reset email dispatched via Firebase. Check your Spam/Promotions folder.",
      };
    } on FirebaseAuthException catch (e) {
      String errMsg = "Failed to send reset link.";
      if (e.code == 'user-not-found') {
        errMsg = "No registered user found with this email.";
      } else if (e.code == 'invalid-email') {
        errMsg = "Invalid email format.";
      }
      return {"success": false, "error": errMsg};
    } catch (e) {
      return {"success": false, "error": "An unexpected error occurred. Try again later."};
    }
  }
}
