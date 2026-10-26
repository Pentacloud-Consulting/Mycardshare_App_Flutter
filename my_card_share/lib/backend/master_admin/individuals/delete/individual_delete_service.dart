import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/individual/profile/individual_profile_store.dart';

class IndividualDeleteService {
  static const String primaryUrl = "https://digitalbusinesscloudcard.com";
  static const String fallbackUrl = "https://mycardshare.com";
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. USER: SUBMIT DELETION REQUEST (From Individual Settings)
  static Future<bool> requestAccountDeletion({
    required String reason,
    String feedback = "",
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("[IndividualDeleteService] No logged in user found");
      return false;
    }

    final uid = user.uid;
    final email = user.email ?? "";
    final activeProfile = IndividualProfileStore.instance.activeProfile;
    final userName = (activeProfile?.fullName.isNotEmpty ?? false)
        ? activeProfile!.fullName
        : (user.displayName ?? "Individual User");

    try {
      // 1. Write request to Firestore 'account_deletion_requests'
      final docRef = _firestore.collection("account_deletion_requests").doc(uid);
      await docRef.set({
        "userId": uid,
        "userName": userName,
        "userEmail": email,
        "reason": reason,
        "feedback": feedback,
        "status": "pending", // pending, confirmed, rejected
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Mark user status in Firestore 'users' collection
      await _firestore.collection("users").doc(uid).set({
        "status": "deletion_pending",
        "deletion_pending": true,
        "deletionRequestedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Create Notification for Master Admin in Firestore
      await _firestore.collection("notifications").add({
        "type": "account_deletion",
        "category": "system",
        "title": "Account Deletion Request ⚠️",
        "body": "$userName ($email) requested account deletion. Reason: $reason",
        "userId": uid,
        "userName": userName,
        "userEmail": email,
        "reason": reason,
        "requestId": docRef.id,
        "route": "/master-admin/individuals",
        "isRead": false,
        "targetRole": "master_admin",
        "createdAt": FieldValue.serverTimestamp(),
      });

      // 4. Send to Backend API
      for (final host in [primaryUrl, fallbackUrl]) {
        try {
          final headers = await _getHeaders();
          final res = await http.post(
            Uri.parse("$host/api/sync/individual-deletion"),
            headers: headers,
            body: jsonEncode({
              "action": "request_deletion",
              "userId": uid,
              "userName": userName,
              "userEmail": email,
              "reason": reason,
              "feedback": feedback,
            }),
          ).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200 || res.statusCode == 201) break;
        } catch (_) {}
      }

      debugPrint("[IndividualDeleteService] Deletion request created successfully for $userName ($uid)");
      return true;
    } catch (e) {
      debugPrint("[IndividualDeleteService] Request deletion error: $e");
      return false;
    }
  }

  /// 2. MASTER ADMIN: STREAM PENDING DELETION REQUESTS (Real-Time, Instant)
  static Stream<List<Map<String, dynamic>>> streamPendingDeletions() {
    return _firestore
        .collection("account_deletion_requests")
        .snapshots()
        .map((snapshot) {
      final List<Map<String, dynamic>> list = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final statusStr = (data["status"] ?? "pending").toString().toLowerCase().trim();
        if (statusStr == "confirmed" || statusStr == "rejected" || statusStr == "completed") {
          continue;
        }

        DateTime dt = DateTime.now();
        if (data["createdAt"] is Timestamp) {
          dt = (data["createdAt"] as Timestamp).toDate();
        }

        final uid = (data["userId"] ?? doc.id).toString();
        list.add({
          "requestId": doc.id,
          "userId": uid,
          "userName": data["userName"] ?? "User",
          "userEmail": data["userEmail"] ?? "",
          "reason": data["reason"] ?? "User requested account deletion",
          "feedback": data["feedback"] ?? "",
          "status": "pending",
          "createdAt": dt,
        });
      }

      return list;
    }).handleError((err) {
      debugPrint("[IndividualDeleteService] streamPendingDeletions error: $err");
      return <Map<String, dynamic>>[];
    });
  }

  /// 3. MASTER ADMIN: FETCH ALL PENDING DELETION REQUESTS
  static Future<List<Map<String, dynamic>>> fetchPendingDeletions() async {
    final Map<String, Map<String, dynamic>> requestsMap = {};

    try {
      final snap = await _firestore.collection("account_deletion_requests").get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final statusStr = (data["status"] ?? "pending").toString().toLowerCase().trim();
        if (statusStr == "confirmed" || statusStr == "rejected" || statusStr == "completed") {
          continue;
        }

        DateTime dt = DateTime.now();
        if (data["createdAt"] is Timestamp) {
          dt = (data["createdAt"] as Timestamp).toDate();
        }

        final uid = (data["userId"] ?? doc.id).toString();
        requestsMap[uid] = {
          "requestId": doc.id,
          "userId": uid,
          "userName": data["userName"] ?? "User",
          "userEmail": data["userEmail"] ?? "",
          "reason": data["reason"] ?? "User requested account deletion",
          "feedback": data["feedback"] ?? "",
          "status": "pending",
          "createdAt": dt,
        };
      }
    } catch (e) {
      debugPrint("[IndividualDeleteService] Firestore get error: $e");
    }

    if (requestsMap.isEmpty) {
      final apiList = await _fetchFromApi();
      for (final req in apiList) {
        final id = (req["userId"] ?? req["requestId"] ?? req["id"] ?? "").toString();
        if (id.isNotEmpty) requestsMap[id] = req;
      }
    }

    return requestsMap.values.toList();
  }

  static Future<List<Map<String, dynamic>>> _fetchFromApi() async {
    for (final host in [primaryUrl, fallbackUrl]) {
      try {
        final headers = await _getHeaders();
        final res = await http.get(
          Uri.parse("$host/api/sync/individual-deletion"),
          headers: headers,
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final json = jsonDecode(res.body);
          final list = json["data"]?["requests"] ?? json["requests"] ?? [];
          return List<Map<String, dynamic>>.from(list);
        }
      } catch (_) {}
    }
    return [];
  }

  /// 4. MASTER ADMIN: CONFIRM PERMANENT DELETE
  static Future<bool> confirmDeleteUser({
    required String requestId,
    required String targetUserId,
  }) async {
    try {
      // 1. Mark request as confirmed/deleted in Firestore
      await _firestore.collection("account_deletion_requests").doc(requestId).set({
        "status": "confirmed",
        "processedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Mark user as deactivated/deleted in Firestore 'users'
      await _firestore.collection("users").doc(targetUserId).set({
        "status": "Deleted",
        "isDeactivated": true,
        "deletedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Mark corresponding notification as read/resolved
      final notifSnap = await _firestore
          .collection("notifications")
          .where("userId", isEqualTo: targetUserId)
          .where("type", isEqualTo: "account_deletion")
          .get();
      for (final doc in notifSnap.docs) {
        await doc.reference.update({"isRead": true, "resolved": true});
      }

      // 4. Trigger backend sync endpoint to delete from MongoDB/Auth
      for (final host in [primaryUrl, fallbackUrl]) {
        try {
          final headers = await _getHeaders();
          final res = await http.post(
            Uri.parse("$host/api/sync/individual-deletion"),
            headers: headers,
            body: jsonEncode({
              "action": "confirm_delete",
              "requestId": requestId,
              "targetUserId": targetUserId,
            }),
          ).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200) break;
        } catch (apiErr) {
          debugPrint("[IndividualDeleteService] Backend API confirm delete note: $apiErr");
        }
      }

      return true;
    } catch (e) {
      debugPrint("[IndividualDeleteService] Confirm delete error: $e");
      return false;
    }
  }

  /// 5. MASTER ADMIN: REJECT DELETION
  static Future<bool> rejectDeletion({
    required String requestId,
    required String targetUserId,
    String? reason,
  }) async {
    try {
      // 1. Mark request as rejected in Firestore
      await _firestore.collection("account_deletion_requests").doc(requestId).set({
        "status": "rejected",
        "rejectReason": reason ?? "Declined by admin",
        "processedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Restore user status to Active in Firestore 'users'
      await _firestore.collection("users").doc(targetUserId).set({
        "status": "Active",
        "deletion_pending": false,
        "isDeactivated": false,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Mark notification as read
      final notifSnap = await _firestore
          .collection("notifications")
          .where("userId", isEqualTo: targetUserId)
          .where("type", isEqualTo: "account_deletion")
          .get();
      for (final doc in notifSnap.docs) {
        await doc.reference.update({"isRead": true, "resolved": true});
      }

      // 4. Trigger backend sync endpoint
      for (final host in [primaryUrl, fallbackUrl]) {
        try {
          final headers = await _getHeaders();
          final res = await http.post(
            Uri.parse("$host/api/sync/individual-deletion"),
            headers: headers,
            body: jsonEncode({
              "action": "reject_deletion",
              "requestId": requestId,
              "targetUserId": targetUserId,
              "rejectReason": reason ?? "Declined by admin",
            }),
          ).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200) break;
        } catch (apiErr) {
          debugPrint("[IndividualDeleteService] Backend API reject delete note: $apiErr");
        }
      }

      return true;
    } catch (e) {
      debugPrint("[IndividualDeleteService] Reject deletion error: $e");
      return false;
    }
  }
}
