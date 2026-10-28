import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/master_individual_model.dart';
import '../master_individuals_service.dart';
import '../../individual/multiple_store/individual_multi_store.dart';
import '../../individual/profile/individual_profile_store.dart';

/// State store managing real individual card users directory for Master Admin
/// Seamlessly synchronizes across Firestore and Next.js /api/sync/master-admin-individuals
class IndividualsDirectoryStore extends ChangeNotifier {
  IndividualsDirectoryStore._internal();
  static final IndividualsDirectoryStore instance = IndividualsDirectoryStore._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MasterIndividualModel> _users = [];
  bool _isLoading = false;
  int _totalCount = 0;
  int _activeCount = 0;
  int _deactivatedCount = 0;

  List<MasterIndividualModel> get users => _users;
  bool get isLoading => _isLoading;

  int get totalCount => _totalCount > 0 ? _totalCount : _users.length;
  int get activeCount => _activeCount > 0 ? _activeCount : _users.where((u) => !u.isDeactivated).length;
  int get deactivatedCount => _deactivatedCount > 0 ? _deactivatedCount : _users.where((u) => u.isDeactivated).length;
  int get proCount => _users.where((u) => u.plan.toLowerCase() == 'pro').length;
  int get freeCount => _users.where((u) => u.plan.toLowerCase() == 'free').length;

  /// Fetch live individuals directly from backend /api/sync/master-admin-individuals
  Future<MasterIndividualsResponse?> fetchFromBackend({
    String filter = 'all',
    String search = '',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await MasterIndividualsService.fetchIndividuals(
        filter: filter,
        search: search,
      );

      _totalCount = res.total;
      _activeCount = res.active;
      _deactivatedCount = res.deactivated;

      final backendModels = res.individuals.map((u) {
        return MasterIndividualModel.fromIndividualUserModel(u);
      }).toList();

      if (backendModels.isNotEmpty) {
        _users = backendModels;
      }

      return res;
    } catch (e) {
      debugPrint('[IndividualsDirectoryStore] Backend fetch error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream real individual users from users collection with immediate local mapping
  Stream<List<MasterIndividualModel>> streamIndividuals() {
    return _firestore.collection('users').snapshots().map((snap) {
      final Map<String, MasterIndividualModel> byKey = {};

      for (final doc in snap.docs) {
        final data = doc.data();

        // 1. Resolve role
        final role = (data['role'] ?? data['userRole'] ?? data['accountType'] ?? '').toString().toLowerCase().trim();
        final isMasterAdmin = data['isMasterAdmin'] == true ||
            role == 'master-admin' ||
            role == 'admin' ||
            role == 'superadmin' ||
            role.contains('admin');

        // Only explicitly registered enterprise/company accounts are enterprises!
        // NOTE: An individual user entering their workplace 'companyName' on their card does NOT make them an enterprise!
        final isEnterprise = role == 'enterprise' ||
            role == 'company' ||
            role == 'organization' ||
            data['isEnterprise'] == true ||
            (data['approvalStatus'] != null && role != 'individual');

        // Employees are accounts specifically attached to an enterprise
        final isEmployee = role == 'employee' ||
            (data['enterpriseUid'] != null && data['enterpriseUid'].toString().trim().isNotEmpty && role != 'individual');

        if (isMasterAdmin || isEnterprise || isEmployee) {
          continue; // 🚫 Strict block: Never show Enterprise, Employee, or Master Admin here
        }

        // 2. Exclude permanently deleted accounts (keep deactivated/pending deletion)
        final status = (data['status'] ?? '').toString().toUpperCase();
        if (status == 'DELETED' || data['isDeleted'] == true || data['deleted'] == true) {
          continue;
        }

        // 3. Resolve email or identifier
        String email = (data['email'] ??
                data['userEmail'] ??
                data['emailAddress'] ??
                data['mail'] ??
                '')
            .toString()
            .trim()
            .toLowerCase();

        if (email.isEmpty && doc.id.contains('@')) {
          email = doc.id.trim().toLowerCase();
        }

        final phone = (data['phoneNumber'] ?? data['phone'] ?? data['mobile'] ?? '').toString().trim();
        final resolvedEmail = email.isNotEmpty
            ? email
            : (phone.isNotEmpty ? '$phone@user.phone' : '${doc.id}@mycardshare.internal');

        final model = MasterIndividualModel.fromMap(doc.id, {
          ...data,
          if (email.isEmpty) 'email': resolvedEmail,
        });

        // 4. Deduplicate by email or doc.id
        final key = email.isNotEmpty ? email : doc.id;
        if (!byKey.containsKey(key)) {
          byKey[key] = model;
        } else {
          final existing = byKey[key]!;
          final isExistingSanitized = existing.id == key.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          final isNewDocUid = doc.id != key.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

          if (isExistingSanitized && isNewDocUid) {
            byKey[key] = model;
          } else if (model.avatarUrl != null && existing.avatarUrl == null) {
            byKey[key] = model;
          }
        }
      }



      final list = byKey.values.toList();
      _users = list;
      _totalCount = list.length;
      _activeCount = list.where((u) => !u.isDeactivated && u.status != 'DELETION_PENDING').length;
      _deactivatedCount = list.where((u) => u.isDeactivated || u.status == 'DELETION_PENDING').length;
      return list;
    });
  }

  /// Deactivate or activate user account
  Future<bool> toggleDeactivateUser(String userId, bool deactivate) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'isDeactivated': deactivate,
        'status': deactivate ? 'Suspended' : 'Active',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        final old = _users[idx];
        _users[idx] = MasterIndividualModel(
          id: old.id,
          name: old.name,
          email: old.email,
          phone: old.phone,
          avatarUrl: old.avatarUrl,
          plan: deactivate ? 'Deactivated' : 'Pro',
          status: deactivate ? 'DEACTIVATED' : 'ACTIVE',
          cardSlug: old.cardSlug,
          views: old.views,
          isDeactivated: deactivate,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('[IndividualsDirectoryStore] toggleDeactivateUser error: $e');
      return false;
    }
  }

  /// Remove user permanently from local state
  void removeUserLocally(String idOrEmail) {
    final lower = idOrEmail.toLowerCase().trim();
    _users.removeWhere((u) =>
        u.id == idOrEmail ||
        u.email.toLowerCase() == lower ||
        u.name.toLowerCase() == lower);
    notifyListeners();
  }
}

