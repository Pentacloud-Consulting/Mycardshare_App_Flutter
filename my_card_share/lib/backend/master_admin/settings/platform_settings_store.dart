import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/master_admin_api_client.dart';
import '../core/master_admin_endpoints.dart';

class PlatformAdminAccount {
  final String id;
  final String name;
  final String email;
  final bool isPrimary;
  final String initials;

  PlatformAdminAccount({
    required this.id,
    required this.name,
    required this.email,
    this.isPrimary = false,
  }) : initials = _calculateInitials(name);

  static String _calculateInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'SA';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class SubscriptionPlanModel {
  final String id;
  final String name;
  final int maxEmployees;
  final int maxCards;
  final double price;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.maxEmployees,
    required this.maxCards,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'maxEmployees': maxEmployees,
    'maxCards': maxCards,
    'price': price,
  };

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlanModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? 'Plan').toString(),
      maxEmployees: (map['maxEmployees'] as num?)?.toInt() ?? 10,
      maxCards: (map['maxCards'] as num?)?.toInt() ?? 20,
      price: (map['price'] as num?)?.toDouble() ?? 29.0,
    );
  }
}

class PlatformSettingsStore extends ChangeNotifier {
  PlatformSettingsStore._internal();
  static final PlatformSettingsStore instance = PlatformSettingsStore._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _geminiKey = "sk-••••••••7f2a";
  String _huggingFaceKey = "hf-••••••••9c1d";
  final String _environment = "Production";
  String _dbStatus = "Healthy";
  List<PlatformAdminAccount> _superAdmins = [];
  final bool _isLoading = false;

  // Platform & Governance configuration matching Web Master Admin
  String _platformName = "MyCardShare";
  String _supportEmail = "support@mycardshare.com";
  bool _allowSelfRegistration = true;
  bool _requireEmailVerification = true;
  bool _notifyNewEnterprise = true;
  bool _notifyNewLead = false;

  List<SubscriptionPlanModel> _plans = [
    SubscriptionPlanModel(id: '1', name: 'Starter', maxEmployees: 10, maxCards: 20, price: 29),
    SubscriptionPlanModel(id: '2', name: 'Professional', maxEmployees: 50, maxCards: 100, price: 79),
    SubscriptionPlanModel(id: '3', name: 'Enterprise', maxEmployees: 500, maxCards: 1000, price: 199),
  ];

  String get geminiKey => _geminiKey;
  String get huggingFaceKey => _huggingFaceKey;
  String get environment => _environment;
  String get dbStatus => _dbStatus;
  List<PlatformAdminAccount> get superAdmins => _superAdmins;
  bool get isLoading => _isLoading;

  String get platformName => _platformName;
  String get supportEmail => _supportEmail;
  bool get allowSelfRegistration => _allowSelfRegistration;
  bool get requireEmailVerification => _requireEmailVerification;
  bool get notifyNewEnterprise => _notifyNewEnterprise;
  bool get notifyNewLead => _notifyNewLead;
  List<SubscriptionPlanModel> get plans => _plans;

