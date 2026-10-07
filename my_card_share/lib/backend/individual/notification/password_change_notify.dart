import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationItem {
  final String id;
  final String section; // 'TODAY', 'YESTERDAY'
  final String category; // 'system', 'leads', 'scans'
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  bool isUnread;
  final String? route;

  AppNotificationItem({
    required this.id,
    required this.section,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.isUnread = true,
    this.route,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'section': section,
        'category': category,
        'title': title,
        'subtitle': subtitle,
        'time': time,
        'isUnread': isUnread,
        'route': route,
      };
}

/// Reactive Notification service managing password updates & dynamic app notifications.
class PasswordChangeNotify extends ChangeNotifier {
  PasswordChangeNotify._internal();
  static final PasswordChangeNotify instance = PasswordChangeNotify._internal();

  final List<AppNotificationItem> _notifications = [
    AppNotificationItem(
      id: 'n_1',
      section: 'TODAY',
      category: 'leads',
      title: 'New lead captured!',
      subtitle: 'Sarah Jenkins viewed your card and left contact info',
      time: '2m ago',
      icon: Icons.person_add_rounded,
      iconBg: const Color(0xFFDCFCE7),
      iconColor: const Color(0xFF16A34A),
      isUnread: true,
      route: '/portal/leads',
    ),
    AppNotificationItem(
      id: 'n_2',
      section: 'TODAY',
      category: 'scans',
      title: 'Card scanned',
      subtitle: 'Someone scanned your QR code at GITEX 2026',
      time: '1h ago',
      icon: Icons.qr_code_scanner_rounded,
      iconBg: const Color(0xFFE0F2FE),
      iconColor: const Color(0xFF0284C7),
      isUnread: true,
      route: '/portal/vault',
    ),
    AppNotificationItem(
      id: 'n_3',
      section: 'YESTERDAY',
      category: 'scans',
      title: 'Voice contact saved',
      subtitle: 'Robert Chen added to your Contact Vault',
      time: 'Yesterday, 4:30 PM',
      icon: Icons.mic_rounded,
      iconBg: const Color(0xFFF3E8FF),
      iconColor: const Color(0xFF9333EA),
      isUnread: false,
      route: '/portal/vault',
    ),
  ];

  List<AppNotificationItem> get notifications => List.unmodifiable(_notifications);

  /// Adds a new notification item dynamically
  void addNotification(AppNotificationItem item) {
    _notifications.insert(0, item);
    notifyListeners();
  }

  /// Triggers notification when password is modified successfully
  void notifyPasswordChanged({
    BuildContext? context,
    required String userEmail,
  }) {
    final newItem = AppNotificationItem(
      id: 'pwd_${DateTime.now().millisecondsSinceEpoch}',
      section: 'TODAY',
      category: 'system',
      title: 'Password updated successfully',
      subtitle: 'Your account password for $userEmail was updated.',
      time: 'Just now',
      icon: Icons.lock_reset_rounded,
      iconBg: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFD97706),
      isUnread: true,
      route: '/portal/settings',
    );

    _notifications.insert(0, newItem);
    notifyListeners();

    // Sync to Firestore in background
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .doc(newItem.id)
            .set(newItem.toJson());
      } catch (e) {
        debugPrint('[PasswordChangeNotify] Firestore sync skipped: $e');
      }
    }

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
    for (var n in _notifications) {
      n.isUnread = false;
    }
    notifyListeners();
  }

  void markAsRead(String id) {
    final matches = _notifications.where((element) => element.id == id);
    if (matches.isNotEmpty) {
      matches.first.isUnread = false;
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}


