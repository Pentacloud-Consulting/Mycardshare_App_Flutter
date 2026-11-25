import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireAdmin } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Enterprise Workspace Management (Employees)
 * GET /api/enterprise/workspace
 */

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const companyId = context.user?.companyId || context.uid;
  if (!companyId) {
    return NextResponse.json({ success: false, error: "No company associated" }, { status: 404 });
  }

  const employees = await companyService.listEmployees(companyId);
  return NextResponse.json(success(employees));
});
