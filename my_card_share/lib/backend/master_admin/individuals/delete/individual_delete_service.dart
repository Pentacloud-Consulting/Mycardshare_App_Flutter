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

    final apiList = await fetchDeletionRequestsFromApi();
    for (final req in apiList) {
      final id = (req["userId"] ?? req["requestId"] ?? req["id"] ?? "").toString();
      if (id.isNotEmpty) requestsMap[id] = req;
    }

    return requestsMap.values.toList();
  }

  /// 3.1 Direct Backend API Fetch with fail-safe timeout
  static Future<List<Map<String, dynamic>>> fetchDeletionRequestsFromApi() async {
    for (final host in [primaryUrl, fallbackUrl]) {
      try {
        final headers = await _getHeaders();
        final res = await http.get(
          Uri.parse("$host/api/sync/individual-deletion"),
          headers: headers,
        ).timeout(const Duration(seconds: 5));

        if (res.statusCode == 200) {
          final json = jsonDecode(res.body);
          final list = json["data"]?["requests"] ?? json["requests"] ?? [];
          return List<Map<String, dynamic>>.from(list);
        }
      } catch (e) {
        debugPrint("[IndividualDeleteService] fetchDeletionRequestsFromApi error: $e");
      }
    }
    return [];
  }

  /// 4. MASTER ADMIN: CONFIRM PERMANENT DELETE
  static Future<bool> confirmDeleteUser({
    required String requestId,
    required String targetUserId,
  }) async {
    try {
      final idToPurge = targetUserId.isNotEmpty ? targetUserId : requestId;

      // Extract user info before deletion
      String userEmail = "";
      String userName = "";

      try {
        DocumentSnapshot reqDoc = await _firestore.collection("account_deletion_requests").doc(requestId).get();
        if (!reqDoc.exists && targetUserId.isNotEmpty) {
          reqDoc = await _firestore.collection("account_deletion_requests").doc(targetUserId).get();
        }
        if (reqDoc.exists) {
          final data = reqDoc.data() as Map<String, dynamic>?;
          userEmail = (data?["userEmail"] ?? "").toString().trim().toLowerCase();
          userName = (data?["userName"] ?? "").toString().trim();
        }
      } catch (_) {}

      if (userEmail.isEmpty) {
        try {
          final uDoc = await _firestore.collection("users").doc(idToPurge).get();
          if (uDoc.exists) {
            final uData = uDoc.data() as Map<String, dynamic>?;
            userEmail = (uData?["email"] ?? "").toString().trim().toLowerCase();
            if (userName.isEmpty) {
              userName = (uData?["fullName"] ?? uData?["name"] ?? "").toString().trim();
            }
          }
        } catch (_) {}
      }

      // 1. Create permanent tombstone in 'deleted_accounts' collection
      final tombstoneData = {
        "userId": idToPurge,
        "email": userEmail,
        "userName": userName,
        "status": "Deleted",
        "isDeleted": true,
        "isDeactivated": true,
        "deleted": true,
        "deletedAt": FieldValue.serverTimestamp(),
        "deletedBy": "master_admin",
        "reason": "Account deletion approved by administrator",
      };

      try {
        await _firestore.collection("deleted_accounts").doc(idToPurge).set(tombstoneData);
        if (userEmail.isNotEmpty) {
          await _firestore.collection("deleted_accounts").doc(userEmail).set(tombstoneData);
          final safeEmailDoc = userEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          await _firestore.collection("deleted_accounts").doc(safeEmailDoc).set(tombstoneData);
        }
      } catch (err) {
        debugPrint("[IndividualDeleteService] deleted_accounts tombstone note: $err");
      }

      // 2. Mark user as completely Deleted in Firestore 'users'
      try {
        final updatePayload = {
          "status": "Deleted",
          "isDeactivated": true,
          "isDeleted": true,
          "deleted": true,
          "deletion_pending": false,
          "deletionRequest": FieldValue.delete(),
          "deletionRequestedAt": FieldValue.delete(),
          "deletedAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
        };

        await _firestore.collection("users").doc(idToPurge).set(updatePayload, SetOptions(merge: true));

        if (userEmail.isNotEmpty) {
          final safeEmailDoc = userEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          await _firestore.collection("users").doc(safeEmailDoc).set(updatePayload, SetOptions(merge: true));
        }
      } catch (_) {}

      // 3. Archive user cards in Firestore 'cards'
      try {
        await _firestore.collection("cards").doc(idToPurge).set({
          "status": "Deleted",
          "cardStatus": "Archived",
          "isDeactivated": true,
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final cardQuery = await _firestore.collection("cards").where("userId", isEqualTo: idToPurge).get();
        for (final doc in cardQuery.docs) {
          await doc.reference.set({
            "status": "Deleted",
            "cardStatus": "Archived",
            "isDeactivated": true,
            "updatedAt": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (_) {}

      // 4. Delete request completely from Firestore 'account_deletion_requests'
      try {
        await _firestore.collection("account_deletion_requests").doc(requestId).delete();
      } catch (_) {}
      if (targetUserId.isNotEmpty && targetUserId != requestId) {
        try {
          await _firestore.collection("account_deletion_requests").doc(targetUserId).delete();
        } catch (_) {}
      }

      // Query and purge any docs in account_deletion_requests matching userId or requestId
      try {
        final querySnap = await _firestore.collection("account_deletion_requests")
            .where("userId", isEqualTo: idToPurge).get();
        for (final doc in querySnap.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}

      // 5. Mark corresponding notification as read/resolved
      try {
        final notifSnap = await _firestore
            .collection("notifications")
            .where("userId", isEqualTo: idToPurge)
            .get();
        for (final doc in notifSnap.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}

      // 6. Trigger backend sync endpoint across supported routes
      final payload = jsonEncode({
        "action": "confirm_delete",
        "requestId": requestId,
        "id": requestId,
        "targetUserId": idToPurge,
        "userId": idToPurge,
        "userEmail": userEmail,
      });

      for (final host in [primaryUrl, fallbackUrl]) {
        for (final endpoint in ["/api/sync/individual-deletion", "/api/sync/master-admin-individuals"]) {
          try {
            final headers = await _getHeaders();
            await http.post(
              Uri.parse("$host$endpoint"),
              headers: headers,
              body: payload,
            ).timeout(const Duration(seconds: 4));
          } catch (_) {}
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
      final idToRestore = targetUserId.isNotEmpty ? targetUserId : requestId;

      // 1. Remove request from Firestore 'account_deletion_requests'
      try {
        await _firestore.collection("account_deletion_requests").doc(requestId).delete();
      } catch (_) {}
      if (targetUserId.isNotEmpty && targetUserId != requestId) {
        try {
          await _firestore.collection("account_deletion_requests").doc(targetUserId).delete();
        } catch (_) {}
      }

      try {
        final querySnap = await _firestore.collection("account_deletion_requests")
            .where("userId", isEqualTo: idToRestore).get();
        for (final doc in querySnap.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}

      // 2. Restore user status to Active in Firestore 'users'
      try {
        await _firestore.collection("users").doc(idToRestore).set({
          "status": "Active",
          "deletion_pending": false,
          "isDeactivated": false,
          "deletionRequest": FieldValue.delete(),
          "deletionRequestedAt": FieldValue.delete(),
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}

      // 3. Mark notification as read
      try {
        final notifSnap = await _firestore
            .collection("notifications")
            .where("userId", isEqualTo: idToRestore)
            .get();
        for (final doc in notifSnap.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}

      // 4. Trigger backend sync endpoint across supported routes
      final payload = jsonEncode({
        "action": "reject_deletion",
        "requestId": requestId,
        "id": requestId,
        "targetUserId": idToRestore,
        "userId": idToRestore,
        "rejectReason": reason ?? "Declined by admin",
      });

      for (final host in [primaryUrl, fallbackUrl]) {
        for (final endpoint in ["/api/sync/individual-deletion", "/api/sync/master-admin-individuals"]) {
          try {
            final headers = await _getHeaders();
            await http.post(
              Uri.parse("$host$endpoint"),
              headers: headers,
              body: payload,
            ).timeout(const Duration(seconds: 4));
          } catch (_) {}
        }
      }

      return true;
    } catch (e) {
      debugPrint("[IndividualDeleteService] Reject deletion error: $e");
      return false;
    }
  }
}
