import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/master_company_model.dart';
import '../core/master_admin_api_client.dart';
import '../core/master_admin_endpoints.dart';

/// State store managing real companies directory for Master Admin
class CompanyManagementStore extends ChangeNotifier {
  CompanyManagementStore._internal();
  static final CompanyManagementStore instance = CompanyManagementStore._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MasterCompanyModel> _companies = [];
  final bool _isLoading = false;

  List<MasterCompanyModel> get companies => _companies;
  bool get isLoading => _isLoading;

  int get totalCount => _companies.length;
  int get activeCount => _companies.where((c) => c.status.toLowerCase() == 'active').length;
  int get suspendedCount => _companies.where((c) => c.status.toLowerCase() == 'suspended').length;

  /// Real-time stream of all registered enterprises
  Stream<List<MasterCompanyModel>> streamCompanies() {
    return _firestore
        .collection('enterprises')
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((doc) {
        return MasterCompanyModel.fromMap(doc.id, doc.data());
      }).toList();

      _companies = list;
      notifyListeners();
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
