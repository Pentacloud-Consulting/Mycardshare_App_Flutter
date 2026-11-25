import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import companyService from "@/backend/services/company.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Unified Company Action Route
 * POST /api/company/create
 * PATCH /api/company/crm-config
 * POST /api/company/validate-voucher
 */

export const POST = apiAdapter(async (request) => {
  const url = new URL(request.url);
  const path = url.pathname;

  if (path.endsWith("/create")) {
    const body = await request.json();
    const result = await companyService.createCompany(body);
    return NextResponse.json(success(result), { status: 201 });
  }

  if (path.endsWith("/validate-voucher")) {
    const { voucherCode, companyId } = await request.json();
    const result = await companyService.validateVoucher(voucherCode, companyId);
    return NextResponse.json(success(result));
  }

  return NextResponse.json(
    { success: false, error: "Action not found" },
    { status: 404 },
  );
});
