import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { connectDB } from "@/backend/config/db";
import { firestoreDb } from "@/backend/config/firebase";
import { isMasterAdmin } from "@/lib/roles";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

/**
 * RESERVED SYSTEM KEYWORDS (Never allowed as user or company slug)
 */
export const RESERVED_SLUGS = new Set([
  "admin",
  "master-admin",
  "enterprise",
  "portal",
  "api",
  "login",
  "signup",
  "join-workspace",
  "onboarding",
  "reset-password",
  "card",
  "cards",
  "company",
  "about",
  "features",
  "pricing",
  "contact",
  "blog",
  "privacy",
  "terms",
  "settings",
  "dashboard",
  "static",
  "public",
  "support",
  "app",
  "auth",
  "root",
]);

/**
 * Helper to slugify any string safely
 */
export function slugify(text: string): string {
  return String(text || "")
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, "") // remove special chars
    .replace(/[\s_-]+/g, "-") // collapse dashes and spaces
    .replace(/^-+|-+$/g, ""); // trim leading/trailing dashes
}

/**
 * SLUG RESOLVER & VALIDATION API (MOBILE APP <-> NEXT.JS WEB)
 *
 * GET /api/sync/slug?slug=zuhaib-khan&type=individual
 * 
 * Query Params:
 * - slug: Candidate slug string to check or resolve
 * - type: "individual" | "enterprise" | "employee"
 * - uid: (Optional) caller user ID to ignore collision against themselves
 * 
 * Returns:
 * - isAvailable: boolean
 * - isReserved: boolean
 * - resolvedUrl: "https://mycardshare.com/card/<slug>"
 * - suggestedSlug: Unique alternative if collision exists (e.g., "zuhaib-khan-102")
 */
export const GET = apiAdapter(async (request: NextRequest) => {
  const { searchParams } = new URL(request.url);
  const rawSlug = searchParams.get("slug");
  const type = searchParams.get("type") || "individual";
  const callerUid = searchParams.get("uid") || "";

  if (!rawSlug) {
    return NextResponse.json(
      fail("SLUG_REQUIRED", "Query parameter 'slug' is required"),
      { status: 400 }
    );
  }

  const cleanSlug = slugify(rawSlug);

  if (cleanSlug.length < 3) {
    return NextResponse.json(
      fail("SLUG_TOO_SHORT", "Slug must be at least 3 characters long"),
      { status: 400 }
    );
  }

  // 1. Check if slug matches reserved system routes
  if (RESERVED_SLUGS.has(cleanSlug)) {
    return NextResponse.json(
      success({
        slug: cleanSlug,
        isAvailable: false,
        isReserved: true,
        reason: "This slug is a reserved system keyword. Please pick another one.",
        suggestedSlug: `${cleanSlug}-${Math.floor(100 + Math.random() * 900)}`,
        resolvedUrl: null,
      })
    );
  }

  // 2. Check collision in Firestore & MongoDB
  const db = await connectDB();
  let isTaken = false;
  let ownerType: "individual" | "enterprise" | null = null;
  let matchedCard: any = null;

  // A. Check in MongoDB Cards
  const existingCard = await db.collection("cards").findOne({ cardSlug: cleanSlug });
  if (existingCard && existingCard.userId !== callerUid) {
    isTaken = true;
    ownerType = existingCard.companyId ? "enterprise" : "individual";
    matchedCard = existingCard;
  }

  // B. Check in Firestore Users
  if (!isTaken) {
    const firestoreUserConflict = await firestoreDb
      .collection("users")
      .where("cardSlug", "==", cleanSlug)
      .limit(1)
      .get();

    if (!firestoreUserConflict.empty && firestoreUserConflict.docs[0].id !== callerUid) {
      isTaken = true;
      ownerType = "individual";
    }
  }

  // C. Check in Firestore Companies
  if (!isTaken) {
    const companyConflict = await firestoreDb
      .collection("companies")
      .where("slug", "==", cleanSlug)
      .limit(1)
      .get();

    if (!companyConflict.empty) {
      isTaken = true;
      ownerType = "enterprise";
    }
  }

  // If taken, generate guaranteed available suggestions
  let suggestedSlug = cleanSlug;
  if (isTaken) {
    let suffix = 1;
    let found = false;
    while (!found && suffix < 50) {
      const candidate = `${cleanSlug}-${suffix}`;
      const conflict = await db.collection("cards").findOne({ cardSlug: candidate });
      if (!conflict) {
        suggestedSlug = candidate;
        found = true;
      }
      suffix++;
    }
  }

  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || "https://mycardshare.com";
  const publicPath = ownerType === "enterprise" && type === "enterprise"
    ? `${baseUrl}/company/${cleanSlug}`
    : `${baseUrl}/card/${cleanSlug}`;

  return NextResponse.json(
    success({
      slug: cleanSlug,
      isAvailable: !isTaken,
      isReserved: false,
      ownerType: isTaken ? ownerType : null,
      suggestedSlug: isTaken ? suggestedSlug : cleanSlug,
      resolvedUrl: publicPath,
      cardDetails: matchedCard
        ? {
            fullName: matchedCard.fullName,
            jobTitle: matchedCard.jobTitle,
            companyName: matchedCard.companyName,
            avatarUrl: matchedCard.avatarUrl,
            cardStatus: matchedCard.cardStatus || "Published",
          }
        : null,
    })
  );
});

