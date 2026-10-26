import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/master_individual_model.dart';
import '../master_individuals_service.dart';
import '../../Global User Directory/global_auth_sync_service.dart';

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

  /// Stream real individual users from users collection + account_deletion_requests + Next.js backend
  Stream<List<MasterIndividualModel>> streamIndividuals() {
    return _firestore.collection('users').snapshots().asyncMap((snap) async {
      // 1. Map users from Firestore
      final Map<String, MasterIndividualModel> userMap = {};

      for (final doc in snap.docs) {
        final data = doc.data();
        final role = (data['role'] ?? '').toString().toLowerCase();
        final companyId = data['companyId'];

        // Include individual users or users with no corporate company assigned
        if (role == 'individual' || role == 'user' || companyId == null || role.isEmpty) {
          final model = MasterIndividualModel.fromMap(doc.id, data);
          userMap[model.id] = model;
        }
      }

      // 2. Fetch pending deletion requests and merge them
      try {
        final deletionSnap = await _firestore
            .collection('account_deletion_requests')
            .get();

        for (final dDoc in deletionSnap.docs) {
          final dData = dDoc.data();
          final statusStr = (dData['status'] ?? 'pending').toString().toLowerCase().trim();
          if (statusStr == 'confirmed' || statusStr == 'rejected' || statusStr == 'completed') {
            continue;
          }

          final uid = (dData['userId'] ?? dDoc.id).toString();

          if (userMap.containsKey(uid)) {
            final existing = userMap[uid]!;
            userMap[uid] = MasterIndividualModel(
              id: existing.id,
              name: dData['userName'] ?? existing.name,
              email: dData['userEmail'] ?? existing.email,
              phone: existing.phone,
              avatarUrl: existing.avatarUrl,
              plan: 'Deactivated',
              status: 'DELETION_PENDING',
              cardSlug: existing.cardSlug,
              views: existing.views,
              isDeactivated: true,
              deletionReason: dData['reason'],
              deletionRequest: dData,
              createdAt: existing.createdAt,
            );
          } else {
            userMap[uid] = MasterIndividualModel(
              id: uid,
              name: (dData['userName'] ?? 'User').toString(),
              email: (dData['userEmail'] ?? '').toString(),
              plan: 'Deactivated',
              status: 'DELETION_PENDING',
              cardSlug: uid,
              views: 0,
              isDeactivated: true,
              deletionReason: dData['reason'],
              deletionRequest: dData,
            );
          }
        }
      } catch (e) {
        debugPrint('[IndividualsDirectoryStore] Deletion requests merge note: $e');
      }

      // Check users collection for any accounts marked deletion_pending or deactivated
      for (final doc in snap.docs) {
        final data = doc.data();
        final st = (data['status'] ?? '').toString().toLowerCase();
        final isDel = data['deletion_pending'] == true ||
            data['isDeactivated'] == true ||
            st == 'deletion_pending' ||
            st == 'deactivated';
        if (isDel && userMap.containsKey(doc.id)) {
          final existing = userMap[doc.id]!;
          userMap[doc.id] = MasterIndividualModel(
            id: existing.id,
            name: existing.name,
            email: existing.email,
            phone: existing.phone,
            avatarUrl: existing.avatarUrl,
            plan: 'Deactivated',
            status: 'DELETION_PENDING',
            cardSlug: existing.cardSlug,
            views: existing.views,
            isDeactivated: true,
            deletionReason: data['deletionReason'] ?? existing.deletionReason ?? 'User requested account deletion',
            deletionRequest: data['deletionRequest'] ?? existing.deletionRequest ?? {'userId': doc.id, 'status': 'pending'},
            createdAt: existing.createdAt,
          );
        }
      }

      // 3. Sync from live backend /api/sync/master-admin-individuals
      try {
        final backendRes = await MasterIndividualsService.fetchIndividuals(filter: 'all');

        for (final u in backendRes.individuals) {
          final model = MasterIndividualModel.fromIndividualUserModel(u);
          // ⚡ DO NOT overwrite if user is already marked DELETION_PENDING or Deactivated locally
          if (userMap.containsKey(model.id) && userMap[model.id]!.isDeactivated) {
            continue;
          }
          userMap[model.id] = model;
        }

        final realDeactivated = userMap.values.where((u) => u.isDeactivated).length;
        _deactivatedCount = realDeactivated > 0 ? realDeactivated : backendRes.deactivated;
        _activeCount = userMap.values.where((u) => !u.isDeactivated).length;
        _totalCount = userMap.length;
      } catch (backendErr) {
        // Fallback to GlobalAuthSyncService if needed
        try {
          final globalData = await GlobalAuthSyncService.fetchAllGlobalUsers(role: "individual");
          final List<dynamic> globalUsers = globalData["users"] ?? [];
          for (final u in globalUsers) {
            final id = (u['id'] ?? u['_id'] ?? '').toString();
            final email = (u['email'] ?? '').toString().toLowerCase();
            if (id.isNotEmpty && !userMap.containsKey(id)) {
              userMap[id] = MasterIndividualModel(
                id: id,
                name: (u['name'] ?? u['fullName'] ?? 'Web User').toString(),
                email: email,
                plan: (u['plan'] ?? u['tier'] ?? 'Free').toString(),
                cardSlug: (u['slug'] ?? u['cardSlug'] ?? '').toString(),
                views: (u['views'] is num ? (u['views'] as num).toInt() : 0),
                isDeactivated: u['isDeactivated'] == true || u['status'] == 'Suspended',
              );
            }
          }
        } catch (_) {}
      }

      final resultList = userMap.values.toList();
      _users = resultList;
      notifyListeners();
      return resultList;
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
