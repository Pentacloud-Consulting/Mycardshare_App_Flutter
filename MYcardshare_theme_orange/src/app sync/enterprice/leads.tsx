import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/backend/config/db";
import { resolveAuth, requireAdmin } from "@/backend/middleware/auth-handler";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

/**
 * ENTERPRISE LEADS & DATE FILTER SYNC API (MOBILE APP <-> NEXT.JS WEB)
 *
 * GET /api/sync/enterprise-leads
 * Query Params:
 *  - companyId: string (optional, falls back to auth user's companyId)
 *  - dateFrom: string (ISO string or YYYY-MM-DD)
 *  - dateTo: string (ISO string or YYYY-MM-DD)
 *  - filter: 'all' | 'this_week' | 'sync_failed' | 'new' | 'crm_synced'
 *  - employeeId / agentId: string (filter by specific team member)
 *  - search: string (search in name, company, email, mobile)
 *
 * POST /api/sync/enterprise-leads
 * Create lead from mobile with automatic CRM synchronization & campaign link.
 */
export const GET = apiAdapter(async (request: NextRequest) => {
  try {
    const context = await resolveAuth(request);
    
    // Determine companyId
    const { searchParams } = new URL(request.url);
    const queryCompanyId = searchParams.get("companyId");
    const companyId = queryCompanyId || context.user?.companyId;

    if (!companyId) {
      return NextResponse.json(
        fail("NO_COMPANY_BOUND", "Company ID is required to fetch enterprise leads."),
        { status: 400 }
      );
    }

    const dateFrom = searchParams.get("dateFrom");
    const dateTo = searchParams.get("dateTo");
    const filter = searchParams.get("filter") || "all";
    const agentId = searchParams.get("agentId") || searchParams.get("employeeId");
    const search = searchParams.get("search") || "";

    const db = await connectDB();
    const collection = db.collection("leads");

    // Base query for enterprise
    const query: any = { companyId };

    // Employee / Agent Filter
    if (agentId && agentId !== "all") {
      query.$or = [{ agentId }, { employeeId: agentId }, { userId: agentId }];
    }

    // Date Range Filter (Calendar icon trigger)
    if (dateFrom || dateTo) {
      query.createdAt = {};
      if (dateFrom) {
        const fromDate = new Date(dateFrom);
        fromDate.setHours(0, 0, 0, 0);
        query.createdAt.$gte = fromDate;
      }
      if (dateTo) {
        const toDate = new Date(dateTo);
        toDate.setHours(23, 59, 59, 999);
        query.createdAt.$lte = toDate;
      }
    }

    // Specific Status Filters
    const now = new Date();
    if (filter === "this_week") {
      const startOfWeek = new Date(now);
      startOfWeek.setDate(now.getDate() - now.getDay());
      startOfWeek.setHours(0, 0, 0, 0);
      query.createdAt = { ...(query.createdAt || {}), $gte: startOfWeek };
    } else if (filter === "sync_failed") {
      query.$or = [
        { crmStatus: "failed" },
        { crmSyncStatus: "failed" },
        { syncFailed: true }
      ];
    } else if (filter === "new") {
      const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
      query.createdAt = { ...(query.createdAt || {}), $gte: twentyFourHoursAgo };
    } else if (filter === "crm_synced") {
      query.$or = [
        { crmStatus: "synced" },
        { crmSyncStatus: "synced" },
        { crmSynced: true }
      ];
    }

    // Text Search
    if (search.trim()) {
      const regex = new RegExp(search.trim(), "i");
      query.$and = query.$and || [];
      query.$and.push({
        $or: [
          { name: regex },
          { fullName: regex },
          { email: regex },
          { mobile: regex },
          { phone: regex },
          { company: regex },
          { notes: regex },
          { employeeName: regex }
        ]
      });
    }

    // Fetch matching leads
    const leads = await collection
      .find(query)
      .sort({ createdAt: -1 })
      .toArray();

    // Calculate Enterprise Quick Metrics
    const totalLeads = await collection.countDocuments({ companyId });
    
    const startOfWeek = new Date(now);
    startOfWeek.setDate(now.getDate() - now.getDay());
    startOfWeek.setHours(0, 0, 0, 0);
    const thisWeekLeads = await collection.countDocuments({
      companyId,
      createdAt: { $gte: startOfWeek }
    });

    const syncFailedLeads = await collection.countDocuments({
      companyId,
      $or: [
        { crmStatus: "failed" },
        { crmSyncStatus: "failed" },
        { syncFailed: true }
      ]
    });

    // Format for Flutter mobile UI consumption
    const formattedLeads = leads.map((l: any) => ({
      id: l._id.toString(),
      leadId: l._id.toString(),
      name: l.name || l.fullName || "Anonymous Lead",
      email: l.email || "",
      mobile: l.mobile || l.phone || "",
      company: l.company || "",
      jobTitle: l.jobTitle || l.title || "",
      employeeId: l.agentId || l.employeeId || l.userId || "",
      employeeName: l.employeeName || l.agentName || "Team Member",
      campaignId: l.campaignId || null,
      campaignName: l.campaignName || null,
      notes: l.notes || "",
      crmStatus: l.crmStatus || (l.syncFailed ? "failed" : "synced"),
      tags: l.tags || [],
      capturedAt: l.createdAt ? new Date(l.createdAt).toISOString() : new Date().toISOString(),
      updatedAt: l.updatedAt ? new Date(l.updatedAt).toISOString() : new Date().toISOString()
    }));

    return NextResponse.json(
      success({
        metrics: {
          total: totalLeads,
          thisWeek: thisWeekLeads,
          syncFailed: syncFailedLeads
        },
        filterApplied: {
          filter,
          dateFrom: dateFrom || null,
          dateTo: dateTo || null,
          agentId: agentId || null,
          search: search || null
        },
        leads: formattedLeads
      })
    );
  } catch (err: any) {
    console.error("❌ [Enterprise Leads Sync] Error:", err);
    return NextResponse.json(
      fail("LEADS_FETCH_FAILED", err.message || "Failed to fetch enterprise leads"),
      { status: 500 }
    );
  }
});

