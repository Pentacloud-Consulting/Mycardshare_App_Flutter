import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import {
  resolveAuth,
  checkCompanySuspended,
} from "@/backend/middleware/auth-handler";
import leadController from "@/backend/controllers/lead.controller";

/**
 * Lead Creation
 * POST /api/leads/create
 */
export const POST = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  await checkCompanySuspended(context);
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

  await leadController.createLead(
    { ...request, body, user: context.user, userData: context.user },
    res,
  );
  return NextResponse.json(responseData);
});
