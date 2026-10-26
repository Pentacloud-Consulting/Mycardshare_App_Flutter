import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/master_individual_model.dart';
import '../master_individuals_service.dart';

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

      _isLoading = false;
      notifyListeners();
      return res;
    } catch (e) {
      debugPrint('[IndividualsDirectoryStore] Backend fetch error: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Stream real individual users from users collection with immediate local mapping
  Stream<List<MasterIndividualModel>> streamIndividuals() {
    return _firestore.collection('users').snapshots().map((snap) {
      final List<MasterIndividualModel> list = [];

      for (final doc in snap.docs) {
        final data = doc.data();
        final role = (data['role'] ?? '').toString().toLowerCase();
        final companyId = data['companyId'];

        // Include individual users or users with no corporate company assigned
        if (role == 'individual' || role == 'user' || companyId == null || role.isEmpty) {
          final model = MasterIndividualModel.fromMap(doc.id, data);
          list.add(model);
        }
      }

      _users = list;
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
}
