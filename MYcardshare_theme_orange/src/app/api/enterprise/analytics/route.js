import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireAdmin } from "@/backend/middleware/auth-handler";
import { connectDB } from "@/backend/config/db";
import { success } from "@/backend/utils/apiResponse";

/**
 * Enterprise Analytics Data
 * GET /api/enterprise/analytics
 */

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const companyId = context.user?.companyId || context.uid;
  if (!companyId) {
    return NextResponse.json({ success: false, error: "No company associated" }, { status: 404 });
  }

  const db = await connectDB();
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

  // Strictly filter out enterprise organization / admin cards from team analytics
  const employeeCardFilter = {
    companyId,
    role: { $nin: ["enterprise", "admin", "super_admin"] },
    userId: { $ne: companyId }
  };
  if (context.user?.email) {
    employeeCardFilter.email = { $ne: context.user.email };
  }

  const [leadsCount, totalViewsAgg, leadTimeline, rawTopEmployees] = await Promise.all([
    db.collection("leads").countDocuments({ companyId }),
    db.collection("cards").aggregate([
      { $match: employeeCardFilter },
      { $group: { _id: null, totalViews: { $sum: "$views" } } }
    ]).toArray(),
    db.collection("leads").aggregate([
      { $match: { companyId, createdAt: { $gte: thirtyDaysAgo } } },
      { $group: { _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]).toArray(),
    db.collection("cards")
      .find(employeeCardFilter)
      .sort({ views: -1 })
      .limit(5)
      .project({ fullName: 1, name: 1, views: 1, jobTitle: 1, avatarUrl: 1, email: 1, userId: 1, slug: 1, cardSlug: 1 })
      .toArray()
  ]);

  let totalViews = totalViewsAgg[0]?.totalViews || 0;

  // Fallback / sync from authoritative companyService if raw query found no views yet
  let topEmployees = rawTopEmployees.map(e => ({
    _id: e._id,
    userId: e.userId,
    fullName: e.name || e.fullName || "Team Member",
    jobTitle: e.jobTitle || "Software Developer",
    avatarUrl: e.avatarUrl || "",
    views: Number(e.views || 0)
  }));

  // Ensure names match Firestore source of truth (e.g. Zulfi instead of company admin name)
  try {
    const { firestoreDb } = await import("@/backend/config/firebase");
    if (firestoreDb && companyId) {
      const empSnap = await firestoreDb
        .collection("enterprises")
        .doc(companyId)
        .collection("employees")
        .get();

      const firestoreEmpMap = new Map();
      for (const doc of empSnap.docs) {
        const d = doc.data();
        const key = d.uid || d.id || doc.id;
        firestoreEmpMap.set(key, d);
        if (d.email) firestoreEmpMap.set(d.email.toLowerCase(), d);
      }

      topEmployees = topEmployees.map(emp => {
        const fEmp = firestoreEmpMap.get(emp.userId) || (emp.email ? firestoreEmpMap.get(emp.email.toLowerCase()) : null);
        if (fEmp) {
          return {
            ...emp,
            fullName: fEmp.name || fEmp.fullName || emp.fullName,
            jobTitle: fEmp.jobTitle || fEmp.roleTitle || emp.jobTitle,
            avatarUrl: fEmp.avatarUrl || emp.avatarUrl,
            views: Math.max(emp.views, Number(fEmp.views || 0))
          };
        }
        return emp;
      });

      // If topEmployees is empty but employees exist in Firestore, surface them with 0 views
      if (topEmployees.length === 0 && empSnap.docs.length > 0) {
        for (const doc of empSnap.docs) {
          const d = doc.data();
          const dRole = (d.role || "").toLowerCase();
          if (dRole === "enterprise" || dRole === "admin" || dRole === "super_admin" || doc.id === companyId || d.uid === companyId || (context.user?.email && d.email?.toLowerCase() === context.user.email.toLowerCase())) continue;
          topEmployees.push({
            _id: doc.id,
            userId: d.uid || doc.id,
            fullName: d.name || d.fullName || "Team Member",
            jobTitle: d.jobTitle || d.roleTitle || "Employee",
            avatarUrl: d.avatarUrl || "",
            views: Number(d.views || 0)
          });
        }
      }
    }
  } catch (_) {}

  // Recalculate totalViews if employee views are higher
  const employeeViewsSum = topEmployees.reduce((sum, e) => sum + (e.views || 0), 0);
  if (employeeViewsSum > totalViews) {
    totalViews = employeeViewsSum;
  }

  return NextResponse.json(success({
    totalLeads: leadsCount,
    totalViews,
    leadTimeline: leadTimeline.map(t => ({ date: t._id, count: t.count })),
    topEmployees
  }));
});
