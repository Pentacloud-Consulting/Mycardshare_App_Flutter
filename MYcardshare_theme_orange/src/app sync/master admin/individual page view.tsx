import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { isMasterAdmin } from "@/lib/roles";
import { connectDB } from "@/backend/config/db";
import { firestoreDb, admin } from "@/backend/config/firebase";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * MASTER ADMIN INDIVIDUALS SCREEN SYNC API (MOBILE APP <-> NEXT.JS WEB)
 * 
 * Fetches:
 * 1. Metrics:
 *    - Total Individuals
 *    - Active Users (Published digital card & active status)
 *    - Deactivated / Pending Deletion Users
 * 2. Filter Pills:
 *    - 'all': All individual users
 *    - 'free': Users on Free tier
 *    - 'pro': Users with Pro subscription
 *    - 'deactivated': Users with status 'inactive', 'deactivated', or 'deletion_pending'
 * 3. Search:
 *    - Searches across name, email, phone, cardSlug
 * 4. Deletion Requests & Actions:
 *    - Direct account deletion or deactivation by Master Admin
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const role = context.user?.role;

  if (!isMasterAdmin(role)) {
    throw new AppError("Access denied: Master Admin authorization required", 403);
  }

  const { searchParams } = new URL(request.url);
  const filter = searchParams.get("filter") || "all";
  const search = (searchParams.get("search") || "").trim().toLowerCase();

  const db = await connectDB();

  // ── 1. Fetch all Firestore Users ──────────────────────────────────────────
  const usersSnap = await firestoreDb.collection("users").get();
  const individualDocs: any[] = [];

  usersSnap.forEach((doc) => {
    const data = doc.data();
    // Exclude users belonging to corporate enterprises or system admins
    if (data.companyId) return;
    if (["master_admin", "platform_admin", "super_admin"].includes(data.role)) return;

    individualDocs.push({
      id: doc.id,
      userId: doc.id,
      ...data,
    });
  });

  const userIds = individualDocs.map((u) => u.userId);

  // ── 2. Batch Fetch Firebase Auth emails/phones ─────────────────────────────
  const emailMap: Record<string, string> = {};
  try {
    const chunks: string[][] = [];
    for (let i = 0; i < userIds.length; i += 100) {
      chunks.push(userIds.slice(i, i + 100));
    }
    const results = await Promise.all(
      chunks.map((chunk) =>
        admin.auth().getUsers(chunk.map((uid) => ({ uid }))).catch(() => ({ users: [] }))
      )
    );
    for (const res of results) {
      for (const u of res.users || []) {
        if (u.email) emailMap[u.uid] = u.email;
      }
    }
  } catch (e) {
    console.warn("⚠️ [Master Admin Individuals] Auth batch lookup warning:", e);
  }

  // ── 3. Fetch MongoDB Cards for these users ─────────────────────────────────
  const cardMap: Record<string, any> = {};
  try {
    const cards = await db
      .collection("cards")
      .find({ userId: { $in: userIds } })
      .toArray();

    for (const card of cards) {
      cardMap[card.userId] = card;
    }
  } catch (e) {
    console.warn("⚠️ [Master Admin Individuals] MongoDB cards fetch warning:", e);
  }

  // ── 4. Fetch Pending Account Deletion Requests ─────────────────────────────
  const deletionMap: Record<string, any> = {};
  try {
    const deletionSnap = await firestoreDb
      .collection("account_deletion_requests")
      .where("status", "==", "pending")
      .get();

    deletionSnap.forEach((doc) => {
      const d = doc.data();
      if (d.userId) {
        deletionMap[d.userId] = {
          requestId: doc.id,
          reason: d.reason || "User requested account deletion",
          requestedAt: d.requestedAt?.toDate?.()?.toISOString?.() || d.requestedAt || new Date().toISOString(),
        };
      }
    });
  } catch (e) {
    console.warn("⚠️ [Master Admin Individuals] Deletion requests lookup warning:", e);
  }

  // ── 5. Assemble and Standardize Individual User List ───────────────────────
  let totalCount = 0;
  let activeCount = 0;
  let deactivatedCount = 0;

  const allIndividuals = individualDocs.map((user) => {
    const card = cardMap[user.userId] || {};
    const email = emailMap[user.userId] || user.email || user.workEmail || card.workEmail || "No Email";
    const fullName = user.displayName || user.fullName || card.fullName || "Individual User";
    const phone = user.phone || user.phoneNumber || card.phone || card.workPhone || "";
    const cardSlug = user.cardSlug || card.slug || card.cardSlug || "";
    const avatarUrl = user.avatarUrl || user.photoURL || card.avatarUrl || null;

    // Check plan & status
    const plan = (user.subscriptionPlan || user.plan || card.plan || "free").toLowerCase();
    const isPro = plan.includes("pro") || plan.includes("premium");

    const isPendingDeletion = Boolean(deletionMap[user.userId] || user.status === "deletion_pending");
    const isDeactivated = isPendingDeletion || user.status === "inactive" || user.status === "deactivated";
    const isActive = !isDeactivated && (user.status === "active" || card.cardStatus === "Published");

    totalCount++;
    if (isDeactivated) deactivatedCount++;
    else if (isActive) activeCount++;

    return {
      id: user.userId,
      userId: user.userId,
      fullName,
      email,
      phone,
      username: cardSlug || user.userId,
      cardSlug,
      avatarUrl,
      plan: isPro ? "Pro" : "Free",
      isPro,
      status: isPendingDeletion ? "DELETION_PENDING" : isDeactivated ? "DEACTIVATED" : "ACTIVE",
      profileStatus: isActive ? "ACTIVE" : "DRAFT",
      deletionRequest: deletionMap[user.userId] || null,
      createdAt: user.createdAt?.toDate?.()?.toISOString?.() || user.createdAt || new Date().toISOString(),
      updatedAt: user.updatedAt?.toDate?.()?.toISOString?.() || user.updatedAt || new Date().toISOString(),
    };
  });

  // ── 6. Filter by Status Pill ──────────────────────────────────────────────
  let filtered = allIndividuals;
  if (filter === "active") {
    filtered = filtered.filter((u) => u.status === "ACTIVE");
  } else if (filter === "deactivated") {
    filtered = filtered.filter((u) => u.status === "DEACTIVATED" || u.status === "DELETION_PENDING");
  } else if (filter === "pro") {
    filtered = filtered.filter((u) => u.isPro);
  } else if (filter === "free") {
    filtered = filtered.filter((u) => !u.isPro);
  }

  // ── 7. Text Search ────────────────────────────────────────────────────────
  if (search) {
    filtered = filtered.filter((u) =>
      u.fullName.toLowerCase().includes(search) ||
      u.email.toLowerCase().includes(search) ||
      u.phone.toLowerCase().includes(search) ||
      u.cardSlug.toLowerCase().includes(search)
    );
  }

  return NextResponse.json(
    success({
      metrics: {
        total: totalCount,
        active: activeCount,
        deactivated: deactivatedCount,
      },
      individuals: filtered,
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const role = context.user?.role;

  if (!isMasterAdmin(role)) {
    throw new AppError("Access denied: Master Admin authorization required", 403);
  }

  const body = await request.json();
  const { action, userId } = body;

  if (!userId) {
    return NextResponse.json(fail("USER_ID_REQUIRED", "User ID is required"), { status: 400 });
  }

  const db = await connectDB();

  // 1. ACTION: CONFIRM DELETION / PERMANENT REMOVAL
  if (action === "confirm_delete" || action === "delete") {
    try {
      await admin.auth().deleteUser(userId).catch(() => {});
    } catch (e) {}

    await Promise.all([
      firestoreDb.collection("users").doc(userId).delete().catch(() => {}),
      db.collection("cards").deleteMany({ userId }).catch(() => {}),
      db.collection("leads").deleteMany({ userId }).catch(() => {}),
      firestoreDb.collection("account_deletion_requests").where("userId", "==", userId).get().then((snap) => {
        snap.forEach((doc) => doc.ref.update({ status: "completed", resolvedAt: new Date() }));
      }).catch(() => {}),
    ]);

    return NextResponse.json(success({ userId }, "Individual account permanently deleted"));
  }

  // 2. ACTION: TOGGLE DEACTIVATE / REACTIVATE
  if (action === "toggle_status") {
    const { status } = body; // 'active' or 'deactivated'
    const newStatus = status === "active" ? "active" : "deactivated";

    await Promise.all([
      firestoreDb.collection("users").doc(userId).set({ status: newStatus }, { merge: true }),
      db.collection("cards").updateOne({ userId }, { $set: { status: newStatus } }),
    ]);

    return NextResponse.json(success({ userId, status: newStatus }, `User marked as ${newStatus}`));
  }

  return NextResponse.json(fail("INVALID_ACTION", "Supported actions: confirm_delete, toggle_status"), { status: 400 });
});
