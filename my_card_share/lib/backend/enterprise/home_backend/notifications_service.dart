import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnterpriseNotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String category; // 'leads', 'security', 'team', 'analytics'
  final bool isUnread;

  EnterpriseNotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    required this.isUnread,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  factory EnterpriseNotificationModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    DateTime ts = DateTime.now();
    if (data['createdAt'] is Timestamp) {
      ts = (data['createdAt'] as Timestamp).toDate();
    }

    return EnterpriseNotificationModel(
      id: id,
      title: data['title'] ?? 'Notification',
      description: data['description'] ?? '',
      timestamp: ts,
      category: data['category'] ?? 'leads',
      isUnread: data['isUnread'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'category': category,
        'isUnread': isUnread,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class EnterpriseNotificationsService {
  EnterpriseNotificationsService._internal();
  static final EnterpriseNotificationsService instance =
      EnterpriseNotificationsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Stream notifications from enterprises/{uid}/notifications
  Stream<List<EnterpriseNotificationModel>> streamNotifications([
    String? uid,
    String filter = 'all',
  ]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const []);
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      List<EnterpriseNotificationModel> list = snapshot.docs
          .map((doc) =>
              EnterpriseNotificationModel.fromFirestore(doc.id, doc.data()))
          .toList();

      if (filter == 'unread') {
        list = list.where((item) => item.isUnread).toList();
      } else if (filter != 'all') {
        list = list.where((item) => item.category == filter).toList();
      }

      return list;
    });
  }

  /// Mark all notifications as read for current enterprise
  Future<void> markAllAsRead([String? uid]) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return;

    try {
      final snap = await _firestore
          .collection('enterprises')
          .doc(targetUid)
          .collection('notifications')
          .where('isUnread', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isUnread': false});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[EnterpriseNotificationsService] markAllAsRead error: $e');
    }
  }

  /// Mark single notification as read
  Future<void> markAsRead(String notificationId, [String? uid]) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return;

    try {
      await _firestore
          .collection('enterprises')
          .doc(targetUid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isUnread': false});
    } catch (e) {
      debugPrint('[EnterpriseNotificationsService] markAsRead error: $e');
    }
  }

  /// Add a notification
  Future<void> addNotification({
    required String uid,
    required String title,
    required String description,
    String category = 'leads',
  }) async {
    try {
      final id = 'notif_${DateTime.now().millisecondsSinceEpoch}';
      final model = EnterpriseNotificationModel(
        id: id,
        title: title,
        description: description,
        timestamp: DateTime.now(),
        category: category,
        isUnread: true,
      );

      await _firestore
          .collection('enterprises')
          .doc(uid)
          .collection('notifications')
          .doc(id)
          .set(model.toFirestore());
    } catch (e) {
      debugPrint('[EnterpriseNotificationsService] addNotification error: $e');
    }
  }
}


