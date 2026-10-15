import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../previews/individual_metrics_store.dart';
import 'models/individual_sync_model.dart';

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
  final IndividualMetricsData metrics;

  IndividualUserRecord({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.role = 'individual',
    this.provider = 'email',
    DateTime? createdAt,
    DateTime? lastLoginAt,
    IndividualMetricsData? metrics,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastLoginAt = lastLoginAt ?? DateTime.now(),
        metrics = metrics ?? const IndividualMetricsData();

  IndividualUserRecord copyWith({
    String? fullName,
    String? password,
    String? role,
    String? provider,
    DateTime? lastLoginAt,
    IndividualMetricsData? metrics,
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
      metrics: metrics ?? this.metrics,
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
        'metrics': metrics.toJson(),
      };
}

enum LoginAuthStatus {
  success,
  wrongPassword,
  emailNotFound,
}

/// Central Individual Multi-Store & Real-Time Sync Hub
/// Manages both local isolated account switches and live Next.js / Firestore platform sync.
class IndividualSyncStore extends ChangeNotifier {
  IndividualSyncStore._internal();
  static final IndividualSyncStore instance = IndividualSyncStore._internal();

  static const String baseUrl = "https://mycardshare.com";

  IndividualSyncData? syncData;
  bool isLoading = false;
  String? errorMessage;

  Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {
        "Content-Type": "application/json",
      };
    }
    final token = await user.getIdToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ── 1. Fetch Complete Individual Sync (GET /api/sync/individual) ────
  Future<void> fetchIndividualSync() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final res = await http
          .get(Uri.parse("$baseUrl/api/sync/individual"), headers: headers)
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        syncData = IndividualSyncData.fromJson(json);
      } else {
        errorMessage = "Error [${res.statusCode}]: ${res.body}";
        await _fetchFromFirestoreFallback();
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("[IndividualSyncStore] Error: $e (using Firestore fallback)");
      await _fetchFromFirestoreFallback();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Direct Firestore fallback sync if Next.js endpoint is not reachable locally
  Future<void> _fetchFromFirestoreFallback() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final d = doc.data() ?? {};

      syncData = IndividualSyncData(
        profile: IndividualCardProfileModel(
          uid: user.uid,
          fullName: d['fullName'] ?? d['name'] ?? user.displayName ?? 'Individual User',
          email: d['email'] ?? user.email ?? '',
          phone: d['phone'] ?? '',
          jobTitle: d['jobTitle'] ?? '',
          company: d['company'] ?? '',
          bio: d['bio'] ?? '',
          cardSlug: d['cardSlug'] ?? d['slug'] ?? user.uid,
          avatarUrl: d['avatarUrl'] ?? d['photoURL'],
          bannerUrl: d['bannerUrl'],
          themeColor: d['themeColor'] ?? '#0052FF',
          isPublished: d['isPublished'] ?? true,
          socialLinks: d['socialLinks'] as Map<String, dynamic>? ?? {},
          cardUrl: 'https://mycardshare.com/card/${d['cardSlug'] ?? d['slug'] ?? user.uid}',
        ),
        analytics: IndividualAnalyticsModel(
          totalViews: (d['views'] as num?)?.toInt() ?? 0,
          uniqueVisitors: (d['uniqueVisitors'] as num?)?.toInt() ?? 0,
          totalShares: (d['shares'] as num?)?.toInt() ?? 0,
          leadsCaptured: 0,
          clickBreakdown: {},
        ),
        leads: [],
        vault: [],
        settings: IndividualSettingsModel(
          plan: d['plan'] ?? 'Pro',
          enableNfc: true,
          publicDirectoryListing: true,
          qrCodeLogoEnabled: true,
        ),
        syncedAt: DateTime.now().toIso8601String(),
      );
    } catch (_) {}
  }

  // ── Action 1: Update Card Profile (profile_editor/) ───────────────
  Future<bool> updateCardProfile(Map<String, dynamic> updates) async {
    return _sendAction("update_profile", updates);
  }

  // ── Action 2: Toggle Card Publish State (previews/) ───────────────
  Future<bool> togglePublishStatus(bool isPublished) async {
    return _sendAction("toggle_publish", {'isPublished': isPublished});
  }

  // ── Action 3: Save Scanned Card to Vault (scanner/ & vault/) ──────
  Future<bool> saveCardToVault(Map<String, dynamic> cardData) async {
    return _sendAction("add_vault_card", {'card': cardData});
  }

  // ── Action 4: Delete Card from Vault ─────────────────────────────
  Future<bool> deleteCardFromVault(String vaultId) async {
    return _sendAction("delete_vault_card", {'id': vaultId});
  }

  Future<bool> _sendAction(String action, Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final body = {'action': action, ...payload};
      final res = await http.patch(
        Uri.parse("$baseUrl/api/sync/individual"),
        headers: headers,
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        await fetchIndividualSync(); // Auto-refresh all mobile screens
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("[IndividualSyncStore] Action $action failed: $e");
      return false;
    }
  }
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
    IndividualMetricsData? metrics,
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
      metrics: metrics ?? existing?.metrics ?? const IndividualMetricsData(),
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
      return true;
    }
    return false;
  }

  /// Get all stored users.
  List<IndividualUserRecord> getAllUsers() {
    return _userStore.values.toList();
  }
}
