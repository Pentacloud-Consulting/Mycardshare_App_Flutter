import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import companyService from "@/backend/services/company.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Public Branding lookup
 * GET /api/company/[companyId]/public-branding
 */
export const GET = apiAdapter(async (request, { params }) => {
  const { companyId } = await params;
  const branding = await companyService.getPublicBranding(companyId);

  if (!branding) {
    return NextResponse.json(
      { success: false, error: "Company branding not found" },
      { status: 404 },
    );
  }

  return NextResponse.json(success(branding));
});
