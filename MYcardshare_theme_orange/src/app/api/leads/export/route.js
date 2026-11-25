import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import leadController from "@/backend/controllers/lead.controller";

/**
 * Lead Export
 * GET /api/leads/export
 */
export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);

  // Extract query params for use in exportLeads
  const { searchParams } = new URL(request.url);
  const query = Object.fromEntries(searchParams.entries());

  let csvData = null;
  let headersSet = {};

  const res = {
    setHeader: (name, value) => {
      headersSet[name] = value;
    },
    send: (data) => {
      csvData = data;
    },
  };

  await leadController.exportLeads(
    { ...request, query, user: context.user, userData: context.user },
    res,
  );

  return new NextResponse(csvData, {
    status: 200,
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition":
        headersSet["Content-Disposition"] ||
        'attachment; filename="leads_export.csv"',
    },
  });
});
