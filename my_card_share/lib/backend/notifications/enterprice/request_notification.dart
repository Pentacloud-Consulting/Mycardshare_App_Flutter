import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../notification_sync_service.dart';

/// Notification service for notifying Enterprises about incoming Employee Join Requests.
/// Directly creates real notification entries in `enterprises/{enterpriseUid}/notifications`
/// which are streamed on Image 2 (Enterprise Notifications page).
class EnterpriseRequestNotificationService {
  EnterpriseRequestNotificationService._internal();
  static final EnterpriseRequestNotificationService instance =
      EnterpriseRequestNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a real notification record for an incoming join request
  Future<void> notifyEnterpriseNewRequest({
    required String enterpriseUid,
    required String applicantName,
    required String applicantEmail,
    required String companyName,
  }) async {
    if (enterpriseUid.isEmpty) return;

    try {
      final targetUids = <String>{
        if (enterpriseUid.isNotEmpty) enterpriseUid,
        if (_firestore.app.options.projectId.isNotEmpty && enterpriseUid.contains('@'))
          'ent_${enterpriseUid.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
      };

      for (final uid in targetUids) {
        final notifRef = _firestore
            .collection('enterprises')
            .doc(uid)
            .collection('notifications')
            .doc();

        final notifData = <String, dynamic>{
          'id': notifRef.id,
          'title': 'New Join Workspace Request',
          'description': '$applicantName ($applicantEmail) requested to join $companyName team.',
          'category': 'team',
          'isUnread': true,
          'applicantName': applicantName,
          'applicantEmail': applicantEmail,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await notifRef.set(notifData);
        debugPrint('[EnterpriseRequestNotificationService] Sent notification to enterprise $uid for $applicantName');

        // Also trigger real Firebase Cloud Messaging push notification via Next.js backend
        await NotificationSyncService.triggerAlert(
          targetUserId: uid,
          title: 'New Join Workspace Request',
          body: '$applicantName ($applicantEmail) requested to join $companyName team.',
          type: 'team_invite',
          data: {
            'applicantEmail': applicantEmail,
            'applicantName': applicantName,
            'enterpriseUid': uid,
          },
        );
      }
    } catch (e) {
      debugPrint('[EnterpriseRequestNotificationService] Error notifying enterprise: $e');
    }
  }

  /// Streams real notifications specifically for Join Requests
  Stream<List<Map<String, dynamic>>> streamRequestNotifications(String enterpriseUid) {
    if (enterpriseUid.isEmpty) return const Stream.empty();

    return _firestore
        .collection('enterprises')
        .doc(enterpriseUid)
        .collection('notifications')
        .where('category', isEqualTo: 'team')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }
}
