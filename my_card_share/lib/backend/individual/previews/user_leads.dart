import 'dart:async';
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
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _leadsSub;
  String _listeningUid = '';

  List<LeadData> get leads => List.unmodifiable(_leads);

  int get totalLeadsCount => _leads.length;
  int get newLeadsCount => _leads.where((l) => l.status.toLowerCase() == 'new').length;
  int get thisWeekLeadsCount => _leads.length;

  /// Adds a new lead to local state and updates metrics.
  void addLead(String targetUid, LeadData lead) {
    // Avoid duplicate lead IDs
    _leads.removeWhere((l) => l.id == lead.id);
    _leads.insert(0, lead);
    _leads.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();

    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final effectiveUid = targetUid.isNotEmpty ? targetUid : currentUid;
    if (effectiveUid.isNotEmpty) {
      IndividualMetricsStore.instance.updateLeadsCount(effectiveUid, totalLeadsCount);
    }
  }

  /// Updates an existing lead in local state, Firestore, and metrics.
  Future<void> updateLead(String targetUid, LeadData updatedLead) async {
    final idx = _leads.indexWhere((l) => l.id == updatedLead.id);
    if (idx != -1) {
      _leads[idx] = updatedLead;
    } else {
      _leads.insert(0, updatedLead);
    }
    _leads.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();

    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final effectiveUid = targetUid.isNotEmpty ? targetUid : currentUid;

    if (effectiveUid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(effectiveUid)
            .collection('leads')
            .doc(updatedLead.id)
            .set(updatedLead.toJson(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('[UserLeadsService] Firestore user lead update notice: $e');
      }

      try {
        await FirebaseFirestore.instance
            .collection('leads')
            .doc(updatedLead.id)
            .set(updatedLead.toJson(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('[UserLeadsService] Global lead update notice: $e');
      }
    }
  }

  /// Deletes a lead from local state and Firestore.
  Future<void> deleteLead(String targetUid, String leadId) async {
    _leads.removeWhere((l) => l.id == leadId);
    notifyListeners();

    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final effectiveUid = targetUid.isNotEmpty ? targetUid : currentUid;

    if (effectiveUid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(effectiveUid)
            .collection('leads')
            .doc(leadId)
            .delete();
      } catch (_) {}

      try {
        await FirebaseFirestore.instance.collection('leads').doc(leadId).delete();
      } catch (_) {}

      IndividualMetricsStore.instance.updateLeadsCount(effectiveUid, totalLeadsCount);
    }
  }

  /// Starts real-time listening to Firestore changes for live lead synchronization.
  void listenToUserLeads([String? uid]) {
    final curUser = FirebaseAuth.instance.currentUser;
    final indProfile = IndividualProfileStore.instance.currentProfile;
    final effectiveUid = (uid != null && uid.trim().isNotEmpty)
        ? uid.trim()
        : (curUser?.uid ?? indProfile?.uid ?? '');

    if (effectiveUid.isEmpty || _listeningUid == effectiveUid) return;
    _listeningUid = effectiveUid;
    _leadsSub?.cancel();

    _leadsSub = FirebaseFirestore.instance
        .collection('users')
        .doc(effectiveUid)
        .collection('leads')
        .snapshots()
        .listen((snapshot) {
      final List<LeadData> liveList = [];
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        if (data['id'] == null || (data['id'] as String).isEmpty) {
          data['id'] = doc.id;
        }
        try {
          liveList.add(LeadData.fromJson(data));
        } catch (e) {
          debugPrint('[UserLeadsService] Error parsing live lead ${doc.id}: $e');
        }
      }

      final Map<String, LeadData> map = {};
      for (final l in liveList) {
        map[l.id] = l;
      }
      for (final l in _leads) {
        if (!map.containsKey(l.id)) {
          map[l.id] = l;
        }
      }

      _leads = map.values.toList();
      _leads.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();

      IndividualMetricsStore.instance.updateLeadsCount(effectiveUid, _leads.length);
    }, onError: (err) {
      debugPrint('[UserLeadsService] Real-time leads listener error: $err');
    });
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
          QuerySnapshot<Map<String, dynamic>> snapshot;
          try {
            snapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(effectiveUid)
                .collection('leads')
                .orderBy('createdAt', descending: true)
                .get();
          } catch (_) {
            snapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(effectiveUid)
                .collection('leads')
                .get();
          }

          for (final doc in snapshot.docs) {
            final data = Map<String, dynamic>.from(doc.data());
            if (data['id'] == null || (data['id'] as String).isEmpty) {
              data['id'] = doc.id;
            }
            try {
              fetched.add(LeadData.fromJson(data));
            } catch (err) {
              debugPrint('[UserLeadsService] Error parsing doc lead ${doc.id}: $err');
            }
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
              final data = Map<String, dynamic>.from(doc.data());
              if (data['id'] == null || (data['id'] as String).isEmpty) {
                data['id'] = doc.id;
              }
              try {
                fetched.add(LeadData.fromJson(data));
              } catch (_) {}
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



