import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../employee_join/email_send_request.dart';
import '../../enterprise/request/request_fetch.dart';
import '../core/master_admin_api_client.dart';
import '../core/master_admin_endpoints.dart';

/// Data model representing any pending approval item in Master Admin
class MasterApprovalItem {
  final String id;
  final String title; // Company name or Applicant name
  final String email; // Company email or Applicant email
  final String type; // 'company' or 'join_request'
  final String targetCompany; // For join requests
  final String? domain;
  final String? logoUrl;
  final String status;
  final DateTime createdAt;
  final EnterpriseJoinRequestModel? rawJoinRequest;

  const MasterApprovalItem({
    required this.id,
    required this.title,
    required this.email,
    required this.type,
    this.targetCompany = '',
    this.domain,
    this.logoUrl,
    required this.status,
    required this.createdAt,
    this.rawJoinRequest,
  });

  String get initials {
    final clean = title.trim();
    if (clean.isEmpty) return 'CO';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

/// State store managing platform-wide approval queue for Master Admin
class ApprovalsQueueStore extends ChangeNotifier {
  ApprovalsQueueStore._internal();
  static final ApprovalsQueueStore instance = ApprovalsQueueStore._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MasterApprovalItem> _pendingItems = [];
  final bool _isLoading = false;

  List<MasterApprovalItem> get pendingItems => _pendingItems;
  List<EnterpriseJoinRequestModel> get pendingQueue =>
      _pendingItems
          .where((i) => i.rawJoinRequest != null)
          .map((i) => i.rawJoinRequest!)
          .toList();

  int get pendingCount => _pendingItems.length;
  bool get isLoading => _isLoading;

  /// Combined real-time stream of pending companies + pending join requests
  Stream<List<MasterApprovalItem>> streamPendingQueue() {
    // Listen to enterprises collection for pending / approvalStatus == pending / isSuspended
    return _firestore.collection('enterprises').snapshots().asyncMap((companySnap) async {
      final List<MasterApprovalItem> items = [];

      // 1. Pending Enterprises
      for (final doc in companySnap.docs) {
        final data = doc.data();
        final status = (data['status'] as String? ?? '').toLowerCase();
        final approvalStatus = (data['approvalStatus'] as String? ?? '').toLowerCase();
        final isSuspended = data['isSuspended'] == true;

        if (status == 'pending' || approvalStatus == 'pending' || (isSuspended && approvalStatus != 'rejected')) {
          DateTime created = DateTime.now();
          if (data['createdAt'] is Timestamp) {
            created = (data['createdAt'] as Timestamp).toDate();
          }

          items.add(
            MasterApprovalItem(
              id: doc.id,
              title: data['companyName'] ?? data['name'] ?? 'Pending Enterprise',
              email: data['email'] ?? '',
              type: 'company',
              domain: data['domain'] ?? data['customDomain'] ?? '${doc.id.toLowerCase()}.mycardshare.com',
              logoUrl: data['logoUrl'],
              status: approvalStatus.isNotEmpty ? approvalStatus : (status.isNotEmpty ? status : 'pending'),
              createdAt: created,
            ),
          );
        }
      }

      // 2. Pending Join Requests
      try {
        final reqSnap = await _firestore
            .collection('enterprise_join_requests')
            .where('status', isEqualTo: 'pending')
            .get();

        for (final doc in reqSnap.docs) {
          final model = EnterpriseJoinRequestModel.fromFirestore(doc.id, doc.data());
          items.add(
            MasterApprovalItem(
              id: doc.id,
              title: model.applicantName.isNotEmpty ? model.applicantName : 'Join Request',
              email: model.applicantEmail,
              type: 'join_request',
              targetCompany: model.enterpriseCompanyName,
              status: model.status,
              createdAt: model.createdAt,
              rawJoinRequest: model,
            ),
          );
        }
      } catch (e) {
        debugPrint('[ApprovalsQueueStore] join_requests query error: $e');
      }

      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _pendingItems = items;
      notifyListeners();
      return items;
    });
  }

  /// Approve an item (either Enterprise company or Join Request)
  Future<bool> approveItem(MasterApprovalItem item) async {
    try {
      if (item.type == 'company') {
        // Unlock enterprise in Firestore
        await _firestore.collection('enterprises').doc(item.id).set({
          'approvalStatus': 'approved',
          'status': 'Active',
          'isSuspended': false,
          'approvedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Also update users collection if present
        await _firestore.collection('users').doc(item.id).set({
          'approvalStatus': 'approved',
          'status': 'active',
          'isSuspended': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Notify Next.js backend API
        await MasterAdminApiClient.post(
          MasterAdminEndpoints.companyApproval(item.id),
          {'action': 'approve', 'status': 'approved'},
        );

        _pendingItems.removeWhere((i) => i.id == item.id);
        notifyListeners();
        return true;
      } else if (item.rawJoinRequest != null) {
        return await approveRequest(item.rawJoinRequest!);
      }
      return false;
    } catch (e) {
      debugPrint('[ApprovalsQueueStore] approveItem error: $e');
      return false;
    }
  }

  /// Reject an item (either Enterprise company or Join Request)
  Future<bool> rejectItem(MasterApprovalItem item, {String? reason}) async {
    try {
      if (item.type == 'company') {
        // Mark enterprise as rejected / suspended in Firestore
        await _firestore.collection('enterprises').doc(item.id).set({
          'approvalStatus': 'rejected',
          'status': 'Suspended',
          'isSuspended': true,
          'rejectionReason': reason ?? 'Declined by Master Admin.',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _firestore.collection('users').doc(item.id).set({
          'approvalStatus': 'rejected',
          'status': 'suspended',
          'isSuspended': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await MasterAdminApiClient.post(
          MasterAdminEndpoints.companyApproval(item.id),
          {'action': 'reject', 'status': 'rejected', 'reason': reason},
        );

        _pendingItems.removeWhere((i) => i.id == item.id);
        notifyListeners();
        return true;
      } else if (item.rawJoinRequest != null) {
        return await rejectRequest(item.rawJoinRequest!, reason: reason);
      }
      return false;
    } catch (e) {
      debugPrint('[ApprovalsQueueStore] rejectItem error: $e');
      return false;
    }
  }

  /// Approve a pending join request
  Future<bool> approveRequest(EnterpriseJoinRequestModel request) async {
    try {
      final ok = await EnterpriseRequestFetchService.instance.approveJoinRequest(request: request);
      if (ok) {
        await MasterAdminApiClient.post(
          MasterAdminEndpoints.companyApproval(request.id),
          {'status': 'approved'},
        );
        _pendingItems.removeWhere((item) => item.id == request.id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      debugPrint('[ApprovalsQueueStore] approveRequest error: $e');
      return false;
    }
  }

  /// Reject a pending join request
  Future<bool> rejectRequest(EnterpriseJoinRequestModel request, {String? reason}) async {
    try {
      final ok = await EnterpriseRequestFetchService.instance.rejectJoinRequest(
        request: request,
        reason: reason ?? 'Request declined by Master Admin.',
      );
      if (ok) {
        _pendingItems.removeWhere((item) => item.id == request.id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      debugPrint('[ApprovalsQueueStore] rejectRequest error: $e');
      return false;
    }
  }
}

