import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import campaignController from "@/backend/controllers/campaign.controller";

/**
 * Individual Campaign Management
 * PATCH /api/campaigns/:campaignId
 * DELETE /api/campaigns/:campaignId
 */

export const PATCH = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  const { campaignId } = await params;
  const body = await request.json();

  let responseData = null;
  const res = {
    json: (data) => {
      responseData = data;
    },
  };

  await campaignController.updateCampaign(
    {
      ...request,
      params: { campaignId },
      body,
      user: context.user,
      userData: context.user,
    },
    res,
  );
  return NextResponse.json(responseData);
});

export const DELETE = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  const { campaignId } = await params;

  let responseData = null;
  const res = {
    json: (data) => {
      responseData = data;
    },
  };

  await campaignController.deleteCampaign(
    {
      ...request,
      params: { campaignId },
      user: context.user,
      userData: context.user,
    },
    res,
  );
  return NextResponse.json(responseData);
});
