import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireAdmin } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Enterprise Workspace Invite
 * POST /api/enterprise/workspace/invite
 */
export const POST = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const companyId = context.user?.companyId || context.uid;
  if (!companyId) {
    return NextResponse.json({ success: false, error: "No company associated" }, { status: 404 });
  }

  const { email } = await request.json();
  if (!email) {
    return NextResponse.json({ success: false, error: "Email required" }, { status: 400 });
  }

  await companyService.sendInvitation(companyId, email);
  return NextResponse.json(success({ message: `Invitation sent to ${email}` }));
});
