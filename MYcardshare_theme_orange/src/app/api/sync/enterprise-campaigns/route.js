import { NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import campaignService from "@/backend/services/campaign.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Sync Endpoint for Enterprise Campaigns (Used by Flutter Mobile App)
 * GET /api/sync/enterprise-campaigns?status=all|active|ended
 * POST /api/sync/enterprise-campaigns
 */

export async function GET(request) {
  try {
    const context = await resolveAuth(request);
    const companyId = context.user?.companyId || context.user?.enterpriseUid || context.uid;

    if (!companyId) {
      return NextResponse.json(
        success({
          summary: { activeCampaignsCount: 0, totalScansThisMonth: "0" },
          campaigns: [],
        })
      );
    }

    const { searchParams } = new URL(request.url);
    const status = (searchParams.get("status") || "all").toLowerCase();
    const activeOnly = status === "active";

    const rawList = await campaignService.listCampaigns(companyId, { activeOnly });

    const campaigns = (rawList || []).map((c, i) => {
      const name = c.name || c.title || c.campaignName || "Marketing Campaign";
      const scans = c.scans || c.scansCount || 0;
      const leads = c.leads || c.leadsWon || 0;
      const isActive = c.isActive !== false;
      const campStatus = isActive ? "Active" : "Ended";

      return {
        id: c.id,
        name,
        title: name,
        campaignName: name,
        tag: "CAMPAIGN",
        scans,
        leads,
        leadsWon: leads,
        conv: scans > 0 ? `${Math.round((leads / scans) * 100)}%` : "0%",
        endsCaption: c.endDate ? `Ends ${new Date(c.endDate).toLocaleDateString()}` : "Active Campaign",
        status: campStatus,
        area: c.area || "",
        budget: c.budget || 0,
        description: c.description || "",
        startDate: c.startDate || "",
        endDate: c.endDate || "",
        createdAt: c.createdAt,
      };
    });

    const activeCampaigns = campaigns.filter((c) => c.status === "Active");
    const totalScans = campaigns.reduce((acc, cur) => acc + (Number(cur.scans) || 0), 0);

    return NextResponse.json(
      success({
        summary: {
          activeCampaignsCount: activeCampaigns.length,
          totalScansThisMonth: totalScans.toString(),
        },
        campaigns,
      })
    );
  } catch (err) {
    console.error("[Sync Enterprise Campaigns GET Error]", err);
    return NextResponse.json(
      success({
        summary: { activeCampaignsCount: 0, totalScansThisMonth: "0" },
        campaigns: [],
      })
    );
  }
}

export async function POST(request) {
  try {
    const context = await resolveAuth(request);
    const companyId = context.user?.companyId || context.user?.enterpriseUid || context.uid;

    if (!companyId) {
      return NextResponse.json({ success: false, error: "No organization associated" }, { status: 400 });
    }

    const body = await request.json().catch(() => ({}));
    const name = (body.name || body.title || body.campaignName || "").trim();

    if (!name) {
      return NextResponse.json({ success: false, error: "Campaign name is required" }, { status: 400 });
    }

    const campaignId = await campaignService.createCampaign(companyId, {
      name,
      description: body.description || "",
      area: body.area || "",
      budget: body.budget ? Number(body.budget) : 0,
      startDate: body.startDate || "",
      endDate: body.endDate || "",
    });

    return NextResponse.json(
      success({
        campaignId,
        campaign: {
          id: campaignId,
          name,
          title: name,
          description: body.description || "",
          area: body.area || "",
          budget: body.budget,
          status: "Active",
          scans: 0,
          leads: 0,
          conv: "0%",
        },
      })
    );
  } catch (err) {
    console.error("[Sync Enterprise Campaigns POST Error]", err);
    return NextResponse.json(
      { success: false, error: "Failed to create campaign" },
      { status: 500 }
    );
  }
}
