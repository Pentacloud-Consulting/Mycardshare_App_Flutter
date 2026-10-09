import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../enterprise/profile/enterprise_profile_store.dart';
import '../home/employee_home_backend.dart';

/// Enterprise brand metadata for employee cards
class EmployeeEnterpriseBrandData {
  final String enterpriseUid;
  final String? companyName;
  final String? logoUrl;
  final String? lockedBannerUrl;
  final bool isBannerLocked;
  final String? brandColor;
  final bool isBrandColorLocked;

  const EmployeeEnterpriseBrandData({
    required this.enterpriseUid,
    this.companyName,
    this.logoUrl,
    this.lockedBannerUrl,
    this.isBannerLocked = false,
    this.brandColor,
    this.isBrandColorLocked = false,
  });

  factory EmployeeEnterpriseBrandData.fromFirestore(String uid, Map<String, dynamic> data) {
    return EmployeeEnterpriseBrandData(
      enterpriseUid: uid,
      companyName: data['companyName'] as String?,
      logoUrl: data['logoUrl'] as String?,
      lockedBannerUrl: data['lockedBannerUrl'] as String? ?? data['bannerUrl'] as String?,
      isBannerLocked: (data['bannerLocked'] as bool?) ?? (data['lockBanner'] as bool?) ?? false,
      brandColor: data['brandColor'] as String? ?? data['primaryColor'] as String?,
      isBrandColorLocked: (data['brandColorLocked'] as bool?) ?? false,
    );
  }
}

/// Backend service in `lib/backend/employee_join/banner fetch/banner fetch.dart`
/// Fetches and streams enterprise brand banner, company logo, and lock status for employees.
class EmployeeBannerFetchService extends ChangeNotifier {
  EmployeeBannerFetchService._internal();
  static final EmployeeBannerFetchService instance = EmployeeBannerFetchService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  EmployeeEnterpriseBrandData? _currentBrandData;
  bool _isLoading = false;

  EmployeeEnterpriseBrandData? get currentBrandData => _currentBrandData;
  String? get lockedBannerUrl => _currentBrandData?.lockedBannerUrl;
  String? get enterpriseLogoUrl => _currentBrandData?.logoUrl;
  bool get isBannerLocked => _currentBrandData?.isBannerLocked ?? false;
  bool get isBrandColorLocked => _currentBrandData?.isBrandColorLocked ?? false;
  bool get isLoading => _isLoading;

  /// Returns the effective banner URL for an employee.
  /// If enterprise locked the banner, returns enterprise lockedBannerUrl.
  /// Otherwise, returns employee's custom banner photo.
  String? getEffectiveBanner(String? employeeCustomBanner) {
    if (isBannerLocked && lockedBannerUrl != null && lockedBannerUrl!.isNotEmpty) {
      return lockedBannerUrl;
    }
    return employeeCustomBanner;
  }

  /// Fetches enterprise brand details for a given enterprise UID or employee email.
  Future<EmployeeEnterpriseBrandData?> fetchEnterpriseBrand({
    String? enterpriseUid,
    String? employeeEmail,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? entId = enterpriseUid ?? EmployeeHomeBackendService.instance.enterpriseUid;
      final email = employeeEmail ?? _auth.currentUser?.email ?? EmployeeHomeBackendService.instance.email;

      // 1. Fallback to active EnterpriseProfileStore if available
      final entProfile = EnterpriseProfileStore.instance.currentProfile;
      if (entProfile != null && (entId == null || entId == entProfile.uid)) {
        entId = entProfile.uid;
      }

      if (entId == null || entId.isEmpty) {
        // Try searching users collection by email to find enterpriseUid
        if (email.isNotEmpty) {
          final docId = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          final userSnap = await _firestore.collection('users').doc(docId).get();
          if (userSnap.exists && userSnap.data() != null) {
            entId = userSnap.data()?['enterpriseUid'] as String?;
          }
        }
      }

      if (entId == null || entId.isEmpty) {
        entId = 'ent_active';
      }

      // Query enterprise document from Firestore
      final entSnap = await _firestore.collection('enterprises').doc(entId).get();
      if (entSnap.exists && entSnap.data() != null) {
        _currentBrandData = EmployeeEnterpriseBrandData.fromFirestore(entId, entSnap.data()!);
      } else if (entProfile != null) {
        _currentBrandData = EmployeeEnterpriseBrandData(
          enterpriseUid: entProfile.uid,
          companyName: entProfile.companyName,
          logoUrl: entProfile.logoUrl,
          lockedBannerUrl: entProfile.bannerUrl,
          isBannerLocked: true,
        );
      }

      debugPrint('[EmployeeBannerFetchService] Fetched brand data: logo=${_currentBrandData?.logoUrl}, banner=${_currentBrandData?.lockedBannerUrl}, locked=${_currentBrandData?.isBannerLocked}');
      return _currentBrandData;
    } catch (e) {
      debugPrint('[EmployeeBannerFetchService] Error fetching enterprise brand: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Streams real-time enterprise brand updates (logo, banner, lock status) for an employee.
  Stream<EmployeeEnterpriseBrandData?> streamEnterpriseBrand(String enterpriseUid) {
    if (enterpriseUid.isEmpty) return const Stream.empty();
    return _firestore
        .collection('enterprises')
        .doc(enterpriseUid)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      _currentBrandData = EmployeeEnterpriseBrandData.fromFirestore(enterpriseUid, snap.data()!);
      notifyListeners();
      return _currentBrandData;
    });
  }
}
