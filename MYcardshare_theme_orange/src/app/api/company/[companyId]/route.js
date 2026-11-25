import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireAdmin } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Manage Company details
 * GET /api/company/[companyId]
 * PUT /api/company/[companyId]
 */

export const GET = apiAdapter(async (request, { params }) => {
  await resolveAuth(request);
  const { companyId } = await params;
  const company = await companyService.getCompany(companyId);

  if (!company) {
    return NextResponse.json(
      { success: false, error: "Company not found" },
      { status: 404 },
    );
  }

  return NextResponse.json(success(company));
});

export const PUT = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const { companyId } = await params;
  const { updates } = await request.json();

  await companyService.updateCompany(companyId, updates);

  return NextResponse.json(
    success({ message: "Company updated successfully" }),
  );
});
