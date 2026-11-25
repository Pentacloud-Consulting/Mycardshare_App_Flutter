import { NextResponse } from "next/server";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { resolveAuth, requireAdmin } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * POST /api/company/[companyId]/invite
 * Admin-only. Records an invitation for this company and (when email
 * transport is configured) dispatches the invite email.
 */
export const POST = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const { companyId } = await params;
  const body = await request.json().catch(() => ({}));
  const email = String(body?.email || "").trim().toLowerCase();

  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new AppError("A valid work email is required.", 400);
  }

  if (context.user.companyId !== companyId) {
    throw new AppError("You can only invite to your own organization.", 403);
  }

  const company = await companyService.getCompany(companyId);
  if (!company) throw new AppError("Company not found.", 404);

  await companyService.sendInvitation(companyId, email);

  return NextResponse.json(
    success({
      message: `Invitation recorded for ${email}.`,
      email,
      voucherCode: company.voucherCode,
      signupUrl: `/signup?voucher=${encodeURIComponent(company.voucherCode || "")}`,
    }),
  );
});
