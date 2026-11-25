import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireMasterAdmin } from "@/backend/middleware/auth-handler";
import { firestoreDb } from "@/backend/config/firebase";
import { connectDB } from "@/backend/config/db";
import { success } from "@/backend/utils/apiResponse";

/**
 * GET /api/platform/dashboard
 * Master-admin aggregated dashboard — OPTIMIZED with parallel fetching
 */
export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  // ── Parallel fetch: companies, users, leads (all at once) ─────
  const [companiesSnapshot, usersSnap, db] = await Promise.all([
    firestoreDb.collection("companies").get(),
    firestoreDb.collection("users").get(),
    connectDB(),
  ]);

  const companies = companiesSnapshot.docs.map((d) => ({
    id: d.id,
    ...d.data(),
    createdAt: d.data().createdAt?.toDate?.() || null,
  }));

  const totalCompanies = companies.length;
  const pendingApprovals = companies.filter((c) => (c.approvalStatus || "pending") === "pending").length;
  const approvedCompanies = companies.filter((c) => c.approvalStatus === "approved").length;
  const rejectedCompanies = companies.filter((c) => c.approvalStatus === "rejected").length;
  const suspendedCompanies = companies.filter((c) => c.isSuspended === true).length;
  const totalUsers = usersSnap.size;

  // Renewals this month
  const now = new Date();
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
  const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);
  const renewalsThisMonth = companies.filter((c) => {
    const rd = c.renewalDate?.toDate?.() || (c.renewalDate ? new Date(c.renewalDate) : null);
    if (!rd) return false;
    return rd >= startOfMonth && rd <= endOfMonth;
  }).length;

  // ── Parallel: campaigns (all companies at once) + lead aggregations ──
  const leadsCollection = db.collection("leads");
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

  const [campaignResults, totalLeads, leadsByCompany, leadTimeline, recentLeads] = await Promise.all([
    // Campaigns: fetch all companies in parallel
    Promise.all(
      companies.map(async (company) => {
        const campSnap = await firestoreDb
          .collection("companies").doc(company.id).collection("campaigns").get();
        return campSnap.docs.map((d) => {
          const data = d.data();
          return {
            id: d.id, companyId: company.id,
            companyName: company.companyName || "Unknown",
            isActive: data.isActive ?? true,
            createdAt: data.createdAt?.toDate?.() || null,
          };
        });
      })
    ),
    leadsCollection.countDocuments({}),
    leadsCollection.aggregate([
      { $group: { _id: "$companyId", count: { $sum: 1 } } },
      { $sort: { count: -1 } }, { $limit: 10 },
    ]).toArray(),
    leadsCollection.aggregate([
      { $match: { createdAt: { $gte: thirtyDaysAgo } } },
      { $group: { _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } },
    ]).toArray(),
    leadsCollection.find({}).sort({ createdAt: -1 }).limit(10).toArray(),
  ]);

  const allCampaigns = campaignResults.flat();
  const activeCampaigns = allCampaigns.filter((c) => c.isActive === true).length;
  const inactiveCampaigns = allCampaigns.filter((c) => c.isActive === false).length;

  const topCompaniesByLeads = leadsByCompany.map((item) => {
    const comp = companies.find((c) => c.id === item._id);
    return { companyId: item._id, companyName: comp?.companyName || item._id || "Unknown", leadCount: item.count };
  });

  // Signup timeline (pure computation, no DB)
  const signupTimeline = [];
  for (let i = 29; i >= 0; i--) {
    const d = new Date(); d.setDate(d.getDate() - i);
    const dateStr = d.toISOString().split("T")[0];
    const count = companies.filter((c) => {
      if (!c.createdAt) return false;
      return new Date(c.createdAt).toISOString().split("T")[0] === dateStr;
    }).length;
    signupTimeline.push({ date: dateStr, count });
  }

  // Recent activity
  const recentActivity = [];
  companies.forEach((c) => {
    if (c.createdAt) {
      recentActivity.push({ type: "company_registered", message: `${c.companyName || "Unknown"} registered`, timestamp: new Date(c.createdAt).toISOString() });
    }
    if (c.approvalStatus === "approved" && c.updatedAt) {
      const ts = c.updatedAt?.toDate?.() || c.updatedAt;
      if (ts) recentActivity.push({ type: "company_approved", message: `${c.companyName || "Unknown"} approved`, timestamp: new Date(ts).toISOString() });
    }
  });
  recentLeads.forEach((lead) => {
    const comp = companies.find((c) => c.id === lead.companyId);
    recentActivity.push({ type: "lead_created", message: `New lead: ${lead.fullName || "Unknown"} (${comp?.companyName || lead.companyId})`, timestamp: lead.createdAt ? new Date(lead.createdAt).toISOString() : null });
  });
  recentActivity.sort((a, b) => new Date(b.timestamp || 0) - new Date(a.timestamp || 0));

  return NextResponse.json(success({
    stats: { totalCompanies, pendingApprovals, approvedCompanies, rejectedCompanies, suspendedCompanies, totalLeads, totalCampaigns: allCampaigns.length, activeCampaigns, inactiveCampaigns, totalUsers, renewalsThisMonth },
    recentActivity: recentActivity.slice(0, 20),
    signupTimeline,
    leadTimeline: leadTimeline.map((t) => ({ date: t._id, count: t.count })),
    campaignBreakdown: { active: activeCampaigns, inactive: inactiveCampaigns },
    topCompaniesByLeads,
    approvalBreakdown: { approved: approvedCompanies, pending: pendingApprovals, rejected: rejectedCompanies, suspended: suspendedCompanies },
  }));
});
