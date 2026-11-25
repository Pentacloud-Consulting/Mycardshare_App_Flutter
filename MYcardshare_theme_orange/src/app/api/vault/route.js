import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { success } from "@/backend/utils/apiResponse";
import { getMergedContacts } from "@/app/api/scanned-contacts/route";

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const contacts = await getMergedContacts(context.uid);
  return NextResponse.json(success(contacts));
});
