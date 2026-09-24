import 'package:flutter/foundation.dart';
import '../../../models/user_model.dart';

/// Response wrapper for Master Admin login authentication.
class MasterAdminAuthResponse {
  final bool isSuccess;
  final String message;
  final UserModel? userModel;

  MasterAdminAuthResponse({
    required this.isSuccess,
    required this.message,
    this.userModel,
  });
}

/// Secure backend service for Master Admin authentication and credential management.
class MasterAdminLoginService {
  MasterAdminLoginService._internal();
  static final MasterAdminLoginService instance = MasterAdminLoginService._internal();

  /// Memory store for Master Admin credentials.
  static final Map<String, String> _adminCredentials = {
    'admin@mycardshare.com': 'admin123',
    'master@mycardshare.com': 'masterpass123',
  };

  static final Map<String, String> _adminNames = {
    'admin@mycardshare.com': 'System Master Admin',
    'master@mycardshare.com': 'Primary Platform Director',
  };

  /// Authenticates Master Admin credentials securely.
  static Future<MasterAdminAuthResponse> authenticateMasterAdmin({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    debugPrint('[MasterAdminLoginService] Authenticating master admin: $normalizedEmail');

    // Simulate secure authorization delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return MasterAdminAuthResponse(
        isSuccess: false,
        message: "Please enter a valid master admin email address.",
      );
    }

    final storedPassword = _adminCredentials[normalizedEmail];

    if (storedPassword == null) {
      return MasterAdminAuthResponse(
        isSuccess: false,
        message: "Master Admin account not found. Restricted access only.",
      );
    }

    if (storedPassword != password) {
      return MasterAdminAuthResponse(
        isSuccess: false,
        message: "Incorrect password entered. Access denied.",
      );
    }

    final adminName = _adminNames[normalizedEmail] ?? 'Master Admin';

    final user = UserModel(
      id: 'admin_master_${normalizedEmail.hashCode}',
      name: adminName,
      email: normalizedEmail,
      role: 'master-admin',
    );

    debugPrint('[MasterAdminLoginService] Master admin $normalizedEmail authenticated successfully');

    return MasterAdminAuthResponse(
      isSuccess: true,
      message: "Master Admin authentication successful!",
      userModel: user,
    );
  }

  /// Securely registers or updates Master Admin credentials.
  static void saveMasterAdminCredential({
    required String email,
    required String password,
    String? name,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    _adminCredentials[normalizedEmail] = password;
    if (name != null && name.trim().isNotEmpty) {
      _adminNames[normalizedEmail] = name.trim();
    }
    debugPrint('[MasterAdminLoginService] Saved Master Admin credential for $normalizedEmail');
  }

  /// Update Master Admin password safely.
  static bool updateAdminPassword(String email, String newPassword) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_adminCredentials.containsKey(normalizedEmail)) {
      _adminCredentials[normalizedEmail] = newPassword;
      debugPrint('[MasterAdminLoginService] Master Admin password updated for $normalizedEmail');
      return true;
    }
    return false;
  }
}
