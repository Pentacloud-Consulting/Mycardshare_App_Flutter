import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_notification_service.dart';

export 'app_notification_service.dart' show AppNotificationItem;

/// Backward-compatible Reactive Notification service managing system, security, and app notifications.
/// Delegates to AppNotificationService without any mock data.
class PasswordChangeNotify extends ChangeNotifier {
  PasswordChangeNotify._internal() {
    AppNotificationService.instance.addListener(() {
      notifyListeners();
    });
  }
  static final PasswordChangeNotify instance = PasswordChangeNotify._internal();

  /// Strictly exposes real notifications from AppNotificationService (zero mocks)
  List<AppNotificationItem> get notifications => AppNotificationService.instance.notifications;

  /// Adds a new notification item dynamically
  void addNotification(AppNotificationItem item) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    AppNotificationService.instance.addNotification(item, targetUid: uid);
  }

  /// Triggers notification when password is modified successfully
  void notifyPasswordChanged({
    BuildContext? context,
    required String userEmail,
  }) {
    final now = DateTime.now();
    final newItem = AppNotificationItem(
      id: 'pwd_${now.millisecondsSinceEpoch}',
      section: 'TODAY',
      category: 'system',
      title: 'Password updated successfully',
      subtitle: 'Your account password for $userEmail was updated.',
      time: 'Just now',
      timestamp: now,
      icon: Icons.lock_reset_rounded,
      iconBg: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFD97706),
      isUnread: true,
      route: '/portal/settings',
    );

    final uid = FirebaseAuth.instance.currentUser?.uid;
    AppNotificationService.instance.addNotification(newItem, targetUid: uid);

    // Show mobile screen floating banner if context is available
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🔒 Password updated successfully!"),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void markAllAsRead() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    AppNotificationService.instance.markAllAsRead(targetUid: uid);
  }

  void markAsRead(String id) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    AppNotificationService.instance.markAsRead(id, targetUid: uid);
  }

  void deleteNotification(String id) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    AppNotificationService.instance.deleteNotification(id, targetUid: uid);
  }
}
