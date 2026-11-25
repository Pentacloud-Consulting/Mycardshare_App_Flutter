import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { connectDB } from "@/backend/config/db";
import { firestoreDb } from "@/backend/config/firebase";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";
import { ObjectId } from "mongodb";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * UNIFIED CAMPAIGN SYNC & REAL LABEL RESOLVER (INDIVIDUAL + ENTERPRISE)
 * 
 * Solves:
 * "Created campaign but its label is not showing it is showing Campaign 1,2,3.."
 * 
 * Key Features:
 * 1. Guarantees real campaign title/label (e.g. 'test campaign 2', 'Web Summit 2026', 'Q3 Sales Offsite').
 * 2. Unifies all campaign creation and fetching under both:
 *    - name / title / label / campaignName (cross-compatible keys)
 * 3. Supports Individual users (tied to userId) AND Enterprise users (tied to companyId).
 * 4. Dual-persists into MongoDB 'campaigns' AND Firestore 'companies/{id}/campaigns'.
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  let context: any = null;
  try {
    context = await resolveAuth(request);
  } catch (e) {
    // Allows tokenless query if userId/companyId query param provided
  }

  const { searchParams } = new URL(request.url);
  const uid = searchParams.get("userId") || context?.uid;
  const companyId = searchParams.get("companyId") || context?.user?.companyId;

  if (!uid && !companyId) {
    throw new AppError("Authentication required or userId/companyId must be provided.", 401);
  }

  const db = await connectDB();

  // Query condition: match companyId OR userId
  const queryConditions: any[] = [];
  if (companyId) queryConditions.push({ companyId });
  if (uid) queryConditions.push({ userId: uid });

  const mongoQuery = queryConditions.length > 1 ? { $or: queryConditions } : queryConditions[0];

  const rawCampaigns = await db
    .collection("campaigns")
    .find(mongoQuery)
    .sort({ createdAt: -1 })
    .toArray();

  const totalScans = rawCampaigns.reduce((acc, c) => acc + (c.scans || c.views || 0), 0);
  const totalLeads = rawCampaigns.reduce((acc, c) => acc + (c.leadsCount || c.leadsWon || 0), 0);

  const formatted = rawCampaigns.map((c, index) => {
    // ⚡ FIX: Use the REAL user-provided name/label first!
    const realName = c.name || c.title || c.label || c.campaignName;
    const displayName = realName && realName.trim().length > 0 
      ? realName.trim() 
      : `Campaign ${rawCampaigns.length - index}`;

    const campaignId = c._id ? c._id.toString() : (c.id || `cmp_${index}`);
    const targetUrl = c.targetUrl || `https://mycardshare.com/campaign/${campaignId}`;

    return {
      id: campaignId,
      campaignId,
      name: displayName,
      title: displayName,
      label: displayName,
      campaignName: displayName,
      description: c.description || "",
      scans: c.scans || c.views || 0,
      totalScans: c.scans || c.views || 0,
      leadsCount: c.leadsCount || c.leadsWon || 0,
      leadsWon: c.leadsCount || c.leadsWon || 0,
      status: c.status || (c.isActive === false ? "ended" : "active"),
      isActive: c.status ? c.status === "active" : c.isActive !== false,
      targetUrl,
      qrCodeUrl: c.qrCodeUrl || `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(targetUrl)}`,
      utmSource: c.utmSource || "networking",
      utmMedium: c.utmMedium || "qr_code",
      createdAt: c.createdAt ? new Date(c.createdAt).toISOString() : new Date().toISOString(),
      updatedAt: c.updatedAt ? new Date(c.updatedAt).toISOString() : new Date().toISOString(),
    };
  });

  return NextResponse.json(
    success({
      summary: {
        activeCampaigns: formatted.filter((c) => c.isActive).length,
        totalScans,
        leadsWon: totalLeads,
      },
      campaigns: formatted,
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  let context: any = null;
  try {
    context = await resolveAuth(request);
  } catch (e) {
    // Allow payload to provide credentials
  }

  const body = await request.json();
  const rawName = body.name || body.title || body.label || body.campaignName;

  if (!rawName || typeof rawName !== "string" || !rawName.trim()) {
    throw new AppError("Campaign title/name is required.", 400);
  }

  const campaignTitle = rawName.trim();
  const uid = body.userId || context?.uid;
  const companyId = body.companyId || context?.user?.companyId;

  if (!uid && !companyId) {
    throw new AppError("User identity or company identity is required to create a campaign.", 400);
  }

  const db = await connectDB();
  const campaignCode = `cmp_${Date.now().toString(36)}`;
  const targetCardSlug = body.targetCardSlug || body.slug || uid || "card";
  const targetUrl = body.targetUrl || `https://mycardshare.com/card/${targetCardSlug}?cmp=${campaignCode}`;

  const campaignDoc: any = {
    name: campaignTitle,
    title: campaignTitle,
    label: campaignTitle,
    campaignName: campaignTitle,
    description: body.description || "",
    userId: uid || null,
    companyId: companyId || null,
    campaignCode,
    targetUrl,
    utmSource: body.utmSource || "mobile_campaign",
    utmMedium: body.utmMedium || "qr_share",
    scans: 0,
    views: 0,
    leadsCount: 0,
    leadsWon: 0,
    status: "active",
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  // 1. Insert into MongoDB 'campaigns'
  const result = await db.collection("campaigns").insertOne(campaignDoc);
  const insertedId = result.insertedId.toString();

  // 2. Dual-mirror into Firestore if companyId exists
  if (companyId) {
    try {
      await firestoreDb
        .collection("companies")
        .doc(companyId)
        .collection("campaigns")
        .doc(insertedId)
        .set({
          ...campaignDoc,
          id: insertedId,
          createdAt: new Date(),
          updatedAt: new Date(),
        });
    } catch (fsErr) {
      console.warn("⚠️ [Campaign Sync] Firestore mirroring warning:", fsErr);
    }
  }

  const qrCodeUrl = `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(targetUrl)}`;

  return NextResponse.json(
    success({
      message: `Campaign '${campaignTitle}' created successfully!`,
      campaign: {
        id: insertedId,
        campaignId: insertedId,
        name: campaignTitle,
        title: campaignTitle,
        label: campaignTitle,
        campaignName: campaignTitle,
        qrCodeUrl,
        ...campaignDoc,
      },
    }, `Campaign '${campaignTitle}' created successfully!`),
    { status: 201 }
  );
});
