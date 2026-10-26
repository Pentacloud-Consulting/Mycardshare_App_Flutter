import { NextRequest, NextResponse } from "next/server";

/**
 * Next.js Web Backend Sync Route for Campaign Tracker
 * Mount: /api/sync/campaign-tracker
 * Also handles: /api/sync/individual-campaigns
 *
 * Ensures all possible campaign name keys (name, title, label, campaignName)
 * return the real user-entered title without falling back to 'Campaign X'.
 */

interface CampaignRecord {
  id: string;
  name: string;
  title: string;
  label: string;
  campaignName: string;
  scans: number;
  totalScans: number;
  leadsWon: number;
  leadsCount: number;
  leads: number;
  conversionRate: string;
  status: "active" | "ended" | "paused";
  targetUrl: string;
  qrCodeUrl: string;
  createdAt: string;
  updatedAt: string;
}

// In-memory or MongoDB/Firestore mock store for synchronized campaigns
const campaignStore: Map<string, CampaignRecord[]> = new Map();

export async function GET(req: NextRequest) {
  try {
    const authHeader = req.headers.get("authorization") || "";
    const token = authHeader.replace(/^Bearer\s+/i, "").trim();
    const userId = token || "demo_user";

    const userCampaigns = campaignStore.get(userId) || [];

    const totalScans = userCampaigns.reduce((acc, c) => acc + (c.scans || 0), 0);
    const totalLeads = userCampaigns.reduce((acc, c) => acc + (c.leadsWon || 0), 0);
    const activeCount = userCampaigns.filter((c) => c.status === "active").length;

    return NextResponse.json({
      success: true,
      data: {
        summary: {
          activeCampaignsCount: activeCount,
          totalScansThisMonth: totalScans.toString(),
          totalLeadsWon: totalLeads.toString(),
        },
        campaigns: userCampaigns.map((c) => ({
          id: c.id,
          _id: c.id,
          // ⚡ Guaranteed uniform key mapping across all platforms
          name: c.name,
          title: c.title,
          label: c.label,
          campaignName: c.campaignName,
          scans: c.scans,
          totalScans: c.totalScans,
          views: c.scans,
          leadsWon: c.leadsWon,
          leadsCount: c.leadsCount,
          leads: c.leads,
          conversionRate: c.conversionRate,
          conv: c.conversionRate,
          status: c.status,
          targetUrl: c.targetUrl,
          qrCodeUrl: c.qrCodeUrl,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
        })),
      },
    });
  } catch (error: any) {
    console.error("[CampaignTracker] GET error:", error);
    return NextResponse.json(
      { success: false, error: error.message || "Failed to load campaigns" },
      { status: 500 }
    );
  }
}

export async function POST(req: NextRequest) {
  try {
    const authHeader = req.headers.get("authorization") || "";
    const token = authHeader.replace(/^Bearer\s+/i, "").trim();
    const userId = token || "demo_user";

    const body = await req.json().catch(() => ({}));
    const rawName = (body.name || body.title || body.label || body.campaignName || "").trim();

    if (!rawName) {
      return NextResponse.json(
        { success: false, error: "Campaign name cannot be empty." },
        { status: 400 }
      );
    }

    const campaignId = body.campaignId || `camp_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    const targetSlug = body.targetCardSlug || body.cardSlug || "default";
    const targetUrl = `https://digitalbusinesscloudcard.com/c/${campaignId}?slug=${targetSlug}`;
    const qrCodeUrl = `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(targetUrl)}`;

    const newCampaign: CampaignRecord = {
      id: campaignId,
      // ⚡ All 4 attributes guaranteed identical to real user input
      name: rawName,
      title: rawName,
      label: rawName,
      campaignName: rawName,
      scans: 0,
      totalScans: 0,
      leadsWon: 0,
      leadsCount: 0,
      leads: 0,
      conversionRate: "0%",
      status: "active",
      targetUrl,
      qrCodeUrl,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const existing = campaignStore.get(userId) || [];
    existing.unshift(newCampaign);
    campaignStore.set(userId, existing);

    return NextResponse.json(
      {
        success: true,
        message: `Campaign '${rawName}' created successfully!`,
        data: {
          campaign: {
            id: newCampaign.id,
            _id: newCampaign.id,
            name: newCampaign.name,
            title: newCampaign.title,
            label: newCampaign.label,
            campaignName: newCampaign.campaignName,
            scans: 0,
            totalScans: 0,
            views: 0,
            leadsWon: 0,
            leadsCount: 0,
            leads: 0,
            conversionRate: "0%",
            conv: "0%",
            status: "active",
            targetUrl: newCampaign.targetUrl,
            qrCodeUrl: newCampaign.qrCodeUrl,
            createdAt: newCampaign.createdAt,
            updatedAt: newCampaign.updatedAt,
          },
        },
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error("[CampaignTracker] POST error:", error);
    return NextResponse.json(
      { success: false, error: error.message || "Failed to create campaign" },
      { status: 500 }
    );
  }
}
