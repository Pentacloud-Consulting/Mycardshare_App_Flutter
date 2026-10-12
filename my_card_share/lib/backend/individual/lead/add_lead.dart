import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api_service.dart';
import 'active_lead.dart';
import '../previews/user_leads.dart';
import '../previews/individual_metrics_store.dart';
import '../notification/lead_requirest.dart';

/// Accurate Backend Service for Adding Leads for Individual Users and Multiple Users.
/// Handles Firestore persistence, cross-user assignment, metrics increments, and notification dispatch.
class AddLeadService {
  AddLeadService._internal();
  static final AddLeadService instance = AddLeadService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns current authenticated user's UID or empty string
  String get currentUid => _auth.currentUser?.uid ?? '';

  /// Adds a single lead to a specific individual user (targetUid).
  /// Updates Firestore user lead collection, global leads audit collection, metrics, and triggers notifications.
  Future<LeadData?> addLead({
    required String targetUid,
    required String name,
    required String email,
    required String phone,
    required String company,
    String notes = '',
    String status = 'New',
    String source = 'via Manual',
  }) async {
    final effectiveUid = targetUid.trim().isNotEmpty ? targetUid.trim() : currentUid;
    if (effectiveUid.isEmpty) {
      debugPrint('[AddLeadService] Error: targetUid is empty and no user logged in.');
      return null;
    }

    final leadId = 'lead_${DateTime.now().millisecondsSinceEpoch}';
    final lead = LeadData(
      id: leadId,
      targetUid: effectiveUid,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      company: company.trim().isNotEmpty ? company.trim() : 'Independent',
      notes: notes.trim(),
      status: status.trim().isNotEmpty ? status.trim() : 'New',
      source: source.trim().isNotEmpty ? source.trim() : 'via Manual',
      createdAt: DateTime.now(),
    );

    try {
      // 1. Save in target user's personal leads subcollection
      await _firestore
          .collection('users')
          .doc(effectiveUid)
          .collection('leads')
          .doc(leadId)
          .set(lead.toJson());
      debugPrint('[AddLeadService] Saved lead $leadId under users/$effectiveUid/leads');

      // 2. Also save to global leads collection for Master Admin audit logs & tracking
      await _firestore.collection('leads').doc(leadId).set({
        ...lead.toJson(),
        'assignedTo': effectiveUid,
        'assignedUsers': [effectiveUid],
        'createdByType': 'manual',
        'createdByUid': currentUid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[AddLeadService] Firestore save error/notice: $e');
    }

    // 3. Post to backend API /api/leads/create in background if available
    try {
      final Uri url = Uri.parse('${IndividualApiService.baseUrl}/api/leads/create');
      http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cardId': effectiveUid,
          'fullName': lead.name,
          'email': lead.email,
          'mobile': lead.phone,
          'company': lead.company,
          'notes': lead.notes,
          'status': lead.status,
          'capturedVia': lead.source,
        }),
      ).catchError((_) => http.Response('', 500));
    } catch (apiErr) {
      debugPrint('[AddLeadService] API sync notice: $apiErr');
    }

    // 4. Update local UserLeadsService if this matches the currently active user
    if (effectiveUid == currentUid || currentUid.isEmpty) {
      UserLeadsService.instance.addLead(effectiveUid, lead);
    }

    // 5. Increment Real Leads Metric on Home Dashboard & Store
    try {
      await IndividualMetricsStore.instance.incrementLeads(effectiveUid);
    } catch (metricErr) {
      debugPrint('[AddLeadService] Metrics increment error: $metricErr');
    }

    // 6. Send in-app notification to the card owner / assigned user
    try {
      await LeadRequestNotification.instance.sendLeadNotification(effectiveUid, lead);
    } catch (notifErr) {
      debugPrint('[AddLeadService] Notification notice: $notifErr');
    }

