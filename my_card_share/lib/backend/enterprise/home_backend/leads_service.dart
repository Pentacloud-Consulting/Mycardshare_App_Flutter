import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnterpriseLeadModel {
  final String id;
  final String name;
  final String company;
  final String email;
  final String capturedBy;
  final DateTime date;
  final String status; // 'Synced' or 'Failed'

  EnterpriseLeadModel({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    required this.capturedBy,
    required this.date,
    required this.status,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'LD';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory EnterpriseLeadModel.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime d = DateTime.now();
    if (data['createdAt'] is Timestamp) {
      d = (data['createdAt'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      d = DateTime.tryParse(data['date']) ?? DateTime.now();
    }

    return EnterpriseLeadModel(
      id: id,
      name: data['name'] ?? 'New Lead',
      company: data['company'] ?? 'N/A',
      email: data['email'] ?? '',
      capturedBy: data['capturedBy'] ?? 'Team Member',
      date: d,
      status: data['status'] ?? 'Synced',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'company': company,
        'email': email,
        'capturedBy': capturedBy,
        'createdAt': FieldValue.serverTimestamp(),
        'status': status,
      };
}

class EnterpriseLeadStats {
  final int totalCount;
  final int thisWeekCount;
  final int syncFailedCount;

  const EnterpriseLeadStats({
    required this.totalCount,
    required this.thisWeekCount,
    required this.syncFailedCount,
  });
}

class EnterpriseLeadsService {
  EnterpriseLeadsService._internal();
  static final EnterpriseLeadsService instance = EnterpriseLeadsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Stream real leads for the logged-in enterprise UID.
  Stream<List<EnterpriseLeadModel>> streamLeads([
    String? uid,
    String selectedFilter = 'All',
    String searchQuery = '',
  ]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const []);
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('leads')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      List<EnterpriseLeadModel> list = snapshot.docs
          .map((doc) => EnterpriseLeadModel.fromFirestore(doc.id, doc.data()))
          .toList();

      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        list = list.where((lead) {
          return lead.name.toLowerCase().contains(q) ||
              lead.company.toLowerCase().contains(q) ||
              lead.capturedBy.toLowerCase().contains(q) ||
              lead.email.toLowerCase().contains(q);
        }).toList();
      }

      if (selectedFilter == 'CRM Synced' || selectedFilter == 'Synced') {
        list = list.where((lead) => lead.status == 'Synced').toList();
      } else if (selectedFilter == 'Failed') {
        list = list.where((lead) => lead.status == 'Failed').toList();
      }

      return list;
    });
  }

  /// Stream leads summary stats for the logged-in enterprise.
  Stream<EnterpriseLeadStats> streamLeadStats([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const EnterpriseLeadStats(
        totalCount: 0,
        thisWeekCount: 0,
        syncFailedCount: 0,
      ));
    }

    return streamLeads(targetUid, 'All', '').map((leads) {
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));

      int thisWeek = 0;
      int failed = 0;

      for (final lead in leads) {
        if (lead.date.isAfter(oneWeekAgo)) thisWeek++;
        if (lead.status == 'Failed') failed++;
      }

      return EnterpriseLeadStats(
        totalCount: leads.length,
        thisWeekCount: thisWeek,
        syncFailedCount: failed,
      );
    });
  }

  /// Add new lead
  Future<bool> addLead({
    required String uid,
    required String name,
    required String company,
    String email = '',
    required String capturedBy,
    String status = 'Synced',
  }) async {
    try {
      final leadId = 'lead_${DateTime.now().millisecondsSinceEpoch}';
      final lead = EnterpriseLeadModel(
        id: leadId,
        name: name,
        company: company,
        email: email,
        capturedBy: capturedBy,
        date: DateTime.now(),
        status: status,
      );

      await _firestore
          .collection('enterprises')
          .doc(uid)
          .collection('leads')
          .doc(leadId)
          .set(lead.toFirestore());

      return true;
    } catch (e) {
      debugPrint('[EnterpriseLeadsService] addLead error: $e');
      return false;
    }
  }

  /// Retry sync failed lead
  Future<bool> retrySyncLead(String uid, String leadId) async {
    try {
      await _firestore
          .collection('enterprises')
          .doc(uid)
          .collection('leads')
          .doc(leadId)
          .update({'status': 'Synced', 'syncedAt': FieldValue.serverTimestamp()});
      return true;
    } catch (e) {
      debugPrint('[EnterpriseLeadsService] retrySyncLead error: $e');
      return false;
    }
  }
}


