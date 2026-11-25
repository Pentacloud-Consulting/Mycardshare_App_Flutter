import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { isMasterAdmin, isEnterprise } from "@/lib/roles";
import { connectDB } from "@/backend/config/db";
import { firestoreDb, admin } from "@/backend/config/firebase";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * MASTER ADMIN COMPANIES SYNC API (MOBILE APP <-> NEXT.JS WEB)
 *
 * Route: 
 *   GET /api/sync/master-admin-companies
 *   GET /api/platform/companies
 *
 * Populates the Master Admin Companies Screen:
 * 1. Top Metric Pills:
 *    - total: Total number of companies
 *    - active: Active / approved companies
 *    - suspended: Suspended companies
 *    - pending: Pending review companies
 * 2. Filter Pills:
 *    - all | active | pending | suspended
 * 3. Search query: Searches across companyName, adminEmail, slug, domain
 * 4. Company Items:
 *    - id, companyId, companyName, slug, domain, adminEmail, adminName,
 *      plan, totalMembers / seats, status, approvalStatus, isSuspended,
 *      logo, createdAt, renewalDate
 */
export const GET = apiAdapter(async (request: NextRequest) => {
  let context: any = null;
  try {
    context = await resolveAuth(request);
  } catch (authErr) {
    console.warn("⚠️ [Companies Sync] Auth token warning:", authErr);
  }

  const { searchParams } = new URL(request.url);
  const filter = (searchParams.get("filter") || "all").toLowerCase().trim();
  const search = (searchParams.get("search") || searchParams.get("q") || "").toLowerCase().trim();

  const db = await connectDB();

  // 1. Fetch companies from Firestore AND MongoDB in parallel
  const [firestoreSnap, mongoCompanies, mongoCards] = await Promise.all([
    firestoreDb.collection("companies").get().catch(() => ({ docs: [] })),
    db.collection("companies").find({}).toArray().catch(() => []),
    db.collection("cards").find({}, { projection: { companyId: 1, workspaceId: 1 } }).toArray().catch(() => []),
  ]);

  // 2. Count members per company
  const memberCounts: Record<string, number> = {};
  for (const card of mongoCards) {
    const cid = card.companyId || card.workspaceId;
    if (cid) {
      memberCounts[cid] = (memberCounts[cid] || 0) + 1;
    }
  }

  // 3. Merge companies by ID / slug
  const companyMap = new Map<string, any>();

  // Add from Firestore
  for (const doc of firestoreSnap.docs || []) {
    const data = doc.data();
    const id = doc.id;
    companyMap.set(id, { id, ...data });
  }

  // Add/Merge from MongoDB
  for (const mc of mongoCompanies || []) {
    const id = String(mc._id || mc.id || mc.companyId);
    if (!companyMap.has(id)) {
      companyMap.set(id, { id, ...mc });
    } else {
      companyMap.set(id, { ...mc, ...companyMap.get(id) });
    }
  }

  // 4. Transform & Normalize Companies
  let totalCount = 0;
  let activeCount = 0;
  let suspendedCount = 0;
  let pendingCount = 0;

  const allCompanies: any[] = [];

  for (const [id, data] of companyMap.entries()) {
    const rawStatus = (data.status || "").toLowerCase();
    const rawApproval = (data.approvalStatus || "").toLowerCase();
    const isSuspended = Boolean(data.isSuspended === true || rawStatus === "suspended");

    let finalStatus = "pending";
    if (isSuspended) {
      finalStatus = "suspended";
    } else if (rawStatus === "active" || rawApproval === "approved") {
      finalStatus = "active";
    } else if (rawStatus === "rejected" || rawApproval === "rejected") {
      finalStatus = "rejected";
    } else {
      finalStatus = "pending";
    }

    totalCount++;
    if (isSuspended) suspendedCount++;
    else if (finalStatus === "active") activeCount++;
    else if (finalStatus === "pending") pendingCount++;

    const seats = memberCounts[id] || data.totalMembers || data.employeeCount || 0;
    const plan = data.subscriptionPlan || data.plan || "Free";

    allCompanies.push({
      id,
      companyId: id,
      companyName: data.companyName || data.name || "Unnamed Enterprise",
      name: data.companyName || data.name || "Unnamed Enterprise",
      slug: data.slug || id,
      domain: data.domain || data.slug || `${id}.mycardshare.com`,
      adminEmail: data.adminEmail || data.officialEmail || data.email || "",
      adminName: data.adminName || data.contactPerson || "Admin",
      phoneNumber: data.phoneNumber || data.phone || "",
      companyLogo: data.companyLogo || data.logo || null,
      logo: data.companyLogo || data.logo || null,
      seats,
      totalMembers: seats,
      plan: plan.toLowerCase().includes("pro") ? "Pro" : "Free",
      subscriptionPlan: plan,
      status: finalStatus, // "active" | "pending" | "suspended" | "rejected"
      approvalStatus: finalStatus === "active" ? "approved" : finalStatus,
      isSuspended,
      createdAt: data.createdAt?.toDate?.()?.toISOString?.() || data.createdAt || new Date().toISOString(),
      renewalDate: data.renewalDate?.toDate?.()?.toISOString?.() || data.renewalDate || null,
    });
  }

  // Sort by createdAt desc
  allCompanies.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());

  // 5. Apply Filter Pills
  let filtered = allCompanies;
  if (filter === "active") {
    filtered = filtered.filter((c) => c.status === "active");
  } else if (filter === "pending") {
    filtered = filtered.filter((c) => c.status === "pending");
  } else if (filter === "suspended") {
    filtered = filtered.filter((c) => c.status === "suspended" || c.isSuspended);
  }

  // 6. Apply Search Query
  if (search) {
    filtered = filtered.filter((c) =>
      [c.companyName, c.adminEmail, c.slug, c.domain, c.adminName].some((field) =>
        String(field || "").toLowerCase().includes(search)
      )
    );
  }

  return NextResponse.json(
    success({
      metrics: {
        total: totalCount,
        active: activeCount,
        suspended: suspendedCount,
        pending: pendingCount,
      },
      statsGrid: {
        totalCompanies: totalCount,
        activeCompanies: activeCount,
        suspendedCompanies: suspendedCount,
        pendingCompanies: pendingCount,
      },
      companies: filtered,
      totalCount: filtered.length,
      syncedAt: new Date().toISOString(),
    })
  );
});
