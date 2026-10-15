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

  String get geminiKey => _geminiKey;
  String get huggingFaceKey => _huggingFaceKey;
  String get environment => _environment;
  String get dbStatus => _dbStatus;
  List<PlatformAdminAccount> get superAdmins => _superAdmins;
  bool get isLoading => _isLoading;

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
}
