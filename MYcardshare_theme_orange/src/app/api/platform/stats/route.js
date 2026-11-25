import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import {
  resolveAuth,
  requireMasterAdmin,
} from "@/backend/middleware/auth-handler";
import platformService from "@/backend/services/platform.service";
import { firestoreDb } from "@/backend/config/firebase";
import { success } from "@/backend/utils/apiResponse";

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  // Fetch real-time metrics for the master dashboard
  const [companies, superAdmins, usersSnapshot] = await Promise.all([
    platformService.listCompanies(),
    platformService.listSuperAdmins(),
    firestoreDb.collection("users").get(),
  ]);

  const stats = {
    totalCompanies: companies.length,
    pendingApprovals: companies.filter((c) => c.approvalStatus === "pending")
      .length,
    systemAdmins: superAdmins.length,
    totalUsers: usersSnapshot.size,
    activeNodes: companies.filter((c) => !c.isSuspended).length,
  };

  return NextResponse.json(success({ stats }));
});
