import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";
import { ObjectId } from "mongodb";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * INDIVIDUAL CAMPAIGN TRACKING SYNC (APP <-> WEB)
 * 
 * Supports:
 * - GET /api/sync/individual-campaigns
 *   Lists user's marketing QR campaigns with click-through rates, total scans, and unique visitors.
 * - POST /api/sync/individual-campaigns
 *   Creates a new QR trackable campaign with custom UTM tags, target card URL, and tracking token.
 * - PATCH /api/sync/individual-campaigns
 *   Updates or archives a campaign.
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;
  const db = await connectDB();

  const campaigns = await db
    .collection("campaigns")
    .find({ userId: uid })
    .sort({ createdAt: -1 })
    .toArray();

  // Aggregate totals
  const totalCampaignScans = campaigns.reduce((acc, c) => acc + (c.scans || c.views || 0), 0);
  const totalLeadsGenerated = campaigns.reduce((acc, c) => acc + (c.leadsCount || 0), 0);

  return NextResponse.json(
    success({
      summary: {
        totalCampaigns: campaigns.length,
        totalScans: totalCampaignScans,
        totalLeadsGenerated,
        avgConversionRate: totalCampaignScans > 0 
          ? Number(((totalLeadsGenerated / totalCampaignScans) * 100).toFixed(1)) 
          : 0,
      },
      campaigns: campaigns.map((c) => ({
        id: c._id.toString(),
        name: c.name || "Untitled Campaign",
        targetUrl: c.targetUrl || `https://mycardshare.com/card/${uid}`,
        campaignCode: c.campaignCode || c.code || c._id.toString().slice(-6),
        qrCodeUrl: `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(c.targetUrl || '')}`,
        status: c.status || "active",
        scans: c.scans || c.views || 0,
        leadsCount: c.leadsCount || 0,
        utmSource: c.utmSource || "qr_flyer",
        utmMedium: c.utmMedium || "print",
        startDate: c.startDate || c.createdAt,
        createdAt: c.createdAt || new Date().toISOString(),
      })),
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  const body = await request.json();
  const { name, targetCardSlug, utmSource = "networking_event", utmMedium = "qr_card" } = body;

  if (!name || typeof name !== "string") {
    throw new AppError("Campaign name is required (e.g. 'Tech Expo 2026 Flyer').", 400);
  }

  const db = await connectDB();
  const cardSlug = targetCardSlug || uid;
  const campaignCode = `cmp_${Date.now().toString().slice(-6)}`;
  const trackedUrl = `https://mycardshare.com/card/${cardSlug}?cmp=${campaignCode}&utm_source=${utmSource}&utm_medium=${utmMedium}`;

  const campaignDoc = {
    userId: uid,
    name,
    campaignCode,
    targetUrl: trackedUrl,
    cardSlug,
    utmSource,
    utmMedium,
    scans: 0,
    leadsCount: 0,
    status: "active",
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const result = await db.collection("campaigns").insertOne(campaignDoc);

  return NextResponse.json(
    success({
      message: "Marketing campaign created with live QR tracking.",
      campaign: {
        ...campaignDoc,
        id: result.insertedId.toString(),
        qrCodeUrl: `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(trackedUrl)}`,
      },
    })
  );
});

export const PATCH = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  const body = await request.json();
  const { campaignId, status, name } = body;

  if (!campaignId) {
    throw new AppError("campaignId is required.", 400);
  }

  const db = await connectDB();
  const updateFields: any = { updatedAt: new Date() };
  if (status) updateFields.status = status;
  if (name) updateFields.name = name;

  await db.collection("campaigns").updateOne(
    { _id: new ObjectId(campaignId), userId: uid },
    { $set: updateFields }
  );

  return NextResponse.json(success({ message: "Campaign updated successfully." }));
});
