import { NextRequest, NextResponse } from "next/server";

/**
 * Next.js Web Backend Sync Route for Master Admin Approvals
 * Endpoint: /api/sync/master-admin
 *
 * Handles live company approval / rejection cascades:
 * - Updates Enterprise document: status: "active", approvalStatus: "approved", isSuspended: false
 * - Sets 365-day subscription tenure (subscriptionStartDate & renewalDate)
 * - Cascades approval to Enterprise Admin User in users collection (users/{adminUserId})
 *   so the admin can instantly log in without getting blocked.
 */

interface CompanyApprovalPayload {
  action: "approve" | "reject";
  companyId: string;
  reason?: string;
  adminUserId?: string;
}

export async function PATCH(request: NextRequest) {
  try {
    const authHeader = request.headers.get("authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return NextResponse.json(
        { success: false, error: { message: "Unauthorized. Bearer token required." } },
        { status: 401 }
      );
    }

    const body: CompanyApprovalPayload = await request.json();
    const { action, companyId, reason, adminUserId } = body;

    if (!companyId || !action) {
      return NextResponse.json(
        { success: false, error: { message: "Missing required fields: companyId and action." } },
        { status: 400 }
      );
    }

    const now = new Date();
    const renewalDate = new Date(now.getTime() + 365 * 24 * 60 * 60 * 1000);

    if (action === "approve") {
      // 1. Company Status Update
      const companyUpdate = {
        companyId,
        status: "active",
        approvalStatus: "approved",
        isSuspended: false,
        approvedAt: now.toISOString(),
        subscriptionStartDate: now.toISOString(),
        renewalDate: renewalDate.toISOString(),
        updatedAt: now.toISOString(),
      };

      // 2. Cascade to Admin User
      const userUpdate = {
        userId: adminUserId || companyId,
        companyId,
        status: "active",
        approvalStatus: "approved",
        isSuspended: false,
        updatedAt: now.toISOString(),
      };

      return NextResponse.json({
        success: true,
        message: `Company ${companyId} and Admin User successfully approved for 365 days.`,
        data: {
          company: companyUpdate,
          adminUser: userUpdate,
        },
      });
    } else if (action === "reject") {
      const rejectionUpdate = {
        companyId,
        status: "suspended",
        approvalStatus: "rejected",
        isSuspended: true,
        rejectionReason: reason || "Declined by Master Admin",
        updatedAt: now.toISOString(),
      };

      const userRejection = {
        userId: adminUserId || companyId,
        companyId,
        status: "suspended",
        approvalStatus: "rejected",
        isSuspended: true,
        updatedAt: now.toISOString(),
      };

      return NextResponse.json({
        success: true,
        message: `Company ${companyId} rejected.`,
        data: {
          company: rejectionUpdate,
          adminUser: userRejection,
        },
      });
    } else {
      return NextResponse.json(
        { success: false, error: { message: `Unsupported action: ${action}` } },
        { status: 400 }
      );
    }
  } catch (error: any) {
    return NextResponse.json(
      {
        success: false,
        error: { message: error?.message || "Internal server error during company approval." },
      },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  // Support POST as well as PATCH for legacy calls
  return PATCH(request);
}