    return lead;
  }

  /// Adds and assigns the same lead to multiple users simultaneously.
  /// Perfect for Master Admin or team-wide lead distribution.
  Future<List<LeadData>> addLeadForMultipleUsers({
    required List<String> targetUids,
    required String name,
    required String email,
    required String phone,
    required String company,
    String notes = '',
    String status = 'New',
    String source = 'via Manual',
  }) async {
    final cleanUids = targetUids.where((u) => u.trim().isNotEmpty).toList();
    if (cleanUids.isEmpty) {
      if (currentUid.isNotEmpty) {
        cleanUids.add(currentUid);
      } else {
        debugPrint('[AddLeadService] Error: targetUids list is empty.');
        return [];
      }
    }

    final List<LeadData> createdLeads = [];
    final masterLeadId = 'lead_multi_${DateTime.now().millisecondsSinceEpoch}';

    for (int i = 0; i < cleanUids.length; i++) {
      final uid = cleanUids[i].trim();
      final leadId = '${masterLeadId}_$i';

      final lead = LeadData(
        id: leadId,
        targetUid: uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        company: company.trim().isNotEmpty ? company.trim() : 'Independent',
        notes: notes.trim(),
        status: status.trim().isNotEmpty ? status.trim() : 'New',
        source: source.trim().isNotEmpty ? source.trim() : 'via Manual',
        createdAt: DateTime.now(),
      );

      try {
        // Save to individual user subcollection
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('leads')
            .doc(leadId)
            .set(lead.toJson());

        // Update local state if matches logged in user
        if (uid == currentUid) {
          UserLeadsService.instance.addLead(uid, lead);
        }

        // Increment user metric count
        await IndividualMetricsStore.instance.incrementLeads(uid);

        // Send notification
        await LeadRequestNotification.instance.sendLeadNotification(uid, lead);

        createdLeads.add(lead);
      } catch (e) {
        debugPrint('[AddLeadService] Failed to assign lead to user $uid: $e');
      }
    }

    // Save consolidated Master record in global leads collection
    try {
      await _firestore.collection('leads').doc(masterLeadId).set({
        'id': masterLeadId,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'company': company.trim().isNotEmpty ? company.trim() : 'Independent',
        'notes': notes.trim(),
        'status': status.trim().isNotEmpty ? status.trim() : 'New',
        'source': source.trim().isNotEmpty ? source.trim() : 'via Manual',
        'assignedUsers': cleanUids,
        'totalAssigned': cleanUids.length,
        'createdByType': 'multi_user_assignment',
        'createdByUid': currentUid,
        'createdAt': DateTime.now().toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('[AddLeadService] Master multi-lead record saved: $masterLeadId');
    } catch (e) {
      debugPrint('[AddLeadService] Global master lead save notice: $e');
    }

    return createdLeads;
  }

  /// Fetches a list of assignable users from Firestore.
  /// Used by Master Admin or multi-user assignment pickers.
  Future<List<Map<String, dynamic>>> fetchAssignableUsers() async {
    final List<Map<String, dynamic>> usersList = [];

    try {
      final snapshot = await _firestore.collection('users').limit(50).get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final name = (data['fullName'] ?? data['name'] ?? data['displayName'] ?? '').toString().trim();
        final email = (data['email'] ?? '').toString().trim();
        final role = (data['jobTitle'] ?? data['role'] ?? 'Member').toString().trim();
        final company = (data['companyName'] ?? data['company'] ?? '').toString().trim();
        final avatar = (data['profilePhoto'] ?? data['avatarUrl'] ?? '').toString().trim();

        usersList.add({
          'uid': doc.id,
          'name': name.isNotEmpty ? name : 'User (${doc.id.substring(0, 6.clamp(0, doc.id.length))})',
          'email': email,
          'role': role,
          'company': company,
          'avatar': avatar,
        });
      }
    } catch (e) {
      debugPrint('[AddLeadService] Error fetching assignable users: $e');
    }

    // If empty or offline, fallback to current user
    if (usersList.isEmpty && currentUid.isNotEmpty) {
      final cur = _auth.currentUser;
      usersList.add({
        'uid': currentUid,
        'name': cur?.displayName ?? 'My Account',
        'email': cur?.email ?? '',
        'role': 'Owner',
        'company': 'Self',
        'avatar': cur?.photoURL ?? '',
      });
    }

    return usersList;
  }

  /// Updates lead status in Firestore (e.g. 'New' -> 'Contacted' -> 'Qualified' -> 'Lost')
  Future<void> updateLeadStatus({
    required String targetUid,
    required String leadId,
    required String newStatus,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(targetUid)
          .collection('leads')
          .doc(leadId)
          .update({'status': newStatus});

      await _firestore
          .collection('leads')
          .doc(leadId)
          .update({'status': newStatus})
          .catchError((_) {});

      debugPrint('[AddLeadService] Updated lead $leadId status to $newStatus');
    } catch (e) {
      debugPrint('[AddLeadService] Error updating lead status: $e');
    }
  }
}
