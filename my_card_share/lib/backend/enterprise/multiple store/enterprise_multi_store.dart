import 'package:flutter/foundation.dart';
import '../../individual/multiple store/individual_multi_store.dart';

/// Represents an Enterprise user account record.
class EnterpriseUserRecord {
  final String id;
  final String companyName;
  final String email;
  final String password;
  final String role;
  final String provider; // 'email' or 'google'
  final DateTime createdAt;
  final DateTime lastLoginAt;

  EnterpriseUserRecord({
    required this.id,
    required this.companyName,
    required this.email,
    required this.password,
    this.role = 'enterprise',
    this.provider = 'email',
    DateTime? createdAt,
    DateTime? lastLoginAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastLoginAt = lastLoginAt ?? DateTime.now();

  EnterpriseUserRecord copyWith({
    String? companyName,
    String? password,
    String? role,
    String? provider,
    DateTime? lastLoginAt,
  }) {
    return EnterpriseUserRecord(
      id: id,
      companyName: companyName ?? this.companyName,
      email: email,
      password: password ?? this.password,
      role: role ?? this.role,
      provider: provider ?? this.provider,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

/// Secure multi-store manager for isolating Enterprise user accounts.
class EnterpriseMultiStore {
  EnterpriseMultiStore._internal();
  static final EnterpriseMultiStore instance = EnterpriseMultiStore._internal();

  /// Memory store mapping normalized lowercased email to enterprise user records.
  final Map<String, EnterpriseUserRecord> _enterpriseUserStore = {};

  /// Save or register a new enterprise user in the multi-store.
  EnterpriseUserRecord saveUser({
    required String companyName,
    required String email,
    required String password,
    String role = 'enterprise',
    String provider = 'email',
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final existing = _enterpriseUserStore[normalizedEmail];

    final record = EnterpriseUserRecord(
      id: existing?.id ?? 'ent_user_${DateTime.now().millisecondsSinceEpoch}',
      companyName: companyName.trim().isNotEmpty ? companyName.trim() : (existing?.companyName ?? 'Enterprise Account'),
      email: normalizedEmail,
      password: password,
      role: role,
      provider: provider,
      createdAt: existing?.createdAt,
      lastLoginAt: DateTime.now(),
    );

    _enterpriseUserStore[normalizedEmail] = record;
    debugPrint('[EnterpriseMultiStore] Saved record for $normalizedEmail (Total enterprise users: ${_enterpriseUserStore.length})');
    return record;
  }

  /// Get a stored enterprise user record by email.
  EnterpriseUserRecord? getUser(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    return _enterpriseUserStore[normalizedEmail];
  }

  /// Verify enterprise user credentials securely.
  LoginAuthStatus verifyCredentials(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    final user = _enterpriseUserStore[normalizedEmail];

    if (user == null) {
      return LoginAuthStatus.emailNotFound;
    }

    if (user.provider == 'google' || user.password == password) {
      _enterpriseUserStore[normalizedEmail] = user.copyWith(lastLoginAt: DateTime.now());
      return LoginAuthStatus.success;
    }

    return LoginAuthStatus.wrongPassword;
  }

  /// Update password for an enterprise user safely.
  bool updatePassword(String email, String newPassword) {
    final normalizedEmail = email.trim().toLowerCase();
    final user = _enterpriseUserStore[normalizedEmail];

    if (user != null) {
      _enterpriseUserStore[normalizedEmail] = user.copyWith(
        password: newPassword,
        lastLoginAt: DateTime.now(),
      );
      debugPrint('[EnterpriseMultiStore] Password updated successfully for $normalizedEmail');
      return true;
    }
    return false;
  }

  /// Get all stored enterprise users.
  List<EnterpriseUserRecord> getAllUsers() {
    return _enterpriseUserStore.values.toList();
  }
}
