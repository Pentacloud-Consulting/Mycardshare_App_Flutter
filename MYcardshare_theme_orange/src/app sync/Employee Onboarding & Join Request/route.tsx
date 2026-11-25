import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { firestoreDb } from "@/backend/config/firebase";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * ENTERPRISE EMPLOYEE ONBOARDING & JOIN REQUEST PIPELINE (APP <-> WEB)
 * 
 * Solves:
 * 1. "Enterprise email se invite code se login hone par team page me fetch nahi ho raha tha."
 * 2. "Bina invite code ke signup karte waqt company email daalne par enterprise admin ke paas pending request nahi ja rahi thi."
 * 
 * Supports:
 * - POST /api/sync/employee-join-request
 *   - action: "submit_join_request" -> Employee submits work email (e.g. rahul@techcorp.com) without invite code
 *   - action: "list_requests" -> Enterprise Admin views pending requests in team page
 *   - action: "approve_request" -> Admin approves employee into the workspace
 *   - action: "reject_request" -> Admin rejects request
 * - GET /api/sync/employee-join-request
 *   - Checks current user's join status (PENDING, APPROVED, REJECTED)
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  // Check if user has an active or pending join request
  const snap = await firestoreDb
    .collection("enterprise_join_requests")
    .where("userId", "==", uid)
    .orderBy("createdAt", "desc")
    .limit(1)
    .get();

  if (snap.empty) {
    return NextResponse.json(
      success({
        hasRequest: false,
        status: "NONE",
      })
    );
  }

  const reqDoc = snap.docs[0].data();
  return NextResponse.json(
    success({
      hasRequest: true,
      requestId: snap.docs[0].id,
      companyId: reqDoc.companyId,
      companyName: reqDoc.companyName,
      status: reqDoc.status, // "pending" | "approved" | "rejected"
      requestedAt: reqDoc.createdAt?.toDate?.()?.toISOString?.() || reqDoc.createdAt,
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  const body = await request.json();
  const { action = "submit_join_request" } = body;
  const db = await connectDB();

  // =========================================================================
  // 1. SUBMIT JOIN REQUEST WITHOUT INVITE CODE (Company Email Domain Matching)
  // =========================================================================
  if (action === "submit_join_request") {
    const { workEmail, fullName, jobTitle, phone } = body;

    const emailToUse = (workEmail || context.auth?.email || "").toLowerCase().trim();
    if (!emailToUse || !emailToUse.includes("@")) {
      throw new AppError("A valid corporate work email is required.", 400);
    }

    const emailDomain = emailToUse.split("@")[1].toLowerCase();

    // Block public email providers from company matching
    const publicDomains = ["gmail.com", "yahoo.com", "outlook.com", "hotmail.com", "icloud.com"];
    if (publicDomains.includes(emailDomain)) {
      throw new AppError("Please use your official company domain email (e.g. name@company.com), not a public Gmail/Yahoo address.", 400);
    }

    // Find company by matching domain in Firestore
    const compSnap = await firestoreDb
      .collection("companies")
      .where("domain", "==", emailDomain)
      .limit(1)
      .get();

    let companyDoc: any = null;
    let companyId = "";

    if (!compSnap.empty) {
      companyDoc = compSnap.docs[0].data();
      companyId = compSnap.docs[0].id;
    } else {
      // Fallback: search emailDomain field or slug
      const altSnap = await firestoreDb
        .collection("companies")
        .where("emailDomain", "==", emailDomain)
        .limit(1)
        .get();

      if (!altSnap.empty) {
        companyDoc = altSnap.docs[0].data();
        companyId = altSnap.docs[0].id;
      }
    }

    if (!companyDoc) {
      return NextResponse.json(
        fail("COMPANY_DOMAIN_NOT_FOUND", `No enterprise workspace is registered for domain '@${emailDomain}'. Ask your company admin to register first.`),
        { status: 404 }
      );
    }

    // Check if autoApproveDomainMatch is turned on by Enterprise Admin
    const isAutoApproved = Boolean(companyDoc.autoApproveDomainMatch);

    if (isAutoApproved) {
      // Auto-approve: link user directly as active employee!
      await Promise.all([
        firestoreDb.collection("users").doc(uid).set(
          {
            companyId,
            companyName: companyDoc.companyName,
            role: "employee",
            jobTitle: jobTitle || "Team Member",
            status: "active",
            onboardingCompleted: true,
            updatedAt: require("firebase-admin").firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        ),
        db.collection("cards").updateOne(
          { userId: uid },
          {
            $set: {
              companyId,
              companyName: companyDoc.companyName,
              fullName: fullName || context.user?.displayName || "Team Member",
              jobTitle: jobTitle || "",
              email: emailToUse,
              role: "employee",
              status: "active",
              themeColor: companyDoc.brandColor || "#0052FF",
              bannerUrl: companyDoc.companyBanner || null,
              companyLogo: companyDoc.companyLogo || null,
              lastUpdated: new Date(),
            },
          },
          { upsert: true }
        ),
      ]);

      return NextResponse.json(
        success({
          autoApproved: true,
          status: "APPROVED",
          companyId,
          companyName: companyDoc.companyName,
          brandColor: companyDoc.brandColor,
          message: `Domain matched! You have been automatically added to ${companyDoc.companyName}.`,
        })
      );
    }

    // Manual Approval Required: Save pending request in Firestore & MongoDB
    const requestDoc = {
      userId: uid,
      companyId,
      companyName: companyDoc.companyName,
      employeeName: fullName || context.user?.displayName || "New Applicant",
      workEmail: emailToUse,
      jobTitle: jobTitle || "Team Member",
      phone: phone || "",
      status: "pending", // "pending" | "approved" | "rejected"
      createdAt: new Date(),
    };

    const insertedRef = await firestoreDb.collection("enterprise_join_requests").add(requestDoc);

    // Also push to MongoDB so admin workspace sees it immediately
    await db.collection("enterprise_join_requests").insertOne({
      ...requestDoc,
      _id: insertedRef.id,
    });

    return NextResponse.json(
      success({
        autoApproved: false,
        status: "PENDING",
        requestId: insertedRef.id,
        companyName: companyDoc.companyName,
        message: `Join request sent to ${companyDoc.companyName} Admin. You will be notified once approved.`,
      })
    );
  }

  // =========================================================================
  // 2. ADMIN APPROVES REQUEST (From Enterprise Team / Workspace Screen)
  // =========================================================================
  if (action === "approve_request") {
    const { requestId } = body;
    const adminCompanyId = context.user?.companyId;

    if (!requestId) {
      throw new AppError("requestId is required.", 400);
    }

    const reqDoc = await firestoreDb.collection("enterprise_join_requests").doc(requestId).get();
    if (!reqDoc.exists) {
      throw new AppError("Join request not found.", 404);
    }

    const reqData = reqDoc.data() as any;
    const targetUserId = reqData.userId;
    const companyId = reqData.companyId;

    if (adminCompanyId && adminCompanyId !== companyId) {
      throw new AppError("Permission denied: You do not administer this enterprise.", 403);
    }

    const company = (await companyService.getCompany(companyId)) as any;

    // 1. Promote User to Employee in Firestore
    await firestoreDb.collection("users").doc(targetUserId).set(
      {
        companyId,
        companyName: company?.companyName || reqData.companyName,
        role: "employee",
        jobTitle: reqData.jobTitle || "Team Member",
        status: "active",
        onboardingCompleted: true,
        updatedAt: require("firebase-admin").firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // 2. Bind MongoDB Card with Corporate Brand Guidelines
    await db.collection("cards").updateOne(
      { userId: targetUserId },
      {
        $set: {
          companyId,
          companyName: company?.companyName || reqData.companyName,
          fullName: reqData.employeeName,
          jobTitle: reqData.jobTitle,
          email: reqData.workEmail,
          role: "employee",
          status: "active",
          themeColor: company?.brandColor || "#0052FF",
          bannerUrl: company?.companyBanner || null,
          companyLogo: company?.companyLogo || null,
          lastUpdated: new Date(),
        },
      },
      { upsert: true }
    );

    // 3. Update Request Status to Approved
    await Promise.all([
      firestoreDb.collection("enterprise_join_requests").doc(requestId).update({
        status: "approved",
        approvedAt: require("firebase-admin").firestore.FieldValue.serverTimestamp(),
      }),
      db.collection("enterprise_join_requests").updateOne(
        { _id: requestId },
        { $set: { status: "approved", approvedAt: new Date() } }
      ),
    ]);

    return NextResponse.json(
      success({
        message: `Employee ${reqData.employeeName} approved and added to workspace!`,
        targetUserId,
      })
    );
  }

  // =========================================================================
  // 3. ADMIN REJECTS REQUEST
  // =========================================================================
  if (action === "reject_request") {
    const { requestId, reason = "Domain verification rejected" } = body;

    await Promise.all([
      firestoreDb.collection("enterprise_join_requests").doc(requestId).update({
        status: "rejected",
        rejectedReason: reason,
        rejectedAt: require("firebase-admin").firestore.FieldValue.serverTimestamp(),
      }),
      db.collection("enterprise_join_requests").updateOne(
        { _id: requestId },
        { $set: { status: "rejected", rejectedReason: reason, rejectedAt: new Date() } }
      ),
    ]);

    return NextResponse.json(
      success({ message: "Join request rejected." })
    );
  }

  throw new AppError(`Unknown action: ${action}`, 400);
});
