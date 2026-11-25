import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { connectDB } from "@/backend/config/db";
import { admin } from "@/backend/config/firebase";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * PUSH NOTIFICATIONS & ACTIVITY ALERTS SYNC (APP <-> WEB)
 * 
 * Supports:
 * 1. GET /api/sync/notifications
 *    - Fetches user notification history (Card Scanned, Lead Received, Enterprise Joined, Security Alerts)
 * 2. POST /api/sync/notifications
 *    - action: "register_token" -> Stores mobile FCM Device Token for Push Notifications
 *    - action: "send_alert" -> Triggers immediate push notification via Firebase Admin FCM
 *    - action: "mark_read" -> Marks specific or all notifications as read
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  const url = new URL(request.url);
  const limit = parseInt(url.searchParams.get("limit") || "30", 10);
  const unreadOnly = url.searchParams.get("unreadOnly") === "true";

  const db = await connectDB();

  const query: any = { userId: uid };
  if (unreadOnly) {
    query.isRead = false;
  }

  const notifications = await db
    .collection("notifications")
    .find(query)
    .sort({ createdAt: -1 })
    .limit(limit)
    .toArray();

  const unreadCount = await db.collection("notifications").countDocuments({
    userId: uid,
    isRead: false,
  });

  return NextResponse.json(
    success({
      unreadCount,
      totalCount: notifications.length,
      notifications,
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  const body = await request.json();
  const { action = "register_token" } = body;
  const db = await connectDB();

  // =========================================================================
  // 1. REGISTER FCM DEVICE TOKEN
  // =========================================================================
  if (action === "register_token") {
    const { fcmToken, deviceType = "android", deviceName = "" } = body;

    if (!fcmToken || typeof fcmToken !== "string") {
      throw new AppError("Valid fcmToken is required.", 400);
    }

    await db.collection("fcm_tokens").updateOne(
      { userId: uid, fcmToken },
      {
        $set: {
          userId: uid,
          fcmToken,
          deviceType,
          deviceName,
          updatedAt: new Date(),
        },
      },
      { upsert: true }
    );

    return NextResponse.json(
      success({
        message: "FCM Device Token registered successfully for push alerts.",
        deviceType,
      })
    );
  }

  // =========================================================================
  // 2. DISPATCH LIVE PUSH NOTIFICATION & ACTIVITY ALERT
  // =========================================================================
  if (action === "send_alert") {
    const {
      targetUserId = uid,
      title,
      body: alertBody,
      type = "lead_capture", // "card_view" | "lead_capture" | "team_invite" | "security"
      data = {},
    } = body;

    if (!title || !alertBody) {
      throw new AppError("title and body are required to send an alert.", 400);
    }

    // A. Store in MongoDB Notification Collection
    const notificationDoc = {
      userId: targetUserId,
      title,
      body: alertBody,
      type,
      data,
      isRead: false,
      createdAt: new Date(),
    };

    const insertResult = await db.collection("notifications").insertOne(notificationDoc);

    // B. Send real FCM Push Notification to all active devices of target user
    let pushSentCount = 0;
    try {
      const tokens = await db
        .collection("fcm_tokens")
        .find({ userId: targetUserId })
        .toArray();

      if (tokens.length > 0 && admin) {
        const registrationTokens = tokens.map((t) => t.fcmToken);

        const messagePayload = {
          notification: {
            title,
            body: alertBody,
          },
          data: {
            notificationId: insertResult.insertedId.toString(),
            type,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            ...Object.keys(data).reduce((acc: any, key) => {
              acc[key] = String(data[key]);
              return acc;
            }, {}),
          },
          tokens: registrationTokens,
        };

        const fcmResponse = await admin.messaging().sendEachForMulticast(messagePayload);
        pushSentCount = fcmResponse.successCount;
      }
    } catch (fcmErr: any) {
      console.warn("[Push Sync] FCM dispatch warning:", fcmErr.message);
    }

    return NextResponse.json(
      success({
        notificationId: insertResult.insertedId,
        pushSentCount,
        message: "Notification logged and dispatched.",
      })
    );
  }

  // =========================================================================
  // 3. MARK NOTIFICATION AS READ
  // =========================================================================
  if (action === "mark_read") {
    const { notificationId, markAll = false } = body;

    if (markAll) {
      await db.collection("notifications").updateMany(
        { userId: uid, isRead: false },
        { $set: { isRead: true, readAt: new Date() } }
      );
    } else if (notificationId) {
      const { ObjectId } = require("mongodb");
      await db.collection("notifications").updateOne(
        { _id: new ObjectId(notificationId), userId: uid },
        { $set: { isRead: true, readAt: new Date() } }
      );
    }

    return NextResponse.json(
      success({ message: "Notifications marked as read." })
    );
  }

  throw new AppError(`Unknown action: ${action}`, 400);
});
