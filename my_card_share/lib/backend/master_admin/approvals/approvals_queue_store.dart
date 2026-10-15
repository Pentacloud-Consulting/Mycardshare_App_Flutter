import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../employee_join/email_send_request.dart';
import '../../enterprise/request/request_fetch.dart';
import '../core/master_admin_api_client.dart';
import '../core/master_admin_endpoints.dart';

/// State store managing platform-wide approval queue
class ApprovalsQueueStore extends ChangeNotifier {
  ApprovalsQueueStore._internal();
  static final ApprovalsQueueStore instance = ApprovalsQueueStore._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<EnterpriseJoinRequestModel> _pendingQueue = [];
  final bool _isLoading = false;

  List<EnterpriseJoinRequestModel> get pendingQueue => _pendingQueue;
  int get pendingCount => _pendingQueue.length;
  bool get isLoading => _isLoading;

  /// Streams real pending requests across the entire platform
  Stream<List<EnterpriseJoinRequestModel>> streamPendingQueue() {
    return _firestore
        .collection('enterprise_join_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((doc) {
        return EnterpriseJoinRequestModel.fromFirestore(doc.id, doc.data());
      }).toList();

      _pendingQueue = list;
      notifyListeners();
      return list;
    });
  }

  /// Approve a pending request
  Future<bool> approveRequest(EnterpriseJoinRequestModel request) async {
    try {
      final ok = await EnterpriseRequestFetchService.instance.approveJoinRequest(request: request);
      if (ok) {
        await MasterAdminApiClient.post(
          MasterAdminEndpoints.companyApproval(request.id),
          {'status': 'approved'},
        );
        _pendingQueue.removeWhere((item) => item.id == request.id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      debugPrint('[ApprovalsQueueStore] approveRequest error: $e');
      return false;
    }
  }

  /// Reject a pending request
  Future<bool> rejectRequest(EnterpriseJoinRequestModel request, {String? reason}) async {
    try {
      final ok = await EnterpriseRequestFetchService.instance.rejectJoinRequest(
        request: request,
        reason: reason ?? 'Request declined by Master Admin.',
      );
      if (ok) {
        _pendingQueue.removeWhere((item) => item.id == request.id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      debugPrint('[ApprovalsQueueStore] rejectRequest error: $e');
      return false;
    }
  }
}
