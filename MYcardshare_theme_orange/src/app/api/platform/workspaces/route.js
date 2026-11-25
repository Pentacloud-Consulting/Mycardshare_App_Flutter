import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireMasterAdmin } from "@/backend/middleware/auth-handler";
import { firestoreDb } from "@/backend/config/firebase";
import { connectDB } from "@/backend/config/db";
import { success } from "@/backend/utils/apiResponse";

/**
 * Master Admin Workspace Overview
 * GET /api/platform/workspaces
 */

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  const [companiesSnap, db] = await Promise.all([
    firestoreDb.collection("companies").get(),
    connectDB(),
  ]);

  const companies = companiesSnap.docs.map(d => ({
    id: d.id,
    ...d.data(),
    createdAt: d.data().createdAt?.toDate?.() || null
  }));

  // Get member counts from MongoDB for all companies in parallel
  const cardsCollection = db.collection("cards");
  const workspaceStats = await Promise.all(companies.map(async (c) => {
    const memberCount = await cardsCollection.countDocuments({ companyId: c.id });
    const activeCards = await cardsCollection.countDocuments({ companyId: c.id, cardStatus: "active" });
    return {
      ...c,
      memberCount,
      activeCards,
    };
  }));

  return NextResponse.json(success(workspaceStats));
});
