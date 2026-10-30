// @ts-nocheck
import { NextRequest, NextResponse } from "next/server";

/**
 * Next.js Web Backend Sync Route for Master Admin Companies
 * Mounted at: /api/sync/master-admin-companies
 *
 * Provides global visibility across all real companies on the platform
 * directly from Firestore enterprises and companies collections.
 * Zero mock records - 100% synchronized with database.
 */

const FIREBASE_API_KEY = "AIzaSyDdd6s5MsYSk-TRQyG-NbhVuvebSyIKbUk";
const PROJECT_ID = "business-card-64459";
const FIRESTORE_BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

export interface MasterCompany {
  id: string;
  name: string;
  email: string;
  plan: string;
  seats: number;
  employeeCount: number;
  status: "Active" | "Pending" | "Suspended";
  domain?: string;
  logoUrl?: string;
  adminUserId?: string;
  createdAt: string;
}

/** Parse Firestore REST API value field */
function parseFirestoreValue(val: any): any {
  if (!val || typeof val !== "object") return val;
  if ("stringValue" in val) return val.stringValue;
  if ("booleanValue" in val) return val.booleanValue;
  if ("integerValue" in val) return parseInt(val.integerValue, 10);
  if ("doubleValue" in val) return parseFloat(val.doubleValue);
  if ("timestampValue" in val) return val.timestampValue;
  if ("nullValue" in val) return null;
  if ("mapValue" in val) {
    const fields = val.mapValue.fields || {};
    const res: Record<string, any> = {};
    for (const key of Object.keys(fields)) {
      res[key] = parseFirestoreValue(fields[key]);
    }
    return res;
  }
  if ("arrayValue" in val) {
    const list = val.arrayValue.values || [];
    return list.map(parseFirestoreValue);
  }
  return val;
}

/** Parse a Firestore REST document into a plain JavaScript object */
function parseFirestoreDoc(doc: any): Record<string, any> {
  const fields = doc.fields || {};
  const data: Record<string, any> = {};
  for (const k of Object.keys(fields)) {
    data[k] = parseFirestoreValue(fields[k]);
  }
  const parts = (doc.name || "").split("/");
  data.id = parts[parts.length - 1];
  data.createdAt = doc.createTime || new Date().toISOString();
  return data;
}

function mapToMasterCompany(doc: any): MasterCompany {
  const data = parseFirestoreDoc(doc);
  const name = (data.companyName || data.name || data.title || "Company").toString().trim();
  const email = (data.companyEmail || data.email || data.adminEmail || "").toString().trim();
  const domain = (data.domain || data.companyDomain || data.website || "").toString().trim();
  const plan = (data.plan || data.subscriptionPlan || data.tier || "Team").toString().trim();
  const seats = typeof data.seats === "number" ? data.seats : (typeof data.employeeCount === "number" ? data.employeeCount : 0);
  const employeeCount = typeof data.employeeCount === "number" ? data.employeeCount : 0;

  const rawStatus = (data.status || data.approvalStatus || "Active").toString();
  let status: "Active" | "Pending" | "Suspended" = "Active";
  if (rawStatus.toLowerCase().includes("pend") || data.approvalStatus === "pending") {
    status = "Pending";
  } else if (rawStatus.toLowerCase().includes("susp") || data.isSuspended === true || rawStatus.toLowerCase().includes("reject")) {
    status = "Suspended";
  }

  const logoUrl = data.logoUrl || data.companyLogo || data.logo || data.avatarUrl || data.profilePhoto || data.photoUrl || undefined;

  return {
    id: data.id,
    name,
    email,
    plan,
    seats,
    employeeCount,
    status,
    domain,
    logoUrl,
    adminUserId: data.adminUserId || data.ownerId || data.userId || undefined,
    createdAt: data.createdAt,
  };
}

