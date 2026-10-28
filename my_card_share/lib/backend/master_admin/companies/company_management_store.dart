import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/master_company_model.dart';
import '../core/master_admin_api_client.dart';
import '../core/master_admin_endpoints.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/master_company_model.dart';
import '../core/master_admin_api_client.dart';
import '../core/master_admin_endpoints.dart';
import '../master_admin_global_service.dart';

/// State store managing real companies directory for Master Admin across the entire platform
class CompanyManagementStore extends ChangeNotifier {
  CompanyManagementStore._internal();
  static final CompanyManagementStore instance = CompanyManagementStore._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MasterCompanyModel> _companies = [];
  bool _isLoading = false;
  int _totalCount = 0;
  int _activeCount = 0;
  int _suspendedCount = 0;

  List<MasterCompanyModel> get companies => _companies;
  bool get isLoading => _isLoading;

  int get totalCount => _totalCount > 0 ? _totalCount : _companies.length;
  int get activeCount => _activeCount > 0 ? _activeCount : _companies.where((c) => c.status.toLowerCase() == 'active').length;
  int get suspendedCount => _suspendedCount > 0 ? _suspendedCount : _companies.where((c) => c.status.toLowerCase() == 'suspended').length;

  /// Fetch all companies globally via unified Master Admin API and Firestore
  Future<void> loadGlobalCompanies({
    String filter = "all",
    String search = "",
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final res = await MasterAdminGlobalService.fetchGlobalCompanies(
        filter: filter,
        search: search,
      );

      if (res['success'] == true) {
        _totalCount = res['total'] ?? 0;
        _activeCount = res['active'] ?? 0;
        _suspendedCount = res['suspended'] ?? 0;
        final List<MasterCompanyModel> list = (res['companies'] as List)
            .cast<MasterCompanyModel>();
        _companies = list;
      }
    } catch (e) {
      debugPrint("[CompanyManagementStore] loadGlobalCompanies error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Real-time stream of all registered enterprises with global fallback
  Stream<List<MasterCompanyModel>> streamCompanies() {
    return _firestore
        .collection('enterprises')
        .snapshots()
        .asyncMap((snap) async {
      final Map<String, MasterCompanyModel> map = {};

      // 1. Add existing companies (e.g. from global API or in-memory)
      for (final c in _companies) {
        map[c.id] = c;
      }

      // 2. Add enterprises from Firestore
      for (final doc in snap.docs) {
        final model = MasterCompanyModel.fromMap(doc.id, doc.data());
        map[doc.id] = model;
      }

      // 3. Also check `companies` collection
      try {
        final compSnap = await _firestore.collection('companies').get();
        for (final doc in compSnap.docs) {
          if (!map.containsKey(doc.id)) {
            map[doc.id] = MasterCompanyModel.fromMap(doc.id, doc.data());
          }
        }
      } catch (_) {}

      final list = map.values.toList();
      _companies = list;
      _totalCount = list.length;
      _activeCount = list.where((c) => c.status.toLowerCase() == 'active').length;
      _suspendedCount = list.where((c) => c.status.toLowerCase() == 'suspended').length;
      return list;
    });
  }

  /// Suspend or Activate a company workspace
  Future<bool> toggleSuspendCompany(String companyId, bool suspend) async {
    try {
      final newStatus = suspend ? 'Suspended' : 'Active';
      await _firestore.collection('enterprises').doc(companyId).set({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore.collection('companies').doc(companyId).set({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Also notify Next.js backend
      await MasterAdminApiClient.post(
        MasterAdminEndpoints.companySuspend(companyId),
        {'suspend': suspend},
      );

      final idx = _companies.indexWhere((c) => c.id == companyId);
      if (idx != -1) {
        final old = _companies[idx];
        _companies[idx] = MasterCompanyModel(
          id: old.id,
          name: old.name,
          email: old.email,
          plan: old.plan,
          employeeCount: old.employeeCount,
          status: newStatus,
          domain: old.domain,
          logoUrl: old.logoUrl,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('[CompanyManagementStore] toggleSuspendCompany error: $e');
      return false;
    }
  }
}
