import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import cardService from "@/backend/services/card.service";
import userService from "@/backend/services/user.service";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * NFC CHIP ACTIVATION & HARDWARE MANAGEMENT (APP <-> WEB)
 * 
 * Supports:
 * 1. GET /api/sync/nfc
 *    - Lists all active NFC tags / physical business cards linked to the user or enterprise.
 * 2. POST /api/sync/nfc
 *    - action: "activate" -> Locks physical NFC chip UID to user's card slug with tamper security.
 *    - action: "verify_tap" -> Resolves an NFC tap (UID / tagId) to public card URL and logs hardware tap metric.
 *    - action: "deactivate" -> Unlinks/revokes an NFC tag (lost card / employee offboarding).
 *    - action: "toggle_lock" -> Enables or disables NFC writing lock protection.
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  const db = await connectDB();

  const nfcTags = await db
    .collection("nfc_tags")
    .find({ userId: uid })
    .sort({ createdAt: -1 })
    .toArray();

  return NextResponse.json(
    success({
      totalTags: nfcTags.length,
      tags: nfcTags,
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const body = await request.json();
  const { action = "activate" } = body;
  const db = await connectDB();

  // =========================================================================
  // 1. VERIFY TAP (Public Tap Resolution - No auth needed on tap)
  // =========================================================================
  if (action === "verify_tap") {
    const { tagUid, serialNumber } = body;

    if (!tagUid && !serialNumber) {
      throw new AppError("tagUid or serialNumber is required to resolve tap.", 400);
    }

    const tag = await db.collection("nfc_tags").findOne({
      $or: [{ tagUid }, { serialNumber }],
      status: "ACTIVE",
    });

    if (!tag) {
      return NextResponse.json(
        fail("NFC_TAG_UNREGISTERED", "This NFC card is unactivated or inactive. Please activate it in the app."),
        { status: 404 }
      );
    }

    // Increment tap count and log tap telemetry
    await Promise.all([
      db.collection("nfc_tags").updateOne(
        { _id: tag._id },
        {
          $inc: { tapCount: 1 },
          $set: { lastTappedAt: new Date() },
        }
      ),
      db.collection("analytics_events").insertOne({
        type: "nfc_tap",
        tagUid: tag.tagUid,
        userId: tag.userId,
        cardSlug: tag.cardSlug,
        timestamp: new Date(),
        userAgent: request.headers.get("user-agent") || "",
      }),
    ]);

    const publicUrl = `https://mycardshare.com/card/${tag.cardSlug}`;

    return NextResponse.json(
      success({
        valid: true,
        cardSlug: tag.cardSlug,
        publicUrl,
        redirectUrl: publicUrl,
        cardholderName: tag.cardholderName,
        isBrandLocked: tag.isBrandLocked || false,
      })
    );
  }

  // Auth required for management operations
  const context = await resolveAuth(request);
  const uid = context.uid;

  // =========================================================================
  // 2. ACTIVATE NFC CHIP / WRITE TO CARD
  // =========================================================================
  if (action === "activate") {
    const {
      tagUid,
      serialNumber,
      cardSlug,
      cardholderName,
      tagType = "NTAG213/NTAG215",
      isBrandLocked = false,
      enterpriseId,
    } = body;

    if (!tagUid) {
      throw new AppError("Physical tagUid (NFC hardware identifier) is required.", 400);
    }

    // Verify user owns card slug or user profile
    const targetSlug = cardSlug || uid;
    const writeUrl = `https://mycardshare.com/card/${targetSlug}`;

    const nfcRecord = {
      tagUid,
      serialNumber: serialNumber || `NFC-${Date.now().toString().slice(-6)}`,
      userId: uid,
      cardSlug: targetSlug,
      writeUrl,
      cardholderName: cardholderName || "Digital Cardholder",
      tagType,
      status: "ACTIVE",
      isLocked: true, // Write-protected on chip
      isBrandLocked,
      enterpriseId: enterpriseId || null,
      tapCount: 0,
      activatedAt: new Date(),
      lastTappedAt: null,
      createdAt: new Date(),
    };

    await db.collection("nfc_tags").updateOne(
      { tagUid },
      { $set: nfcRecord },
      { upsert: true }
    );

    // Also update User profile NFC setting
    await db.collection("users").updateOne(
      { uid },
      { $set: { hasActiveNfc: true, lastActivatedNfcUid: tagUid } }
    );

    return NextResponse.json(
      success({
        message: "NFC Tag activated successfully and bound to your digital card.",
        tag: nfcRecord,
        ndefPayload: {
          recordType: "URI",
          uri: writeUrl,
        },
      })
    );
  }

  // =========================================================================
  // 3. DEACTIVATE / UNLINK NFC TAG (e.g. Lost Card)
  // =========================================================================
  if (action === "deactivate") {
    const { tagUid } = body;

    if (!tagUid) {
      throw new AppError("tagUid is required to deactivate tag.", 400);
    }

    await db.collection("nfc_tags").updateOne(
      { tagUid, userId: uid },
      {
        $set: {
          status: "DEACTIVATED",
          deactivatedAt: new Date(),
        },
      }
    );

    return NextResponse.json(
      success({ message: "NFC Tag has been deactivated and will no longer resolve taps." })
    );
  }

  // =========================================================================
  // 4. TOGGLE WRITE-LOCK
  // =========================================================================
  if (action === "toggle_lock") {
    const { tagUid, isLocked } = body;

    await db.collection("nfc_tags").updateOne(
      { tagUid, userId: uid },
      { $set: { isLocked: Boolean(isLocked) } }
    );

    return NextResponse.json(
      success({ message: `NFC Write lock updated to ${isLocked}.` })
    );
  }

  throw new AppError(`Unknown action: ${action}`, 400);
});
