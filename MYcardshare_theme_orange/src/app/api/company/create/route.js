import { NextResponse } from "next/server";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import companyService from "@/backend/services/company.service";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { success } from "@/backend/utils/apiResponse";

export const POST = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const body = await request.json();

  const master = process.env.ENTERPRISE_REGISTRATION_MASTER_KEY?.trim();
  if (master) {
    const provided = String(body.registrationSecret ?? "").trim();
    if (provided !== master) {
      throw new AppError(
        "Enterprise signup requires a valid organization invitation code.",
        403,
      );
    }
  }
  const { registrationSecret: _rs, ...companyPayload } = body;

  // Link the current user as the admin of the new company
  const result = await companyService.createCompany({
    ...companyPayload,
    adminUserId: context.uid,
  });

  return NextResponse.json(success(result), { status: 201 });
});
