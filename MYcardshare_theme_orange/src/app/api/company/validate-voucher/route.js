import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import companyService from "@/backend/services/company.service";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { success } from "@/backend/utils/apiResponse";

export const POST = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const body = await request.json();
  const { voucherCode, workspaceId, skip } = body || {};

  const result = await companyService.validateVoucher(voucherCode, context.uid, {
    skip: Boolean(skip),
    workspaceId
  });

  return NextResponse.json(success(result));
});
