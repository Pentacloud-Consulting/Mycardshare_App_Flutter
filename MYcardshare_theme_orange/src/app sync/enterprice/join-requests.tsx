import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { firestoreDb, admin } from "@/backend/config/firebase";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * ENTERPRISE JOIN REQUEST & REAL NOTIFICATION PIPELINE (APP <-> WEB)
 * 
 * Supports:
 * 1. POST /api/sync/enterprise-join
 *    - action: "verify_admin_email"
 *      - Checks if input email (e.g., zuhaibent@gmail.com) belongs to a verified enterprise admin
 *      - Returns enterprise details (companyName, companyId, logo, brandColor) for the green badge in UI
 * 
 *    - action: "send_join_request"
 *      - Creates request in Firestore 'enterprise_join_requests' AND 'enterprises/{id}/join_requests'
 *      - Dispatches real in-app alert to Enterprise Admin
 *      - Dispatches real FCM push notification to Admin's mobile device
 * 
 *    - action: "approve_employee"
 *      - Admin approves request
 *      - Instantly updates user role: "employee", status: "active", companyId
 *      - Automatically creates/updates employee's branded card in MongoDB and Firestore
 * 
 *    - action: "reject_employee"
 *      - Admin rejects request with reason
 * 
 * 2. GET /api/sync/enterprise-join
 *    - If called by Admin -> returns all pending join requests for their enterprise
 *    - If called by Employee -> returns their active join request status (PENDING / APPROVED / REJECTED)
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;
  const userRole = context.user?.role;
  const companyId = context.user?.companyId;

  // 1. ADMIN VIEW: Fetch all pending requests for this company
  if (companyId && (userRole === "enterprise" || userRole === "admin" || userRole === "super_admin")) {
    const snap = await firestoreDb
      .collection("enterprise_join_requests")
      .where("companyId", "==", companyId)
      .where("status", "==", "pending")
      .get();

    const pendingRequests = snap.docs.map((doc) => ({
      requestId: doc.id,
      ...doc.data(),
      requestedAt: doc.data().createdAt?.toDate?.()?.toISOString?.() || doc.data().createdAt || new Date().toISOString(),
    }));

    return NextResponse.json(
      success({
        role: "admin",
        companyId,
        totalPending: pendingRequests.length,
        requests: pendingRequests,
      })
    );
  }

  // 2. EMPLOYEE VIEW: Check current employee's join request status
  const employeeSnap = await firestoreDb
    .collection("enterprise_join_requests")
    .where("userId", "==", uid)
    .orderBy("createdAt", "desc")
    .limit(1)
    .get();

  if (employeeSnap.empty) {
    return NextResponse.json(
      success({
        role: "applicant",
        hasRequest: false,
        status: "NONE",
      })
    );
  }

  const reqDoc = employeeSnap.docs[0].data();
  return NextResponse.json(
    success({
      role: "applicant",
      hasRequest: true,
      requestId: employeeSnap.docs[0].id,
      companyId: reqDoc.companyId,
      companyName: reqDoc.companyName,
      status: reqDoc.status, // "pending" | "approved" | "rejected"
      requestedAt: reqDoc.createdAt?.toDate?.()?.toISOString?.() || reqDoc.createdAt,
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const body = await request.json();
  const { action = "send_join_request" } = body;
  const db = await connectDB();

  // =========================================================================
  // 1. VERIFY ENTERPRISE ADMIN EMAIL (Green badge in UI)
  // =========================================================================
  if (action === "verify_admin_email") {
    const { enterpriseEmail } = body;

    if (!enterpriseEmail || typeof enterpriseEmail !== "string") {
      throw new AppError("A valid enterprise email is required.", 400);
    }

    const cleanEmail = enterpriseEmail.trim().toLowerCase();

    // Find company by adminEmail, officialEmail, or email
    const compSnap = await firestoreDb
      .collection("companies")
      .where("adminEmail", "==", cleanEmail)
      .limit(1)
      .get();

    let targetCompany: any = null;
    let targetCompanyId = "";

    if (!compSnap.empty) {
      targetCompany = compSnap.docs[0].data();
      targetCompanyId = compSnap.docs[0].id;
    } else {
      // Check officialEmail or email field
      const altSnap = await firestoreDb
        .collection("companies")
        .where("officialEmail", "==", cleanEmail)
        .limit(1)
        .get();

      if (!altSnap.empty) {
        targetCompany = altSnap.docs[0].data();
        targetCompanyId = altSnap.docs[0].id;
      }
    }

    if (!targetCompany) {
      return NextResponse.json(
        fail("ENTERPRISE_NOT_FOUND", `No registered enterprise company found with email: ${cleanEmail}`),
        { status: 404 }
      );
    }

    return NextResponse.json(
      success({
        verified: true,
        companyId: targetCompanyId,
        companyName: targetCompany.companyName || "Corporate Enterprise",
        companyLogo: targetCompany.companyLogo || null,
        brandColor: targetCompany.brandColor || "#0052FF",
        adminEmail: cleanEmail,
        message: `Verified Enterprise: ${targetCompany.companyName}`,
      })
    );
  }

  // Authentication required for sending, approving, or rejecting requests
  const context = await resolveAuth(request);
  const uid = context.uid;

  // =========================================================================
  // 2. SEND JOIN REQUEST (Employee taps "Send Join Request")
  // =========================================================================
  if (action === "send_join_request") {
    const {
      enterpriseEmail,
      companyId: providedCompanyId,
      employeeName,
      employeeEmail,
      jobTitle = "Team Member",
      phone = "",
    } = body;

    let targetCompanyId = providedCompanyId;
    let targetCompany: any = null;

    if (targetCompanyId) {
      targetCompany = (await companyService.getCompany(targetCompanyId)) as any;
    } else if (enterpriseEmail) {
      const cleanEmail = enterpriseEmail.trim().toLowerCase();
      const compSnap = await firestoreDb
        .collection("companies")
        .where("adminEmail", "==", cleanEmail)
        .limit(1)
        .get();

      if (!compSnap.empty) {
        targetCompany = compSnap.docs[0].data();
        targetCompanyId = compSnap.docs[0].id;
      }
    }

    if (!targetCompany || !targetCompanyId) {
      throw new AppError("Invalid enterprise workspace. Please verify the admin email first.", 400);
    }

    const applicantEmail = (employeeEmail || context.auth?.email || "").toLowerCase().trim();
    const applicantName = employeeName || context.user?.displayName || "Applicant";

    // Create Request Document
    const requestData = {
      userId: uid,
      companyId: targetCompanyId,
      companyName: targetCompany.companyName || "Corporate Workspace",
      employeeName: applicantName,
      employeeEmail: applicantEmail,
      jobTitle,
      phone,
      status: "pending", // "pending" | "approved" | "rejected"
      createdAt: new Date(),
    };

    // 1. Save in global 'enterprise_join_requests'
    const reqRef = await firestoreDb.collection("enterprise_join_requests").add(requestData);

    // 2. Also save in company subcollection 'enterprises/{id}/join_requests'
    await firestoreDb
      .collection("companies")
      .doc(targetCompanyId)
      .collection("join_requests")
      .doc(reqRef.id)
      .set(requestData);

    // 3. Mirror into MongoDB
    await db.collection("enterprise_join_requests").insertOne({
      ...requestData,
      _id: reqRef.id,
    });

    // 4. DISPATCH IN-APP NOTIFICATION & PUSH TO ENTERPRISE ADMIN
    try {
      const adminUserId = targetCompany.adminUserId;
      const notifDoc = {
        userId: adminUserId || targetCompanyId,
        companyId: targetCompanyId,
        title: "New Employee Join Request 📩",
        body: `${applicantName} (${applicantEmail}) has requested to join ${targetCompany.companyName}.`,
        type: "team_invite",
        data: {
          requestId: reqRef.id,
          employeeEmail: applicantEmail,
          employeeName: applicantName,
          companyId: targetCompanyId,
        },
        isRead: false,
        createdAt: new Date(),
      };

      await Promise.all([
        db.collection("notifications").insertOne(notifDoc),
        firestoreDb.collection("notifications").add(notifDoc),
      ]);

      // Push FCM Notification to Admin if registered
      if (adminUserId && admin) {
        const tokens = await db.collection("fcm_tokens").find({ userId: adminUserId }).toArray();
        if (tokens.length > 0) {
          const regTokens = tokens.map((t) => t.fcmToken);
          await admin.messaging().sendEachForMulticast({
            notification: {
              title: notifDoc.title,
              body: notifDoc.body,
            },
            data: {
              requestId: reqRef.id,
              type: "team_invite",
            },
            tokens: regTokens,
          });
        }
      }
    } catch (notifErr: any) {
      console.warn("[Enterprise Join] Admin notification warning:", notifErr.message);
    }

    return NextResponse.json(
      success({
        requestId: reqRef.id,
        status: "PENDING",
        companyName: targetCompany.companyName,
        message: `Join request sent to ${targetCompany.companyName}! Admin has been notified.`,
      })
    );
  }

  // =========================================================================
  // 3. APPROVE REQUEST (Admin clicks "Approve")
  // =========================================================================
  if (action === "approve_employee") {
    const { requestId } = body;

    if (!requestId) {
      throw new AppError("requestId is required.", 400);
    }

    const reqDoc = await firestoreDb.collection("enterprise_join_requests").doc(requestId).get();
    if (!reqDoc.exists) {
      throw new AppError("Join request not found.", 404);
    }

    const reqData = reqDoc.data() as any;
    const targetUserId = reqData.userId;
    const targetCompanyId = reqData.companyId;

    const company = (await companyService.getCompany(targetCompanyId)) as any;

    // 1. Promote User to Employee in Firestore
    await firestoreDb.collection("users").doc(targetUserId).set(
      {
        companyId: targetCompanyId,
        companyName: company?.companyName || reqData.companyName,
        role: "employee",
        jobTitle: reqData.jobTitle || "Team Member",
        status: "active",
        onboardingCompleted: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // 2. Add to Company Employees Subcollection in Firestore
    await firestoreDb
      .collection("companies")
      .doc(targetCompanyId)
      .collection("employees")
      .doc(targetUserId)
      .set({
        id: targetUserId,
        userId: targetUserId,
        name: reqData.employeeName,
        email: reqData.employeeEmail,
        role: "employee",
        jobTitle: reqData.jobTitle || "Team Member",
        status: "active",
        joinedAt: new Date().toISOString(),
      });

    // 3. Bind MongoDB Card with Corporate Brand Guidelines
    const slug = `${reqData.employeeName.toLowerCase().replace(/[^a-z0-9]/g, "-")}-${targetCompanyId.slice(-4)}`;
    await db.collection("cards").updateOne(
      { userId: targetUserId },
      {
        $set: {
          companyId: targetCompanyId,
          companyName: company?.companyName || reqData.companyName,
          fullName: reqData.employeeName,
          jobTitle: reqData.jobTitle || "Team Member",
          email: reqData.employeeEmail,
          role: "employee",
          status: "active",
          cardStatus: "Published",
          themeColor: company?.brandColor || "#0052FF",
          bannerUrl: company?.companyBanner || null,
          companyLogo: company?.companyLogo || null,
          slug,
          lastUpdated: new Date(),
        },
      },
      { upsert: true }
    );

    // 4. Mark Request as Approved
    await Promise.all([
      firestoreDb.collection("enterprise_join_requests").doc(requestId).update({
        status: "approved",
        approvedAt: admin.firestore.FieldValue.serverTimestamp(),
        approvedBy: uid,
      }),
      db.collection("enterprise_join_requests").updateOne(
        { _id: requestId },
        { $set: { status: "approved", approvedAt: new Date() } }
      ),
    ]);

    // 5. Notify Employee: "Congratulations! Your request has been approved."
    try {
      const empNotif = {
        userId: targetUserId,
        title: "Workspace Access Approved! 🎉",
        body: `You are now an official team member of ${company?.companyName || "the enterprise"}. Login to view your branded card.`,
        type: "team_approved",
        isRead: false,
        createdAt: new Date(),
      };
      await db.collection("notifications").insertOne(empNotif);
    } catch (e) {}

    return NextResponse.json(
      success({
        message: `Employee ${reqData.employeeName} approved and added to workspace!`,
        targetUserId,
        status: "active",
      })
    );
  }

  // =========================================================================
  // 4. REJECT REQUEST (Admin clicks "Reject")
  // =========================================================================
  if (action === "reject_employee") {
    const { requestId, reason = "Declined by enterprise administrator" } = body;

    await Promise.all([
      firestoreDb.collection("enterprise_join_requests").doc(requestId).update({
        status: "rejected",
        rejectedReason: reason,
        rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
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
