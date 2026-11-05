import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../individual/api_service.dart';

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
  final String nationality;
  final String budgetRange;
  final String propertyType;
  final String source;
  final String? campaignId;
  final String? campaignName;

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
    this.nationality = '',
    this.budgetRange = '',
    this.propertyType = '',
    this.source = 'manual',
    this.campaignId,
    this.campaignName,
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
    } else if (data['createdAt'] is String) {
      d = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
    } else if (data['date'] is String) {
      d = DateTime.tryParse(data['date']) ?? DateTime.now();
    } else if (data['capturedAt'] is String) {
      d = DateTime.tryParse(data['capturedAt']) ?? DateTime.now();
    }

    return EnterpriseLeadModel(
      id: id,
      name: data['name'] ?? data['fullName'] ?? 'New Lead',
      company: data['company'] ?? 'N/A',
      email: data['email'] ?? '',
      phone: data['phone'] ?? data['mobile'] ?? '',
      notes: data['notes'] ?? '',
      capturedBy: data['capturedBy'] ?? data['employeeName'] ?? 'Team Member',
      date: d,
      status: data['status'] ?? (data['crmStatus'] == 'failed' ? 'Failed' : 'Synced'),
      nationality: data['nationality'] ?? '',
      budgetRange: data['budgetRange'] ?? '',
      propertyType: data['propertyType'] ?? '',
      source: data['source'] ?? 'manual',
      campaignId: data['campaignId'] as String?,
      campaignName: data['campaignName'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'fullName': name,
        'company': company,
        'email': email,
        'phone': phone,
        'mobile': phone,
        'notes': notes,
        'capturedBy': capturedBy,
        'createdAt': FieldValue.serverTimestamp(),
        'status': status,
        'nationality': nationality,
        'budgetRange': budgetRange,
        'propertyType': propertyType,
        'source': source,
        if (campaignId != null) 'campaignId': campaignId,
        if (campaignName != null) 'campaignName': campaignName,
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

  /// Sync leads from Web MongoDB via /api/sync/enterprise-leads to local Firestore
  Future<void> syncLeadsFromApi([String? uid]) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return;

    try {
      final res = await IndividualApiService.get('/api/sync/enterprise-leads?companyId=$targetUid');
      if (res != null && res['leads'] is List) {
        final leadsList = res['leads'] as List;
        for (final item in leadsList) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            final id = (map['id'] ?? map['leadId'] ?? '').toString();
            if (id.isEmpty) continue;

            final model = EnterpriseLeadModel.fromFirestore(id, map);
            await _firestore
                .collection('enterprises')
                .doc(targetUid)
                .collection('leads')
                .doc(id)
                .set(model.toFirestore(), SetOptions(merge: true));
          }
        }
        debugPrint('[EnterpriseLeadsService] Synced ${leadsList.length} leads from MongoDB API.');
      }
    } catch (e) {
      debugPrint('[EnterpriseLeadsService] syncLeadsFromApi note: $e');
    }
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
    String nationality = '',
    String budgetRange = '',
    String propertyType = '',
    String source = 'manual',
    String? campaignId,
    String? campaignName,
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
        nationality: nationality,
        budgetRange: budgetRange,
        propertyType: propertyType,
        source: source,
        campaignId: campaignId,
        campaignName: campaignName,
      );

      await _firestore
          .collection('enterprises')
          .doc(uid)
          .collection('leads')
          .doc(leadId)
          .set(lead.toFirestore(), SetOptions(merge: true));

      // Dual-Sync to Web Next.js MongoDB backend
      unawaited(IndividualApiService.post('/api/sync/enterprise-leads', {
        'companyId': uid,
        'fullName': name,
        'mobile': phone,
        'email': email,
        'company': company,
        'notes': notes,
        'nationality': nationality,
        'budgetRange': budgetRange,
        'propertyType': propertyType,
        'source': source.isNotEmpty ? source : 'mobile',
        'capturedBy': capturedBy,
        if (campaignId != null) 'campaignId': campaignId,
        if (campaignName != null) 'campaignName': campaignName,
      }).catchError((e) {
        debugPrint('[EnterpriseLeadsService] MongoDB dual-sync notice: $e');
        return null;
      }));

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

      // Also trigger API sync
      unawaited(syncLeadsFromApi(uid));
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
    String? nationality,
    String? budgetRange,
    String? propertyType,
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
      if (nationality != null) updates['nationality'] = nationality.trim();
      if (budgetRange != null) updates['budgetRange'] = budgetRange.trim();
      if (propertyType != null) updates['propertyType'] = propertyType.trim();
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('enterprises')
          .doc(uid)
          .collection('leads')
          .doc(leadId)
          .update(updates);

      // Also PATCH to Web API
      unawaited(IndividualApiService.post('/api/enterprise/leads?id=$leadId', updates).catchError((e) {
        debugPrint('[EnterpriseLeadsService] Update lead API note: $e');
        return null;
      }));

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

      // Dual-delete from MongoDB leads collection
      unawaited(IndividualApiService.delete('/api/enterprise/leads?id=$leadId').catchError((e) {
        debugPrint('[EnterpriseLeadsService] Delete lead API note: $e');
        return null;
      }));

      return true;
    } catch (e) {
      debugPrint('[EnterpriseLeadsService] deleteLead error: $e');
      return false;
    }
  }
}


