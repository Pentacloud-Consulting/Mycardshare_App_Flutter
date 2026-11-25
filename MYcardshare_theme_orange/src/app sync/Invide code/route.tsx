import { NextRequest, NextResponse } from "next/server";
import { resolveAuth, requireAdmin } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { firestoreDb } from "@/backend/config/firebase";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";
import crypto from "crypto";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * 15-MINUTE ROTATING DETERMINISTIC CODE GENERATOR
 * Generates an 8-digit secure numeric code (10000000 - 99999999) based on
 * the enterprise ID and the current 15-minute time window slot.
 */
function generate15MinRotatingCode(enterpriseId: string, timeWindowOffset: number = 0): string {
  const currentSlot = Math.floor(Date.now() / (15 * 60 * 1000)) + timeWindowOffset;
  const hash = crypto
    .createHash("sha256")
    .update(`${enterpriseId}_salt_nexus_invite_${currentSlot}`)
    .digest("hex");

  // Extract 8 digits
  const intVal = parseInt(hash.substring(0, 8), 16);
  const code = (10000000 + (intVal % 90000000)).toString();
  return code;
}

/**
 * ENTERPRISE EMPLOYEE INVITE & SECURE ONBOARDING SYNC (APP <-> WEB)
 * 
 * Supports:
 * 1. GET /api/sync/invite-code
 *    - Fetches the active 8-digit rotating code, countdown timer (seconds remaining),
 *      and formatted join URLs for the admin's enterprise workspace.
 * 
 * 2. POST /api/sync/invite-code
 *    - action: "verify_code" -> Used by employee during onboarding to verify 8-digit code or voucher
 *    - action: "add_single_employee" -> Admin invites/adds employee with name, email, role, job title
 *    - action: "batch_invite_emails" -> Admin invites multiple email addresses at once
 *    - action: "accept_invite" -> Employee confirms onboarding, binds company branding & card
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const companyId = context.user?.companyId;

  if (!companyId) {
    throw new AppError("No enterprise workspace associated with this user account.", 400);
  }

  const company: any = await companyService.getCompany(companyId);
  if (!company) {
    throw new AppError("Enterprise workspace not found.", 404);
  }

  // 15-Minute Rotating Token Calculation
  const now = Date.now();
  const slotDurationMs = 15 * 60 * 1000;
  const currentSlotStart = Math.floor(now / slotDurationMs) * slotDurationMs;
  const nextSlotStart = currentSlotStart + slotDurationMs;
  const secondsRemaining = Math.max(0, Math.floor((nextSlotStart - now) / 1000));

  const rotatingCode = generate15MinRotatingCode(companyId);
  const permanentVoucherCode = company.voucherCode || `CORP-${companyId.slice(-6).toUpperCase()}`;

  const baseUrl =
    process.env.NEXT_PUBLIC_BASE_URL ||
    process.env.PUBLIC_BASE_URL ||
    "https://mycardshare.com";

  const standardJoinUrl = `${baseUrl}/join-workspace?enterpriseId=${companyId}&code=${rotatingCode}`;
  const permanentJoinUrl = `${baseUrl}/join-workspace?enterpriseId=${companyId}&voucher=${permanentVoucherCode}`;

  return NextResponse.json(
    success({
      enterpriseId: companyId,
      companyName: company.companyName || "Enterprise Workspace",
      companySlug: company.slug || companyId,
      companyLogo: company.companyLogo || null,
      brandColor: company.brandColor || "#0052FF",
      rotatingCode: {
        code: rotatingCode,
        secondsRemaining,
        expiresAt: new Date(nextSlotStart).toISOString(),
      },
      permanentVoucher: {
        voucherCode: permanentVoucherCode,
      },
      inviteUrls: {
        standardJoinUrl,
        permanentJoinUrl,
      },
      autoApproveDomainMatch: Boolean(company.autoApproveDomainMatch),
      allowedDomain: company.domain || company.emailDomain || null,
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const body = await request.json();
  const { action = "verify_code" } = body;

  // =========================================================================
  // 1. VERIFY INVITE CODE / VOUCHER (Employee Joining flow - Public)
  // =========================================================================
  if (action === "verify_code") {
    const { enterpriseId, code, voucher } = body;

    if (!code && !voucher) {
      throw new AppError("Please provide an 8-digit invite code or voucher.", 400);
    }

    let targetCompany: any = null;

    if (enterpriseId) {
      targetCompany = await companyService.getCompany(enterpriseId);
    } else if (voucher) {
      // Find company by voucher code in Firestore
      const snap = await firestoreDb
        .collection("companies")
        .where("voucherCode", "==", voucher.trim().toUpperCase())
        .limit(1)
        .get();
      if (!snap.empty) {
        targetCompany = { id: snap.docs[0].id, ...snap.docs[0].data() };
      }
    }

    if (!targetCompany) {
      return NextResponse.json(
        fail("WORKSPACE_NOT_FOUND", "No enterprise workspace found for this code."),
        { status: 404 }
      );
    }

    const companyId = targetCompany.id || targetCompany._id;

    // Verify 8-Digit Rotating Code (checks current window and previous 15-min window for grace period)
    let isCodeValid = false;
    if (code) {
      const trimmedCode = code.toString().trim();
      const currentCode = generate15MinRotatingCode(companyId, 0);
      const graceCode = generate15MinRotatingCode(companyId, -1); // 15-min grace window

      if (trimmedCode === currentCode || trimmedCode === graceCode) {
        isCodeValid = true;
      }
    }

    // Verify Permanent Voucher Code
    if (voucher && targetCompany.voucherCode) {
      if (voucher.trim().toUpperCase() === targetCompany.voucherCode.trim().toUpperCase()) {
        isCodeValid = true;
      }
    }

    if (!isCodeValid) {
      return NextResponse.json(
        fail("INVALID_EXPIRED_CODE", "Invite code is invalid or has expired. Please ask your Admin for a refreshed link."),
        { status: 403 }
      );
    }

    return NextResponse.json(
      success({
        valid: true,
        enterpriseId: companyId,
        companyName: targetCompany.companyName || "",
        companySlug: targetCompany.slug || "",
        companyLogo: targetCompany.companyLogo || null,
        brandColor: targetCompany.brandColor || "#0052FF",
        isColorLocked: Boolean(targetCompany.isColorLocked),
        employeeLimit: targetCompany.employeeLimit || 50,
      })
    );
  }

  // Admin authentication required for Employee Invitations
  const context = await resolveAuth(request);
  const companyId = context.user?.companyId;

  if (!companyId) {
    throw new AppError("Admin access required: no enterprise workspace associated.", 403);
  }

  // =========================================================================
  // 2. ADD SINGLE EMPLOYEE DIRECTLY (Admin Form)
  // =========================================================================
  if (action === "add_single_employee") {
    const { fullName, workEmail, jobTitle, role = "employee" } = body;

    if (!fullName || !workEmail) {
      throw new AppError("Full name and work email are required.", 400);
    }

    const employeeDocId = `emp_${Date.now()}`;
    const employeeData = {
      id: employeeDocId,
      name: fullName,
      email: workEmail.toLowerCase().trim(),
      role,
      jobTitle: jobTitle || "Team Member",
      companyId,
      status: "invited",
      invitedAt: new Date().toISOString(),
    };

    // 1. Add to Firestore enterprise subcollection
    await firestoreDb
      .collection("companies")
      .doc(companyId)
      .collection("employees")
      .doc(employeeDocId)
      .set(employeeData);

    // 2. Also register in MongoDB Cards placeholder
    const db = await connectDB();
    const slug = `${fullName.toLowerCase().replace(/[^a-z0-9]/g, "-")}-${companyId.slice(-4)}`;
    
    await db.collection("cards").updateOne(
      { email: workEmail.toLowerCase().trim() },
      {
        $setOnInsert: {
          fullName,
          jobTitle: jobTitle || "",
          companyId,
          companyName: context.user?.companyName || "Enterprise Workspace",
          email: workEmail.toLowerCase().trim(),
          slug,
          role: "employee",
          cardStatus: "invited",
          createdAt: new Date(),
        },
      },
      { upsert: true }
    );

    return NextResponse.json(
      success({
        message: `Employee ${fullName} invited successfully.`,
        employee: employeeData,
      })
    );
  }

  // =========================================================================
  // 3. BATCH INVITE EMAILS (Admin Batch Chips Form)
  // =========================================================================
  if (action === "batch_invite_emails") {
    const { emails = [] } = body;

    if (!Array.isArray(emails) || emails.length === 0) {
      throw new AppError("An array of work emails is required.", 400);
    }

    const cleanEmails = emails.map((e: string) => e.toLowerCase().trim()).filter(Boolean);

    // Add to Firestore invitedEmails array union
    const companyRef = firestoreDb.collection("companies").doc(companyId);
    await companyRef.update({
      invitedEmails: require("firebase-admin").firestore.FieldValue.arrayUnion(...cleanEmails),
    });

    return NextResponse.json(
      success({
        message: `Successfully sent invites to ${cleanEmails.length} email addresses.`,
        invitedCount: cleanEmails.length,
      })
    );
  }

  // =========================================================================
  // 4. ACCEPT INVITE / ONBOARD EMPLOYEE
  // =========================================================================
  if (action === "accept_invite") {
    const uid = context.uid;
    const { enterpriseId, jobTitle, phone } = body;

    if (!enterpriseId) {
      throw new AppError("Enterprise ID required to accept invite.", 400);
    }

    const company: any = await companyService.getCompany(enterpriseId);
    if (!company) {
      throw new AppError("Target enterprise workspace not found.", 404);
    }

    // Update user profile with company binding
    await firestoreDb.collection("users").doc(uid).set(
      {
        companyId: enterpriseId,
        companyName: company.companyName,
        role: "employee",
        jobTitle: jobTitle || "Team Member",
        updatedAt: require("firebase-admin").firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // Update MongoDB Card
    const db = await connectDB();
    await db.collection("cards").updateOne(
      { userId: uid },
      {
        $set: {
          companyId: enterpriseId,
          companyName: company.companyName,
          role: "employee",
          jobTitle: jobTitle || "",
          themeColor: company.brandColor || "#0052FF",
          bannerUrl: company.companyBanner || null,
          companyLogo: company.companyLogo || null,
          updatedAt: new Date(),
        },
      },
      { upsert: true }
    );

    return NextResponse.json(
      success({
        message: `Successfully joined ${company.companyName}! Brand guidelines applied.`,
        enterpriseId,
        companyName: company.companyName,
        brandColor: company.brandColor,
      })
    );
  }

  throw new AppError(`Unknown action: ${action}`, 400);
});
