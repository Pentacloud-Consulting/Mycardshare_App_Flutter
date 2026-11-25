import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireMasterAdmin } from "@/backend/middleware/auth-handler";
import { firestoreDb } from "@/backend/config/firebase";
import { connectDB } from "@/backend/config/db";
import { ObjectId } from "mongodb";
import { success } from "@/backend/utils/apiResponse";

/**
 * GET /api/platform/leads — All leads across all companies
 */
export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  const { searchParams } = new URL(request.url);
  const companyId = searchParams.get("companyId");
  const campaignId = searchParams.get("campaignId");
  const dateFrom = searchParams.get("dateFrom");
  const dateTo = searchParams.get("dateTo");

  const db = await connectDB();
  const query = {};
  if (companyId) query.companyId = companyId;
  if (campaignId) query.campaignId = campaignId;
  if (dateFrom || dateTo) {
    query.createdAt = {};
    if (dateFrom) query.createdAt.$gte = new Date(dateFrom);
    if (dateTo) query.createdAt.$lte = new Date(dateTo);
  }

  const [leads, companiesSnap] = await Promise.all([
    db.collection("leads").find(query).sort({ createdAt: -1 }).limit(500).toArray(),
    firestoreDb.collection("companies").get(),
  ]);

  const companyMap = {};
  companiesSnap.docs.forEach((d) => { companyMap[d.id] = d.data().companyName || "Unknown"; });

  const enriched = leads.map((lead) => ({
    ...lead, _id: lead._id.toString(),
    companyName: companyMap[lead.companyId] || lead.companyId || "Unknown",
  }));

  return NextResponse.json(success(enriched));
});

/**
 * POST /api/platform/leads — Create a lead
 */
export const POST = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  const body = await request.json();
  const { fullName, mobile, email, companyId, campaignId, nationality, budgetRange, propertyType, source } = body;

  if (!fullName || !mobile) {
    return NextResponse.json({ success: false, error: "fullName and mobile are required" }, { status: 400 });
  }

  const db = await connectDB();
  const lead = {
    fullName, mobile, email: email || "",
    companyId: companyId || "", campaignId: campaignId || "",
    nationality: nationality || "", budgetRange: budgetRange || "",
    propertyType: propertyType || "", source: source || "master-admin",
    status: "New", agentId: context.uid,
    createdAt: new Date(), updatedAt: new Date(),
  };

  const result = await db.collection("leads").insertOne(lead);
  return NextResponse.json(success({ leadId: result.insertedId.toString() }));
});

/**
 * DELETE /api/platform/leads?id=xxx — Delete a lead
 */
export const DELETE = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  const { searchParams } = new URL(request.url);
  const leadId = searchParams.get("id");

  if (!leadId) {
    return NextResponse.json({ success: false, error: "Lead ID required" }, { status: 400 });
  }

  const db = await connectDB();
  const result = await db.collection("leads").deleteOne({ _id: new ObjectId(leadId) });

  if (result.deletedCount === 0) {
    return NextResponse.json({ success: false, error: "Lead not found" }, { status: 404 });
  }

  return NextResponse.json(success({ message: "Lead deleted" }));
});
