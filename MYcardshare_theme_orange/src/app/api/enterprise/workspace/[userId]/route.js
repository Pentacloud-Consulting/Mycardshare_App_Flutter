import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireAdmin } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Update Workspace Employee Role
 * PATCH /api/enterprise/workspace/[userId]
 */
export const PATCH = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const { userId } = await params;
  const { role } = await request.json();

  const companyId = context.user?.companyId || context.uid;
  if (!companyId) {
    return NextResponse.json({ success: false, error: "No company associated" }, { status: 404 });
  }

  // Ensure caller is not updating their own role to circumvent limits or that we pass the current user's companyId
  await companyService.updateUserRole(userId, role, companyId);
  
  return NextResponse.json(success({ message: "Role updated successfully" }));
});

/**
 * Remove Workspace Employee
 * DELETE /api/enterprise/workspace/[userId]
 */
export const DELETE = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const { userId } = await params;

  const companyId = context.user?.companyId || context.uid;
  if (!companyId) {
    return NextResponse.json({ success: false, error: "No company associated" }, { status: 404 });
  }

  await companyService.removeEmployee(userId, companyId);
  
  return NextResponse.json(success({ message: "Employee removed successfully" }));
});
