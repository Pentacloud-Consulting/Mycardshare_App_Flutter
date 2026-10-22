import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a single real-time user notification
class AppNotificationItem {
  final String id;
  final String section; // 'TODAY', 'YESTERDAY', 'EARLIER'
  final String category; // 'system', 'leads', 'scans'
  final String title;
  final String subtitle;
  final String time;
  final DateTime timestamp;
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
    required this.timestamp,
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
        'timestamp': timestamp.toIso8601String(),
        'isUnread': isUnread,
        'route': route,
      };

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    final parsedTime = json['timestamp'] != null
        ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
        : DateTime.now();

    final cat = (json['category'] as String? ?? 'system').toLowerCase();
    final notifTitle = json['title'] as String? ?? 'Notification';
    final dynamicBg = _resolveBgColor(cat);
    final dynamicColor = _resolveIconColor(cat);
    final dynamicIcon = _resolveIcon(cat, notifTitle);

    return AppNotificationItem(
      id: json['id'] as String? ?? 'notif_${parsedTime.millisecondsSinceEpoch}',
      section: _resolveSection(parsedTime),
      category: (json['category'] as String? ?? 'system').toLowerCase(),
      title: json['title'] as String? ?? 'Notification',
      subtitle: json['subtitle'] as String? ?? '',
      time: _formatRelativeTime(parsedTime),
      timestamp: parsedTime,
      icon: dynamicIcon,
      iconBg: dynamicBg,
      iconColor: dynamicColor,
      isUnread: json['isUnread'] as bool? ?? true,
      route: json['route'] as String?,
    );
  }

  static String _resolveSection(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notifDate = DateTime(dt.year, dt.month, dt.day);

    if (notifDate == today) return 'TODAY';
    if (notifDate == today.subtract(const Duration(days: 1))) return 'YESTERDAY';
    return 'EARLIER';
  }

  static String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) {
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return 'Yesterday, $hour:$minute $ampm';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  static Color _resolveBgColor(String category) {
    switch (category.toLowerCase()) {
      case 'leads':
        return const Color(0xFFDCFCE7);
      case 'scans':
        return const Color(0xFFE0F2FE);
      case 'system':
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  static Color _resolveIconColor(String category) {
    switch (category.toLowerCase()) {
      case 'leads':
        return const Color(0xFF16A34A);
      case 'scans':
        return const Color(0xFF0284C7);
      case 'system':
      default:
        return const Color(0xFFD97706);
    }
  }

  static IconData _resolveIcon(String category, String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('password') || lowerTitle.contains('security')) {
      return Icons.lock_reset_rounded;
    }
    if (lowerTitle.contains('voice')) {
      return Icons.mic_rounded;
    }
    switch (category.toLowerCase()) {
      case 'leads':
        return Icons.person_add_rounded;
      case 'scans':
        return Icons.qr_code_scanner_rounded;
      case 'system':
      default:
        return Icons.info_outline_rounded;
    }
  }
}

/// Central Backend Notification Service managing real notifications from Firestore.
/// Strictly uses real Firestore data with ZERO mock items.
class AppNotificationService extends ChangeNotifier {
  AppNotificationService._internal();
  static final AppNotificationService instance = AppNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AppNotificationItem> _notifications = [];
  bool _isLoading = false;
  StreamSubscription? _realtimeSubscription;

  List<AppNotificationItem> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => n.isUnread).length;

  String get _currentUid => _auth.currentUser?.uid ?? '';

  /// Fetches real notifications from Firestore for a given user or current user
  Future<void> fetchNotifications([String? uid]) async {
    final targetUid = uid ?? _currentUid;
    if (targetUid.isEmpty) {
      _notifications = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(targetUid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      _notifications = snapshot.docs
          .map((doc) => AppNotificationItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[AppNotificationService] Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Set up real-time listener if not already active
    _startRealtimeListener(targetUid);
  }

  /// Sets up real-time Firestore synchronization
  void _startRealtimeListener(String uid) {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _notifications = snapshot.docs
            .map((doc) => AppNotificationItem.fromJson(doc.data()))
            .toList();
        notifyListeners();
      },
      onError: (err) {
        debugPrint('[AppNotificationService] Realtime sync notice: $err');
      },
    );
  }

  /// Adds a new real notification item into local state and Firestore
  Future<void> addNotification(AppNotificationItem item, {String? targetUid}) async {
    final effectiveUid = targetUid ?? _currentUid;

    // Insert locally for instant responsive UI
    _notifications.removeWhere((n) => n.id == item.id);
    _notifications.insert(0, item);
    notifyListeners();

    if (effectiveUid.isNotEmpty) {
      try {
        await _firestore
            .collection('users')
            .doc(effectiveUid)
            .collection('notifications')
            .doc(item.id)
            .set(item.toJson());
        debugPrint('[AppNotificationService] Saved notification ${item.id} to Firestore');
      } catch (e) {
        debugPrint('[AppNotificationService] Error saving notification to Firestore: $e');
      }
    }
  }

  /// Marks a specific notification as read in local state and Firestore
  Future<void> markAsRead(String id, {String? targetUid}) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isUnread = false;
      notifyListeners();
    }

    final effectiveUid = targetUid ?? _currentUid;
    if (effectiveUid.isNotEmpty) {
      try {
        await _firestore
            .collection('users')
            .doc(effectiveUid)
            .collection('notifications')
            .doc(id)
            .update({'isUnread': false});
      } catch (e) {
        debugPrint('[AppNotificationService] Error marking notification as read: $e');
      }
    }
  }

  /// Marks all notifications as read in local state and Firestore
  Future<void> markAllAsRead({String? targetUid}) async {
    for (var n in _notifications) {
      n.isUnread = false;
    }
    notifyListeners();

    final effectiveUid = targetUid ?? _currentUid;
    if (effectiveUid.isNotEmpty) {
      try {
        final unreadDocs = await _firestore
            .collection('users')
            .doc(effectiveUid)
            .collection('notifications')
            .where('isUnread', isEqualTo: true)
            .get();

        final batch = _firestore.batch();
        for (var doc in unreadDocs.docs) {
          batch.update(doc.reference, {'isUnread': false});
        }
        await batch.commit();
      } catch (e) {
        debugPrint('[AppNotificationService] Error marking all as read: $e');
      }
    }
  }

  /// Deletes a notification from local state and Firestore
  Future<void> deleteNotification(String id, {String? targetUid}) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();

    final effectiveUid = targetUid ?? _currentUid;
    if (effectiveUid.isNotEmpty) {
      try {
        await _firestore
            .collection('users')
            .doc(effectiveUid)
            .collection('notifications')
            .doc(id)
            .delete();
        debugPrint('[AppNotificationService] Deleted notification $id from Firestore');
      } catch (e) {
        debugPrint('[AppNotificationService] Error deleting notification from Firestore: $e');
      }
    }
  }

  /// Clears all notifications from local state and Firestore
  Future<void> clearAllNotifications({String? targetUid}) async {
    _notifications.clear();
    notifyListeners();

    final effectiveUid = targetUid ?? _currentUid;
    if (effectiveUid.isNotEmpty) {
      try {
        final docs = await _firestore
            .collection('users')
            .doc(effectiveUid)
            .collection('notifications')
            .get();
        final batch = _firestore.batch();
        for (var doc in docs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        debugPrint('[AppNotificationService] Cleared all notifications from Firestore');
      } catch (e) {
        debugPrint('[AppNotificationService] Error clearing notifications from Firestore: $e');
      }
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
