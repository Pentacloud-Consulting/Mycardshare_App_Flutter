import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../employee_join/email_send_request.dart';
import '../../enterprise/request/request_fetch.dart';
import '../core/master_admin_api_client.dart';
import '../core/master_admin_endpoints.dart';
import '../master_approval_service.dart';

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

  final Set<String> _locallyResolvedIds = {};

  bool isResolved(String id) => _locallyResolvedIds.contains(id);

  void markLocallyResolved(String id) {
    _locallyResolvedIds.add(id);
    _pendingItems.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  int get pendingCount => _pendingItems.where((i) => !_locallyResolvedIds.contains(i.id)).length;
  bool get isLoading => _isLoading;

  /// Combined real-time stream of pending companies + pending join requests
  Stream<List<MasterApprovalItem>> streamPendingQueue() {
    // Listen to enterprises collection for pending / approvalStatus == pending / isSuspended
    return _firestore.collection('enterprises').snapshots().asyncMap((companySnap) async {
      final List<MasterApprovalItem> items = [];

      // 1. Pending Enterprises
      for (final doc in companySnap.docs) {
        if (_locallyResolvedIds.contains(doc.id)) continue;

        final data = doc.data();
        final status = (data['status'] as String? ?? '').toLowerCase();
        final approvalStatus = (data['approvalStatus'] as String? ?? '').toLowerCase();

        // If explicitly approved or active, it is NOT pending
        if (approvalStatus == 'approved' || status == 'active') {
          continue;
        }

        if (status == 'pending' || approvalStatus == 'pending') {
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

      // 1b. Check companies collection if any pending items exist
      try {
        final compPendingSnap = await _firestore
            .collection('companies')
            .where('approvalStatus', isEqualTo: 'pending')
            .get();
        for (final doc in compPendingSnap.docs) {
          if (!items.any((it) => it.id == doc.id)) {
            final data = doc.data();
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
                status: 'pending',
                createdAt: created,
              ),
            );
          }
        }
      } catch (_) {}

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

      items.removeWhere((it) => _locallyResolvedIds.contains(it.id));
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _pendingItems = items;
      notifyListeners();
      return items;
    });
  }

  /// Approve an item (either Enterprise company or Join Request)
  Future<bool> approveItem(MasterApprovalItem item) async {
    markLocallyResolved(item.id);
    try {
      if (item.type == 'company') {
        final now = DateTime.now();
        final renewal = now.add(const Duration(days: 365));

        // 1. Unlock enterprise in Firestore enterprises collection
        try {
          await _firestore.collection('enterprises').doc(item.id).set({
            'approvalStatus': 'approved',
            'status': 'Active',
            'isSuspended': false,
            'approvedAt': FieldValue.serverTimestamp(),
            'subscriptionStartDate': Timestamp.fromDate(now),
            'renewalDate': Timestamp.fromDate(renewal),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('[ApprovalsQueueStore] enterprises doc update note: $e');
        }

        // 2. Unlock in companies collection (handles Doc ID, companyId, and slug)
        try {
          await _firestore.collection('companies').doc(item.id).set({
            'approvalStatus': 'approved',
            'status': 'active',
            'isSuspended': false,
            'approvedAt': FieldValue.serverTimestamp(),
            'renewalDate': Timestamp.fromDate(renewal),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          final compSnap = await _firestore
              .collection('companies')
              .where('companyId', isEqualTo: item.id)
              .get();
          for (final doc in compSnap.docs) {
            await doc.reference.set({
              'approvalStatus': 'approved',
              'status': 'active',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (e) {
          debugPrint('[ApprovalsQueueStore] companies doc update note: $e');
        }

        // 3. Promote Admin User in users collection
        try {
          await _firestore.collection('users').doc(item.id).set({
            'approvalStatus': 'approved',
            'status': 'active',
            'role': 'enterprise',
            'isSuspended': false,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          if (item.email.trim().isNotEmpty) {
            final emailDocId = item.email.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
            await _firestore.collection('users').doc(emailDocId).set({
              'approvalStatus': 'approved',
              'status': 'active',
              'role': 'enterprise',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            final usersByEmail = await _firestore
                .collection('users')
                .where('email', isEqualTo: item.email.trim().toLowerCase())
                .get();
            for (final doc in usersByEmail.docs) {
              await doc.reference.set({
                'approvalStatus': 'approved',
                'status': 'active',
                'role': 'enterprise',
                'isSuspended': false,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }
          }

          final usersSnap = await _firestore
              .collection('users')
              .where('companyId', isEqualTo: item.id)
              .get();
          for (final doc in usersSnap.docs) {
            await doc.reference.set({
              'approvalStatus': 'approved',
              'status': 'active',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (e) {
          debugPrint('[ApprovalsQueueStore] users doc update note: $e');
        }

        // 4. Notify Next.js live backend sync API (/api/sync/master-admin)
        try {
          await MasterApprovalSyncService.approveCompany(
            companyId: item.id,
            action: 'approve',
          );
        } catch (apiErr) {
          debugPrint('[ApprovalsQueueStore] MasterApprovalSyncService error: $apiErr');
        }

        // 5. Notify legacy Next.js backend API
        try {
          await MasterAdminApiClient.post(
            MasterAdminEndpoints.companyApproval(item.id),
            {'action': 'approve', 'status': 'approved'},
          );
        } catch (_) {}

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
    markLocallyResolved(item.id);
    try {
      if (item.type == 'company') {
        // Mark enterprise as rejected / suspended in Firestore
        try {
          await _firestore.collection('enterprises').doc(item.id).set({
            'approvalStatus': 'rejected',
            'status': 'Suspended',
            'isSuspended': true,
            'rejectionReason': reason ?? 'Declined by Master Admin.',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}

        try {
          await _firestore.collection('companies').doc(item.id).set({
            'approvalStatus': 'rejected',
            'status': 'suspended',
            'isSuspended': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}

        try {
          await _firestore.collection('users').doc(item.id).set({
            'approvalStatus': 'rejected',
            'status': 'suspended',
            'isSuspended': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}

        // Cascade rejection to any users tied to this company
        try {
          final usersSnap = await _firestore
              .collection('users')
              .where('companyId', isEqualTo: item.id)
              .get();
          for (final doc in usersSnap.docs) {
            await doc.reference.set({
              'approvalStatus': 'rejected',
              'status': 'suspended',
              'isSuspended': true,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (e) {
          debugPrint('[ApprovalsQueueStore] Error cascading user rejection: $e');
        }

        // Notify Next.js live backend sync API
        try {
          await MasterApprovalSyncService.approveCompany(
            companyId: item.id,
            action: 'reject',
            reason: reason,
          );
        } catch (apiErr) {
          debugPrint('[ApprovalsQueueStore] MasterApprovalSyncService reject error: $apiErr');
        }

        try {
          await MasterAdminApiClient.post(
            MasterAdminEndpoints.companyApproval(item.id),
            {'action': 'reject', 'status': 'rejected', 'reason': reason},
          );
        } catch (_) {}

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