export const POST = apiAdapter(async (request: NextRequest) => {
  try {
    const context = await resolveAuth(request);
    const body = await request.json();

    const companyId = body.companyId || context.user?.companyId;
    if (!companyId) {
      return NextResponse.json(
        fail("NO_COMPANY_BOUND", "Company ID is required to create a lead"),
        { status: 400 }
      );
    }

    const {
      name,
      fullName,
      email,
      mobile,
      phone,
      company,
      jobTitle,
      employeeId,
      employeeName,
      campaignId,
      campaignName,
      notes
    } = body;

    const contactMobile = mobile || phone || "";
    const contactName = name || fullName || "New Lead";

    const db = await connectDB();
    const collection = db.collection("leads");

    // Prevent duplicate lead by mobile under same company
    if (contactMobile) {
      const duplicate = await collection.findOne({
        companyId,
        $or: [{ mobile: contactMobile }, { phone: contactMobile }]
      });
      if (duplicate) {
        return NextResponse.json(
          fail("DUPLICATE_LEAD", "A lead with this phone number already exists in your enterprise."),
          { status: 409 }
        );
      }
    }

    const newLead = {
      companyId,
      name: contactName,
      fullName: contactName,
      email: email || "",
      mobile: contactMobile,
      phone: contactMobile,
      company: company || "",
      jobTitle: jobTitle || "",
      agentId: employeeId || context.user?.uid || "",
      employeeId: employeeId || context.user?.uid || "",
      employeeName: employeeName || context.user?.name || "Team Member",
      campaignId: campaignId || null,
      campaignName: campaignName || null,
      notes: notes || "",
      crmStatus: "synced",
      syncFailed: false,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const result = await collection.insertOne(newLead);

    return NextResponse.json(
      success({
        id: result.insertedId.toString(),
        leadId: result.insertedId.toString(),
        ...newLead
      }, "Lead captured successfully"),
      { status: 201 }
    );
  } catch (err: any) {
    console.error("❌ [Enterprise Create Lead] Error:", err);
    return NextResponse.json(
      fail("LEAD_CREATE_FAILED", err.message || "Failed to create lead"),
      { status: 500 }
    );
  }
});
