import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireAdmin } from "@/backend/middleware/auth-handler";
import { connectDB } from "@/backend/config/db";
import { firestoreDb, admin } from "@/backend/config/firebase";
import { ObjectId } from "mongodb";
import { success } from "@/backend/utils/apiResponse";

/**
 * Enterprise Lead Management
 * GET /api/enterprise/leads
 * POST /api/enterprise/leads
 * DELETE /api/enterprise/leads?id=xxx
 */

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const companyId = context.user?.companyId || context.user?.enterpriseUid || context.uid;
  if (!companyId) {
    return NextResponse.json({ success: false, error: "No company associated" }, { status: 404 });
  }

  const { searchParams } = new URL(request.url);
  const campaignId = searchParams.get("campaignId");
  const agentId = searchParams.get("agentId");

  const leadsMap = new Map();

  // 1. Fetch from MongoDB
  try {
    const db = await connectDB();
    const query = { companyId };
    if (campaignId) query.campaignId = campaignId;
    if (agentId) query.agentId = agentId;

    const mongoLeads = await db.collection("leads").find(query).sort({ createdAt: -1 }).limit(1000).toArray();
    for (const l of mongoLeads) {
      const idStr = l._id?.toString() || l.id;
      leadsMap.set(idStr, { ...l, _id: idStr });
    }
  } catch (mErr) {
    console.warn("[Enterprise Leads] MongoDB query notice:", mErr?.message);
  }

  // 2. Fetch from Firestore enterprises/{companyId}/leads (saved by mobile app)
  try {
    const entLeadsSnap = await firestoreDb.collection("enterprises").doc(companyId).collection("leads").get();
    for (const doc of entLeadsSnap.docs) {
      if (!leadsMap.has(doc.id)) {
        const d = doc.data();
        leadsMap.set(doc.id, {
          _id: doc.id,
          id: doc.id,
          fullName: d.name || d.fullName || "Lead Contact",
          mobile: d.phone || d.mobile || "",
          email: d.email || "",
          companyId,
          campaignId: d.campaignId || "",
          nationality: d.nationality || "",
          budgetRange: d.budgetRange || d.budget || "",
          propertyType: d.propertyType || "",
          source: d.source || "mobile",
          status: d.status || "New",
          createdAt: d.createdAt?.toDate?.() || d.createdAt || new Date(),
          updatedAt: d.updatedAt?.toDate?.() || d.updatedAt || new Date(),
        });
      }
    }
  } catch (_) {}

  // 3. Fetch from Firestore companies/{companyId}/leads
  try {
    const compLeadsSnap = await firestoreDb.collection("companies").doc(companyId).collection("leads").get();
    for (const doc of compLeadsSnap.docs) {
      if (!leadsMap.has(doc.id)) {
        const d = doc.data();
        leadsMap.set(doc.id, {
          _id: doc.id,
          id: doc.id,
          fullName: d.name || d.fullName || "Lead Contact",
          mobile: d.phone || d.mobile || "",
          email: d.email || "",
          companyId,
          campaignId: d.campaignId || "",
          nationality: d.nationality || "",
          budgetRange: d.budgetRange || d.budget || "",
          propertyType: d.propertyType || "",
          source: d.source || "mobile",
          status: d.status || "New",
          createdAt: d.createdAt?.toDate?.() || d.createdAt || new Date(),
          updatedAt: d.updatedAt?.toDate?.() || d.updatedAt || new Date(),
        });
      }
    }
  } catch (_) {}

  const formatted = Array.from(leadsMap.values()).sort(
    (a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0)
  );
  return NextResponse.json(success(formatted));
});

export const POST = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const companyId = context.user?.companyId || context.user?.enterpriseUid || context.uid;
  if (!companyId) {
    return NextResponse.json({ success: false, error: "No company associated" }, { status: 404 });
  }

  const body = await request.json();
  const { fullName, mobile, email, campaignId, nationality, budgetRange, propertyType, source } = body;

  if (!fullName || !mobile) {
    return NextResponse.json({ success: false, error: "Name and Mobile are required" }, { status: 400 });
  }

  const now = new Date();
  const lead = {
    fullName,
    name: fullName,
    mobile,
    phone: mobile,
    email: email || "",
    companyId,
    enterpriseUid: companyId,
    campaignId: campaignId || "",
    nationality: nationality || "",
    budgetRange: budgetRange || "",
    propertyType: propertyType || "",
    source: source || "manual",
    status: "New",
    agentId: context.uid,
    createdAt: now,
    updatedAt: now,
  };

  // 1. Write to Firestore enterprises/{companyId}/leads (read by mobile app)
  let leadId = "";
  try {
    const fsRef = await firestoreDb.collection("enterprises").doc(companyId).collection("leads").add({
      ...lead,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    leadId = fsRef.id;
  } catch (_) {}

  // 2. Write to MongoDB
  try {
    const db = await connectDB();
    const result = await db.collection("leads").insertOne({
      ...lead,
      ...(leadId ? { _id: leadId } : {}),
    });
    if (!leadId) leadId = result.insertedId.toString();
  } catch (_) {}

  return NextResponse.json(success({ leadId }));
});

export const DELETE = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const companyId = context.user?.companyId || context.user?.enterpriseUid || context.uid;
  const { searchParams } = new URL(request.url);
  const leadId = searchParams.get("id");

  if (!leadId) return NextResponse.json({ success: false, error: "Lead ID required" }, { status: 400 });

  // 1. Delete from MongoDB
  try {
    const db = await connectDB();
    const query = {
      $or: [{ _id: leadId }, ...(ObjectId.isValid(leadId) ? [{ _id: new ObjectId(leadId) }] : [])],
    };
    await db.collection("leads").deleteOne(query);
  } catch (_) {}

  // 2. Delete from Firestore
  try {
    await firestoreDb.collection("enterprises").doc(companyId).collection("leads").doc(leadId).delete();
  } catch (_) {}
  try {
    await firestoreDb.collection("companies").doc(companyId).collection("leads").doc(leadId).delete();
  } catch (_) {}

  return NextResponse.json(success({ message: "Lead deleted" }));
});

export const PATCH = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const companyId = context.user?.companyId;
  const { searchParams } = new URL(request.url);
  const leadId = searchParams.get("id");

  if (!leadId) return NextResponse.json({ success: false, error: "Lead ID required" }, { status: 400 });

  const body = await request.json();

  // Whitelist updatable fields
  const allowed = [
    "fullName", "mobile", "email", "nationality", "budgetRange",
    "propertyType", "propertyCategory", "emirate", "areaOfInterest",
    "investorType", "timeline", "notes", "status"
  ];

  const updates = {};
  for (const key of allowed) {
    if (body[key] !== undefined) updates[key] = body[key];
  }

  if (Object.keys(updates).length === 0) {
    return NextResponse.json({ success: false, error: "No valid fields to update" }, { status: 400 });
  }

  updates.updatedAt = new Date();

  const db = await connectDB();
  const query = { _id: new ObjectId(leadId) };
  if (companyId) {
    query.companyId = companyId;
  }

  const result = await db.collection("leads").updateOne(
    query,
    { $set: updates }
  );

  if (result.matchedCount === 0) {
    return NextResponse.json({ success: false, error: "Lead not found or access denied" }, { status: 404 });
  }

  return NextResponse.json(success({ message: "Lead updated" }));
});
