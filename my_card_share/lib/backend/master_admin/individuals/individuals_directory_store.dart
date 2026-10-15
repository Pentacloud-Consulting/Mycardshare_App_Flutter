import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/master_individual_model.dart';
import '../../Global User Directory/global_auth_sync_service.dart';

/// State store managing real individual card users directory for Master Admin
/// Seamlessly synchronizes across Firestore and Next.js /api/sync/global-directory
class IndividualsDirectoryStore extends ChangeNotifier {
  IndividualsDirectoryStore._internal();
  static final IndividualsDirectoryStore instance = IndividualsDirectoryStore._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MasterIndividualModel> _users = [];
  final bool _isLoading = false;

  List<MasterIndividualModel> get users => _users;
  bool get isLoading => _isLoading;

  int get totalCount => _users.length;
  int get proCount => _users.where((u) => u.plan.toLowerCase() == 'pro').length;
  int get freeCount => _users.where((u) => u.plan.toLowerCase() == 'free').length;
  int get deactivatedCount => _users.where((u) => u.isDeactivated).length;

  /// Stream real individual users from users collection + Next.js global directory sync
  Stream<List<MasterIndividualModel>> streamIndividuals() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'individual')
        .snapshots()
        .asyncMap((snap) async {
      final firestoreList = snap.docs.map((doc) {
        return MasterIndividualModel.fromMap(doc.id, doc.data());
      }).toList();

      // Fetch global directory from Next.js (which includes MongoDB Web users)
      try {
        final globalData = await GlobalAuthSyncService.fetchAllGlobalUsers(role: "individual");
        final List<dynamic> globalUsers = globalData["users"] ?? [];

        if (globalUsers.isNotEmpty) {
          final existingIds = firestoreList.map((u) => u.id).toSet();
          final existingEmails = firestoreList.map((u) => u.email.toLowerCase()).toSet();

          for (final u in globalUsers) {
            final id = (u['id'] ?? u['_id'] ?? '').toString();
            final email = (u['email'] ?? '').toString().toLowerCase();

            if (!existingIds.contains(id) && !existingEmails.contains(email) && email.isNotEmpty) {
              firestoreList.add(
                MasterIndividualModel(
                  id: id,
                  name: (u['name'] ?? u['fullName'] ?? 'Web User').toString(),
                  email: email,
                  plan: (u['plan'] ?? u['tier'] ?? 'Free').toString(),
                  cardSlug: (u['slug'] ?? u['cardSlug'] ?? '').toString(),
                  views: (u['views'] is num ? (u['views'] as num).toInt() : 0),
                  isDeactivated: u['isDeactivated'] == true || u['status'] == 'Suspended',
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('[IndividualsDirectoryStore] Global directory sync note: $e');
      }

      _users = firestoreList;
      notifyListeners();
      return firestoreList;
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
          plan: deactivate ? 'Deactivated' : 'Pro',
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
