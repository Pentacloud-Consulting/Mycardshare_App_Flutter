import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth, requireAdmin } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Enterprise Profile Management
 * GET /api/enterprise/profile
 * PATCH /api/enterprise/profile
 */

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const companyId = context.user?.companyId || context.uid;
  if (!companyId) {
    return NextResponse.json({ success: false, error: "No company associated" }, { status: 404 });
  }

  const company = await companyService.getCompany(companyId);
  console.log("[Enterprise Profile] GET fetched company:", company);
  return NextResponse.json(success(company));
});

export const PATCH = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  requireAdmin(context);

  const companyId = context.user?.companyId || context.uid;
  if (!companyId) {
    return NextResponse.json({ success: false, error: "No company associated" }, { status: 404 });
  }

  const updates = await request.json();
  console.log("[Enterprise Profile] Received PATCH with updates:", updates);
  // Filter allowed fields to prevent privilege escalation
  const allowed = ["companyName", "slug", "description", "area", "emirate", "address", "phoneNumber", "website", "socialLinks", "companyBanner", "companyLogo", "isIntegrationEnabled", "zapierWebhookUrl"];
  const filteredUpdates = {};
  allowed.forEach(k => { if (updates[k] !== undefined) filteredUpdates[k] = updates[k]; });
  console.log("[Enterprise Profile] Filtered updates to save:", filteredUpdates);

  if (filteredUpdates.slug) {
    const newSlug = String(filteredUpdates.slug).trim().toLowerCase();
    if (!/^[a-z0-9-]+$/.test(newSlug)) {
      return NextResponse.json({ success: false, error: "Slug must be lowercase alphanumeric with hyphens only" }, { status: 400 });
    }
    
    // Check if it's changing
    const company = await companyService.getCompany(companyId);
    if (company.slug !== newSlug) {
      const slugExists = await companyService.checkSlugExists(newSlug);
      if (slugExists) {
        return NextResponse.json({ success: false, error: "This slug is already taken" }, { status: 409 });
      }
      filteredUpdates.slug = newSlug;
    } else {
      delete filteredUpdates.slug;
    }
  }

  await companyService.updateCompany(companyId, filteredUpdates);
  return NextResponse.json(success({ message: "Profile updated" }));
});
