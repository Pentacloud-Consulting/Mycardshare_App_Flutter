import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lead/active_lead.dart';
import 'password_change_notify.dart';

/// Backend service to handle lead request notifications for card owners when a visitor exchanges contact.
class LeadRequestNotification {
  LeadRequestNotification._internal();
  static final LeadRequestNotification instance = LeadRequestNotification._internal();

  /// Sends a real lead request notification to the card owner user.
  Future<void> sendLeadNotification(String targetUid, LeadData lead) async {
    final title = "New Lead Request";
    final subtitle = "${lead.name} from ${lead.company} shared contact details!";
    final notifId = 'notif_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Add notification item into PasswordChangeNotify list for live UI re-rendering
    PasswordChangeNotify.instance.addNotification(
      AppNotificationItem(
        id: notifId,
        title: title,
        subtitle: subtitle,
        time: 'Just now',
        category: 'leads',
        route: '/portal/leads',
        icon: Icons.person_add_rounded,
        iconBg: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
        section: 'TODAY',
      ),
    );

    // 2. Persist notification to Firestore under user's notification collection
    if (targetUid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(targetUid)
            .collection('notifications')
            .doc(notifId)
            .set({
          'id': notifId,
          'title': title,
          'subtitle': subtitle,
          'category': 'leads',
          'route': '/portal/leads',
          'timestamp': DateTime.now().toIso8601String(),
          'isUnread': true,
        });

        debugPrint('[LeadRequestNotification] Sent lead notification for UID: $targetUid');
      } catch (e) {
        debugPrint('[LeadRequestNotification] Firestore notification save notice: $e');
      }
    }
  }
}
