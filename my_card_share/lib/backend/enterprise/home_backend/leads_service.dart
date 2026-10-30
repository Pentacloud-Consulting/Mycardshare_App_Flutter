import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnterpriseLeadModel {
  final String id;
  final String name;
  final String company;
  final String email;
  final String phone;
  final String notes;
  final String capturedBy;
  final DateTime date;
  final String status; // 'Synced' or 'Failed'

  EnterpriseLeadModel({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    this.phone = '',
    this.notes = '',
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
      phone: data['phone'] ?? data['mobile'] ?? '',
      notes: data['notes'] ?? '',
      capturedBy: data['capturedBy'] ?? 'Team Member',
      date: d,
      status: data['status'] ?? 'Synced',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'company': company,
        'email': email,
        'phone': phone,
        'mobile': phone,
        'notes': notes,
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
    DateTimeRange? dateRange,
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

      if (dateRange != null) {
        final start = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
        final end = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day, 23, 59, 59, 999);
        list = list.where((lead) {
          return !lead.date.isBefore(start) && !lead.date.isAfter(end);
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
  Stream<EnterpriseLeadStats> streamLeadStats([String? uid, DateTimeRange? dateRange]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const EnterpriseLeadStats(
        totalCount: 0,
        thisWeekCount: 0,
        syncFailedCount: 0,
      ));
    }

    return streamLeads(targetUid, 'All', '', dateRange).map((leads) {
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
    String phone = '',
    String email = '',
    String notes = '',
    required String capturedBy,
    String status = 'Synced',
  }) async {
    try {
      String leadId = 'lead_${DateTime.now().millisecondsSinceEpoch}';
      final cleanEmail = email.trim().toLowerCase();
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

      // ── Deduplication: reuse existing doc ID if email or phone already exists ──
      try {
        if (cleanEmail.isNotEmpty) {
          final existing = await _firestore
              .collection('enterprises')
              .doc(uid)
              .collection('leads')
              .where('email', isEqualTo: cleanEmail)
              .limit(1)
              .get();
          if (existing.docs.isNotEmpty) {
            leadId = existing.docs.first.id;
            debugPrint('[EnterpriseLeadsService] Found existing lead by email. Updating $leadId.');
          }
        }
        if (leadId.startsWith('lead_') && cleanPhone.isNotEmpty && cleanPhone.length >= 7) {
          final existingPhone = await _firestore
              .collection('enterprises')
              .doc(uid)
              .collection('leads')
              .where('phone', isEqualTo: phone.trim())
              .limit(1)
              .get();
          if (existingPhone.docs.isNotEmpty) {
            leadId = existingPhone.docs.first.id;
            debugPrint('[EnterpriseLeadsService] Found existing lead by phone. Updating $leadId.');
          }
        }
      } catch (_) {}
      // ──────────────────────────────────────────────────────────────────────────

      final lead = EnterpriseLeadModel(
        id: leadId,
        name: name,
        company: company,
        phone: phone,
        email: email,
        notes: notes,
        capturedBy: capturedBy,
        date: DateTime.now(),
        status: status,
      );

      await _firestore
          .collection('enterprises')
          .doc(uid)
          .collection('leads')
          .doc(leadId)
          .set(lead.toFirestore(), SetOptions(merge: true));

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

  /// Update enterprise lead status or details
  Future<bool> updateLead({
    required String uid,
    required String leadId,
    String? name,
    String? company,
    String? phone,
    String? email,
    String? notes,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name.trim();
      if (company != null) updates['company'] = company.trim();
      if (phone != null) {
        updates['phone'] = phone.trim();
        updates['mobile'] = phone.trim();
      }
      if (email != null) updates['email'] = email.trim();
      if (notes != null) updates['notes'] = notes.trim();
      if (status != null) updates['status'] = status.trim();
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('enterprises')
          .doc(uid)
          .collection('leads')
          .doc(leadId)
          .update(updates);
      return true;
    } catch (e) {
      debugPrint('[EnterpriseLeadsService] updateLead error: $e');
      return false;
    }
  }

  /// Delete enterprise lead
  Future<bool> deleteLead(String uid, String leadId) async {
    try {
      await _firestore
          .collection('enterprises')
          .doc(uid)
          .collection('leads')
          .doc(leadId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('[EnterpriseLeadsService] deleteLead error: $e');
      return false;
    }
  }
}


