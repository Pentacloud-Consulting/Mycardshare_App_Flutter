import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { isMasterAdmin } from "@/lib/roles";
import { connectDB } from "@/backend/config/db";
import { firestoreDb, admin } from "@/backend/config/firebase";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";
import { ObjectId } from "mongodb";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * INDIVIDUAL ACCOUNT DELETION & MASTER ADMIN NOTIFICATION SYNC (APP <-> WEB)
 * 
 * Supports:
 * 1. POST /api/sync/individual-deletion
 *    - action: "request_deletion"
 *      - Individual user requests account deletion from mobile/web settings.
 *      - Records request in Firestore 'account_deletion_requests' & MongoDB.
 *      - Dispatches real In-App Notification & Push Alert to Master Admin.
 * 
 *    - action: "confirm_delete" (Master Admin Action)
 *      - Permanently deletes or soft-deactivates user from Firebase Auth, Firestore 'users', and MongoDB 'cards'.
 *      - Marks deletion request as "completed".
 * 
 *    - action: "reject_deletion" (Master Admin Action)
 *      - Rejects deletion request with a reason.
 * 
 * 2. GET /api/sync/individual-deletion
 *    - Master Admin: Lists all pending account deletion requests for the Individuals Screen.
 *    - Individual User: Checks current status of their deletion request.
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;
  const role = context.user?.role;
  const db = await connectDB();

  // =========================================================================
  // 1. MASTER ADMIN VIEW: List all deletion requests
  // =========================================================================
  if (isMasterAdmin(role)) {
    let rawDocs: any[] = [];
    try {
      const snap = await firestoreDb
        .collection("account_deletion_requests")
        .limit(100)
        .get();
      rawDocs = snap.docs.map((doc) => ({
        id: doc.id,
        requestId: doc.id,
        ...doc.data(),
        requestedAt: doc.data().requestedAt?.toDate?.()?.toISOString?.() || doc.data().requestedAt || new Date().toISOString(),
      }));
    } catch (err) {
      console.warn("⚠️ [Deletion Requests] Firestore fetch warning:", err);
    }

    // Sort in memory by requestedAt desc (safe from index requirement)
    rawDocs.sort((a, b) => new Date(b.requestedAt).getTime() - new Date(a.requestedAt).getTime());

    const pendingRequests = rawDocs.filter((r: any) => r.status === "pending" || !r.status);

    return NextResponse.json(
      success({
        totalRequests: pendingRequests.length,
        requests: pendingRequests,
      })
    );
  }

  // =========================================================================
  // 2. INDIVIDUAL USER VIEW: Check own deletion status
  // =========================================================================
  let userRequests: any[] = [];
  try {
    const userSnap = await firestoreDb
      .collection("account_deletion_requests")
      .where("userId", "==", uid)
      .limit(10)
      .get();
    userRequests = userSnap.docs.map((d) => ({ id: d.id, ...d.data() }));
  } catch (err) {
    console.warn("⚠️ [Deletion User Check] Firestore warning:", err);
  }

  if (userRequests.length === 0) {
    return NextResponse.json(
      success({
        hasDeletionRequest: false,
        status: "NONE",
      })
    );
  }

  userRequests.sort((a, b) => {
    const tA = new Date(a.requestedAt?.toDate?.() || a.requestedAt || 0).getTime();
    const tB = new Date(b.requestedAt?.toDate?.() || b.requestedAt || 0).getTime();
    return tB - tA;
  });

  const reqData = userRequests[0];
  return NextResponse.json(
    success({
      hasDeletionRequest: true,
      requestId: reqData.id,
      status: reqData.status || "pending",
      reason: reqData.reason || "",
      requestedAt: reqData.requestedAt?.toDate?.()?.toISOString?.() || reqData.requestedAt,
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;
  const body = await request.json();
  const { action = "request_deletion" } = body;
  const db = await connectDB();

  // =========================================================================
  // 1. INDIVIDUAL USER SUBMITS DELETION REQUEST
  // =========================================================================
  if (action === "request_deletion") {
    const { reason = "User requested account deletion", feedback = "" } = body;

    const userDoc = await firestoreDb.collection("users").doc(uid).get();
    const userData = userDoc.exists ? userDoc.data() : {};
    const userName = userData?.displayName || userData?.fullName || "Individual User";
    const userEmail = context.auth?.email || userData?.email || "";

    const cardDoc = await db.collection("cards").findOne({ userId: uid });

    const deletionPayload = {
      userId: uid,
      userName,
      userEmail,
      cardSlug: cardDoc?.slug || uid,
      role: userData?.role || "individual",
      reason,
      feedback,
      status: "pending", // "pending" | "completed" | "rejected"
      requestedAt: new Date(),
    };

    // 1. Save in Firestore 'account_deletion_requests'
    const docRef = await firestoreDb.collection("account_deletion_requests").add(deletionPayload);

    // 2. Mirror into MongoDB
    await db.collection("account_deletion_requests").insertOne({
      ...deletionPayload,
      _id: docRef.id,
    });

    // 3. Mark user status in Firestore & MongoDB as 'deletion_pending'
    await Promise.all([
      firestoreDb.collection("users").doc(uid).set({ status: "deletion_pending" }, { merge: true }),
      db.collection("cards").updateOne({ userId: uid }, { $set: { status: "deletion_pending", cardStatus: "Draft" } }),
    ]);

    // 4. DISPATCH REAL IN-APP NOTIFICATION & PUSH TO MASTER ADMINS
    try {
      const notifDoc = {
        title: "Account Deletion Request ⚠️",
        body: `${userName} (${userEmail}) has requested to delete their account. Reason: "${reason}"`,
        type: "account_deletion",
        targetRole: "master_admin",
        data: {
          requestId: docRef.id,
          userId: uid,
          userEmail,
          userName,
          reason,
        },
        isRead: false,
        createdAt: new Date(),
      };

      // Add to notifications collection for Master Admin
      await Promise.all([
        db.collection("notifications").insertOne(notifDoc),
        firestoreDb.collection("notifications").add(notifDoc),
      ]);

      // Push FCM Notification to all Master Admin devices
      if (admin) {
        const masterAdmins = await firestoreDb.collection("users").where("role", "==", "master_admin").get();
        const masterUids = masterAdmins.docs.map((d) => d.id);

        if (masterUids.length > 0) {
          const tokens = await db.collection("fcm_tokens").find({ userId: { $in: masterUids } }).toArray();
          if (tokens.length > 0) {
            const regTokens = tokens.map((t) => t.fcmToken);
            await admin.messaging().sendEachForMulticast({
              notification: {
                title: notifDoc.title,
                body: notifDoc.body,
              },
              data: {
                requestId: docRef.id,
                type: "account_deletion",
              },
              tokens: regTokens,
            });
          }
        }
      }
    } catch (notifErr: any) {
      console.warn("[Deletion Sync] Master Admin notification dispatch warning:", notifErr.message);
    }

    return NextResponse.json(
      success({
        requestId: docRef.id,
        status: "pending",
        message: "Your deletion request has been submitted. Master Admin will process it within 24 hours.",
      })
    );
  }

  // Master Admin role check for confirming or rejecting
  const role = context.user?.role;
  if (!isMasterAdmin(role)) {
    throw new AppError("Access denied: Master Admin authorization required.", 403);
  }

  // =========================================================================
  // 2. MASTER ADMIN CONFIRMS DELETION
  // =========================================================================
  if (
    action === "confirm_delete" ||
    action === "delete" ||
    action === "permanently_delete"
  ) {
    let requestId = body.requestId || body.id;
    let targetUserId = body.targetUserId || body.userId;

    if (!targetUserId && requestId) {
      const rSnap = await firestoreDb.collection("account_deletion_requests").doc(requestId).get();
      if (rSnap.exists) {
        targetUserId = rSnap.data()?.userId;
      }
    }

    if (!requestId && targetUserId) {
      const rSnap = await firestoreDb
        .collection("account_deletion_requests")
        .where("userId", "==", targetUserId)
        .where("status", "==", "pending")
        .limit(1)
        .get();
      if (!rSnap.empty) {
        requestId = rSnap.docs[0].id;
      }
    }

    if (!targetUserId && !requestId) {
      throw new AppError("Either requestId or targetUserId is required.", 400);
    }

    // 1. Delete or Deactivate User in Firebase Auth
    if (targetUserId) {
      try {
        await admin.auth().deleteUser(targetUserId);
      } catch (authErr: any) {
        console.warn("[Deletion Sync] Firebase Auth delete warning:", authErr.message);
      }
    }

    // 2. Update status in Firestore & MongoDB
    const promises: Promise<any>[] = [];
    if (targetUserId) {
      promises.push(firestoreDb.collection("users").doc(targetUserId).delete());
      promises.push(db.collection("cards").deleteOne({ userId: targetUserId }));
      promises.push(db.collection("leads").deleteMany({ userId: targetUserId }));
    }
    if (requestId) {
      promises.push(
        firestoreDb.collection("account_deletion_requests").doc(requestId).update({
          status: "completed",
          completedAt: new Date(),
          completedBy: uid,
        })
      );
      promises.push(
        db.collection("account_deletion_requests").updateOne(
          { _id: requestId },
          { $set: { status: "completed", completedAt: new Date(), completedBy: uid } }
        )
      );
    }

    await Promise.all(promises);

    return NextResponse.json(
      success({
        message: `User account ${targetUserId || requestId} has been permanently deleted and purged from database.`,
        requestId,
        targetUserId,
      })
    );
  }

  // =========================================================================
  // 3. MASTER ADMIN REJECTS DELETION
  // =========================================================================
  if (action === "reject_deletion" || action === "reject") {
    let requestId = body.requestId || body.id;
    let targetUserId = body.targetUserId || body.userId;
    const rejectReason = body.rejectReason || body.reason || "Rejected by platform admin";

    if (!targetUserId && requestId) {
      const rSnap = await firestoreDb.collection("account_deletion_requests").doc(requestId).get();
      if (rSnap.exists) {
        targetUserId = rSnap.data()?.userId;
      }
    }

    const promises: Promise<any>[] = [];
    if (targetUserId) {
      promises.push(firestoreDb.collection("users").doc(targetUserId).set({ status: "active" }, { merge: true }));
      promises.push(db.collection("cards").updateOne({ userId: targetUserId }, { $set: { status: "active" } }));
    }
    if (requestId) {
      promises.push(
        firestoreDb.collection("account_deletion_requests").doc(requestId).update({
          status: "rejected",
          rejectReason,
          rejectedAt: new Date(),
        })
      );
      promises.push(
        db.collection("account_deletion_requests").updateOne(
          { _id: requestId },
          { $set: { status: "rejected", rejectReason, rejectedAt: new Date() } }
        )
      );
    }

    await Promise.all(promises);

    return NextResponse.json(
      success({ message: "Deletion request rejected. User restored to active state." })
    );
  }

  throw new AppError(`Unknown action: ${action}`, 400);
});

export const PATCH = POST;
export const DELETE = POST;

