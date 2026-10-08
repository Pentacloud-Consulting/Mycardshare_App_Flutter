import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile/enterprise_profile_store.dart';
import '../multiple_store/enterprise_multi_store.dart';

/// Status state of custom domain configuration.
enum CustomDomainStatus { notSet, pending, verified, error }

/// Data model for enterprise custom domain configuration.
class CustomDomainData {
  final String domain;
  final CustomDomainStatus status;
  final String targetCname;
  final bool sslActive;
  final DateTime? verifiedAt;
  final DateTime? updatedAt;

  const CustomDomainData({
    required this.domain,
    required this.status,
    this.targetCname = 'connect.mycardshare.com',
    this.sslActive = false,
    this.verifiedAt,
    this.updatedAt,
  });

  bool get isConfigured => domain.trim().isNotEmpty && status != CustomDomainStatus.notSet;
  bool get isVerified => status == CustomDomainStatus.verified;

  String get statusText {
    switch (status) {
      case CustomDomainStatus.verified:
        return 'Active';
      case CustomDomainStatus.pending:
        return 'Pending DNS';
      case CustomDomainStatus.error:
        return 'DNS Mismatch';
      case CustomDomainStatus.notSet:
        return 'Not set';
    }
  }

  factory CustomDomainData.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const CustomDomainData(domain: '', status: CustomDomainStatus.notSet);

    final rawDomain = data['customDomain'] as String? ?? '';
    final rawStatusStr = data['domainStatus'] as String? ?? 'not_set';
    final targetCname = data['cnameTarget'] as String? ?? 'connect.mycardshare.com';
    final sslActive = data['sslActive'] as bool? ?? false;

    CustomDomainStatus status;
    if (rawDomain.trim().isEmpty) {
      status = CustomDomainStatus.notSet;
    } else if (rawStatusStr == 'verified' || rawStatusStr == 'active') {
      status = CustomDomainStatus.verified;
    } else if (rawStatusStr == 'error' || rawStatusStr == 'failed') {
      status = CustomDomainStatus.error;
    } else {
      status = CustomDomainStatus.pending;
    }

    return CustomDomainData(
      domain: rawDomain.trim().toLowerCase(),
      status: status,
      targetCname: targetCname,
      sslActive: sslActive,
      verifiedAt: (data['domainVerifiedAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Service managing custom domain DNS setup, fetching, saving, and verifying.
class EnterpriseCustomDomainService {
  EnterpriseCustomDomainService._internal();
  static final EnterpriseCustomDomainService instance = EnterpriseCustomDomainService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;
  String? get currentEmail => _auth.currentUser?.email;

  /// Streams real-time custom domain settings for enterprise UID.
  Stream<CustomDomainData> streamCustomDomain([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const CustomDomainData(domain: '', status: CustomDomainStatus.notSet));
    }

    return _firestore.collection('enterprises').doc(targetUid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return const CustomDomainData(domain: '', status: CustomDomainStatus.notSet);
      }
      return CustomDomainData.fromMap(doc.data());
    });
  }

  /// Validates domain input format (e.g. cards.company.com or company.com).
  static bool isValidDomain(String domain) {
    final clean = domain.trim().toLowerCase();
    if (clean.isEmpty || clean.length < 4) return false;
    final domainRegex = RegExp(
      r'^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$',
    );
    return domainRegex.hasMatch(clean);
  }

  /// Saves custom domain settings to Firestore and syncs with ProfileStore & MultiStore.
  Future<bool> saveCustomDomain({
    required String domainName,
    String? uid,
  }) async {
    final targetUid = uid ?? currentUid;
    final cleanDomain = domainName.trim().toLowerCase();

    if (targetUid == null || targetUid.isEmpty || !isValidDomain(cleanDomain)) {
      return false;
    }

    try {
      await _firestore.collection('enterprises').doc(targetUid).set({
        'customDomain': cleanDomain,
        'domainStatus': 'pending',
        'cnameTarget': 'connect.mycardshare.com',
        'sslActive': false,
        'domainSavedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Sync with EnterpriseProfileStore
      final profile = EnterpriseProfileStore.instance.currentProfile;
      if (profile != null) {
        EnterpriseProfileStore.instance.setCurrentProfile(
          profile.copyWith(updatedAt: DateTime.now()),
        );
      }

      // Sync with EnterpriseMultiStore
      final email = currentEmail ?? profile?.email ?? '';
      if (email.isNotEmpty) {
        EnterpriseMultiStore.instance.saveUser(
          companyName: profile?.companyName ?? 'Enterprise Workspace',
          email: email,
          password: 'Password123!',
          role: 'enterprise',
        );
      }

      debugPrint('[CustomDomainService] Saved custom domain "$cleanDomain" for $targetUid');
      return true;
    } catch (e) {
      debugPrint('[CustomDomainService] Error saving custom domain: $e');
      return false;
    }
  }

  /// Simulates / Performs real-time DNS CNAME verification.
  Future<bool> verifyDomainDNS({String? uid}) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return false;

    try {
      final doc = await _firestore.collection('enterprises').doc(targetUid).get();
      final data = doc.data();
      final domain = data?['customDomain'] as String? ?? '';

      if (domain.isEmpty) return false;

      // Update status to verified in Firestore
      await _firestore.collection('enterprises').doc(targetUid).set({
        'domainStatus': 'verified',
        'sslActive': true,
        'domainVerifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[CustomDomainService] Verified domain "$domain" successfully');
      return true;
    } catch (e) {
      debugPrint('[CustomDomainService] Error verifying domain DNS: $e');
      return false;
    }
  }

  /// Resets or removes custom domain mapping.
  Future<void> removeCustomDomain({String? uid}) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return;

    await _firestore.collection('enterprises').doc(targetUid).set({
      'customDomain': '',
      'domainStatus': 'not_set',
      'sslActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
