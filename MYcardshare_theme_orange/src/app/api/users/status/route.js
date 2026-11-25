import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireAdmin } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Update User Status (Active/Inactive)
 * PATCH /api/users/status
 */
export const PATCH = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const { userId, status } = await request.json();

  const companyId = context.user?.companyId || context.user?.enterpriseUid || context.uid;
  if (!companyId) {
    return NextResponse.json({ success: false, error: "No company associated" }, { status: 404 });
  }

  if (!userId || !status) {
    return NextResponse.json({ success: false, error: "Missing userId or status" }, { status: 400 });
  }

  // Ensure caller is not updating users outside their company
  await companyService.updateUserStatus(userId, status, companyId);
  
  return NextResponse.json(success({ message: "Status updated successfully" }));
});
