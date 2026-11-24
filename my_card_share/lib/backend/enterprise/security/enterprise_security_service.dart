import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../profile/enterprise_profile_store.dart';

/// Data model representing Enterprise Security, SSO & Domain Lock Policies.
class EnterpriseSecurityPolicies {
  final bool ssoEnforced;
  final String ssoProvider; // 'Google Workspace', 'Microsoft Entra ID', 'Okta', 'SAML 2.0'
  final bool domainLockEnabled;
  final String allowedDomain;
  final bool twoFactorRequired;
  final bool brandLockEnabled;
  final bool requireApprovalForJoins;
  final String complianceStatus;
  final String encryptionStatus;
  final DateTime updatedAt;

  EnterpriseSecurityPolicies({
    this.ssoEnforced = true,
    this.ssoProvider = 'Google Workspace',
    this.domainLockEnabled = true,
    this.allowedDomain = '',
    this.twoFactorRequired = false,
    this.brandLockEnabled = true,
    this.requireApprovalForJoins = true,
    this.complianceStatus = 'SOC 2 Type II & ISO 27001 Verified',
    this.encryptionStatus = 'TLS 1.3 / AES-256 Active',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  EnterpriseSecurityPolicies copyWith({
    bool? ssoEnforced,
    String? ssoProvider,
    bool? domainLockEnabled,
    String? allowedDomain,
    bool? twoFactorRequired,
    bool? brandLockEnabled,
    bool? requireApprovalForJoins,
    String? complianceStatus,
    String? encryptionStatus,
    DateTime? updatedAt,
  }) {
    return EnterpriseSecurityPolicies(
      ssoEnforced: ssoEnforced ?? this.ssoEnforced,
      ssoProvider: ssoProvider ?? this.ssoProvider,
      domainLockEnabled: domainLockEnabled ?? this.domainLockEnabled,
      allowedDomain: allowedDomain ?? this.allowedDomain,
      twoFactorRequired: twoFactorRequired ?? this.twoFactorRequired,
      brandLockEnabled: brandLockEnabled ?? this.brandLockEnabled,
      requireApprovalForJoins:
          requireApprovalForJoins ?? this.requireApprovalForJoins,
      complianceStatus: complianceStatus ?? this.complianceStatus,
      encryptionStatus: encryptionStatus ?? this.encryptionStatus,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory EnterpriseSecurityPolicies.fromMap(
      Map<String, dynamic> data, String fallbackDomain) {
    final domain = (data['allowedDomain'] as String?)?.trim();
    return EnterpriseSecurityPolicies(
      ssoEnforced: data['ssoEnforced'] as bool? ?? true,
      ssoProvider: data['ssoProvider'] as String? ?? 'Google Workspace',
      domainLockEnabled: data['domainLockEnabled'] as bool? ?? true,
      allowedDomain:
          (domain != null && domain.isNotEmpty) ? domain : fallbackDomain,
      twoFactorRequired: data['twoFactorRequired'] as bool? ?? false,
      brandLockEnabled: data['brandLockEnabled'] as bool? ?? true,
      requireApprovalForJoins:
          data['requireApprovalForJoins'] as bool? ?? true,
      complianceStatus: data['complianceStatus'] as String? ??
          'SOC 2 Type II & ISO 27001 Verified',
      encryptionStatus:
          data['encryptionStatus'] as String? ?? 'TLS 1.3 / AES-256 Active',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'ssoEnforced': ssoEnforced,
        'ssoProvider': ssoProvider,
        'domainLockEnabled': domainLockEnabled,
        'allowedDomain': allowedDomain,
        'twoFactorRequired': twoFactorRequired,
        'brandLockEnabled': brandLockEnabled,
        'requireApprovalForJoins': requireApprovalForJoins,
        'complianceStatus': complianceStatus,
        'encryptionStatus': encryptionStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

/// Real Firestore-backed Enterprise Security & Access Control Service.
class EnterpriseSecurityService {
  EnterpriseSecurityService._internal();
  static final EnterpriseSecurityService instance =
      EnterpriseSecurityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Helper to extract default corporate domain from current user email.
  String _detectFallbackDomain() {
    final email = _auth.currentUser?.email ??
        EnterpriseProfileStore.instance.currentProfile?.email ??
        '';
    if (email.contains('@')) {
      final parts = email.split('@');
      if (parts.length > 1 && parts[1].isNotEmpty) {
        return parts[1].toLowerCase();
      }
    }
    return 'mycardshare.com';
  }

  /// Real-time stream of Enterprise Security policies for the given uid.
  Stream<EnterpriseSecurityPolicies> streamPolicies([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(
          EnterpriseSecurityPolicies(allowedDomain: _detectFallbackDomain()));
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .snapshots()
        .map((snap) {
      final fallbackDomain = _detectFallbackDomain();
      if (!snap.exists || snap.data() == null) {
        return EnterpriseSecurityPolicies(allowedDomain: fallbackDomain);
      }
      final data = snap.data()!;
      final secMap = data['securityPolicies'] as Map<String, dynamic>? ?? data;
      return EnterpriseSecurityPolicies.fromMap(secMap, fallbackDomain);
    });
  }

  /// Saves a single policy update directly into Firestore for real-time reactivity.
  Future<bool> updatePolicy(String key, dynamic value, [String? uid]) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return false;

    try {
      await _firestore.collection('enterprises').doc(targetUid).set({
        'securityPolicies': {
          key: value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        // Also keep top-level mirror for backward compatibility
        key: value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('[EnterpriseSecurityService] updatePolicy error: $e');
      return false;
    }
  }

  /// Saves all security policies at once.
  Future<bool> saveAllPolicies(EnterpriseSecurityPolicies policies,
      [String? uid]) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return false;

    try {
      final map = policies.toMap();
      await _firestore.collection('enterprises').doc(targetUid).set({
        'securityPolicies': map,
        'ssoEnforced': policies.ssoEnforced,
        'ssoProvider': policies.ssoProvider,
        'domainLockEnabled': policies.domainLockEnabled,
        'allowedDomain': policies.allowedDomain,
        'twoFactorRequired': policies.twoFactorRequired,
        'brandLockEnabled': policies.brandLockEnabled,
        'requireApprovalForJoins': policies.requireApprovalForJoins,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('[EnterpriseSecurityService] saveAllPolicies error: $e');
      return false;
    }
  }
}
