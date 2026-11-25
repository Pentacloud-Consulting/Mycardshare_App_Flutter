import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import leadController from "@/backend/controllers/lead.controller";

/**
 * Individual Lead Management
 * PATCH /api/leads/:leadId
 * DELETE /api/leads/:leadId
 */

export const PATCH = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  const { leadId } = await params;
  const body = await request.json();

  let responseData = null;
  const res = {
    status: (code) => ({
      json: (data) => {
        responseData = data;
      },
    }),
    json: (data) => {
      responseData = data;
    },
  };

  await leadController.updateLead(
    {
      ...request,
      params: { leadId },
      body,
      query: { companyId: body.companyId },
      user: context.user,
      userData: context.user,
    },
    res,
  );
  return NextResponse.json(responseData);
});

export const DELETE = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  const { leadId } = await params;

  let responseData = null;
  const res = {
    status: (code) => ({
      json: (data) => {
        responseData = data;
      },
    }),
    json: (data) => {
      responseData = data;
    },
  };

  await leadController.deleteLead(
    {
      ...request,
      params: { leadId },
      user: context.user,
      userData: context.user,
    },
    res,
  );
  return NextResponse.json(responseData);
});
