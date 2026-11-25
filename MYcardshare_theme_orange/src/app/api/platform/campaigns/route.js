import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireMasterAdmin } from "@/backend/middleware/auth-handler";
import { firestoreDb } from "@/backend/config/firebase";
import { success } from "@/backend/utils/apiResponse";

/**
 * GET /api/platform/campaigns — OPTIMIZED with parallel fetching
 */
export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  const companiesSnap = await firestoreDb.collection("companies").get();

  // Fetch all campaigns in parallel
  const results = await Promise.all(
    companiesSnap.docs.map(async (companyDoc) => {
      const companyData = companyDoc.data();
      const campSnap = await firestoreDb
        .collection("companies").doc(companyDoc.id).collection("campaigns").get();
      return campSnap.docs.map((d) => {
        const data = d.data();
        return {
          id: d.id, companyId: companyDoc.id,
          companyName: companyData.companyName || "Unknown",
          name: data.name || "", description: data.description || "",
          budget: data.budget || null, startDate: data.startDate || null,
          endDate: data.endDate || null, isActive: data.isActive ?? true,
          imageUrl: data.imageUrl || null, area: data.area || data.emirate || null,
          createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
          updatedAt: data.updatedAt?.toDate?.()?.toISOString() || null,
        };
      });
    })
  );

  const allCampaigns = results.flat();
  allCampaigns.sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));
  return NextResponse.json(success(allCampaigns));
});
