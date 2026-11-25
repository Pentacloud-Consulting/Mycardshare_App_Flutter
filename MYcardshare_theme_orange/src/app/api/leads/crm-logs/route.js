import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import leadController from "@/backend/controllers/lead.controller";

/**
 * CRM Logs Retrieval
 * GET /api/leads/crm-logs
 */
export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  let responseData = null;
  const res = {
    json: (data) => {
      responseData = data;
    },
  };

  await leadController.getCrmLogs(
    { ...request, user: context.user, userData: context.user },
    res,
  );
  return NextResponse.json(responseData);
});
