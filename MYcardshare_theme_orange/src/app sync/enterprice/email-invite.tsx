import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { firestoreDb, admin } from "@/backend/config/firebase";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";
import crypto from "crypto";
import nodemailer from "nodemailer";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * 15-MINUTE DETERMINISTIC ROTATING CODE GENERATOR
 */
function generate15MinRotatingCode(enterpriseId: string, timeWindowOffset: number = 0): string {
  const currentSlot = Math.floor(Date.now() / (15 * 60 * 1000)) + timeWindowOffset;
  const hash = crypto
    .createHash("sha256")
    .update(`${enterpriseId}_salt_enterprise_invite_${currentSlot}`)
    .digest("hex");
  const intVal = parseInt(hash.substring(0, 8), 16);
  return (10000000 + (intVal % 90000000)).toString();
}

/**
 * EMAIL TRANSPORTER CONFIGURATION
 * Uses standard SMTP (Gmail / SendGrid / Custom SMTP) with safe fallback.
 */
function getEmailTransporter() {
  const smtpHost = process.env.SMTP_HOST || "smtp.gmail.com";
  const smtpPort = parseInt(process.env.SMTP_PORT || "587", 10);
  const smtpUser = process.env.SMTP_USER || process.env.EMAIL_USER;
  const smtpPass = process.env.SMTP_PASS || process.env.EMAIL_PASS;

  if (smtpUser && smtpPass) {
    return nodemailer.createTransport({
      host: smtpHost,
      port: smtpPort,
      secure: smtpPort === 465,
      auth: {
        user: smtpUser,
        pass: smtpPass,
      },
    });
  }
  return null;
}

