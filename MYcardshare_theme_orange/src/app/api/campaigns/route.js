import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import {
  resolveAuth,
  checkCompanySuspended,
} from "@/backend/middleware/auth-handler";
import { AppError } from "@/backend/utils/api-adapter";
import campaignController from "@/backend/controllers/campaign.controller";

/**
 * Campaign Management
 * GET /api/campaigns
 * POST /api/campaigns
 */

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const { searchParams } = new URL(request.url);
  const activeOnly = searchParams.get("activeOnly");

  const companyId = context.user?.companyId || context.user?.enterpriseUid || context.uid;

  let responseData = null;
  const res = {
    json: (data) => {
      responseData = data;
    },
  };

  await campaignController.listCampaigns(
    { ...request, user: { ...context.user, companyId }, userData: { ...context.user, companyId }, query: { activeOnly } },
    res,
  );
  return NextResponse.json(responseData);
});

export const POST = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  await checkCompanySuspended(context);
  const body = await request.json();

  const companyId = body.companyId || context.user?.companyId || context.user?.enterpriseUid || context.uid;

  let responseData = null;
  let statusCode = 200;
  const res = {
    status: (code) => { statusCode = code; return res; },
    json: (data) => { responseData = data; },
  };

  await campaignController.createCampaign(
    { ...request, body: { ...body, companyId }, user: { ...context.user, companyId }, userData: { ...context.user, companyId } },
    res,
  );
  return NextResponse.json(responseData, { status: statusCode });
});

export const DELETE = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const { searchParams } = new URL(request.url);
  const campaignId = searchParams.get("id");
  const isMaster = ["super_admin", "master_admin", "platform_admin"].includes(context.user?.role);
  const companyId = (isMaster ? searchParams.get("companyId") : null) || context.user?.companyId || context.user?.enterpriseUid || context.uid;

  if (!campaignId) throw new AppError("campaignId is required", 400);

  let responseData = null;
  const res = { json: (data) => { responseData = data; } };

  await campaignController.deleteCampaign(
    { ...request, params: { campaignId }, user: { ...context.user, companyId }, userData: { ...context.user, companyId } },
    res
  );
  return NextResponse.json(responseData);
});

export const PATCH = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const { searchParams } = new URL(request.url);
  const campaignId = searchParams.get("id");
  const isMaster = ["super_admin", "master_admin", "platform_admin"].includes(context.user?.role);
  const companyId = (isMaster ? searchParams.get("companyId") : null) || context.user?.companyId || context.user?.enterpriseUid || context.uid;

  if (!campaignId) throw new AppError("campaignId is required", 400);

  const body = await request.json();
  let responseData = null;
  const res = { json: (data) => { responseData = data; } };

  await campaignController.updateCampaign(
    { ...request, body, params: { campaignId }, user: { ...context.user, companyId }, userData: { ...context.user, companyId } },
    res
  );
  return NextResponse.json(responseData);
});
