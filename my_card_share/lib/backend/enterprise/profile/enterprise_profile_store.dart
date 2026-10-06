import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for an Enterprise user profile (stored in Firestore).
class EnterpriseProfileData {
  final String uid;
  final String companyName;
  final String email;
  final String? logoUrl;
  final String? bannerUrl;
  final String industry;
  final String website;
  final String phoneNumber;
  final String address;
  final String shortBio;
  final String plan; // 'free', 'pro', 'enterprise'
  final int employeeCount;
  final String brandColor;
  final String templateId;
  final String cardSlug;
  final DateTime updatedAt;

  EnterpriseProfileData({
    required this.uid,
    required this.companyName,
    required this.email,
    this.logoUrl,
    this.bannerUrl,
    this.industry = '',
    this.website = '',
    this.phoneNumber = '',
    this.address = '',
    this.shortBio = '',
    this.plan = 'free',
    this.employeeCount = 0,
    this.brandColor = '#0052FF',
    this.templateId = 'modern_glass',
    this.cardSlug = '',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  EnterpriseProfileData copyWith({
    String? companyName,
    String? email,
    String? logoUrl,
    String? bannerUrl,
    String? industry,
    String? website,
    String? phoneNumber,
    String? address,
    String? shortBio,
    String? plan,
    int? employeeCount,
    String? brandColor,
    String? templateId,
    String? cardSlug,
    DateTime? updatedAt,
  }) {
    return EnterpriseProfileData(
      uid: uid,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      industry: industry ?? this.industry,
      website: website ?? this.website,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      shortBio: shortBio ?? this.shortBio,
      plan: plan ?? this.plan,
      employeeCount: employeeCount ?? this.employeeCount,
      brandColor: brandColor ?? this.brandColor,
      templateId: templateId ?? this.templateId,
      cardSlug: cardSlug ?? this.cardSlug,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'companyName': companyName,
        'email': email,
        'logoUrl': logoUrl,
        'bannerUrl': bannerUrl,
        'industry': industry,
        'website': website,
        'phoneNumber': phoneNumber,
        'address': address,
        'shortBio': shortBio,
        'plan': plan,
        'employeeCount': employeeCount,
        'brandColor': brandColor,
        'templateId': templateId,
        'cardSlug': cardSlug,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory EnterpriseProfileData.fromFirestore(
      String uid, Map<String, dynamic> data) {
    return EnterpriseProfileData(
      uid: uid,
      companyName: data['companyName'] ?? data['fullName'] ?? 'My Company',
      email: data['email'] ?? '',
      logoUrl: data['logoUrl'] as String?,
      bannerUrl: data['bannerUrl'] as String?,
      industry: data['industry'] ?? '',
      website: data['website'] ?? '',
      phoneNumber: data['phoneNumber'] ?? data['phone'] ?? '',
      address: data['address'] ?? '',
      shortBio: data['shortBio'] ?? data['bio'] ?? '',
      plan: data['plan'] ?? 'free',
      employeeCount: (data['employeeCount'] as num?)?.toInt() ?? 0,
      brandColor: data['brandColor'] ?? '#0052FF',
      templateId: data['templateId'] ?? 'modern_glass',
      cardSlug: data['cardSlug'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Generates a URL-safe card slug from company name.
  static String generateCardSlug(String companyName) {
    final slug = companyName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    final ts = DateTime.now().millisecondsSinceEpoch % 10000;
    return '$slug-$ts';
  }
}

/// Real Firestore-backed profile store for Enterprise users.
/// Mirrors the pattern of IndividualProfileStore.
class EnterpriseProfileStore {
  EnterpriseProfileStore._internal();
  static final EnterpriseProfileStore instance =
      EnterpriseProfileStore._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EnterpriseProfileData? _currentProfile;

  EnterpriseProfileData? get currentProfile => _currentProfile;

  /// Internal setter used by EnterpriseAuthService after sign-up to avoid a round-trip read.
  // ignore: use_setters_to_change_properties
  void setCurrentProfile(EnterpriseProfileData? data) {
    _currentProfile = data;
  }

  bool get hasProfile => _currentProfile != null;


  // ─── Load Profile from Firestore ─────────────────────────────────────────

  /// Loads the enterprise profile from `enterprises/{uid}` in Firestore.
  /// Falls back to `users/{uid}` for basic info if enterprise doc is absent.
  Future<void> loadProfile(
      String uid, String email, String companyName) async {
    try {
      final doc =
          await _firestore.collection('enterprises').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        _currentProfile =
            EnterpriseProfileData.fromFirestore(uid, doc.data()!);
        debugPrint(
            '[EnterpriseProfileStore] Loaded from enterprises/$uid');
        return;
      }

      // Fallback: read from users collection
      final userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        final slug = data['cardSlug'] as String? ??
            EnterpriseProfileData.generateCardSlug(
                data['companyName'] ?? data['fullName'] ?? companyName);

        _currentProfile = EnterpriseProfileData(
          uid: uid,
          companyName:
              data['companyName'] ?? data['fullName'] ?? companyName,
          email: data['email'] ?? email,
          logoUrl: data['avatarUrl'] as String?,
          cardSlug: slug,
          plan: data['plan'] ?? 'free',
        );
        debugPrint(
            '[EnterpriseProfileStore] Loaded from users/$uid (fallback)');
        return;
      }

      // Brand-new user: create minimal in-memory profile
      _currentProfile = EnterpriseProfileData(
        uid: uid,
        companyName: companyName.trim().isNotEmpty
            ? companyName.trim()
            : 'My Company',
        email: email,
        cardSlug: EnterpriseProfileData.generateCardSlug(companyName),
      );
      debugPrint(
          '[EnterpriseProfileStore] Created minimal profile for new enterprise user $uid');
    } catch (e) {
      debugPrint('[EnterpriseProfileStore] loadProfile error: $e');
      _currentProfile = EnterpriseProfileData(
        uid: uid,
        companyName:
            companyName.isNotEmpty ? companyName : 'My Company',
        email: email,
        cardSlug:
            EnterpriseProfileData.generateCardSlug(companyName),
      );
    }
  }

  // ─── Save Profile to Firestore ────────────────────────────────────────────

  /// Persists a full enterprise profile update to `enterprises/{uid}`.
  Future<bool> saveProfile({
    required String uid,
    required String companyName,
    required String email,
    String? logoUrl,
    String? bannerUrl,
    String? industry,
    String? website,
    String? phoneNumber,
    String? address,
    String? shortBio,
    String? plan,
    int? employeeCount,
    String? brandColor,
    String? templateId,
    String? cardSlug,
  }) async {
    try {
      final existing = _currentProfile;
      final resolvedSlug = cardSlug ??
          existing?.cardSlug ??
          EnterpriseProfileData.generateCardSlug(companyName);

      final updated = EnterpriseProfileData(
        uid: uid,
        companyName: companyName.trim().isNotEmpty
            ? companyName.trim()
            : (existing?.companyName ?? 'My Company'),
        email: email.trim().isNotEmpty
            ? email.trim()
            : (existing?.email ?? ''),
        logoUrl: logoUrl ?? existing?.logoUrl,
        bannerUrl: bannerUrl ?? existing?.bannerUrl,
        industry: industry ?? existing?.industry ?? '',
        website: website ?? existing?.website ?? '',
        phoneNumber: phoneNumber ?? existing?.phoneNumber ?? '',
        address: address ?? existing?.address ?? '',
        shortBio: shortBio ?? existing?.shortBio ?? '',
        plan: plan ?? existing?.plan ?? 'free',
        employeeCount: employeeCount ?? existing?.employeeCount ?? 0,
        brandColor: brandColor ?? existing?.brandColor ?? '#0052FF',
        templateId: templateId ?? existing?.templateId ?? 'modern_glass',
        cardSlug: resolvedSlug,
      );

      await _firestore
          .collection('enterprises')
          .doc(uid)
          .set(updated.toFirestore(), SetOptions(merge: true));

      // Mirror basics to users/{uid} so auth gate sees role info
      await _firestore.collection('users').doc(uid).set({
        'companyName': updated.companyName,
        'email': updated.email,
        'logoUrl': updated.logoUrl,
        'plan': updated.plan,
        'cardSlug': updated.cardSlug,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _currentProfile = updated;
      debugPrint(
          '[EnterpriseProfileStore] Saved enterprise profile for $uid');
      return true;
    } catch (e) {
      debugPrint('[EnterpriseProfileStore] saveProfile error: $e');
      return false;
    }
  }

  // ─── Update Individual Fields ─────────────────────────────────────────────

  /// Partial update of specific fields without replacing the full document.
  Future<bool> updateFields(
      String uid, Map<String, dynamic> fields) async {
    try {
      await _firestore.collection('enterprises').doc(uid).update(
          {...fields, 'updatedAt': FieldValue.serverTimestamp()});

      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(
          companyName: fields['companyName'] as String?,
          logoUrl: fields['logoUrl'] as String?,
          bannerUrl: fields['bannerUrl'] as String?,
          brandColor: fields['brandColor'] as String?,
          templateId: fields['templateId'] as String?,
          plan: fields['plan'] as String?,
          employeeCount: (fields['employeeCount'] as num?)?.toInt(),
        );
      }
      debugPrint(
          '[EnterpriseProfileStore] Updated fields for $uid: ${fields.keys}');
      return true;
    } catch (e) {
      debugPrint('[EnterpriseProfileStore] updateFields error: $e');
      return false;
    }
  }

  // ─── Real-time Stream ─────────────────────────────────────────────────────

  /// Returns a real-time Firestore stream of the enterprise profile.
  Stream<EnterpriseProfileData?> profileStream(String uid) {
    return _firestore
        .collection('enterprises')
        .doc(uid)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      final data =
          EnterpriseProfileData.fromFirestore(uid, snap.data()!);
      _currentProfile = data;
      return data;
    });
  }

  // ─── Clear / Sign-Out ─────────────────────────────────────────────────────

  void clearProfile() {
    _currentProfile = null;
    debugPrint('[EnterpriseProfileStore] Profile cleared (sign-out).');
  }
}
