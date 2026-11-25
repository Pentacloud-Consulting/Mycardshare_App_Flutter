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
  const body = await request.json().catch(() => ({}));
  const action = body.action || "approve";

  let updates;
  if (action === "approve") {
    const now = new Date();
    const renewalDate = new Date(now);
    renewalDate.setDate(renewalDate.getDate() + 365);
    updates = {
      status: "active",
      approvalStatus: "approved",
      isSuspended: false,
      subscriptionStartDate: now,
      renewalDate: renewalDate,
      subscriptionStatus: "active",
    };
  } else {
    updates = {
      status: "rejected",
      approvalStatus: "rejected",
      isSuspended: true,
      subscriptionStatus: "inactive",
    };
  }

  await platformService.updateCompanyStatus(companyId, updates);
  return NextResponse.json(
    success({ message: `Company ${action}d successfully`, action, status: updates.status }),
  );
});

export const POST = PATCH;

