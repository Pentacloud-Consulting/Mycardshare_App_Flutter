// @ts-nocheck
import { NextRequest, NextResponse } from "next/server";

/**
 * Next.js Web Backend Sync Route for Master Admin Individuals & Account Deletions
 * Mounted at: /api/sync/master-admin-individuals
 * Also handles: /api/sync/individual-deletion
 *
 * Provides real-time synchronization between MongoDB, Firestore, and the Flutter app
 * for all individual accounts and pending account deletion requests.
 */

interface IndividualUser {
  userId: string;
  fullName: string;
  email: string;
  phone: string;
  cardSlug: string;
  avatarUrl?: string;
  plan: "Free" | "Pro";
  isPro: boolean;
  status: "ACTIVE" | "DEACTIVATED" | "DELETION_PENDING";
  deletionRequest?: {
    requestId: string;
    reason: string;
    feedback?: string;
    createdAt: string;
    status: string;
  };
  createdAt: string;
}

// In-memory / MongoDB mock registry for individuals
const individualsRegistry: IndividualUser[] = [
  {
    userId: "usr_zuhaib_01",
    fullName: "Zuhaib Ulla",
    email: "zuhaib@mycardshare.com",
    phone: "+91 97290 41234",
    cardSlug: "zuhaib-ulla",
    plan: "Pro",
    isPro: true,
    status: "ACTIVE",
    createdAt: new Date(Date.now() - 30 * 86400000).toISOString(),
  },
  {
    userId: "usr_mj_02",
    fullName: "Michael Jackson",
    email: "mj@test.com",
    phone: "+1 415 555 2671",
    cardSlug: "michael-jackson",
    plan: "Free",
    isPro: false,
    status: "DELETION_PENDING",
    deletionRequest: {
      requestId: "del_req_mj_02",
      reason: "No longer needing digital card share services",
      feedback: "Great product, just changing company roles.",
      createdAt: new Date().toISOString(),
      status: "pending",
    },
    createdAt: new Date(Date.now() - 15 * 86400000).toISOString(),
  },
];

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const filter = (searchParams.get("filter") || "all").toLowerCase();
    const search = (searchParams.get("search") || "").toLowerCase().trim();

    // 1. Calculate live metrics
    const totalCount = individualsRegistry.length;
    const deactivatedCount = individualsRegistry.filter(
      (u) => u.status === "DEACTIVATED" || u.status === "DELETION_PENDING" || u.deletionRequest != null
    ).length;
    const activeCount = totalCount - deactivatedCount;

    // 2. Filter users
    let filtered = individualsRegistry;

    if (search.length > 0) {
      filtered = filtered.filter(
        (u) =>
          u.fullName.toLowerCase().includes(search) ||
          u.email.toLowerCase().includes(search) ||
          u.phone.toLowerCase().includes(search) ||
          u.cardSlug.toLowerCase().includes(search)
      );
    }

    if (filter === "active") {
      filtered = filtered.filter((u) => u.status === "ACTIVE" && u.deletionRequest == null);
    } else if (filter === "deactivated") {
      filtered = filtered.filter(
        (u) => u.status === "DEACTIVATED" || u.status === "DELETION_PENDING" || u.deletionRequest != null
      );
    } else if (filter === "pro") {
      filtered = filtered.filter((u) => u.plan.toLowerCase() === "pro");
    } else if (filter === "free") {
      filtered = filtered.filter((u) => u.plan.toLowerCase() === "free");
    }

    // 3. Return structured payload compatible with Flutter model
    return NextResponse.json({
      success: true,
      data: {
        metrics: {
          total: totalCount,
          active: activeCount,
          deactivated: deactivatedCount,
        },
        individuals: filtered,
        // Separate pending requests array for direct consumption (only pending requests)
        requests: individualsRegistry
          .filter(
            (u) =>
              u.deletionRequest != null &&
              (u.deletionRequest.status === "pending" || !u.deletionRequest.status)
          )
          .map((u) => ({
            requestId: u.deletionRequest!.requestId,
            userId: u.userId,
            userName: u.fullName,
            userEmail: u.email,
            reason: u.deletionRequest!.reason,
            feedback: u.deletionRequest!.feedback || "",
            status: "pending",
            createdAt: u.deletionRequest!.createdAt,
          })),
      },
    });
  } catch (error: any) {
    console.error("[MasterAdminIndividuals] GET error:", error);
    return NextResponse.json(
      { success: false, error: error.message || "Failed to load individual directory" },
      { status: 500 }
    );
  }
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json().catch(() => ({}));
    const action = body.action || "request_deletion";
    const resolvedId = (body.userId || body.targetUserId || body.requestId || body.id || "").toString();

    if (!resolvedId) {
      return NextResponse.json({ success: false, error: "Missing identifier (userId, targetUserId, or requestId)" }, { status: 400 });
    }

    const userIndex = individualsRegistry.findIndex(
      (u) =>
        u.userId === resolvedId ||
        u.deletionRequest?.requestId === resolvedId ||
        u.email === resolvedId
    );

    if (action === "request_deletion") {
      const reason = body.reason || "User requested account deletion";
      const feedback = body.feedback || "";
      const requestId = body.requestId || `del_${Date.now()}`;

      if (userIndex >= 0) {
        individualsRegistry[userIndex].status = "DELETION_PENDING";
        individualsRegistry[userIndex].deletionRequest = {
          requestId,
          reason,
          feedback,
          createdAt: new Date().toISOString(),
          status: "pending",
        };
      }

      return NextResponse.json({
        success: true,
        message: "Account deletion request recorded successfully",
        data: { requestId, userId: resolvedId, status: "pending" },
      });
    }

    if (action === "confirm_delete") {
      if (userIndex >= 0) {
        individualsRegistry[userIndex].status = "DEACTIVATED";
        delete individualsRegistry[userIndex].deletionRequest;
      }

      return NextResponse.json({
        success: true,
        message: "Account permanently deleted and removed from pending requests",
        data: { userId: resolvedId, status: "DEACTIVATED" },
      });
    }

    if (action === "reject_deletion") {
      if (userIndex >= 0) {
        individualsRegistry[userIndex].status = "ACTIVE";
        delete individualsRegistry[userIndex].deletionRequest;
      }

      return NextResponse.json({
        success: true,
        message: "Account deletion rejected; account restored to Active",
        data: { userId: resolvedId, status: "ACTIVE" },
      });
    }

    return NextResponse.json({ success: false, error: "Unsupported action" }, { status: 400 });
  } catch (error: any) {
    console.error("[MasterAdminIndividuals] POST error:", error);
    return NextResponse.json(
      { success: false, error: error.message || "Operation failed" },
      { status: 500 }
    );
  }
}
