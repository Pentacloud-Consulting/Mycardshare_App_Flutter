import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lead/active_lead.dart';
import 'individual_metrics_store.dart';
import '../profile/individual_profile_store.dart';

/// Backend service to manage, fetch, and count real leads for a user.
class UserLeadsService extends ChangeNotifier {
  UserLeadsService._internal();
  static final UserLeadsService instance = UserLeadsService._internal();

  List<LeadData> _leads = [];

  List<LeadData> get leads => List.unmodifiable(_leads);

  int get totalLeadsCount => _leads.length;
  int get newLeadsCount => _leads.where((l) => l.status.toLowerCase() == 'new').length;
  int get thisWeekLeadsCount => _leads.length;

  /// Adds a new lead to local state and updates metrics.
  void addLead(String targetUid, LeadData lead) {
    // Avoid duplicate lead IDs
    _leads.removeWhere((l) => l.id == lead.id);
    _leads.insert(0, lead);
    notifyListeners();

    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final effectiveUid = targetUid.isNotEmpty ? targetUid : currentUid;
    if (effectiveUid.isNotEmpty) {
      IndividualMetricsStore.instance.updateLeadsCount(effectiveUid, totalLeadsCount);
    }
  }

  /// Fetches real leads from Firestore for a given user.
  Future<List<LeadData>> fetchUserLeads([String? uid]) async {
    final curUser = FirebaseAuth.instance.currentUser;
    final indProfile = IndividualProfileStore.instance.currentProfile;
    final effectiveUid = (uid != null && uid.trim().isNotEmpty)
        ? uid.trim()
        : (curUser?.uid ?? indProfile?.uid ?? '');

    try {
      final List<LeadData> fetched = [];

      // 1. Check user personal leads subcollection
      if (effectiveUid.isNotEmpty) {
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(effectiveUid)
              .collection('leads')
              .orderBy('createdAt', descending: true)
              .get();

          for (final doc in snapshot.docs) {
            fetched.add(LeadData.fromJson(doc.data()));
          }
        } catch (e) {
          debugPrint('[UserLeadsService] users subcollection fetch notice: $e');
        }
      }

      // 2. Also check global leads collection assigned to this user or created by them
      if (effectiveUid.isNotEmpty) {
        try {
          final globalSnap = await FirebaseFirestore.instance
              .collection('leads')
              .where('assignedTo', isEqualTo: effectiveUid)
              .limit(50)
              .get();

          for (final doc in globalSnap.docs) {
            if (!fetched.any((l) => l.id == doc.id)) {
              fetched.add(LeadData.fromJson(doc.data()));
            }
          }
        } catch (_) {}
      }

      // 3. Merge with existing in-memory leads (prevent wiping locally created leads)
      final Map<String, LeadData> mergedMap = {};
      for (final l in fetched) {
        mergedMap[l.id] = l;
      }
      for (final l in _leads) {
        if (!mergedMap.containsKey(l.id)) {
          mergedMap[l.id] = l;
        }
      }

      _leads = mergedMap.values.toList();
      _leads.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();

      if (effectiveUid.isNotEmpty) {
        IndividualMetricsStore.instance.updateLeadsCount(effectiveUid, _leads.length);
      }
    } catch (e) {
      debugPrint('[UserLeadsService] Error fetching leads: $e');
    }

    return _leads;
  }
}



