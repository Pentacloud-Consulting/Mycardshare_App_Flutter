import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../individual/multiple_store/individual_multi_store.dart';
import 'models/enterprise_sync_model.dart';

/// Represents an Enterprise user account record for local multi-auth caching.
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

/// Central Enterprise Multi-Store & Real-Time Sync Hub
/// Manages both local isolated account switches and live Next.js / Firestore platform sync.
class EnterpriseMultiStore extends ChangeNotifier {
  EnterpriseMultiStore._internal();
  static final EnterpriseMultiStore instance = EnterpriseMultiStore._internal();

  static const String baseUrl = "https://mycardshare.com";

  EnterpriseSyncData? syncData;
  bool isLoading = false;
  String? errorMessage;

  /// Memory store mapping normalized email to enterprise user records
  final Map<String, EnterpriseUserRecord> _enterpriseUserStore = {};

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

  // ── Load Entire Enterprise Data (GET /api/sync/enterprise) ────────
  Future<void> fetchEnterpriseSync() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getHeaders();
      final res = await http
          .get(Uri.parse("$baseUrl/api/sync/enterprise"), headers: headers)
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        syncData = EnterpriseSyncData.fromJson(json);
      } else {
        errorMessage = "Sync Note [${res.statusCode}]: ${res.body}";
        // Fallback: Populate from Firestore if local connection or offline
        await _fetchFromFirestoreFallback();
      }
    } catch (e) {
      errorMessage = e.toString();
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

      final entDoc = await FirebaseFirestore.instance.collection('enterprises').doc(user.uid).get();
      final data = entDoc.data() ?? {};

      syncData = EnterpriseSyncData(
        brandProfile: BrandProfileModel(
          companyId: user.uid,
          companyName: data['companyName'] ?? data['name'] ?? 'Enterprise Workspace',
          slug: data['slug'] ?? user.uid,
          companyLogo: data['companyLogo'] ?? data['logoUrl'],
          companyBanner: data['companyBanner'] ?? data['bannerUrl'],
          brandColor: data['brandColor'] ?? '#0052FF',
          isColorLocked: data['isColorLocked'] ?? false,
          website: data['website'] ?? '',
          officialEmail: data['email'] ?? user.email ?? '',
          phone: data['phone'] ?? '',
          address: data['address'] ?? '',
          industry: data['industry'] ?? '',
          socialLinks: data['socialLinks'] as List? ?? [],
          verifiedDomain: data['verifiedDomain'] ?? '',
        ),
        dashboardMetrics: DashboardMetricsModel(
          totalEmployees: (data['employeeCount'] as num?)?.toInt() ?? 0,
          activeEmployees: (data['activeEmployees'] as num?)?.toInt() ?? 0,
          totalLeads: (data['totalLeads'] as num?)?.toInt() ?? 0,
          totalCardViews: (data['totalCardViews'] as num?)?.toInt() ?? 0,
          totalCardShares: (data['totalCardShares'] as num?)?.toInt() ?? 0,
          ctrPercentage: (data['ctrPercentage'] is num) ? (data['ctrPercentage'] as num).toDouble() : 0.0,
          pendingRequestsCount: 0,
          monthlyGrowthRate: 0.0,
        ),
        workspace: WorkspaceDataModel(
          employees: [],
          joinRequests: [],
          seatAllocation: SeatAllocationModel(
            employeeLimit: (data['employeeLimit'] as num?)?.toInt() ?? 50,
            occupiedSeats: (data['employeeCount'] as num?)?.toInt() ?? 0,
            availableSeats: 50,
            isSeatExceeded: false,
          ),
        ),
        leadsData: LeadsDataModel(totalLeads: 0, recentLeads: [], crmConnectors: {}),
        campaigns: [],
        settings: SettingsDataModel(
          subscriptionPlan: data['plan'] ?? 'enterprise_pro',
          status: data['status'] ?? 'active',
          autoApproveDomainMatch: data['autoApproveDomainMatch'] ?? false,
          inviteCode: data['inviteCode'] ?? '',
        ),
        syncedAt: DateTime.now().toIso8601String(),
      );
    } catch (_) {}
  }

  // ── Action 1: Approve Join Request ──────────────────────────────
  Future<bool> approveJoinRequest({
    required String requestId,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    return _sendAction("approve_join_request", {
      "requestId": requestId,
      "userId": userId,
      "userName": userName,
      "userEmail": userEmail,
    });
  }

  // ── Action 2: Reject Join Request ───────────────────────────────
  Future<bool> rejectJoinRequest({
    required String requestId,
    String? reason,
  }) async {
    return _sendAction("reject_join_request", {
      "requestId": requestId,
      "reason": reason ?? "Declined by Admin",
    });
  }

  // ── Action 3: Toggle Employee Active/Suspended Status ─────────────
  Future<bool> toggleEmployeeStatus({
    required String employeeUserId,
    required String newStatus, // "active" or "suspended"
  }) async {
    return _sendAction("toggle_employee_status", {
      "employeeUserId": employeeUserId,
      "newStatus": newStatus,
    });
  }

  // ── Action 4: Update Brand Profile (brand_profile/) ──────────────
  Future<bool> updateBrandProfile(Map<String, dynamic> brandUpdates) async {
    return _sendAction("update_branding", brandUpdates);
  }

  Future<bool> _sendAction(String action, Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final res = await http.patch(
        Uri.parse("$baseUrl/api/sync/enterprise"),
        headers: headers,
        body: jsonEncode({"action": action, "payload": payload}),
      );
      if (res.statusCode == 200) {
        await fetchEnterpriseSync(); // Auto-refresh all screens
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Action $action failed: $e");
      return false;
    }
  }

  // ── Local User Account Management Methods (Preserved for compatibility) ──
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
    debugPrint('[EnterpriseMultiStore] Saved record for $normalizedEmail (Total users: ${_enterpriseUserStore.length})');
    return record;
  }

  EnterpriseUserRecord? getUser(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    return _enterpriseUserStore[normalizedEmail];
  }

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

  bool updatePassword(String email, String newPassword) {
    final normalizedEmail = email.trim().toLowerCase();
    final user = _enterpriseUserStore[normalizedEmail];

    if (user != null) {
      _enterpriseUserStore[normalizedEmail] = user.copyWith(
        password: newPassword,
        lastLoginAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  List<EnterpriseUserRecord> getAllUsers() {
    return _enterpriseUserStore.values.toList();
  }
}