/**
 * POST /api/sync/slug
 * 
 * Auto-Generate & Claim Unique Slug on Registration / Profile Update
 * Body: { fullName: "Zuhaib Khan", companyName?: "TCS", role: "individual" | "enterprise" | "employee" }
 */
export const POST = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;
  const body = await request.json();

  const { fullName, companyName, desiredSlug, role = "individual" } = body || {};

  // Form base string
  let baseString = desiredSlug;
  if (!baseString) {
    if (role === "employee" && companyName) {
      baseString = `${fullName || "member"}-${companyName}`;
    } else if (role === "enterprise") {
      baseString = companyName || fullName || "company";
    } else {
      baseString = fullName || "card";
    }
  }

  let candidateSlug = slugify(baseString);
  if (candidateSlug.length < 3) candidateSlug = `card-${uid.slice(-5)}`;

  // Disallow reserved
  if (RESERVED_SLUGS.has(candidateSlug)) {
    candidateSlug = `${candidateSlug}-${Math.floor(100 + Math.random() * 900)}`;
  }

  // Ensure uniqueness across database
  const db = await connectDB();
  let finalSlug = candidateSlug;
  let counter = 1;

  while (true) {
    const cardConflict = await db.collection("cards").findOne({ cardSlug: finalSlug, userId: { $ne: uid } });
    const userConflict = await firestoreDb
      .collection("users")
      .where("cardSlug", "==", finalSlug)
      .limit(1)
      .get();
    const hasUserConflict = !userConflict.empty && userConflict.docs[0].id !== uid;

    if (!cardConflict && !hasUserConflict) {
      break; // Unique slug found!
    }

    finalSlug = `${candidateSlug}-${counter}`;
    counter++;
  }

  // Persist claimed slug to user and card
  await firestoreDb.collection("users").doc(uid).set(
    { cardSlug: finalSlug, updatedAt: new Date() },
    { merge: true }
  );

  await db.collection("cards").updateOne(
    { userId: uid },
    { $set: { cardSlug: finalSlug, lastUpdated: new Date() } },
    { upsert: true }
  );

  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || "https://mycardshare.com";

  return NextResponse.json(
    success({
      message: "Slug successfully generated and claimed",
      cardSlug: finalSlug,
      publicUrl: `${baseUrl}/card/${finalSlug}`,
    })
  );
});

/**
 * PATCH /api/sync/slug
 * 
 * Master Admin Override & Moderation API
 * Allows Super Admin to re-assign or release trademark-infringing slugs
 */
export const PATCH = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const role = context.user?.role;

  if (!isMasterAdmin(role)) {
    throw new AppError("Access denied: Master Admin role required for slug overrides", 403);
  }

  const body = await request.json();
  const { targetUserId, newSlug, reason } = body || {};

  if (!targetUserId || !newSlug) {
    return NextResponse.json(
      fail("MISSING_FIELDS", "targetUserId and newSlug are required"),
      { status: 400 }
    );
  }

  const cleanSlug = slugify(newSlug);
  if (RESERVED_SLUGS.has(cleanSlug)) {
    return NextResponse.json(
      fail("RESERVED_SLUG", "Cannot assign reserved system keyword as user slug"),
      { status: 400 }
    );
  }

  const db = await connectDB();
  const conflict = await db.collection("cards").findOne({ cardSlug: cleanSlug, userId: { $ne: targetUserId } });
  if (conflict) {
    return NextResponse.json(
      fail("SLUG_ALREADY_TAKEN", `The slug '${cleanSlug}' is already assigned to another user`),
      { status: 409 }
    );
  }

  // Override in Firestore and MongoDB
  await firestoreDb.collection("users").doc(targetUserId).set(
    {
      cardSlug: cleanSlug,
      slugModeratedBy: context.uid,
      slugModerationReason: reason || "Administrative trademark alignment",
      updatedAt: new Date(),
    },
    { merge: true }
  );

  await db.collection("cards").updateOne(
    { userId: targetUserId },
    { $set: { cardSlug: cleanSlug, lastUpdated: new Date() } }
  );

  return NextResponse.json(
    success({
      message: `Slug successfully overridden to '${cleanSlug}' for user ${targetUserId}`,
      newSlug: cleanSlug,
    })
  );
});
