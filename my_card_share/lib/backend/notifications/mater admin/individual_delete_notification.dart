import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class IndividualDeleteNotification {
  IndividualDeleteNotification._internal();
  static final IndividualDeleteNotification instance = IndividualDeleteNotification._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// REAL-TIME STREAM OF DELETION NOTIFICATIONS FOR MASTER ADMIN
  Stream<List<Map<String, dynamic>>> streamDeletionNotifications() {
    return _firestore
        .collection("notifications")
        .where("type", isEqualTo: "account_deletion")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        DateTime dt = DateTime.now();
        if (data["createdAt"] is Timestamp) {
          dt = (data["createdAt"] as Timestamp).toDate();
        }
        return {
          "id": doc.id,
          "title": data["title"] ?? "Account Deletion Request",
          "body": data["body"] ?? "",
          "userId": data["userId"] ?? "",
          "userName": data["userName"] ?? "User",
          "userEmail": data["userEmail"] ?? "",
          "reason": data["reason"] ?? "",
          "requestId": data["requestId"] ?? "",
          "createdAt": dt,
          "isRead": data["isRead"] ?? false,
          "route": data["route"] ?? "/master-admin/individuals",
        };
      }).toList();
    });
  }

  /// REAL-TIME UNREAD DELETION REQUESTS COUNT STREAM
  Stream<int> streamUnreadCount() {
    return _firestore
        .collection("notifications")
        .where("type", isEqualTo: "account_deletion")
        .where("isRead", isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// MARK NOTIFICATION AS READ
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection("notifications").doc(notificationId).update({"isRead": true});
    } catch (e) {
      debugPrint("[IndividualDeleteNotification] markAsRead error: $e");
    }
  }

  /// DELETE / DISMISS NOTIFICATION
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection("notifications").doc(notificationId).delete();
    } catch (e) {
      debugPrint("[IndividualDeleteNotification] deleteNotification error: $e");
    }
  }
}
