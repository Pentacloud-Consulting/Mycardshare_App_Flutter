import { NextRequest, NextResponse } from "next/server";
import crypto from "crypto";

/**
 * Next.js Web Backend Sync Route for Enterprise Invite Link & Collision Prevention
 * Endpoint: /api/sync/enterprise-invite-link
 *
 * Prevents cross-company code collision:
 * - Employs a 15-minute rotating hash salt: `${enterpriseId}_salt_nexus_invite_${currentSlot}`
 * - Enforces strict company binding when enterpriseId is specified or matches permanent voucherCode
 * - Dual check prevents cross-joining arbitrary companies (e.g. "Islamic web")
 */

interface CompanyRecord {
  enterpriseId: string;
  companyName: string;
  voucherCode: string;
  memberCount: number;
  logoUrl?: string;
  status: "active" | "pending" | "suspended";
}

// Mock company registry for enterprise invite resolution
const enterpriseRegistry: CompanyRecord[] = [
  {
    enterpriseId: "ent_mycardshare_01",
    companyName: "My Card Share Technologies",
    voucherCode: "MCS77889",
    memberCount: 14,
    logoUrl: "https://mycardshare.com/assets/logo.png",
    status: "active",
  },
  {
    enterpriseId: "ent_islamic_web_02",
    companyName: "Islamic Web Solutions",
    voucherCode: "ISL99214",
    memberCount: 6,
    logoUrl: "https://islamicweb.com/logo.png",
    status: "active",
  },
  {
    enterpriseId: "ent_pentacloud_03",
    companyName: "Pentacloud Consulting",
    voucherCode: "PENTA2026",
    memberCount: 28,
    logoUrl: "https://pentacloud.com/logo.png",
    status: "active",
  },
];

function generate15MinRotatingCode(enterpriseId: string, slotOffset = 0): string {
  const currentSlot = Math.floor(Date.now() / (15 * 60 * 1000)) + slotOffset;
  const hash = crypto
    .createHash("sha256")
    .update(`${enterpriseId}_salt_nexus_invite_${currentSlot}`)
    .digest("hex");
  // Take first 8 digits numeric/alpha
  const rawNum = parseInt(hash.substring(0, 8), 16);
  return (10000000 + (rawNum % 90000000)).toString();
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { action, code, enterpriseId, fullName, workEmail, password, jobTitle } = body;

    // ── 1. Code Lookup & Collision-Safe Verification ──
    if (action === "lookup_code") {
      const cleanCode = (code || "").trim();
      if (!cleanCode) {
        return NextResponse.json(
          { success: false, error: { message: "Invite code is required." } },
          { status: 400 }
        );
      }

      let matchedCompany: CompanyRecord | null = null;

      // If enterpriseId is provided, strictly search only within that company
      if (enterpriseId) {
        const company = enterpriseRegistry.find((c) => c.enterpriseId === enterpriseId);
        if (company) {
          const currentCode = generate15MinRotatingCode(company.enterpriseId, 0);
          const previousCode = generate15MinRotatingCode(company.enterpriseId, -1);
          if (
            cleanCode === company.voucherCode ||
            cleanCode === currentCode ||
            cleanCode === previousCode
          ) {
            matchedCompany = company;
          }
        }
      } else {
        // Search across companies matching either permanent voucherCode or rotating 15-min code
        for (const company of enterpriseRegistry) {
          const currentCode = generate15MinRotatingCode(company.enterpriseId, 0);
          const previousCode = generate15MinRotatingCode(company.enterpriseId, -1);

          if (
            cleanCode === company.voucherCode ||
            cleanCode === currentCode ||
            cleanCode === previousCode
          ) {
            matchedCompany = company;
            break;
          }
        }
      }

      if (!matchedCompany) {
        return NextResponse.json(
          {
            success: false,
            error: {
              message:
                "Invalid or expired invite code. Please request a new invite link from your company administrator.",
            },
          },
          { status: 404 }
        );
      }

      return NextResponse.json({
        success: true,
        data: {
          enterpriseId: matchedCompany.enterpriseId,
          companyName: matchedCompany.companyName,
          memberCount: matchedCompany.memberCount,
          logoUrl: matchedCompany.logoUrl,
          isExpired: false,
          isVoucherCode: cleanCode === matchedCompany.voucherCode,
        },
      });
    }

    // ── 2. Instant Onboarding with Collision Prevention ──
    if (action === "instant_onboard") {
      if (!enterpriseId || !code || !workEmail || !fullName) {
        return NextResponse.json(
          {
            success: false,
            error: { message: "Missing required onboarding fields." },
          },
          { status: 400 }
        );
      }

      const company = enterpriseRegistry.find((c) => c.enterpriseId === enterpriseId);
      if (!company) {
        return NextResponse.json(
          { success: false, error: { message: "Specified enterprise workspace not found." } },
          { status: 404 }
        );
      }

      const currentCode = generate15MinRotatingCode(company.enterpriseId, 0);
      const previousCode = generate15MinRotatingCode(company.enterpriseId, -1);
      const isValid =
        code === company.voucherCode || code === currentCode || code === previousCode;

      if (!isValid) {
        return NextResponse.json(
          {
            success: false,
            error: { message: "Invite code verification failed for this enterprise." },
          },
          { status: 400 }
        );
      }

      return NextResponse.json({
        success: true,
        data: {
          userId: `usr_emp_${Date.now()}`,
          enterpriseId: company.enterpriseId,
          companyName: company.companyName,
          workEmail: workEmail.toLowerCase(),
          fullName,
          jobTitle: jobTitle || "Team Member",
          status: "active",
          joinedAt: new Date().toISOString(),
        },
      });
    }

    return NextResponse.json(
      { success: false, error: { message: `Unsupported action: ${action}` } },
      { status: 400 }
    );
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: { message: error?.message || "Internal server error." } },
      { status: 500 }
    );
  }
}

export async function GET(request: NextRequest) {
  // Returns live rotating invite code for authenticated company admin
  const searchParams = request.nextUrl.searchParams;
  const enterpriseId = searchParams.get("enterpriseId") || "ent_mycardshare_01";
  const rotatingCode = generate15MinRotatingCode(enterpriseId, 0);

  return NextResponse.json({
    success: true,
    data: {
      enterpriseId,
      inviteCode: rotatingCode,
      expiresInSeconds: 15 * 60 - (Math.floor(Date.now() / 1000) % (15 * 60)),
      link: `https://digitalbusinesscloudcard.com/join/${enterpriseId}?code=${rotatingCode}`,
    },
  });
}
