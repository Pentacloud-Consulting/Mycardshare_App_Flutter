import { NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { firestoreDb } from "@/backend/config/firebase";
import { success } from "@/backend/utils/apiResponse";

/**
 * Mobile App & Web Enterprise Invite Code Synchronization Endpoint
 * GET /api/sync/invite-code -> returns live 15-min rotating code & voucher for current enterprise
 * POST /api/sync/invite-code -> handles verify_code, add_single_employee, batch_invite_emails
 */

export async function GET(request) {
  try {
    const context = await resolveAuth(request);
    const companyId = context.user?.companyId || context.uid;

    if (!companyId) {
      return NextResponse.json({ success: false, error: "Authentication required" }, { status: 401 });
    }

    const company = await companyService.getCompany(companyId);
    if (!company) {
      return NextResponse.json({ success: false, error: "Enterprise workspace not found" }, { status: 404 });
    }

    const inviteCode = company.inviteCode || company.voucherCode || "83063542";
    const inviteUrl = company.inviteUrl || `mycardshare.com/join-workspace?enterpriseId=${companyId}&code=${inviteCode}`;

    // Compute remaining seconds in current 15-minute window
    const now = Date.now();
    const elapsedInWindow = now % (15 * 60 * 1000);
    const expiresInSeconds = Math.max(0, Math.floor((15 * 60 * 1000 - elapsedInWindow) / 1000));

    return NextResponse.json(
      success({
        inviteCode,
        voucherCode: company.voucherCode || "",
        inviteUrl,
        expiresInSeconds,
        companyName: company.companyName || "Organization Workspace",
        enterpriseId: companyId,
      })
    );
  } catch (err) {
    console.error("[Invite Sync GET Error]", err);
    return NextResponse.json(
      { success: false, error: "Failed to fetch synchronized invite code" },
      { status: 500 }
    );
  }
}

export async function POST(request) {
  try {
    const body = await request.json().catch(() => ({}));
    const { action } = body;

    // Action 1: Verify Code for Joining Employee
    if (action === "verify_code" || !action) {
      const enterpriseId = body.enterpriseId || body.workspaceId;
      const rawCode = (body.code || body.voucher || "").trim();

      if (!rawCode && !enterpriseId) {
        return NextResponse.json({ success: false, error: "Code or enterprise ID required" }, { status: 400 });
      }

      let company = null;
      if (enterpriseId) {
        company = await companyService.getCompany(enterpriseId);
      }

      if (!company && rawCode) {
        const norm = rawCode.toUpperCase();
        let query = await firestoreDb.collection("companies").where("voucherCode", "==", norm).limit(1).get();
        if (!query.empty) {
          company = await companyService.getCompany(query.docs[0].data().companyId || query.docs[0].id);
        }
        if (!company) {
          query = await firestoreDb.collection("companies").where("inviteCode", "==", rawCode).limit(1).get();
          if (!query.empty) {
            company = await companyService.getCompany(query.docs[0].data().companyId || query.docs[0].id);
          }
        }
        if (!company) {
          query = await firestoreDb.collection("enterprises").where("inviteCode", "==", rawCode).limit(1).get();
          if (!query.empty) {
            company = await companyService.getCompany(query.docs[0].data().companyId || query.docs[0].id);
          }
        }
      }

      if (!company) {
        return NextResponse.json({ success: false, valid: false, error: "Invalid invite code" }, { status: 404 });
      }

      const effectiveId = company.id || enterpriseId;
      return NextResponse.json(
        success({
          valid: true,
          enterpriseId: effectiveId,
          workspaceId: effectiveId,
          companyName: company.companyName || "Organization Workspace",
          companySlug: company.slug || "",
          voucherCode: company.voucherCode || "",
          inviteCode: company.inviteCode || rawCode,
        })
      );
    }

    // Action 2: Add Single Employee
    if (action === "add_single_employee") {
      const context = await resolveAuth(request);
      const companyId = context.user?.companyId || context.uid;
      const { workEmail, fullName, jobTitle, role } = body;

      if (!workEmail) {
        return NextResponse.json({ success: false, error: "Work email is required" }, { status: 400 });
      }

      if (companyId) {
        await companyService.sendInvitation(companyId, workEmail.trim().toLowerCase());
      }
      return NextResponse.json(success({ message: `Invitation sent to ${workEmail}` }));
    }

    // Action 3: Batch Invite Emails
    if (action === "batch_invite_emails") {
      const context = await resolveAuth(request);
      const companyId = context.user?.companyId || context.uid;
      const { emails } = body;

      if (Array.isArray(emails) && companyId) {
        for (const em of emails) {
          const clean = String(em).trim().toLowerCase();
          if (clean && clean.includes("@")) {
            await companyService.sendInvitation(companyId, clean).catch(() => {});
          }
        }
      }
      return NextResponse.json(success({ message: "Batch invitations processed successfully" }));
    }

    return NextResponse.json({ success: false, error: "Unrecognized sync action" }, { status: 400 });
  } catch (err) {
    console.error("[Invite Sync POST Error]", err);
    return NextResponse.json(
      { success: false, error: "Server error in invite code sync" },
      { status: 500 }
    );
  }
}
