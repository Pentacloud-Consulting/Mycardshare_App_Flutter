import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { connectDB } from "@/backend/config/db";
import companyService from "@/backend/services/company.service";
import { success } from "@/backend/utils/apiResponse";

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const companyId = context.user?.companyId || context.user?.workspaceId || context.uid;

  if (!companyId) {
    return NextResponse.json(
      { success: false, error: "Company not found" },
      { status: 404 },
    );
  }

  const db = await connectDB();

  // 1. Fetch Company Employees using the authoritative companyService (exact same source as Workspace)
  let employees = [];
  try {
    employees = await companyService.listEmployees(companyId);
  } catch (err) {
    console.error("[Company/Stats] Failed to list employees via companyService:", err);
  }

  const employeeCount = employees.length;
  const activeCards = employees.filter((e) => {
    const s = String(e.cardStatus || "").toLowerCase().trim();
    return s === "published" || s === "live" || s === "active" || s === "public";
  }).length;
  const draftCards = employees.filter((e) => {
    const s = String(e.cardStatus || "").toLowerCase().trim();
    return !s || s === "draft" || s === "private";
  }).length;

  const leadsCount = await db.collection("leads").countDocuments({ companyId });

  // 2. Fetch aggregated views for the enterprise (excluding admin/enterprise card)
  const cardAgg = await db
    .collection("cards")
    .aggregate([
      { 
        $match: { 
          companyId,
          role: { $nin: ["enterprise", "admin", "super_admin"] },
          userId: { $ne: companyId }
        } 
      },
      { $group: { _id: null, totalViews: { $sum: "$views" } } },
    ])
    .toArray();

  let totalViews = cardAgg[0]?.totalViews || 0;

  // Dual-sync views to Firestore so mobile app listeners immediately reflect real metrics
  try {
    const { firestoreDb } = await import("@/backend/config/firebase");
    if (firestoreDb && companyId) {
      // 1. Sync enterprise document views
      const entRef = firestoreDb.collection("enterprises").doc(companyId);
      const entDoc = await entRef.get();
      const currentEntViews = Number(entDoc.data()?.views || 0);
      if (totalViews > currentEntViews) {
        await entRef.set({ views: totalViews }, { merge: true });
      } else if (currentEntViews > totalViews) {
        totalViews = currentEntViews;
      }

      // 2. Sync employee document views in enterprises/{companyId}/employees
      for (const emp of employees) {
        if (!emp.userId) continue;
        const empCard = await db.collection("cards").findOne({ 
          userId: emp.userId,
          companyId 
        });
        const empViews = Number(empCard?.views || 0);
        if (empViews > 0) {
          const empDocRef = entRef.collection("employees").doc(emp.userId);
          await empDocRef.set({ 
            views: empViews,
            cardStatus: emp.cardStatus || "Published",
            status: "Active"
          }, { merge: true });

          const userDocRef = firestoreDb.collection("users").doc(emp.userId);
          await userDocRef.set({ views: empViews }, { merge: true });
        }
      }
    }
  } catch (syncErr) {
    console.warn("[Company/Stats] Firestore dual-sync note:", syncErr?.message);
  }

  // 3. Fetch Workforce preview
  const workforce = employees.slice(0, 10).map((e) => ({
    fullName: e.fullName,
    jobTitle: e.jobTitle,
    avatarUrl: e.avatarUrl,
    lastUpdated: e.lastUpdated,
    cardStatus: e.cardStatus,
  }));

  // 4. Workspace Admins count
  const adminsCount = 1;

  const stats = {
    totalWorkforce: employeeCount,
    activeCards,
    draftCards,
    workspaceAdmins: adminsCount,
    totalLeads: leadsCount,
    engagement: totalViews,
    totalViews,
    activeCampaigns: 1,
    weeklyEngagementTrends: "+5.2%",
    workforce: workforce || [],
  };

  return NextResponse.json(success({ 
    totalViews,
    employeeCount,
    activeCards,
    draftCards,
    leadsCount,
    stats 
  }));
});
