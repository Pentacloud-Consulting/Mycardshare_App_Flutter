import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import leadController from "@/backend/controllers/lead.controller";

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  let responseData = null;
  const res = {
    json: (data) => {
      responseData = data;
    },
  };

  // Extract query params for use in listLeads
  const { searchParams } = new URL(request.url);
  const query = Object.fromEntries(searchParams.entries());

  await leadController.listLeads(
    { ...request, query, user: context.user, userData: context.user },
    res,
  );
  return NextResponse.json(responseData);
});
