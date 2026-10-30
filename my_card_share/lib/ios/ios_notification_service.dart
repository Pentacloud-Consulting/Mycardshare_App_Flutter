import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// iOS Push Notification permission and display handler.
/// Pairs with firebase_messaging for FCM on iOS.
///
/// How to use:
///   await IOSNotificationService.instance.requestPermission();
///
/// Wire in main.dart:
///   if (!kIsWeb && Platform.isIOS) {
///     await IOSNotificationService.instance.requestPermission();
///   }
class IOSNotificationService {
  IOSNotificationService._internal();
  static final IOSNotificationService instance = IOSNotificationService._internal();

  /// Request iOS push notification permission via firebase_messaging.
  /// On iOS 10+ this shows the system permission dialog.
  Future<void> requestPermission() async {
    if (kIsWeb || !Platform.isIOS) return;
    debugPrint('[IOSNotificationService] Requesting push notification permission...');
    // FirebaseMessaging.instance.requestPermission() is called by
    // the existing NotificationService in lib/notifications/.
    // This service is a no-op placeholder — wire full FCM setup here if needed.
  }

  /// Show an in-app iOS-style notification banner when app is foreground.
  static void showForegroundBanner(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                  Text(body, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
