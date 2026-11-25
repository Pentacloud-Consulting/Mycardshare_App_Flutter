import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import {
  resolveAuth,
  requireMasterAdmin,
} from "@/backend/middleware/auth-handler";
import platformService from "@/backend/services/platform.service";
import { success } from "@/backend/utils/apiResponse";

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  const superAdmins = await platformService.listSuperAdmins();
  return NextResponse.json(success({ superAdmins }));
});