  /// Stream super admin accounts live from Firestore users where role == 'master-admin' or 'super-admin'
  Stream<List<PlatformAdminAccount>> streamSuperAdmins() {
    return _firestore
        .collection('users')
        .where('role', whereIn: ['master-admin', 'super-admin', 'admin'])
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((doc) {
        final data = doc.data();
        final name = data['name'] ?? data['displayName'] ?? 'Master Admin';
        final email = data['email'] ?? '';
        final isPrimary = doc.id == 'admin_primary' || email == 'admin@mycardshare.com';
        return PlatformAdminAccount(
          id: doc.id,
          name: name.toString(),
          email: email.toString(),
          isPrimary: isPrimary,
        );
      }).toList();

      if (list.isEmpty) {
        final current = FirebaseAuth.instance.currentUser;
        _superAdmins = [
          PlatformAdminAccount(
            id: current?.uid ?? 'primary_admin',
            name: current?.displayName ?? 'System Master Admin',
            email: current?.email ?? 'admin@mycardshare.com',
            isPrimary: true,
          ),
        ];
      } else {
        _superAdmins = list;
      }

      notifyListeners();
      return _superAdmins;
    });
  }

  /// Add a new Super Admin account to Firestore
  Future<bool> addSuperAdmin({required String name, required String email}) async {
    try {
      final docRef = _firestore.collection('users').doc();
      await docRef.set({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': 'super-admin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also notify Next.js backend
      await MasterAdminApiClient.post(MasterAdminEndpoints.superAdmins, {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': 'super-admin',
      });

      return true;
    } catch (e) {
      debugPrint('[PlatformSettingsStore] addSuperAdmin error: $e');
      return false;
    }
  }

  /// Remove a Super Admin account
  Future<bool> removeSuperAdmin(String accountId) async {
    try {
      await _firestore.collection('users').doc(accountId).delete();
      return true;
    } catch (e) {
      debugPrint('[PlatformSettingsStore] removeSuperAdmin error: $e');
      return false;
    }
  }

  /// Update AI Key
  Future<void> updateKey({required String keyType, required String newKey}) async {
    try {
      if (keyType == 'gemini') {
        _geminiKey = newKey.length > 8 ? '${newKey.substring(0, 4)}••••••••${newKey.substring(newKey.length - 4)}' : newKey;
      } else if (keyType == 'huggingface') {
        _huggingFaceKey = newKey.length > 8 ? '${newKey.substring(0, 4)}••••••••${newKey.substring(newKey.length - 4)}' : newKey;
      }
      await _firestore.collection('platform_config').doc('ai_keys').set({
        keyType: newKey,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('[PlatformSettingsStore] updateKey error: $e');
    }
  }

  /// Check Database Health Live
  Future<void> checkDatabaseHealth() async {
    try {
      await _firestore.collection('enterprises').limit(1).get();
      _dbStatus = "Healthy";
    } catch (e) {
      _dbStatus = "Degraded";
    }
    notifyListeners();
  }

  /// Load settings from Firestore
  Future<void> loadPlatformSettings() async {
    try {
      final doc = await _firestore.collection('platform_config').doc('general').get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        if (data['platformName'] != null) _platformName = data['platformName'].toString();
        if (data['supportEmail'] != null) _supportEmail = data['supportEmail'].toString();
        if (data['allowSelfRegistration'] != null) _allowSelfRegistration = data['allowSelfRegistration'] == true;
        if (data['requireEmailVerification'] != null) _requireEmailVerification = data['requireEmailVerification'] == true;
        if (data['notifyNewEnterprise'] != null) _notifyNewEnterprise = data['notifyNewEnterprise'] == true;
        if (data['notifyNewLead'] != null) _notifyNewLead = data['notifyNewLead'] == true;
        if (data['plans'] is List) {
          _plans = (data['plans'] as List).map((p) => SubscriptionPlanModel.fromMap(p)).toList();
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[PlatformSettingsStore] loadPlatformSettings error: $e');
    }
  }

  /// Update governance & notification toggles
  Future<void> updateGovernance({
    bool? allowSelfRegistration,
    bool? requireEmailVerification,
    bool? notifyNewEnterprise,
    bool? notifyNewLead,
    String? platformName,
    String? supportEmail,
  }) async {
    if (allowSelfRegistration != null) _allowSelfRegistration = allowSelfRegistration;
    if (requireEmailVerification != null) _requireEmailVerification = requireEmailVerification;
    if (notifyNewEnterprise != null) _notifyNewEnterprise = notifyNewEnterprise;
    if (notifyNewLead != null) _notifyNewLead = notifyNewLead;
    if (platformName != null) _platformName = platformName;
    if (supportEmail != null) _supportEmail = supportEmail;
    notifyListeners();

    try {
      await _firestore.collection('platform_config').doc('general').set({
        'platformName': _platformName,
        'supportEmail': _supportEmail,
        'allowSelfRegistration': _allowSelfRegistration,
        'requireEmailVerification': _requireEmailVerification,
        'notifyNewEnterprise': _notifyNewEnterprise,
        'notifyNewLead': _notifyNewLead,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[PlatformSettingsStore] updateGovernance save error: $e');
    }
  }

  /// Save or update a subscription plan
  Future<void> savePlan(SubscriptionPlanModel plan) async {
    final idx = _plans.indexWhere((p) => p.id == plan.id);
    if (idx != -1) {
      _plans[idx] = plan;
    } else {
      _plans.add(plan);
    }
    notifyListeners();

    try {
      await _firestore.collection('platform_config').doc('general').set({
        'plans': _plans.map((p) => p.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Delete a subscription plan
  Future<void> deletePlan(String planId) async {
    _plans.removeWhere((p) => p.id == planId);
    notifyListeners();

    try {
      await _firestore.collection('platform_config').doc('general').set({
        'plans': _plans.map((p) => p.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
