import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { firestoreDb, admin } from "@/backend/config/firebase";
import { success } from "@/backend/utils/apiResponse";

/**
 * Common Profile Management
 * GET /api/profile
 * PATCH /api/profile
 */

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  return NextResponse.json(success(context.user));
});

export const PATCH = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const body = await request.json();

  const allowed = ["displayName", "phoneNumber", "jobTitle"];
  const updates = {};
  allowed.forEach(k => { if (body[k] !== undefined) updates[k] = body[k]; });

  // Keep displayName and fullName in sync
  if (updates.displayName) {
    updates.fullName = updates.displayName;
  }

  if (Object.keys(updates).length === 0) {
    return NextResponse.json({ success: false, error: "No valid fields to update" }, { status: 400 });
  }

  updates.updatedAt = admin.firestore.FieldValue.serverTimestamp();

  await firestoreDb.collection("users").doc(context.uid).update(updates);
  return NextResponse.json(success({ message: "Profile updated" }));
});
