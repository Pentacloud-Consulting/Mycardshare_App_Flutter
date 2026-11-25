import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";
import { ObjectId } from "mongodb";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * INDIVIDUAL CAMPAIGN SYNC (APP <-> WEB)
 * 
 * Supports:
 * - GET /api/sync/individual-campaigns
 *   Lists individual freelancer/creator marketing campaigns.
 * 
 * - POST /api/sync/individual-campaigns
 *   Creates individual QR campaign with UTM tags and tracked URLs.
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;
  const db = await connectDB();

  const url = new URL(request.url);
  const statusFilter = url.searchParams.get("status") || "all";

  const campaigns = await db
    .collection("campaigns")
    .find({ userId: uid })
    .sort({ createdAt: -1 })
    .toArray();

  const now = new Date();
  const formatted = campaigns.map((c) => {
    const endDate = c.endDate ? new Date(c.endDate) : null;
    const isEnded = c.isActive === false || c.status === "ended" || (endDate && endDate < now);
    const diffTime = endDate ? endDate.getTime() - now.getTime() : 0;
    const diffDays = Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));

    const scans = c.scans || c.views || 0;
    const conversionRate = c.conversionRate || (scans > 0 ? Number(((c.leadsCount || 5) / scans * 100).toFixed(0)) : 14);

    return {
      id: c._id.toString(),
      name: c.name || "Networking Campaign",
      description: c.description || "",
      status: isEnded ? "ended" : "active",
      isActive: !isEnded,
      scans,
      conversionRate: `${conversionRate}%`,
      endsInDays: diffDays,
      endsInText: isEnded ? "Ended" : (diffDays > 0 ? `Ends in ${diffDays} days` : "Ending today"),
      qrCodeUrl: c.qrCodeUrl || `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(c.targetUrl || `https://mycardshare.com/card/${uid}`)}`,
      targetUrl: c.targetUrl || `https://mycardshare.com/card/${uid}`,
      startDate: c.startDate || c.createdAt,
      endDate: c.endDate || null,
      createdAt: c.createdAt || new Date().toISOString(),
    };
  });

  const filtered = statusFilter === "all"
    ? formatted
    : formatted.filter((c) => c.status === statusFilter);

  const activeCount = formatted.filter((c) => c.status === "active").length;
  const totalScans = formatted.reduce((sum, c) => sum + (c.scans || 0), 0);

  return NextResponse.json(
    success({
      summary: {
        activeCampaignsCount: activeCount,
        totalScansThisMonth: totalScans,
        totalCampaigns: formatted.length,
      },
      campaigns: filtered,
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  const body = await request.json();
  const { action = "create" } = body;
  const db = await connectDB();

  // =========================================================================
  // 1. CREATE INDIVIDUAL CAMPAIGN
  // =========================================================================
  if (action === "create") {
    const { name, description, durationDays = 14, utmSource = "networking_event" } = body;

    if (!name || typeof name !== "string") {
      throw new AppError("Campaign name is required.", 400);
    }

    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(startDate.getDate() + (parseInt(durationDays, 10) || 14));

    const campaignCode = `ind_${Date.now().toString().slice(-6)}`;
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || "https://mycardshare.com";
    const targetUrl = `${baseUrl}/card/${uid}?cmp=${campaignCode}&utm_source=${utmSource}`;
    const qrCodeUrl = `https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=${encodeURIComponent(targetUrl)}`;

    const campaignDoc = {
      userId: uid,
      name,
      description: description || "",
      campaignCode,
      targetUrl,
      qrCodeUrl,
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
      status: "active",
      isActive: true,
      scans: 0,
      leadsCount: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const result = await db.collection("campaigns").insertOne(campaignDoc);

    return NextResponse.json(
      success({
        message: `Campaign '${name}' created successfully!`,
        campaign: {
          id: result.insertedId.toString(),
          ...campaignDoc,
        },
      })
    );
  }

  // =========================================================================
  // 2. TOGGLE / PAUSE CAMPAIGN
  // =========================================================================
  if (action === "toggle_status") {
    const { campaignId, status } = body;
    if (!campaignId) throw new AppError("campaignId is required.", 400);

    const isNowActive = status === "active";
    await db.collection("campaigns").updateOne(
      { _id: new ObjectId(campaignId), userId: uid },
      { $set: { status: isNowActive ? "active" : "ended", isActive: isNowActive, updatedAt: new Date() } }
    );

    return NextResponse.json(success({ message: `Campaign status updated to ${status}.` }));
  }

  throw new AppError(`Unknown action: ${action}`, 400);
});
