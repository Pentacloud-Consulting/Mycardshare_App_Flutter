import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireAdmin } from "@/backend/middleware/auth-handler";
import { isMasterAdmin, isEnterprise } from "@/lib/roles";
import companyService from "@/backend/services/company.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Employee management for a company
 * GET /api/company/[companyId]/employees
 */
export const GET = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  const { companyId } = await params;
  
  const user = context.user;
  const role = user?.role;
  const isMember = user?.companyId === companyId || user?.workspaceId === companyId;
  if (!isMasterAdmin(role) && !isEnterprise(role) && !isMember) {
    requireAdmin(context);
  }

  const employees = await companyService.listEmployees(companyId);

  return NextResponse.json(success({ employees }));
});
