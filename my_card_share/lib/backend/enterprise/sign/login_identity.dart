import 'package:flutter/foundation.dart';
import '../../../models/user_model.dart';
import '../../individual/multiple store/individual_multi_store.dart';
import '../multiple store/enterprise_multi_store.dart';
import 'user_sign_up_store.dart';
import '../../sign/google_login.dart';

/// Authentication response wrapper for Enterprise Login Identity service.
class EnterpriseLoginResponse {
  final LoginAuthStatus status;
  final String message;
  final UserModel? userModel;
  final EnterpriseUserRecord? userRecord;

  EnterpriseLoginResponse({
    required this.status,
    required this.message,
    this.userModel,
    this.userRecord,
  });

  bool get isSuccess => status == LoginAuthStatus.success;
  bool get isWrongPassword => status == LoginAuthStatus.wrongPassword;
  bool get isEmailNotFound => status == LoginAuthStatus.emailNotFound;
}

/// EnterpriseLoginIdentity handles Enterprise login authentication & Google Sign-In per Backend.md.
class EnterpriseLoginIdentity {
  EnterpriseLoginIdentity._internal();
  static final EnterpriseLoginIdentity instance = EnterpriseLoginIdentity._internal();

  /// Authenticates an Enterprise user using email and password against stored records.
  static EnterpriseLoginResponse authenticateUser({
    required String email,
    required String password,
    String role = 'enterprise',
  }) {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      return EnterpriseLoginResponse(
        status: LoginAuthStatus.emailNotFound,
        message: "Please enter your email address.",
      );
    }

    // Verify credentials in EnterpriseMultiStore
    final authStatus = EnterpriseMultiStore.instance.verifyCredentials(normalizedEmail, password);

    if (authStatus == LoginAuthStatus.emailNotFound) {
      return EnterpriseLoginResponse(
        status: LoginAuthStatus.emailNotFound,
        message: "Email address not found.",
      );
    }

    if (authStatus == LoginAuthStatus.wrongPassword) {
      return EnterpriseLoginResponse(
        status: LoginAuthStatus.wrongPassword,
        message: "The password entered is wrong. If forgotten, please click on 'Forgot Password' to reset.",
      );
    }

    // Auth Success
    final record = EnterpriseMultiStore.instance.getUser(normalizedEmail)!;
    final userModel = UserModel(
      id: record.id,
      name: record.companyName,
      email: record.email,
      role: role,
    );

    debugPrint('[EnterpriseLoginIdentity] Enterprise user successfully authenticated: ${record.email}');

    return EnterpriseLoginResponse(
      status: LoginAuthStatus.success,
      message: "Enterprise Login successful!",
      userModel: userModel,
      userRecord: record,
    );
  }

  /// Handles Async Google Sign-In authentication for Enterprise users per Backend.md.
  static Future<EnterpriseLoginResponse> loginWithGoogleAsync({
    String? googleEmail,
    String? companyName,
    String role = 'enterprise',
  }) async {
    final result = await GoogleLoginService.loginWithGoogle(
      role: role,
      googleEmail: googleEmail,
      googleName: companyName,
      autoProvision: true,
    );

    final record = EnterpriseMultiStore.instance.getUser(result.userModel?.email ?? '');

    return EnterpriseLoginResponse(
      status: result.isSuccess ? LoginAuthStatus.success : LoginAuthStatus.emailNotFound,
      message: result.message,
      userModel: result.userModel,
      userRecord: record,
    );
  }

  /// Synchronous fallback for Google Sign-In authentication.
  static EnterpriseLoginResponse loginWithGoogle({
    String? googleEmail,
    String? companyName,
    String role = 'enterprise',
  }) {
    final email = googleEmail?.trim().toLowerCase() ?? 'enterprise.google@example.com';
    final name = companyName?.trim().isNotEmpty == true ? companyName!.trim() : 'Enterprise Google User';

    // Auto-register or fetch existing record in EnterpriseMultiStore
    final record = EnterpriseUserSignUpStore.saveUserSignUp(
      companyName: name,
      email: email,
      password: 'GOOGLE_OAUTH_PROTECTED',
      role: role,
      provider: 'google',
    );

    final userModel = UserModel(
      id: record.id,
      name: record.companyName,
      email: record.email,
      role: role,
    );

    debugPrint('[EnterpriseLoginIdentity] Enterprise Google auth completed for: $email');

    return EnterpriseLoginResponse(
      status: LoginAuthStatus.success,
      message: "Enterprise Google login successful!",
      userModel: userModel,
      userRecord: record,
    );
  }
}
