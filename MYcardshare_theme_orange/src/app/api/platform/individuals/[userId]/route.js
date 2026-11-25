import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import {
  resolveAuth,
  requireMasterAdmin,
} from "@/backend/middleware/auth-handler";
import platformService from "@/backend/services/platform.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * DELETE /api/platform/individuals/:userId
 * Delete an individual user and all related data
 */
export const DELETE = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  const { userId } = await params;
  await platformService.deleteIndividual(userId);
  return NextResponse.json(success({ message: "Individual deleted successfully" }));
});
