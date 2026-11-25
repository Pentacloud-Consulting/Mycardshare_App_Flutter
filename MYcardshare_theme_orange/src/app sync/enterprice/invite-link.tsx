import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { firestoreDb, admin } from "@/backend/config/firebase";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";
import crypto from "crypto";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * DETERMINISTIC 15-MINUTE ROTATING CODE ALGORITHM
 * Generates an 8-digit numeric code (10000000 - 99999999) based on
 * Enterprise UID and current 15-minute time-slot window.
 */
function generate15MinRotatingCode(enterpriseId: string, timeWindowOffset: number = 0): string {
  const currentSlot = Math.floor(Date.now() / (15 * 60 * 1000)) + timeWindowOffset;
  const hash = crypto
    .createHash("sha256")
    .update(`${enterpriseId}_salt_nexus_invite_${currentSlot}`)
    .digest("hex");

  const intVal = parseInt(hash.substring(0, 8), 16);
  return (10000000 + (intVal % 90000000)).toString();
}

/**
 * ENTERPRISE INVITE LINK & INSTANT WORKSPACE ONBOARDING SYNC (APP <-> WEB)
 * 
 * Target Flow:
 * 1. Admin generates 15-minute rotating invite link / 8-digit code (popup_invite.dart / invite_link.dart)
 * 2. Employee enters link or 8-digit code in app (join_workspace.dart)
 * 3. System instantly resolves company preview (Name, Logo, Member Count, Brand Color)
 * 4. Employee submits (join_login.dart) -> Instant Onboarding with NO manual approval!
 * 
 * Supports:
 * - GET /api/sync/enterprise-invite-link
 *   - Admin: Fetches live 8-digit code, remaining time countdown, and shareable join links
 *   - Public (with ?code=... or ?enterpriseId=...): Look up enterprise details for landing screen preview
 * 
 * - POST /api/sync/enterprise-invite-link
 *   - action: "lookup_code" -> Live preview of company when employee types 8-digit code
 *   - action: "instant_onboard" -> Complete instant registration & bind to enterprise workspace
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const url = new URL(request.url);
  const lookupCode = url.searchParams.get("code");
  const enterpriseIdParam = url.searchParams.get("enterpriseId");
  const inviteeParam = url.searchParams.get("invitee");

  // =========================================================================
  // CASE A: PUBLIC LANDING PREVIEW (Employee opens /join-workspace?code=... link)
  // =========================================================================
  if (lookupCode || enterpriseIdParam) {
    let targetCompany: any = null;
    let targetCompanyId = enterpriseIdParam || "";

    if (enterpriseIdParam) {
      targetCompany = (await companyService.getCompany(enterpriseIdParam)) as any;
    }

    // If only code is provided, search across active companies
    if (!targetCompany && lookupCode) {
      const companiesSnap = await firestoreDb.collection("companies").get();
      for (const doc of companiesSnap.docs) {
        const cId = doc.id;
        const currentCode = generate15MinRotatingCode(cId, 0);
        const graceCode = generate15MinRotatingCode(cId, -1); // 15-min grace window

        if (lookupCode.trim() === currentCode || lookupCode.trim() === graceCode) {
          targetCompany = doc.data();
          targetCompanyId = cId;
          break;
        }
      }
    }

    if (!targetCompany) {
      return NextResponse.json(
        fail("INVALID_EXPIRED_LINK", "This invite link is invalid or has expired (15-minute validity). Ask your admin for a fresh link."),
        { status: 404 }
      );
    }

    // Count current active employees in workspace
    let activeMembersCount = 0;
    try {
      const empSnap = await firestoreDb
        .collection("companies")
        .doc(targetCompanyId)
        .collection("employees")
        .get();
      activeMembersCount = empSnap.size;
    } catch (e) {}

    return NextResponse.json(
      success({
        valid: true,
        enterpriseId: targetCompanyId,
        companyName: targetCompany.companyName || "Corporate Workspace",
        companyLogo: targetCompany.companyLogo || null,
        companyBanner: targetCompany.companyBanner || null,
        brandColor: targetCompany.brandColor || "#0052FF",
        isColorLocked: Boolean(targetCompany.isColorLocked),
        activeMembersCount,
        inviteeEmail: inviteeParam || null,
      })
    );
  }

  // =========================================================================
  // CASE B: ADMIN GENERATES LIVE LINK (popup_invite.dart / invite_link.dart)
  // =========================================================================
  const context = await resolveAuth(request);
  const companyId = context.user?.companyId;

  if (!companyId) {
    throw new AppError("No enterprise workspace associated with your account.", 400);
  }

  const company: any = await companyService.getCompany(companyId);
  if (!company) {
    throw new AppError("Enterprise workspace not found.", 404);
  }

  const now = Date.now();
  const slotDurationMs = 15 * 60 * 1000;
  const currentSlotStart = Math.floor(now / slotDurationMs) * slotDurationMs;
  const nextSlotStart = currentSlotStart + slotDurationMs;
  const secondsRemaining = Math.max(0, Math.floor((nextSlotStart - now) / 1000));

  const rotatingCode = generate15MinRotatingCode(companyId);
  const baseUrl =
    process.env.NEXT_PUBLIC_BASE_URL ||
    process.env.PUBLIC_BASE_URL ||
    "https://mycardshare.com";

  const generalWorkspaceUrl = `${baseUrl}/join-workspace?enterpriseId=${companyId}&code=${rotatingCode}`;

  return NextResponse.json(
    success({
      enterpriseId: companyId,
      companyName: company.companyName || "Corporate Workspace",
      companyLogo: company.companyLogo || null,
      brandColor: company.brandColor || "#0052FF",
      rotatingCode: {
        code: rotatingCode,
        secondsRemaining,
        expiresAt: new Date(nextSlotStart).toISOString(),
      },
      inviteUrls: {
        generalWorkspaceUrl,
        customTargetedUrlTemplate: `${baseUrl}/join-workspace?enterpriseId=${companyId}&code=${rotatingCode}&invitee={email}`,
      },
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const body = await request.json();
  const { action = "lookup_code" } = body;
  const db = await connectDB();

  // =========================================================================
  // 1. LOOKUP ENTERPRISE BY 8-DIGIT CODE (join_workspace.dart typing code)
  // =========================================================================
  if (action === "lookup_code") {
    const { code, enterpriseId } = body;

    if (!code) {
      throw new AppError("Please enter an 8-digit invite code.", 400);
    }

    const trimmedCode = code.toString().trim();
    let targetCompany: any = null;
    let targetCompanyId = enterpriseId || "";

    if (enterpriseId) {
      const comp = (await companyService.getCompany(enterpriseId)) as any;
      if (comp) {
        const currentCode = generate15MinRotatingCode(enterpriseId, 0);
        const graceCode = generate15MinRotatingCode(enterpriseId, -1);
        const voucher = comp.voucherCode ? String(comp.voucherCode).trim().toUpperCase() : null;

        if (trimmedCode === currentCode || trimmedCode === graceCode || (voucher && trimmedCode.toUpperCase() === voucher)) {
          targetCompany = comp;
          targetCompanyId = enterpriseId;
        }
      }
    } else {
      // Check permanent voucher codes first (precise match)
      const voucherSnap = await firestoreDb
        .collection("companies")
        .where("voucherCode", "==", trimmedCode.toUpperCase())
        .limit(1)
        .get();

      if (!voucherSnap.empty) {
        targetCompany = voucherSnap.docs[0].data();
        targetCompanyId = voucherSnap.docs[0].id;
      } else {
        // Fallback scan across active approved companies only
        const companiesSnap = await firestoreDb
          .collection("companies")
          .where("approvalStatus", "==", "approved")
          .get();

        for (const doc of companiesSnap.docs) {
          const cId = doc.id;
          const currentCode = generate15MinRotatingCode(cId, 0);
          const graceCode = generate15MinRotatingCode(cId, -1);

          if (trimmedCode === currentCode || trimmedCode === graceCode) {
            targetCompany = doc.data();
            targetCompanyId = cId;
            break;
          }
        }
      }
    }

    if (!targetCompany) {
      return NextResponse.json(
        fail("CODE_NOT_FOUND_OR_EXPIRED", "The 8-digit invite code is invalid or has expired (15-minute window)."),
        { status: 404 }
      );
    }

    let activeMembersCount = 0;
    try {
      const empSnap = await firestoreDb
        .collection("companies")
        .doc(targetCompanyId)
        .collection("employees")
        .get();
      activeMembersCount = empSnap.size;
    } catch (e) {}

    return NextResponse.json(
      success({
        valid: true,
        enterpriseId: targetCompanyId,
        companyName: targetCompany.companyName || "Corporate Workspace",
        companyLogo: targetCompany.companyLogo || null,
        companyBanner: targetCompany.companyBanner || null,
        brandColor: targetCompany.brandColor || "#0052FF",
        isColorLocked: Boolean(targetCompany.isColorLocked),
        activeMembersCount,
      })
    );
  }

  // =========================================================================
  // 2. INSTANT ONBOARDING (join_login.dart -> NO MANUAL APPROVAL NEEDED!)
  // =========================================================================
  if (action === "instant_onboard") {
    const { enterpriseId, code, fullName, workEmail, password, jobTitle } = body;

    if (!enterpriseId || !code || !fullName || !workEmail) {
      throw new AppError("enterpriseId, code, fullName, and workEmail are required.", 400);
    }

    const company: any = await companyService.getCompany(enterpriseId);
    if (!company) {
      throw new AppError("Target enterprise workspace not found.", 404);
    }

    // 1. Verify 15-Minute Rotating Code OR Permanent Voucher Code
    const trimmedCode = code.toString().trim();
    const currentCode = generate15MinRotatingCode(enterpriseId, 0);
    const graceCode = generate15MinRotatingCode(enterpriseId, -1);
    const voucher = company.voucherCode ? String(company.voucherCode).trim().toUpperCase() : null;

    const isMatch = (trimmedCode === currentCode || trimmedCode === graceCode || (voucher && trimmedCode.toUpperCase() === voucher));

    if (!isMatch) {
      throw new AppError("Invite code expired or invalid. Please ask admin for a refreshed link.", 403);
    }

    const cleanEmail = workEmail.toLowerCase().trim();

    // 2. Resolve or Create User in Firebase Auth
    let userRecord: any = null;
    try {
      userRecord = await admin.auth().getUserByEmail(cleanEmail);
    } catch (err: any) {
      if (err.code === "auth/user-not-found" && password) {
        userRecord = await admin.auth().createUser({
          email: cleanEmail,
          password,
          displayName: fullName,
        });
      } else {
        throw new AppError("User account not found. Please provide a password to create your account.", 400);
      }
    }

    const newUserId = userRecord.uid;

    // 3. Promote & Bind User to Enterprise in Firestore (Active Status - NO PENDING!)
    const employeeData = {
      uid: newUserId,
      userId: newUserId,
      email: cleanEmail,
      displayName: fullName,
      fullName,
      jobTitle: jobTitle || "Team Member",
      companyId: enterpriseId,
      companyName: company.companyName || "Corporate Workspace",
      role: "employee",
      status: "active",
      onboardingCompleted: true,
      joinedViaInviteLink: true,
      joinedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await Promise.all([
      // Update users/{uid}
      firestoreDb.collection("users").doc(newUserId).set(employeeData, { merge: true }),
      // Add into companies/{id}/employees/{uid}
      firestoreDb
        .collection("companies")
        .doc(enterpriseId)
        .collection("employees")
        .doc(newUserId)
        .set(employeeData),
    ]);

    // 4. Create / Bind Corporate Digital Card in MongoDB with Locked Brand Colors
    const slug = `${fullName.toLowerCase().replace(/[^a-z0-9]/g, "-")}-${enterpriseId.slice(-4)}`;
    await db.collection("cards").updateOne(
      { userId: newUserId },
      {
        $set: {
          userId: newUserId,
          companyId: enterpriseId,
          companyName: company.companyName,
          fullName,
          email: cleanEmail,
          jobTitle: jobTitle || "Team Member",
          role: "employee",
          status: "active",
          cardStatus: "Published",
          themeColor: company.brandColor || "#0052FF",
          bannerUrl: company.companyBanner || null,
          companyLogo: company.companyLogo || null,
          isColorLocked: Boolean(company.isColorLocked),
          slug,
          lastUpdated: new Date(),
        },
        $setOnInsert: {
          views: 0,
          shares: 0,
          createdAt: new Date(),
        },
      },
      { upsert: true }
    );

    return NextResponse.json(
      success({
        instantOnboardingSuccess: true,
        userId: newUserId,
        companyId: enterpriseId,
        companyName: company.companyName,
        role: "employee",
        status: "active",
        brandColor: company.brandColor || "#0052FF",
        message: `Welcome to ${company.companyName}! You have joined the workspace instantly.`,
      })
    );
  }

  throw new AppError(`Unknown action: ${action}`, 400);
});
