import 'package:flutter/material.dart';
import 'app_notification_service.dart';

/// Backend service to trigger real Contact Saved (Voice, Manual, OCR) notifications.
class VaultNotificationService {
  VaultNotificationService._internal();
  static final VaultNotificationService instance = VaultNotificationService._internal();

  /// Triggers a real notification when a new contact is added to the user's Contact Vault.
  Future<void> notifyContactSaved({
    required String targetUid,
    required String contactName,
    String method = 'Manual', // 'Voice', 'Manual', 'OCR'
  }) async {
    final now = DateTime.now();
    final notifId = 'contact_notif_${now.millisecondsSinceEpoch}';

    final isVoice = method.toLowerCase() == 'voice';
    final title = isVoice ? "Voice contact saved" : "Contact saved";
    final icon = isVoice ? Icons.mic_rounded : Icons.edit_note_rounded;
    final iconBg = isVoice ? const Color(0xFFF3E8FF) : const Color(0xFFE0E7FF);
    final iconColor = isVoice ? const Color(0xFF9333EA) : const Color(0xFF4F46E5);

    final item = AppNotificationItem(
      id: notifId,
      title: title,
      subtitle: "$contactName added to your Contact Vault",
      time: "Just now",
      timestamp: now,
      category: "scans",
      route: "/portal/vault",
      icon: icon,
      iconBg: iconBg,
      iconColor: iconColor,
      section: "TODAY",
      isUnread: true,
    );

    await AppNotificationService.instance.addNotification(item, targetUid: targetUid);
    debugPrint('[VaultNotificationService] Sent contact saved notification to UID: $targetUid');
  }
}
