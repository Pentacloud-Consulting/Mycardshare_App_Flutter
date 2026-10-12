import 'package:flutter/material.dart';
import '../lead/active_lead.dart';
import 'app_notification_service.dart';

/// Backend service to handle real lead request notifications for card owners when a visitor exchanges contact.
class LeadRequestNotification {
  LeadRequestNotification._internal();
  static final LeadRequestNotification instance = LeadRequestNotification._internal();

  /// Sends a real lead request notification to the card owner user.
  Future<void> sendLeadNotification(String targetUid, LeadData lead) async {
    final title = "New lead captured!";
    final subtitle = "${lead.name} from ${lead.company} shared contact details";
    final now = DateTime.now();
    final notifId = 'lead_notif_${now.millisecondsSinceEpoch}';

    final item = AppNotificationItem(
      id: notifId,
      title: title,
      subtitle: subtitle,
      time: 'Just now',
      timestamp: now,
      category: 'leads',
      route: '/portal/leads',
      icon: Icons.person_add_rounded,
      iconBg: const Color(0xFFDCFCE7),
      iconColor: const Color(0xFF16A34A),
      section: 'TODAY',
      isUnread: true,
    );

    await AppNotificationService.instance.addNotification(item, targetUid: targetUid);
    debugPrint('[LeadRequestNotification] Sent lead notification for UID: $targetUid');
  }
}
