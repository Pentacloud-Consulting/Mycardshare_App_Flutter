import 'package:flutter/foundation.dart';
import '../../../models/user_model.dart';
import '../multiple store/individual_multi_store.dart';
import 'user_sign_up_store.dart';
import '../../sign/google_login.dart';

/// Authentication response wrapper for Login Identity service.
class LoginIdentityResponse {
  final LoginAuthStatus status;
  final String message;
  final UserModel? userModel;
  final IndividualUserRecord? userRecord;

  LoginIdentityResponse({
    required this.status,
    required this.message,
    this.userModel,
    this.userRecord,
  });

  bool get isSuccess => status == LoginAuthStatus.success;
  bool get isWrongPassword => status == LoginAuthStatus.wrongPassword;
  bool get isEmailNotFound => status == LoginAuthStatus.emailNotFound;
}

/// LoginIdentity handles individual login authentication & Google Sign-In.
class LoginIdentity {
  LoginIdentity._internal();
  static final LoginIdentity instance = LoginIdentity._internal();

  /// Authenticates an individual user using email and password against stored records.
  static LoginIdentityResponse authenticateUser({
    required String email,
    required String password,
    String role = 'individual',
  }) {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      return LoginIdentityResponse(
        status: LoginAuthStatus.emailNotFound,
        message: "Please enter your email address.",
      );
    }

    // Verify credentials in multi-store
    final authStatus = IndividualMultiStore.instance.verifyCredentials(normalizedEmail, password);

    if (authStatus == LoginAuthStatus.emailNotFound) {
      return LoginIdentityResponse(
        status: LoginAuthStatus.emailNotFound,
        message: "Email address not found.",
      );
    }

    if (authStatus == LoginAuthStatus.wrongPassword) {
      return LoginIdentityResponse(
        status: LoginAuthStatus.wrongPassword,
        message: "The password entered is wrong. If forgotten, please click on 'Forgot Password' to reset.",
      );
    }

    // Auth Success
    final record = IndividualMultiStore.instance.getUser(normalizedEmail)!;
    final userModel = UserModel(
      id: record.id,
      name: record.fullName,
      email: record.email,
      role: role,
    );

    debugPrint('[LoginIdentity] User successfully authenticated: ${record.email}');

    return LoginIdentityResponse(
      status: LoginAuthStatus.success,
      message: "Login successful!",
      userModel: userModel,
      userRecord: record,
    );
  }

  /// Handles Async Google Sign-In authentication for Individual users per Backend.md.
  static Future<LoginIdentityResponse> loginWithGoogleAsync({
    String? googleEmail,
    String? googleName,
    String role = 'individual',
  }) async {
    final result = await GoogleLoginService.loginWithGoogle(
      role: role,
      googleEmail: googleEmail,
      googleName: googleName,
      autoProvision: true,
    );

    final record = IndividualMultiStore.instance.getUser(result.userModel?.email ?? '');

    return LoginIdentityResponse(
      status: result.isSuccess ? LoginAuthStatus.success : LoginAuthStatus.emailNotFound,
      message: result.message,
      userModel: result.userModel,
      userRecord: record,
    );
  }

  /// Synchronous fallback for Google Sign-In authentication.
  static LoginIdentityResponse loginWithGoogle({
    String? googleEmail,
    String? googleName,
    String role = 'individual',
  }) {
    final email = googleEmail?.trim().toLowerCase() ?? 'google.user@example.com';
    final name = googleName?.trim().isNotEmpty == true ? googleName!.trim() : 'Google User';

    final record = UserSignUpStore.saveUserSignUp(
      fullName: name,
      email: email,
      password: 'GOOGLE_OAUTH_PROTECTED',
      role: role,
      provider: 'google',
    );

    final userModel = UserModel(
      id: record.id,
      name: record.fullName,
      email: record.email,
      role: role,
    );

    debugPrint('[LoginIdentity] Google auth completed for: $email');

    return LoginIdentityResponse(
      status: LoginAuthStatus.success,
      message: "Google login successful!",
      userModel: userModel,
      userRecord: record,
    );
  }
}
