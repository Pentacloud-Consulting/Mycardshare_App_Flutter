import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lead/active_lead.dart';
import 'individual_metrics_store.dart';

/// Backend service to manage, fetch, and count real leads for a user.
class UserLeadsService extends ChangeNotifier {
  UserLeadsService._internal();
  static final UserLeadsService instance = UserLeadsService._internal();

  List<LeadData> _leads = [];

  List<LeadData> get leads => List.unmodifiable(_leads);

  int get totalLeadsCount => _leads.length;
  int get newLeadsCount => _leads.where((l) => l.status == 'New').length;
  int get thisWeekLeadsCount => _leads.length; // Simplified count

  /// Adds a new lead to local state and updates metrics.
  void addLead(String targetUid, LeadData lead) {
    _leads.insert(0, lead);
    notifyListeners();

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == targetUid || targetUid.isNotEmpty) {
      IndividualMetricsStore.instance.updateLeadsCount(targetUid, totalLeadsCount);
    }
  }

  /// Fetches real leads from Firestore for a given user.
  Future<List<LeadData>> fetchUserLeads(String uid) async {
    if (uid.isEmpty) return _leads;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('leads')
          .orderBy('createdAt', descending: true)
          .get();

      _leads = snapshot.docs
          .map((doc) => LeadData.fromJson(doc.data()))
          .toList();
      notifyListeners();

      IndividualMetricsStore.instance.updateLeadsCount(uid, _leads.length);
    } catch (e) {
      debugPrint('[UserLeadsService] Error fetching leads: $e');
    }

    return _leads;
  }
}


