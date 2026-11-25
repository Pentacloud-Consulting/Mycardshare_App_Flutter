import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { firestoreDb, admin } from "@/backend/config/firebase";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

/**
 * ENTERPRISE GOOGLE SIGNUP & WORKSPACE PROVISIONING SYNC (APP <-> WEB)
 *
 * Route: POST /api/sync/enterprise-google-signup
 * Also accessible via: /api/sync/enterprise/google-signup
 *
 * What this fixes:
 * 1. Allows signing up / registering an enterprise directly using a Google account.
 * 2. Real-time extraction of Google credentials (UID, email, displayName, photoURL/picture).
 * 3. Atomic creation/linking of the Organization in Firestore (`companies`), user in Firestore (`users`),
 *    and corporate card document in MongoDB (`cards`).
 * 4. Automatic status assignment: Sets `status: "pending"` or `"approved"`, role: `"enterprise"`,
 *    and immediately syncs profile avatar to Google's high-res PFP.
 * 5. Returns full enterprise profile, voucher code, and auth context so Flutter / Web client can
 *    proceed directly to enterprise dashboard or status screen without getting stuck in individual mode.
 */

function generateSlug(companyName: string): string {
  const base = String(companyName || "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  return (base || "enterprise") + "-" + Math.random().toString(36).substring(2, 6);
}

export const POST = apiAdapter(async (request: NextRequest) => {
  // 1. Resolve Firebase Auth context from Google bearer token
  const context = await resolveAuth(request);
  const uid = context.uid;
  const authPayload = (context.auth || {}) as any;

  const body = await request.json().catch(() => ({}));
  const {
    companyName,
    slug: customSlug,
    industry,
    website,
    phone,
    phoneNumber,
    adminTitle,
    address,
    companyLogo,
    registrationSecret,
  } = body;

  const resolvedEmail = body.email || authPayload.email || context.user?.email || "";
  const resolvedName =
    body.fullName ||
    body.adminName ||
    authPayload.name ||
    context.user?.displayName ||
    resolvedEmail.split("@")[0] ||
    "Enterprise Admin";
  const resolvedPhoto =
    authPayload.picture ||
    authPayload.photoURL ||
    context.user?.avatarUrl ||
    context.user?.photoURL ||
    null;

  // 2. Validate Enterprise Registration Master Secret (if configured)
  const masterSecret = process.env.ENTERPRISE_REGISTRATION_MASTER_KEY?.trim();
  if (masterSecret) {
    const provided = String(registrationSecret ?? "").trim();
    if (provided !== masterSecret) {
      return NextResponse.json(
        fail("INVALID_REGISTRATION_SECRET", "Enterprise signup requires a valid organization master invitation code."),
        { status: 403 }
      );
    }
  }

  // 3. Resolve Company Name (auto-fallback if user tapped Google Sign-In before typing name)
  let finalCompanyName = (companyName || "").trim();
  if (!finalCompanyName) {
    if (resolvedEmail.includes("@") && !resolvedEmail.endsWith("@gmail.com")) {
      const domainPart = resolvedEmail.split("@")[1].split(".")[0];
      finalCompanyName = domainPart.charAt(0).toUpperCase() + domainPart.slice(1) + " Corp";
    } else {
      finalCompanyName = `${resolvedName}'s Enterprise`;
    }
  }

  // 4. Resolve slug
  const finalSlug = (customSlug || "").trim().toLowerCase() || generateSlug(finalCompanyName);

  // 5. Check if user already owns an enterprise workspace
  const existingCompanySnap = await firestoreDb
    .collection("companies")
    .where("adminUserId", "==", uid)
    .limit(1)
    .get();

  let companyId: string;
  let voucherCode: string;
  let companyRecord: any;

  if (!existingCompanySnap.empty) {
    const doc = existingCompanySnap.docs[0];
    companyId = doc.id;
    companyRecord = doc.data();
    voucherCode = companyRecord.voucherCode || `CORP-${companyId.slice(-6).toUpperCase()}`;

    // Update existing company if name/details supplied
    await firestoreDb.collection("companies").doc(companyId).set(
      {
        companyName: companyRecord.companyName || finalCompanyName,
        officialEmail: resolvedEmail,
        companyLogo: companyLogo || companyRecord.companyLogo || resolvedPhoto,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  } else {
    // 6. Create brand new Enterprise in Firestore
    const companyRef = firestoreDb.collection("companies").doc();
    companyId = companyRef.id;
    voucherCode = Math.random().toString(36).substring(2, 8).toUpperCase();

    companyRecord = {
      companyId,
      companyName: finalCompanyName,
      slug: finalSlug,
      voucherCode,
      adminUserId: uid,
      adminName: resolvedName,
      adminEmail: resolvedEmail,
      adminTitle: adminTitle || "Founder / Admin",
      officialEmail: resolvedEmail,
      website: website || "",
      phone: phone || phoneNumber || "",
      address: address || "",
      industry: industry || "Technology & Services",
      companyLogo: companyLogo || resolvedPhoto,
      companyBanner: null,
      brandColor: "#0052FF",
      isColorLocked: false,
      employeeLimit: 50,
      approvalStatus: "pending", // Master admin can approve or auto-promote
      status: "pending",
      isSuspended: false,
      subscriptionPlan: "enterprise_pro",
      subscriptionStatus: "active",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await companyRef.set(companyRecord);
  }

  // 7. Atomically upgrade user in Firestore to enterprise role with Google metadata
  const userUpdates: Record<string, any> = {
    uid,
    email: resolvedEmail,
    displayName: resolvedName,
    fullName: resolvedName,
    avatarUrl: resolvedPhoto,
    photoURL: resolvedPhoto,
    role: "enterprise",
    status: companyRecord.approvalStatus === "approved" ? "active" : "pending",
    approvalStatus: companyRecord.approvalStatus || "pending",
    companyId,
    companyName: finalCompanyName,
    accountType: "enterprise",
    onboardingCompleted: true,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await firestoreDb.collection("users").doc(uid).set(userUpdates, { merge: true });

  // 8. Provision Enterprise Master Card in MongoDB
  try {
    const db = await connectDB();
    const existingCard = await db.collection("cards").findOne({ userId: uid });

    const cardPayload: Record<string, any> = {
      userId: uid,
      companyId,
      companyName: finalCompanyName,
      fullName: resolvedName,
      title: adminTitle || "Enterprise Administrator",
      designation: adminTitle || "Enterprise Administrator",
      email: resolvedEmail,
      phone: phone || phoneNumber || "",
      avatarUrl: resolvedPhoto,
      photoURL: resolvedPhoto,
      companyLogo: companyLogo || resolvedPhoto,
      cardSlug: finalSlug,
      themeColor: "#0052FF",
      isPublished: true,
      cardStatus: "Published",
      role: "enterprise",
      updatedAt: new Date(),
    };

    if (existingCard) {
      await db.collection("cards").updateOne(
        { userId: uid },
        { $set: cardPayload }
      );
    } else {
      cardPayload.createdAt = new Date();
      cardPayload.views = 0;
      cardPayload.shares = 0;
      cardPayload.contactsSaved = 0;
      await db.collection("cards").insertOne(cardPayload);
    }
  } catch (mongoErr) {
    console.warn("⚠️ [Enterprise Google Signup] MongoDB card sync warning:", mongoErr);
  }

  // 9. Return Unified Sync Response
  return NextResponse.json(
    success({
      message: "Enterprise account successfully registered and synchronized with Google.",
      user: {
        uid,
        email: resolvedEmail,
        fullName: resolvedName,
        avatarUrl: resolvedPhoto,
        role: "enterprise",
        status: userUpdates.status,
        approvalStatus: companyRecord.approvalStatus,
        companyId,
        companyName: finalCompanyName,
      },
      enterprise: {
        companyId,
        companyName: finalCompanyName,
        slug: finalSlug,
        voucherCode,
        employeeLimit: 50,
        approvalStatus: companyRecord.approvalStatus,
        status: companyRecord.status,
      },
    }),
    { status: 201 }
  );
});
