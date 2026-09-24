import 'package:flutter/foundation.dart';

/// Represents an individual user's stored account record.
class IndividualUserRecord {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String role;
  final String provider; // 'email' or 'google'
  final DateTime createdAt;
  final DateTime lastLoginAt;

  IndividualUserRecord({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.role = 'individual',
    this.provider = 'email',
    DateTime? createdAt,
    DateTime? lastLoginAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastLoginAt = lastLoginAt ?? DateTime.now();

  IndividualUserRecord copyWith({
    String? fullName,
    String? password,
    String? role,
    String? provider,
    DateTime? lastLoginAt,
  }) {
    return IndividualUserRecord(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      password: password ?? this.password,
      role: role ?? this.role,
      provider: provider ?? this.provider,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
        'provider': provider,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt.toIso8601String(),
      };
}

enum LoginAuthStatus {
  success,
  wrongPassword,
  emailNotFound,
}

/// Secure multi-store manager for isolating individual user accounts.
class IndividualMultiStore {
  IndividualMultiStore._internal();
  static final IndividualMultiStore instance = IndividualMultiStore._internal();

  /// Isolated memory store mapping normalized lowercased email to user records.
  final Map<String, IndividualUserRecord> _userStore = {};

  /// Save or register a new user in the multi-store.
  IndividualUserRecord saveUser({
    required String fullName,
    required String email,
    required String password,
    String role = 'individual',
    String provider = 'email',
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final existing = _userStore[normalizedEmail];

    final record = IndividualUserRecord(
      id: existing?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim().isNotEmpty ? fullName.trim() : (existing?.fullName ?? 'Individual User'),
      email: normalizedEmail,
      password: password,
      role: role,
      provider: provider,
      createdAt: existing?.createdAt,
      lastLoginAt: DateTime.now(),
    );

    _userStore[normalizedEmail] = record;
    debugPrint('[IndividualMultiStore] Saved record for $normalizedEmail (Total users: ${_userStore.length})');
    return record;
  }

  /// Get a stored user record by email.
  IndividualUserRecord? getUser(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    return _userStore[normalizedEmail];
  }

  /// Verify user credentials securely.
  LoginAuthStatus verifyCredentials(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    final user = _userStore[normalizedEmail];

    if (user == null) {
      return LoginAuthStatus.emailNotFound;
    }

    // Google authenticated users or matching password
    if (user.provider == 'google' || user.password == password) {
      _userStore[normalizedEmail] = user.copyWith(lastLoginAt: DateTime.now());
      return LoginAuthStatus.success;
    }

    return LoginAuthStatus.wrongPassword;
  }

  /// Update password for a specific user safely.
  bool updatePassword(String email, String newPassword) {
    final normalizedEmail = email.trim().toLowerCase();
    final user = _userStore[normalizedEmail];

    if (user != null) {
      _userStore[normalizedEmail] = user.copyWith(
        password: newPassword,
        lastLoginAt: DateTime.now(),
      );
      debugPrint('[IndividualMultiStore] Password updated successfully for $normalizedEmail');
      return true;
    }
    return false;
  }

  /// Get all stored users (admin/debug purposes).
  List<IndividualUserRecord> getAllUsers() {
    return _userStore.values.toList();
  }
}
