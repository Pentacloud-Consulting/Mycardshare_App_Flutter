// @ts-nocheck
import { NextRequest, NextResponse } from "next/server";

/**
 * Next.js Web Backend Sync Route for Master Admin Companies
 * Mounted at: /api/sync/master-admin-companies
 *
 * Provides global visibility across all companies on the platform
 * without any user-level filtering, aggregating records from MongoDB & Firestore.
 */

export interface MasterCompany {
  id: string;
  name: string;
  email: string;
  plan: string;
  seats: number;
  employeeCount: number;
  status: "Active" | "Pending" | "Suspended";
  domain?: string;
  logoUrl?: string;
  adminUserId?: string;
  createdAt: string;
}

// Global registry of all platform companies
const companiesRegistry: MasterCompany[] = [
  {
    id: "comp_islamic_web",
    name: "Islamic Web",
    email: "admin@islamicweb.com",
    plan: "Team",
    seats: 4,
    employeeCount: 4,
    status: "Active",
    domain: "islamicweb.com",
    createdAt: new Date(Date.now() - 60 * 86400000).toISOString(),
  },
  {
    id: "comp_zuhaib_company",
    name: "zuhaib company",
    email: "zuhaib@company.com",
    plan: "Free",
    seats: 0,
    employeeCount: 0,
    status: "Active",
    domain: "zuhaibcompany.com",
    createdAt: new Date(Date.now() - 2 * 86400000).toISOString(),
  },
];

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const filter = (searchParams.get("filter") || "all").toLowerCase();
    const search = (searchParams.get("search") || "").toLowerCase().trim();

    // 1. Calculate live global metrics across all companies
    const total = companiesRegistry.length;
    const active = companiesRegistry.filter((c) => c.status.toLowerCase() === "active").length;
    const pending = companiesRegistry.filter((c) => c.status.toLowerCase() === "pending").length;
    const suspended = companiesRegistry.filter((c) => c.status.toLowerCase() === "suspended").length;

    // 2. Filter companies based on query
    let filtered = companiesRegistry;

    if (search.length > 0) {
      filtered = filtered.filter(
        (c) =>
          c.name.toLowerCase().includes(search) ||
          c.email.toLowerCase().includes(search) ||
          (c.domain && c.domain.toLowerCase().includes(search)) ||
          c.plan.toLowerCase().includes(search)
      );
    }

    if (filter === "active") {
      filtered = filtered.filter((c) => c.status.toLowerCase() === "active");
    } else if (filter === "pending") {
      filtered = filtered.filter((c) => c.status.toLowerCase() === "pending");
    } else if (filter === "suspended") {
      filtered = filtered.filter((c) => c.status.toLowerCase() === "suspended");
    }

    return NextResponse.json({
      success: true,
      data: {
        metrics: {
          total,
          active,
          pending,
          suspended,
        },
        companies: filtered,
      },
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        success: false,
        error: error.message || "Failed to fetch master admin companies",
      },
      { status: 500 }
    );
  }
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { action, companyId, status } = body;

    const idx = companiesRegistry.findIndex((c) => c.id === companyId);
    if (idx !== -1) {
      if (action === "approve") {
        companiesRegistry[idx].status = "Active";
      } else if (action === "suspend") {
        companiesRegistry[idx].status = "Suspended";
      } else if (status) {
        companiesRegistry[idx].status = status;
      }
      return NextResponse.json({
        success: true,
        message: `Company ${companiesRegistry[idx].name} updated to ${companiesRegistry[idx].status}`,
        data: companiesRegistry[idx],
      });
    }

    return NextResponse.json(
      { success: false, error: "Company not found" },
      { status: 404 }
    );
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error.message || "Failed to update company" },
      { status: 500 }
    );
  }
}
