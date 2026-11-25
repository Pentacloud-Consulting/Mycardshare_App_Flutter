import { NextResponse } from "next/server";
import companyService from "@/backend/services/company.service";
import { firestoreDb } from "@/backend/config/firebase";
import { success } from "@/backend/utils/apiResponse";

/**
 * Universal Workspace Invitation Verification
 * GET /api/invite/verify?workspaceId=XXX&voucher=YYY
 * GET /api/invite/verify?enterpriseId=XXX&code=YYY
 * GET /api/invite/verify?code=YYY
 * POST /api/invite/verify  { workspaceId, enterpriseId, code, voucher }
 */
async function handleVerify(params) {
  const workspaceId = (params.workspaceId || params.enterpriseId || params.companyId || "").trim();
  const rawCode = (params.voucher || params.code || params.inviteCode || "").trim();

  if (!rawCode && !workspaceId) {
    return NextResponse.json(
      { success: false, error: "Please provide an invite code or workspace invitation link." },
      { status: 400 }
    );
  }

  let company = null;

  // 1. If workspaceId was provided, look it up directly
  if (workspaceId) {
    company = await companyService.getCompany(workspaceId);
    if (!company) {
      return NextResponse.json(
        { success: false, error: "Enterprise workspace not found." },
        { status: 404 }
      );
    }

    // If code is provided, verify against voucherCode or inviteCode
    if (rawCode) {
      const normInput = rawCode.toUpperCase();
      const normVoucher = (company.voucherCode || "").trim().toUpperCase();
      const normInvite = (company.inviteCode || "").trim();

      const matchesVoucher = normVoucher && normInput === normVoucher;
      const matchesInvite = normInvite && (rawCode === normInvite || normInput === normInvite);

      if (!matchesVoucher && !matchesInvite) {
        return NextResponse.json(
          { success: false, error: "Invalid invite code for this workspace." },
          { status: 403 }
        );
      }
    }
  } else {
    // 2. Only raw code provided (e.g. employee entered 8-digit code or voucher on join page)
    const normInput = rawCode.toUpperCase();

    // Search companies by voucherCode
    let query = await firestoreDb.collection("companies").where("voucherCode", "==", normInput).limit(1).get();
    if (!query.empty) {
      const doc = query.docs[0];
      company = await companyService.getCompany(doc.data().companyId || doc.id);
    }

    // Search companies by inviteCode (8-digit app code)
    if (!company) {
      query = await firestoreDb.collection("companies").where("inviteCode", "==", rawCode).limit(1).get();
      if (!query.empty) {
        const doc = query.docs[0];
        company = await companyService.getCompany(doc.data().companyId || doc.id);
      }
    }

    // Search enterprises by voucherCode
    if (!company) {
      query = await firestoreDb.collection("enterprises").where("voucherCode", "==", normInput).limit(1).get();
      if (!query.empty) {
        const doc = query.docs[0];
        company = await companyService.getCompany(doc.data().companyId || doc.id);
      }
    }

    // Search enterprises by inviteCode
    if (!company) {
      query = await firestoreDb.collection("enterprises").where("inviteCode", "==", rawCode).limit(1).get();
      if (!query.empty) {
        const doc = query.docs[0];
        company = await companyService.getCompany(doc.data().companyId || doc.id);
      }
    }

    if (!company) {
      return NextResponse.json(
        { success: false, error: "Invitation code was not recognized. Please check with your administrator." },
        { status: 404 }
      );
    }
  }

  const effectiveWorkspaceId = company.id || company.companyId || workspaceId;
  const effectiveInviteCode = company.inviteCode || rawCode;
  const effectiveVoucher = company.voucherCode || rawCode;

  return NextResponse.json(
    success({
      valid: true,
      workspaceId: effectiveWorkspaceId,
      companyId: effectiveWorkspaceId,
      companyName: company.companyName || "Organization Workspace",
      companySlug: company.slug || "",
      voucherCode: effectiveVoucher,
      inviteCode: effectiveInviteCode,
      inviteUrl: `mycardshare.com/join-workspace?enterpriseId=${effectiveWorkspaceId}&code=${effectiveInviteCode}`,
    })
  );
}

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const params = {
      workspaceId: searchParams.get("workspaceId"),
      enterpriseId: searchParams.get("enterpriseId"),
      companyId: searchParams.get("companyId"),
      voucher: searchParams.get("voucher"),
      code: searchParams.get("code"),
      inviteCode: searchParams.get("inviteCode"),
    };
    return await handleVerify(params);
  } catch (err) {
    console.error("[Verify Invite Error]", err);
    return NextResponse.json(
      { success: false, error: "Server error while verifying invitation." },
      { status: 500 }
    );
  }
}

export async function POST(request) {
  try {
    const body = await request.json().catch(() => ({}));
    return await handleVerify(body);
  } catch (err) {
    console.error("[Verify Invite Error]", err);
    return NextResponse.json(
      { success: false, error: "Server error while verifying invitation." },
      { status: 500 }
    );
  }
}
