import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import {
  resolveAuth,
  requireMasterAdmin,
} from "@/backend/middleware/auth-handler";
import platformService from "@/backend/services/platform.service";
import { success } from "@/backend/utils/apiResponse";

export const PATCH = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  const { companyId } = await params;
  const { isSuspended } = await request.json();

  await platformService.updateCompanyStatus(companyId, { isSuspended });
  return NextResponse.json(
    success({ message: "Company suspension updated", isSuspended }),
  );
});