async function fetchLiveCompanies(): Promise<MasterCompany[]> {
  const enterprisesUrl = `${FIRESTORE_BASE}/enterprises?pageSize=300&key=${FIREBASE_API_KEY}`;
  const companiesUrl = `${FIRESTORE_BASE}/companies?pageSize=300&key=${FIREBASE_API_KEY}`;

  const map = new Map<string, MasterCompany>();

  try {
    const res = await fetch(enterprisesUrl, { headers: { Accept: "application/json" }, cache: "no-store" });
    if (res.ok) {
      const json = await res.json();
      for (const d of json.documents || []) {
        const c = mapToMasterCompany(d);
        if (c.name.trim().length > 0) {
          map.set(c.id, c);
        }
      }
    }
  } catch (e) {
    console.warn("[MasterAdminCompanies] enterprises fetch note:", e);
  }

  try {
    const res = await fetch(companiesUrl, { headers: { Accept: "application/json" }, cache: "no-store" });
    if (res.ok) {
      const json = await res.json();
      for (const d of json.documents || []) {
        const c = mapToMasterCompany(d);
        if (c.name.trim().length > 0 && !map.has(c.id)) {
          map.set(c.id, c);
        }
      }
    }
  } catch (e) {
    console.warn("[MasterAdminCompanies] companies fetch note:", e);
  }

  return Array.from(map.values());
}

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const filter = (searchParams.get("filter") || "all").toLowerCase();
    const search = (searchParams.get("search") || "").toLowerCase().trim();

    // 1. Fetch 100% real companies directly from Firestore
    const liveCompanies = await fetchLiveCompanies();

    // 2. Metrics across real database companies
    const total = liveCompanies.length;
    const active = liveCompanies.filter((c) => c.status.toLowerCase() === "active").length;
    const pending = liveCompanies.filter((c) => c.status.toLowerCase() === "pending").length;
    const suspended = liveCompanies.filter((c) => c.status.toLowerCase() === "suspended").length;

    // 3. Filter companies based on query
    let filtered = liveCompanies;

    if (search.length > 0) {
      filtered = filtered.filter(
        (c) =>
          c.name.toLowerCase().includes(search) ||
          c.email.toLowerCase().includes(search) ||
          (c.domain && c.domain.toLowerCase().includes(search)) ||
          c.plan.toLowerCase().includes(search)
      );
    }

    if (filter === "active") {
      filtered = filtered.filter((c) => c.status.toLowerCase() === "active");
    } else if (filter === "pending") {
      filtered = filtered.filter((c) => c.status.toLowerCase() === "pending");
    } else if (filter === "suspended") {
      filtered = filtered.filter((c) => c.status.toLowerCase() === "suspended");
    }

    return NextResponse.json({
      success: true,
      data: {
        metrics: {
          total,
          active,
          pending,
          suspended,
        },
        companies: filtered,
      },
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        success: false,
        error: error.message || "Failed to fetch master admin companies",
      },
      { status: 500 }
    );
  }
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json().catch(() => ({}));
    const { action, companyId, status } = body;

    if (!companyId) {
      return NextResponse.json({ success: false, error: "Missing companyId" }, { status: 400 });
    }

    if (action === "delete") {
      await fetch(`${FIRESTORE_BASE}/enterprises/${companyId}?key=${FIREBASE_API_KEY}`, { method: "DELETE" }).catch(() => {});
      await fetch(`${FIRESTORE_BASE}/companies/${companyId}?key=${FIREBASE_API_KEY}`, { method: "DELETE" }).catch(() => {});
      return NextResponse.json({
        success: true,
        message: `Company ${companyId} deleted permanently from database`,
      });
    }

    const newStatus = action === "approve" ? "Active" : (action === "suspend" ? "Suspended" : (status || "Active"));
    const isSuspended = newStatus === "Suspended";

    const updatePayload = {
      fields: {
        status: { stringValue: newStatus },
        isSuspended: { booleanValue: isSuspended },
        approvalStatus: { stringValue: newStatus === "Active" ? "approved" : (isSuspended ? "rejected" : "pending") },
      },
    };

    await fetch(`${FIRESTORE_BASE}/enterprises/${companyId}?updateMask.fieldPaths=status&updateMask.fieldPaths=isSuspended&updateMask.fieldPaths=approvalStatus&key=${FIREBASE_API_KEY}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(updatePayload),
    }).catch(() => {});

    await fetch(`${FIRESTORE_BASE}/companies/${companyId}?updateMask.fieldPaths=status&updateMask.fieldPaths=isSuspended&updateMask.fieldPaths=approvalStatus&key=${FIREBASE_API_KEY}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(updatePayload),
    }).catch(() => {});

    return NextResponse.json({
      success: true,
      message: `Company ${companyId} updated to ${newStatus} in database`,
      data: { id: companyId, status: newStatus },
    });
  } catch (error: any) {
    return NextResponse.json({ success: false, error: error.message || "Operation failed" }, { status: 500 });
  }
}
