import 'package:flutter/material.dart';
import 'app_notification_service.dart';

/// Backend service to trigger real Card Scanned & QR scan notifications for card owners.
class ScanNotificationService {
  ScanNotificationService._internal();
  static final ScanNotificationService instance = ScanNotificationService._internal();

  /// Triggers a real "Card scanned" notification when a visitor scans the card or QR code.
  Future<void> notifyCardScanned({
    required String targetUid,
    String? location,
    String? viewerName,
  }) async {
    final now = DateTime.now();
    final notifId = 'scan_notif_${now.millisecondsSinceEpoch}';

    final subtitle = viewerName != null && viewerName.trim().isNotEmpty
        ? "$viewerName scanned your QR code${location != null ? ' at $location' : ''}"
        : "Someone scanned your QR code${location != null ? ' at $location' : ''}";

    final item = AppNotificationItem(
      id: notifId,
      title: "Card scanned",
      subtitle: subtitle,
      time: "Just now",
      timestamp: now,
      category: "scans",
      route: "/portal/analytics",
      icon: Icons.qr_code_scanner_rounded,
      iconBg: const Color(0xFFE0F2FE),
      iconColor: const Color(0xFF0284C7),
      section: "TODAY",
      isUnread: true,
    );

    await AppNotificationService.instance.addNotification(item, targetUid: targetUid);
    debugPrint('[ScanNotificationService] Sent card scanned notification to UID: $targetUid');
  }
}
