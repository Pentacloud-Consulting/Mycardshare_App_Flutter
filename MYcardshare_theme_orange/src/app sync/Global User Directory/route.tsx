import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { connectDB } from "@/backend/config/db";
import { firestoreDb, admin } from "@/backend/config/firebase";
import { isMasterAdmin } from "@/lib/roles";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * GLOBAL CROSS-PLATFORM DIRECTORY & LOGIN AUDIT SYNC (WEB <-> APP)
 * 
 * Problem Solved:
 * "Web me bohot saare Individual, Enterprise aur Employee users logged in hain,
 *  lekin Mobile App me wo sync nahi ho rahe the."
 * 
 * Target Endpoints:
 * 1. GET /api/sync/global-directory
 *    - Master Admin / Enterprise View: Real-time aggregated directory of ALL active users
 *      across Web and Mobile apps, combined from Firestore ('users', 'companies') AND MongoDB ('cards', 'leads').
 * 
 * 2. POST /api/sync/global-directory
 *    - action: "app_session_heartbeat" -> Mobile app launch par call hoti hai, user ko 'online_app' mark karti hai
 *    - action: "resolve_user_role" -> Web credentials se login hone par user ka exact role (individual, employee, enterprise_admin, master_admin) resolve karti hai
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  let context: any = null;
  try {
    context = await resolveAuth(request);
  } catch (e) {
    // Allows public diagnostic or filtered query
  }

  const url = new URL(request.url);
  const targetRole = url.searchParams.get("role") || "all"; // "all" | "individual" | "employee" | "enterprise"
  const searchQuery = url.searchParams.get("query")?.toLowerCase() || "";
  const limit = parseInt(url.searchParams.get("limit") || "100", 10);

  const db = await connectDB();

  // ── 1. Fetch all Firestore Users ──────────────────────────────────
  const firestoreUsersMap: Record<string, any> = {};
  try {
    const usersSnap = await firestoreDb.collection("users").get();
    usersSnap.forEach((doc) => {
      const d = doc.data();
      firestoreUsersMap[doc.id] = {
        uid: doc.id,
        email: d.email || "",
        displayName: d.displayName || d.name || "",
        role: d.role || "individual",
        companyId: d.companyId || null,
        companyName: d.companyName || null,
        photoURL: d.photoURL || d.avatarUrl || null,
        status: d.status || "active",
        createdAt: d.createdAt?.toDate?.()?.toISOString?.() || d.createdAt || null,
        lastLoginPlatform: d.lastLoginPlatform || "web",
      };
    });
  } catch (err: any) {
    console.warn("[Global Directory] Firestore users fetch warning:", err.message);
  }

  // ── 2. Fetch all MongoDB Cards (Physical Digital Cards) ───────────
  let mongoCards: any[] = [];
  try {
    mongoCards = await db
      .collection("cards")
      .find({})
      .sort({ updatedAt: -1 })
      .limit(limit)
      .toArray();
  } catch (err: any) {
    console.warn("[Global Directory] MongoDB cards fetch warning:", err.message);
  }

  // ── 3. Fetch Enterprises from Firestore ───────────────────────────
  const enterprisesMap: Record<string, any> = {};
  try {
    const compSnap = await firestoreDb.collection("companies").get();
    compSnap.forEach((doc) => {
      const d = doc.data();
      enterprisesMap[doc.id] = {
        id: doc.id,
        name: d.companyName || "Enterprise",
        brandColor: d.brandColor || "#0052FF",
        logo: d.companyLogo || null,
        adminEmail: d.adminEmail || "",
        totalEmployees: d.totalEmployees || 0,
        status: d.status || "active",
      };
    });
  } catch (err: any) {
    console.warn("[Global Directory] Firestore companies warning:", err.message);
  }

  // ── 4. Unified Merge & Normalization ──────────────────────────────
  const unifiedUserList: any[] = [];

  // Add all MongoDB cardholders
  for (const card of mongoCards) {
    const uid = card.userId || card.uid;
    const fsProfile = firestoreUsersMap[uid] || {};

    let userRole = card.companyId ? "employee" : (fsProfile.role || "individual");
    if (fsProfile.role === "master_admin" || fsProfile.role === "super_admin") {
      userRole = "master_admin";
    }

    const companyInfo = card.companyId ? enterprisesMap[card.companyId] : null;

    unifiedUserList.push({
      uid,
      cardId: card._id.toString(),
      cardSlug: card.slug || uid,
      fullName: card.fullName || card.name || fsProfile.displayName || "Active User",
      email: card.email || card.workEmail || fsProfile.email || "",
      phone: card.phone || card.workPhone || "",
      jobTitle: card.jobTitle || card.title || "",
      companyName: companyInfo?.name || card.companyName || fsProfile.companyName || "",
      companyId: card.companyId || fsProfile.companyId || null,
      avatarUrl: card.avatarUrl || fsProfile.photoURL || null,
      role: userRole,
      status: card.cardStatus || fsProfile.status || "active",
      isPublished: card.isPublished ?? true,
      views: card.views || 0,
      shares: card.shares || 0,
      sourceOrigin: card.companyId ? "corporate_seat" : "individual_cloud",
      registeredAt: card.createdAt || fsProfile.createdAt || new Date().toISOString(),
      webAccess: true,
      appAccess: true,
    });
  }

  // Filter by Role & Search Query
  let filtered = unifiedUserList;
  if (targetRole !== "all") {
    filtered = filtered.filter((u) => u.role === targetRole);
  }

  if (searchQuery) {
    filtered = filtered.filter(
      (u) =>
        u.fullName.toLowerCase().includes(searchQuery) ||
        u.email.toLowerCase().includes(searchQuery) ||
        u.companyName.toLowerCase().includes(searchQuery) ||
        u.cardSlug.toLowerCase().includes(searchQuery)
    );
  }

  // Summary Metrics
  const individualCount = unifiedUserList.filter((u) => u.role === "individual").length;
  const employeeCount = unifiedUserList.filter((u) => u.role === "employee").length;
  const enterpriseCount = Object.keys(enterprisesMap).length;

  return NextResponse.json(
    success({
      counts: {
        totalActiveUsers: unifiedUserList.length,
        individuals: individualCount,
        employees: employeeCount,
        enterprises: enterpriseCount,
      },
      users: filtered,
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  const body = await request.json();
  const { action = "app_session_heartbeat" } = body;
  const db = await connectDB();

  // =========================================================================
  // 1. MOBILE APP SESSION HEARTBEAT (Bridges Web <-> Mobile presence)
  // =========================================================================
  if (action === "app_session_heartbeat") {
    const { deviceModel = "Mobile Device", appVersion = "2.0.0", platform = "android" } = body;

    const now = new Date();
    await Promise.all([
      // Update Firestore user record
      firestoreDb.collection("users").doc(uid).set(
        {
          lastLoginPlatform: `mobile_${platform}`,
          lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
          deviceModel,
          appVersion,
        },
        { merge: true }
      ),
      // Update MongoDB card telemetry
      db.collection("cards").updateOne(
        { userId: uid },
        {
          $set: {
            lastAppSyncAt: now,
            activePlatform: "mobile",
          },
        }
      ),
    ]);

    return NextResponse.json(
      success({
        message: "Mobile session synced with Web database.",
        uid,
        serverTime: now.toISOString(),
      })
    );
  }

  // =========================================================================
  // 2. UNIFIED ROLE RESOLVER FOR APP LOGIN
  // =========================================================================
  if (action === "resolve_user_role") {
    const userDoc = await firestoreDb.collection("users").doc(uid).get();
    const cardDoc = await db.collection("cards").findOne({ userId: uid });

    const userData = userDoc.exists ? userDoc.data() : {};
    let resolvedRole = userData?.role || "individual";

    if (cardDoc?.companyId || userData?.companyId) {
      resolvedRole = "employee";
    }

    if (isMasterAdmin(userData?.role)) {
      resolvedRole = "master_admin";
    }

    return NextResponse.json(
      success({
        uid,
        email: context.auth.email,
        role: resolvedRole,
        companyId: cardDoc?.companyId || userData?.companyId || null,
        companyName: cardDoc?.companyName || userData?.companyName || null,
        hasPublishedCard: Boolean(cardDoc),
        cardSlug: cardDoc?.slug || null,
      })
    );
  }

  throw new AppError(`Unknown action: ${action}`, 400);
});