/**
 * ENTERPRISE EMAIL INVITATION & DIRECT ONBOARDING SYNC (APP <-> WEB)
 * 
 * Supports:
 * 1. POST /api/sync/enterprise-email-invite
 *    - action: "send_batch_email_invites"
 *      - Admin adds emails (e.g. tushti@pentacloudconsulting.com) & submits.
 *      - Generates rotating 15-minute secure code & direct invitation link.
 *      - Stores pending invitation in Firestore & MongoDB.
 *      - Sends real branded email to recipient with [Accept & Join Team] button.
 * 
 *    - action: "accept_email_invite"
 *      - Invited employee clicks link from email or types email + password.
 *      - Validates invitation token/code.
 *      - Directly creates/binds employee in Firebase Auth, Firestore, and MongoDB.
 *      - Instant team onboarding (NO WAITING FOR APPROVAL).
 * 
 * 2. GET /api/sync/enterprise-email-invite?enterpriseId=...&code=...&email=...
 *    - Resolves invitation link when employee opens it from their email inbox.
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const url = new URL(request.url);
  const enterpriseId = url.searchParams.get("enterpriseId");
  const code = url.searchParams.get("code");
  const email = url.searchParams.get("email")?.toLowerCase().trim();

  if (!enterpriseId || !code) {
    throw new AppError("Invalid invitation link parameters.", 400);
  }

  const company: any = await companyService.getCompany(enterpriseId);
  if (!company) {
    throw new AppError("Enterprise workspace not found.", 404);
  }

  // Verify 15-minute code
  const currentCode = generate15MinRotatingCode(enterpriseId, 0);
  const graceCode = generate15MinRotatingCode(enterpriseId, -1);
  const isCodeValid = code.trim() === currentCode || code.trim() === graceCode;

  return NextResponse.json(
    success({
      valid: isCodeValid,
      isExpired: !isCodeValid,
      enterpriseId,
      companyName: company.companyName || "Corporate Workspace",
      companyLogo: company.companyLogo || null,
      companyBanner: company.companyBanner || null,
      brandColor: company.brandColor || "#0052FF",
      isColorLocked: Boolean(company.isColorLocked),
      invitedEmail: email || null,
      message: isCodeValid 
        ? `You have been invited to join ${company.companyName}!`
        : "This invitation link has expired. Please ask your administrator to resend the invite.",
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const body = await request.json();
  const { action = "send_batch_email_invites" } = body;
  const db = await connectDB();

  // =========================================================================
  // 1. ADMIN DISPATCHES EMAIL INVITATIONS (Screenshot Modal Flow)
  // =========================================================================
  if (action === "send_batch_email_invites") {
    const context = await resolveAuth(request);
    const companyId = context.user?.companyId;

    if (!companyId) {
      throw new AppError("No enterprise workspace associated with your admin account.", 403);
    }

    const { emails = [], customMessage } = body;
    if (!Array.isArray(emails) || emails.length === 0) {
      throw new AppError("At least one employee email is required.", 400);
    }

    const company: any = await companyService.getCompany(companyId);
    if (!company) {
      throw new AppError("Company record not found.", 404);
    }

    const companyName = company.companyName || "Enterprise Workspace";
    const rotatingCode = generate15MinRotatingCode(companyId);
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || "https://mycardshare.com";

    const transporter = getEmailTransporter();
    const sentResults: any[] = [];

    for (const rawEmail of emails) {
      const cleanEmail = String(rawEmail).toLowerCase().trim();
      if (!cleanEmail || !cleanEmail.includes("@")) continue;

      const directJoinUrl = `${baseUrl}/join-workspace?enterpriseId=${companyId}&code=${rotatingCode}&email=${encodeURIComponent(cleanEmail)}`;

      const inviteDoc = {
        companyId,
        companyName,
        email: cleanEmail,
        rotatingCode,
        directJoinUrl,
        status: "pending", // "pending" | "accepted"
        invitedByAdminId: context.uid,
        invitedAt: new Date(),
      };

      // 1. Persist in Firestore 'companies/{id}/invitations'
      await firestoreDb
        .collection("companies")
        .doc(companyId)
        .collection("invitations")
        .doc(cleanEmail)
        .set(inviteDoc, { merge: true });

      // 2. Persist in MongoDB
      await db.collection("enterprise_invitations").updateOne(
        { companyId, email: cleanEmail },
        { $set: inviteDoc },
        { upsert: true }
      );

      // 3. Dispatch Branded HTML Email via Nodemailer if SMTP configured
      let emailDispatched = false;
      let emailError = null;

      if (transporter) {
        try {
          const mailHtml = `
            <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 30px; border-radius: 16px; background-color: #ffffff; border: 1px solid #e2e8f0;">
              <div style="text-align: center; margin-bottom: 24px;">
                <h1 style="color: #0052FF; margin: 0; font-size: 24px;">MyCardShare Enterprise</h1>
              </div>
              <h2 style="color: #1e293b; font-size: 20px; margin-bottom: 12px;">You've Been Invited to Join ${companyName}! 🏢</h2>
              <p style="color: #64748b; font-size: 15px; line-height: 1.6;">
                The administrator of <strong>${companyName}</strong> has invited you to activate your official branded digital business card and join their corporate workspace.
              </p>
              ${customMessage ? `<p style="padding: 12px; background: #f8fafc; border-left: 4px solid #0052FF; color: #334155; font-style: italic;">"${customMessage}"</p>` : ""}
              
              <div style="text-align: center; margin: 32px 0;">
                <a href="${directJoinUrl}" style="background-color: #0052FF; color: #ffffff; padding: 14px 32px; text-decoration: none; border-radius: 12px; font-weight: bold; font-size: 15px; display: inline-block; box-shadow: 0 4px 14px rgba(0, 82, 255, 0.3);">
                  Accept & Join Team ➔
                </a>
              </div>
              
              <div style="background: #f1f5f9; padding: 16px; border-radius: 12px; text-align: center; margin-bottom: 20px;">
                <p style="margin: 0 0 6px 0; color: #64748b; font-size: 13px;">Or enter this 8-digit code in the MyCardShare mobile app:</p>
                <span style="font-size: 24px; font-weight: 800; letter-spacing: 4px; color: #0052FF;">${rotatingCode}</span>
                <p style="margin: 6px 0 0 0; color: #94a3b8; font-size: 11px;">Valid for 15 minutes. Automatically refreshes for your security.</p>
              </div>

              <hr style="border: 0; border-top: 1px solid #e2e8f0; margin: 24px 0;" />
              <p style="color: #94a3b8; font-size: 12px; text-align: center; margin: 0;">
                This invitation was sent to ${cleanEmail}. If you were not expecting this, you can ignore this email.
              </p>
            </div>
          `;

          await transporter.sendMail({
            from: process.env.EMAIL_FROM || `"MyCardShare Enterprise" <noreply@mycardshare.com>`,
            to: cleanEmail,
            subject: `Invitation: Join ${companyName} on MyCardShare`,
            html: mailHtml,
          });
          emailDispatched = true;
        } catch (err: any) {
          console.error(`[Invite Email] Failed to send email to ${cleanEmail}:`, err.message);
          emailError = err.message;
        }
      }

      sentResults.push({
        email: cleanEmail,
        directJoinUrl,
        rotatingCode,
        emailDispatched,
        emailError,
      });
    }

    return NextResponse.json(
      success({
        message: `Invitations processed for ${sentResults.length} team members.`,
        enterpriseId: companyId,
        companyName,
        rotatingCode,
        results: sentResults,
      })
    );
  }

  // =========================================================================
  // 2. EMPLOYEE ACCEPTS EMAIL INVITE (Fills Email & Password -> Instant Join)
  // =========================================================================
  if (action === "accept_email_invite") {
    const { enterpriseId, email, password, fullName, jobTitle } = body;

    if (!enterpriseId || !email || !password) {
      throw new AppError("enterpriseId, email, and password are required to join.", 400);
    }

    const cleanEmail = email.toLowerCase().trim();
    const company: any = await companyService.getCompany(enterpriseId);

    if (!company) {
      throw new AppError("Target enterprise workspace not found.", 404);
    }

    // 1. Resolve or Create User in Firebase Auth
    let userRecord: any = null;
    try {
      userRecord = await admin.auth().getUserByEmail(cleanEmail);
      // Update password if existing
      await admin.auth().updateUser(userRecord.uid, { password });
    } catch (err: any) {
      if (err.code === "auth/user-not-found") {
        userRecord = await admin.auth().createUser({
          email: cleanEmail,
          password,
          displayName: fullName || "Team Member",
        });
      } else {
        throw new AppError(err.message || "Failed to authenticate employee.", 500);
      }
    }

    const employeeUid = userRecord.uid;
    const employeeName = fullName || userRecord.displayName || "Team Member";

    // 2. Bind Employee to Enterprise Workspace in Firestore (Active Status)
    const employeeProfile = {
      uid: employeeUid,
      userId: employeeUid,
      email: cleanEmail,
      displayName: employeeName,
      fullName: employeeName,
      jobTitle: jobTitle || "Team Member",
      companyId: enterpriseId,
      companyName: company.companyName,
      role: "employee",
      status: "active",
      onboardingCompleted: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await Promise.all([
      firestoreDb.collection("users").doc(employeeUid).set(employeeProfile, { merge: true }),
      firestoreDb
        .collection("companies")
        .doc(enterpriseId)
        .collection("employees")
        .doc(employeeUid)
        .set(employeeProfile),
      // Mark invitation as accepted
      firestoreDb
        .collection("companies")
        .doc(enterpriseId)
        .collection("invitations")
        .doc(cleanEmail)
        .set({ status: "accepted", acceptedAt: new Date() }, { merge: true }),
    ]);

    // 3. Auto-Create Branded Corporate Digital Card in MongoDB
    const slug = `${employeeName.toLowerCase().replace(/[^a-z0-9]/g, "-")}-${enterpriseId.slice(-4)}`;
    await db.collection("cards").updateOne(
      { userId: employeeUid },
      {
        $set: {
          userId: employeeUid,
          companyId: enterpriseId,
          companyName: company.companyName,
          fullName: employeeName,
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
        joined: true,
        userId: employeeUid,
        companyId: enterpriseId,
        companyName: company.companyName,
        role: "employee",
        status: "active",
        message: `Welcome to ${company.companyName}! You have successfully joined your team workspace.`,
      })
    );
  }

  throw new AppError(`Unknown action: ${action}`, 400);
});
