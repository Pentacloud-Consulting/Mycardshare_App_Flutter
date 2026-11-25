import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireMasterAdmin } from "@/backend/middleware/auth-handler";
import { firestoreDb, admin } from "@/backend/config/firebase";
import { connectDB } from "@/backend/config/db";
import { success } from "@/backend/utils/apiResponse";
import platformService from "@/backend/services/platform.service";

/**
 * GET /api/platform/companies/[companyId]
 * Fetch a single company's details
 */
export const GET = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  const { companyId } = await params;
  const companyDoc = await firestoreDb.collection("companies").doc(companyId).get();

  if (!companyDoc.exists) {
    return NextResponse.json({ success: false, error: "Company not found" }, { status: 404 });
  }

  const data = companyDoc.data();

  return NextResponse.json(success({ 
    company: {
      companyId: companyDoc.id,
      companyName: data.companyName,
      slug: data.slug,
      description: data.description,
      email: data.email || null,
      phoneNumber: data.phoneNumber,
      website: data.website,
      officeAddress: data.officeAddress,
      approvalStatus: data.approvalStatus,
      isSuspended: data.isSuspended,
      subscriptionStartDate: data.subscriptionStartDate?.toDate?.() || null,
      renewalDate: data.renewalDate?.toDate?.() || null,
      subscriptionStatus: data.subscriptionStatus || null,
      createdAt: data.createdAt?.toDate?.() || null,
      updatedAt: data.updatedAt?.toDate?.() || null,
    } 
  }));
});

/**
 * PATCH /api/platform/companies/[companyId]
 * Update subscription details (Master Admin only)
 */
export const PATCH = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  const { companyId } = await params;
  const body = await request.json();

  const ref = firestoreDb.collection("companies").doc(companyId);
  const doc = await ref.get();

  if (!doc.exists) {
    return NextResponse.json({ success: false, error: "Company not found" }, { status: 404 });
  }

  const updates = {};
  if (body.subscriptionStartDate) {
    updates.subscriptionStartDate = new Date(body.subscriptionStartDate);
  }
  if (body.renewalDate) {
    updates.renewalDate = new Date(body.renewalDate);
  }
  if (body.subscriptionStatus && ["active", "expired", "suspended"].includes(body.subscriptionStatus)) {
    updates.subscriptionStatus = body.subscriptionStatus;
  }

  if (Object.keys(updates).length === 0) {
    return NextResponse.json({ success: false, error: "No valid fields to update" }, { status: 400 });
  }

  await platformService.updateCompanyStatus(companyId, updates);

  return NextResponse.json(success({ message: "Subscription updated successfully" }));
});

/**
 * DELETE /api/platform/companies/[companyId]
 * Permanently delete a company and all associated data
 */
export const DELETE = apiAdapter(async (request, { params }) => {
  const context = await resolveAuth(request);
  requireMasterAdmin(context);

  const { companyId } = await params;
  const companyRef = firestoreDb.collection("companies").doc(companyId);
  const companyDoc = await companyRef.get();

  if (!companyDoc.exists) {
    return NextResponse.json(
      { success: false, error: "Company not found" },
      { status: 404 }
    );
  }

  const companyData = companyDoc.data();

  // 1. Delete all campaigns (subcollection)
  const campaignsSnap = await companyRef.collection("campaigns").get();
  const batch1 = firestoreDb.batch();
  campaignsSnap.docs.forEach((doc) => batch1.delete(doc.ref));
  if (campaignsSnap.docs.length > 0) await batch1.commit();

  // 2. Delete all leads from MongoDB
  try {
    const db = await connectDB();
    await db.collection("leads").deleteMany({ companyId });
    await db.collection("crmLogs").deleteMany({ companyId });
  } catch (err) {
    console.warn("[delete company] MongoDB cleanup error:", err.message);
  }

  // 3. Delete all users belonging to this company
  const usersSnap = await firestoreDb
    .collection("users")
    .where("companyId", "==", companyId)
    .get();

  for (const userDoc of usersSnap.docs) {
    try {
      await admin.auth().deleteUser(userDoc.id);
    } catch (err) {
      console.warn(`[delete company] Auth user ${userDoc.id} cleanup:`, err.message);
    }
    await userDoc.ref.delete();
  }

  // 4. Delete the admin user if different
  const adminUserId = companyData.adminUserId;
  if (adminUserId) {
    try {
      await admin.auth().deleteUser(adminUserId);
    } catch (_) {}
    try {
      await firestoreDb.collection("users").doc(adminUserId).delete();
    } catch (_) {}
  }

  // 5. Delete the company document
  await companyRef.delete();

  return NextResponse.json(success({ message: "Company deleted successfully" }));
});
