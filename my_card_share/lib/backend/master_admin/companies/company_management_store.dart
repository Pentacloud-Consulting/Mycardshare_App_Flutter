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
    notifyListeners();

    try {
      // 1. Direct Firestore read from enterprises and companies collections (instant authoritative source)
      final snapEnterprises = await _firestore.collection('enterprises').get();
      final snapCompanies = await _firestore.collection('companies').get();
      final Map<String, MasterCompanyModel> map = {};

      for (final doc in snapEnterprises.docs) {
        map[doc.id] = MasterCompanyModel.fromMap(doc.id, doc.data());
      }
      for (final doc in snapCompanies.docs) {
        if (!map.containsKey(doc.id)) {
          map[doc.id] = MasterCompanyModel.fromMap(doc.id, doc.data());
        }
      }

      if (map.isNotEmpty) {
        final list = map.values.toList();
        _companies = list;
        _totalCount = list.length;
        _activeCount = list.where((c) => c.status.toLowerCase() == 'active').length;
        _suspendedCount = list.where((c) => c.status.toLowerCase() == 'suspended').length;
        notifyListeners();
      }

      // 2. Cross-reference with remote backend
      final res = await MasterAdminGlobalService.fetchGlobalCompanies(
        filter: filter,
        search: search,
      );

      if (res['success'] == true && res['companies'] != null) {
        final List<MasterCompanyModel> list = (res['companies'] as List)
            .cast<MasterCompanyModel>();
        for (final item in list) {
          if (!map.containsKey(item.id)) {
            map[item.id] = item;
          }
        }
        final finalList = map.values.toList();
        _companies = finalList;
        _totalCount = finalList.length;
        _activeCount = finalList.where((c) => c.status.toLowerCase() == 'active').length;
        _suspendedCount = finalList.where((c) => c.status.toLowerCase() == 'suspended').length;
      }
    } catch (e) {
      debugPrint("[CompanyManagementStore] loadGlobalCompanies error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Real-time stream of all registered enterprises with global fallback and deduplication
  Stream<List<MasterCompanyModel>> streamCompanies() {
    return _firestore
        .collection('enterprises')
        .snapshots()
        .asyncMap((snap) async {
      final Map<String, MasterCompanyModel> map = {};

      // 1. Add enterprises from Firestore first (source of truth)
      for (final doc in snap.docs) {
        final model = MasterCompanyModel.fromMap(doc.id, doc.data());
        map[doc.id] = model;
      }

      // 2. Add from `companies` collection
      try {
        final compSnap = await _firestore.collection('companies').get();
        for (final doc in compSnap.docs) {
          final model = MasterCompanyModel.fromMap(doc.id, doc.data());
          final existingKey = map.keys.firstWhere(
            (k) => map[k]!.name.trim().toLowerCase() == model.name.trim().toLowerCase(),
            orElse: () => '',
          );
          if (existingKey.isNotEmpty) {
            if (model.status.toLowerCase() == 'active' && map[existingKey]!.status.toLowerCase() != 'active') {
              map[existingKey] = model;
            }
          } else if (!map.containsKey(doc.id)) {
            map[doc.id] = model;
          }
        }
      } catch (_) {}

      // 3. Fallback for remote/mock companies if not in Firestore
      for (final c in _companies) {
        final alreadyExists = map.values.any((m) =>
            m.id == c.id ||
            m.name.trim().toLowerCase() == c.name.trim().toLowerCase());
        if (!alreadyExists) {
          map[c.id] = c;
        }
      }

      final list = map.values.toList();
      _companies = list;
      _totalCount = list.length;
      _activeCount = list.where((c) => c.status.toLowerCase() == 'active').length;
      _suspendedCount = list.where((c) => c.status.toLowerCase() == 'suspended').length;
      scheduleMicrotask(() => notifyListeners());
      return list;
    });
  }

  /// Immediately update company status in memory for instantaneous UI response
  void updateCompanyStatusLocally(String companyId, String newStatus) {
    bool updated = false;
    for (int i = 0; i < _companies.length; i++) {
      final c = _companies[i];
      if (c.id == companyId || c.name.trim().toLowerCase() == companyId.trim().toLowerCase()) {
        _companies[i] = MasterCompanyModel(
          id: c.id,
          name: c.name,
          email: c.email,
          plan: c.plan,
          employeeCount: c.employeeCount,
          status: newStatus.capitalizeFirst(),
          domain: c.domain,
          logoUrl: c.logoUrl,
          createdAt: c.createdAt,
        );
        updated = true;
      }
    }
    if (updated) {
      _activeCount = _companies.where((c) => c.status.toLowerCase() == 'active').length;
      _suspendedCount = _companies.where((c) => c.status.toLowerCase() == 'suspended').length;
      notifyListeners();
    }
  }

  /// Permanently delete an entire enterprise company and its data across the platform
  Future<bool> deleteCompanyPermanently({
    required String companyId,
    required String companyName,
    String? adminEmail,
  }) async {
    try {
      debugPrint('[CompanyManagementStore] Deleting company permanently: $companyName ($companyId)');

      // 1. Remove from local list immediately
      _companies.removeWhere((c) =>
          c.id == companyId ||
          c.name.trim().toLowerCase() == companyName.trim().toLowerCase());
      _totalCount = _companies.length;
      _activeCount = _companies.where((c) => c.status.toLowerCase() == 'active').length;
      _suspendedCount = _companies.where((c) => c.status.toLowerCase() == 'suspended').length;
      notifyListeners();

      // 2. Delete enterprise document in Firestore
      try {
        await _firestore.collection('enterprises').doc(companyId).delete();
      } catch (e) {
        debugPrint('[CompanyManagementStore] Error deleting enterprises/$companyId: $e');
      }

      try {
        final entByName = await _firestore
            .collection('enterprises')
            .where('companyName', isEqualTo: companyName)
            .get();
        for (final doc in entByName.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}

      // 3. Delete company document in Firestore
      try {
        await _firestore.collection('companies').doc(companyId).delete();
      } catch (e) {
        debugPrint('[CompanyManagementStore] Error deleting companies/$companyId: $e');
      }

      try {
        final compByName = await _firestore
            .collection('companies')
            .where('companyName', isEqualTo: companyName)
            .get();
        for (final doc in compByName.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}

      try {
        final compById = await _firestore
            .collection('companies')
            .where('companyId', isEqualTo: companyId)
            .get();
        for (final doc in compById.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}

      // 4. Clean up / mark users associated with this company
      try {
        final userQueries = [
          _firestore.collection('users').where('companyId', isEqualTo: companyId),
          _firestore.collection('users').where('enterpriseUid', isEqualTo: companyId),
          _firestore.collection('users').where('companyName', isEqualTo: companyName),
          if (adminEmail != null && adminEmail.trim().isNotEmpty)
            _firestore.collection('users').where('email', isEqualTo: adminEmail.trim().toLowerCase()),
        ];

        for (final q in userQueries) {
          final snap = await q.get();
          for (final doc in snap.docs) {
            await doc.reference.set({
              'status': 'Deleted',
              'isDeactivated': true,
              'isSuspended': true,
              'deletedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }
      } catch (e) {
        debugPrint('[CompanyManagementStore] User cleanup note: $e');
      }

      // 5. Clean up pending join requests
      try {
        final reqSnap = await _firestore
            .collection('join_requests')
            .where('enterpriseCompanyName', isEqualTo: companyName)
            .get();
        for (final doc in reqSnap.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}

      // 6. Notify backend API
      try {
        await MasterAdminApiClient.post(
          '/api/sync/master-admin-companies',
          {
            'action': 'delete',
            'companyId': companyId,
            'companyName': companyName,
          },
        );
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('[CompanyManagementStore] deleteCompanyPermanently error: $e');
      return false;
    }
  }

  /// Suspend or Activate a company workspace with full Firestore and memory cascade
  Future<bool> toggleSuspendCompany(String companyId, bool suspend, {String? companyName}) async {
    try {
      final newStatus = suspend ? 'Suspended' : 'Active';
      final approvalStatus = suspend ? 'rejected' : 'approved';

      // 1. Update enterprises
      try {
        await _firestore.collection('enterprises').doc(companyId).set({
          'status': newStatus,
          'approvalStatus': approvalStatus,
          'isSuspended': suspend,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}

      if (companyName != null && companyName.trim().isNotEmpty) {
        try {
          final entByName = await _firestore
              .collection('enterprises')
              .where('companyName', isEqualTo: companyName)
              .get();
          for (final doc in entByName.docs) {
            await doc.reference.set({
              'status': newStatus,
              'approvalStatus': approvalStatus,
              'isSuspended': suspend,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (_) {}
      }

      // 2. Update companies
      try {
        await _firestore.collection('companies').doc(companyId).set({
          'status': newStatus.toLowerCase(),
          'approvalStatus': approvalStatus,
          'isSuspended': suspend,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}

      if (companyName != null && companyName.trim().isNotEmpty) {
        try {
          final compByName = await _firestore
              .collection('companies')
              .where('companyName', isEqualTo: companyName)
              .get();
          for (final doc in compByName.docs) {
            await doc.reference.set({
              'status': newStatus.toLowerCase(),
              'approvalStatus': approvalStatus,
              'isSuspended': suspend,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (_) {}
      }

      // 3. Cascade to associated users
      try {
        final userQueries = [
          _firestore.collection('users').where('companyId', isEqualTo: companyId),
          _firestore.collection('users').where('enterpriseUid', isEqualTo: companyId),
          if (companyName != null && companyName.trim().isNotEmpty)
            _firestore.collection('users').where('companyName', isEqualTo: companyName),
        ];
        for (final q in userQueries) {
          final snap = await q.get();
          for (final doc in snap.docs) {
            await doc.reference.set({
              'isSuspended': suspend,
              'status': newStatus.toLowerCase(),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }
      } catch (_) {}

      // 4. Update memory store immediately
      updateCompanyStatusLocally(companyId, newStatus);
      if (companyName != null && companyName.trim().isNotEmpty) {
        updateCompanyStatusLocally(companyName, newStatus);
      }

      // 5. Also notify Next.js backend
      try {
        await MasterAdminApiClient.post(
          MasterAdminEndpoints.companySuspend(companyId),
          {'suspend': suspend},
        );
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('[CompanyManagementStore] toggleSuspendCompany error: $e');
      return false;
    }
  }
}
