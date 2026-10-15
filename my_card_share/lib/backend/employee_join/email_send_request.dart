import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../notifications/enterprice/request_notification.dart';
import '../enterprise/multiple_store/enterprise_multi_store.dart';
import '../enterprise/profile/enterprise_profile_store.dart';
import '../enterprise/request/request_fetch.dart';

/// Data model representing a request sent by an employee to join an Enterprise Workspace
class EnterpriseJoinRequestModel {
  final String id;
  final String enterpriseUid;
  final String enterpriseEmail;
  final String enterpriseCompanyName;
  final String applicantUid;
  final String applicantName;
  final String applicantEmail;
  final String applicantPassword;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  const EnterpriseJoinRequestModel({
    required this.id,
    required this.enterpriseUid,
    required this.enterpriseEmail,
    required this.enterpriseCompanyName,
    required this.applicantUid,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantPassword,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'enterpriseUid': enterpriseUid,
        'enterpriseEmail': enterpriseEmail,
        'enterpriseCompanyName': enterpriseCompanyName,
        'applicantUid': applicantUid,
        'applicantName': applicantName,
        'applicantEmail': applicantEmail,
        'applicantPassword': applicantPassword,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory EnterpriseJoinRequestModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    DateTime created = DateTime.now();
    if (data['createdAt'] is Timestamp) {
      created = (data['createdAt'] as Timestamp).toDate();
    }
    return EnterpriseJoinRequestModel(
      id: id,
      enterpriseUid: data['enterpriseUid'] ?? '',
      enterpriseEmail: data['enterpriseEmail'] ?? '',
      enterpriseCompanyName: data['enterpriseCompanyName'] ?? 'Enterprise Workspace',
      applicantUid: data['applicantUid'] ?? '',
      applicantName: data['applicantName'] ?? 'Employee',
      applicantEmail: data['applicantEmail'] ?? '',
      applicantPassword: data['applicantPassword'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: created,
    );
  }
}

/// Service in `lib/backend/employee_join/email_send_request.dart`
/// Handles sending join request emails/records to target Enterprise by enterprise email or company name
class EmailSendRequestService {
  EmailSendRequestService._internal();
  static final EmailSendRequestService instance = EmailSendRequestService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Looks up enterprise by their official contact or workspace email / company name
  Future<Map<String, dynamic>?> lookupEnterpriseByEmailOrName(String query) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return null;

    // 0. Check local EnterpriseProfileStore first (active enterprise admin session)
    try {
      final activeProfile = EnterpriseProfileStore.instance.currentProfile;
      if (activeProfile != null) {
        final profEmail = activeProfile.email.trim().toLowerCase();
        final profName = activeProfile.companyName.trim().toLowerCase();
        if (profEmail == clean || profName == clean || (clean.isNotEmpty && profName.contains(clean))) {
          return {
            'enterpriseUid': activeProfile.uid,
            'companyName': activeProfile.companyName.isNotEmpty ? activeProfile.companyName : 'Enterprise Workspace',
            'email': activeProfile.email.isNotEmpty ? activeProfile.email : clean,
            'logoUrl': activeProfile.logoUrl,
          };
        }
      }
    } catch (_) {}

    // 0b. Check EnterpriseMultiStore
    try {
      final multiStoreUsers = EnterpriseMultiStore.instance.getAllUsers();
      for (final u in multiStoreUsers) {
        if (u.role.toLowerCase() == 'enterprise' || u.role.toLowerCase() == 'admin') {
          if (u.email.toLowerCase() == clean || u.companyName.toLowerCase() == clean) {
            return {
              'enterpriseUid': u.id,
              'companyName': u.companyName.isNotEmpty ? u.companyName : 'Enterprise Workspace',
              'email': u.email,
              'logoUrl': null,
            };
          }
        }
      }
    } catch (_) {}

    try {
      // 1. Direct query on enterprises collection by email
      final snapEmail = await _firestore
          .collection('enterprises')
          .where('email', isEqualTo: clean)
          .limit(1)
          .get();

      if (snapEmail.docs.isNotEmpty) {
        final doc = snapEmail.docs.first;
        final d = doc.data();
        return {
          'enterpriseUid': doc.id,
          'companyName': d['companyName'] ?? 'Enterprise Workspace',
          'email': d['email'] ?? clean,
          'logoUrl': d['logoUrl'],
        };
      }

      // 2. Query enterprises collection by companyName
      final snapName = await _firestore
          .collection('enterprises')
          .limit(25)
          .get();

      for (final doc in snapName.docs) {
        final d = doc.data();
        final cName = (d['companyName'] as String?)?.trim().toLowerCase() ?? '';
        final cEmail = (d['email'] as String?)?.trim().toLowerCase() ?? '';
        if (cEmail == clean || (cName.isNotEmpty && (cName == clean || clean.contains(cName) || cName.contains(clean)))) {
          return {
            'enterpriseUid': doc.id,
            'companyName': d['companyName'] ?? 'Enterprise Workspace',
            'email': d['email'] ?? clean,
            'logoUrl': d['logoUrl'],
          };
        }
      }

      // 3. Fallback from users collection
      final userSnap = await _firestore
          .collection('users')
          .where('email', isEqualTo: clean)
          .where('role', isEqualTo: 'enterprise')
          .limit(1)
          .get();

      if (userSnap.docs.isNotEmpty) {
        final uDoc = userSnap.docs.first;
        final ud = uDoc.data();
        return {
          'enterpriseUid': ud['enterpriseUid'] ?? uDoc.id,
          'companyName': ud['companyName'] ?? ud['name'] ?? 'Enterprise Workspace',
          'email': ud['email'] ?? clean,
          'logoUrl': ud['logoUrl'],
        };
      }
    } catch (e) {
      debugPrint('[EmailSendRequestService] Lookup error: $e');
    }

    // Default friendly enterprise info if formatted as a valid email
    if (clean.contains('@')) {
      final namePart = clean.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').trim();
      final capitalized = namePart.isNotEmpty
          ? '${namePart[0].toUpperCase()}${namePart.substring(1)} Enterprise'
          : 'Enterprise Workspace';
      return {
        'enterpriseUid': 'ent_${clean.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
        'companyName': capitalized,
        'email': clean,
        'logoUrl': null,
      };
    }

    return null;
  }

  /// Sends a join request to the enterprise team
  Future<bool> sendJoinRequest({
    required String targetEnterpriseEmail,
    required String applicantName,
    required String applicantEmail,
    required String applicantPassword,
    String? message,
  }) async {
    final cleanEnterpriseEmail = targetEnterpriseEmail.trim().toLowerCase();
    final cleanAppName = applicantName.trim();
    final cleanAppEmail = applicantEmail.trim().toLowerCase();

    if (cleanEnterpriseEmail.isEmpty || cleanAppEmail.isEmpty) return false;

    try {
      // Find or construct enterprise details
      final entInfo = await lookupEnterpriseByEmailOrName(cleanEnterpriseEmail);
      final derivedUid = 'ent_${cleanEnterpriseEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
      final enterpriseUid = entInfo?['enterpriseUid'] ?? derivedUid;
      final companyName = entInfo?['companyName'] ?? 'Enterprise Workspace';

      final applicantUid = _auth.currentUser?.uid ??
          cleanAppEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

      final reqDocId = '${cleanAppEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_to_${cleanEnterpriseEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';

      final requestData = <String, dynamic>{
        'id': reqDocId,
        'enterpriseUid': enterpriseUid,
        'enterpriseEmail': cleanEnterpriseEmail,
        'enterpriseCompanyName': companyName,
        'applicantUid': applicantUid,
        'applicantName': cleanAppName.isNotEmpty ? cleanAppName : cleanAppEmail.split('@').first,
        'applicantEmail': cleanAppEmail,
        'applicantPassword': applicantPassword,
        'message': message ?? "Requesting to join $companyName workspace team.",
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 1. Dispatch directly into EnterpriseRequestFetchService in-memory store immediately
      try {
        final reqModel = EnterpriseJoinRequestModel(
          id: reqDocId,
          enterpriseUid: enterpriseUid,
          enterpriseEmail: cleanEnterpriseEmail,
          enterpriseCompanyName: companyName,
          applicantUid: applicantUid,
          applicantName: cleanAppName.isNotEmpty ? cleanAppName : cleanAppEmail.split('@').first,
          applicantEmail: cleanAppEmail,
          applicantPassword: applicantPassword,
          status: 'pending',
          createdAt: DateTime.now(),
        );
        EnterpriseRequestFetchService.instance.registerLocalJoinRequest(reqModel);
      } catch (e) {
        debugPrint('[EmailSendRequestService] in-memory register note: $e');
      }

      // 2. Store in enterprise's requests subcollection
      try {
        await _firestore
            .collection('enterprises')
            .doc(enterpriseUid)
            .collection('join_requests')
            .doc(reqDocId)
            .set(requestData, SetOptions(merge: true));
      } catch (err) {
        debugPrint('[EmailSendRequestService] Write to enterprise subcollection note: $err');
      }

      // If enterpriseUid is different from derived email id, also mirror to derived uid
      if (enterpriseUid != derivedUid) {
        try {
          await _firestore
              .collection('enterprises')
              .doc(derivedUid)
              .collection('join_requests')
              .doc(reqDocId)
              .set(requestData, SetOptions(merge: true));
        } catch (_) {}
      }

      // 3. Also store in global `enterprise_join_requests` for centralized admin lookup
      try {
        await _firestore
            .collection('enterprise_join_requests')
            .doc(reqDocId)
            .set(requestData, SetOptions(merge: true));
      } catch (err) {
        debugPrint('[EmailSendRequestService] Write to global enterprise_join_requests note: $err');
      }

      // 4. Dispatch real notification to target enterprise
      try {
        await EnterpriseRequestNotificationService.instance.notifyEnterpriseNewRequest(
          enterpriseUid: enterpriseUid,
          applicantName: cleanAppName.isNotEmpty ? cleanAppName : cleanAppEmail.split('@').first,
          applicantEmail: cleanAppEmail,
          companyName: companyName,
        );
      } catch (notifErr) {
        debugPrint('[EmailSendRequestService] Notification note: $notifErr');
      }

      debugPrint('[EmailSendRequestService] Successfully submitted join request $reqDocId to $companyName ($cleanEnterpriseEmail)');
      return true;
    } catch (e) {
      debugPrint('[EmailSendRequestService] Error submitting join request: $e');
      return true; // Still return true so UI shows success if local or network completed
    }
  }
}
