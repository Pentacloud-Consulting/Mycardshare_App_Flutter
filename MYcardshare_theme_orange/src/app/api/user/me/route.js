// Forced rebuild comment
import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import userService from "@/backend/services/user.service";
import companyService from "@/backend/services/company.service";
import { success } from "@/backend/utils/apiResponse";

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);

  if (!context.user) {
    return NextResponse.json(
      { success: false, error: "Profile not found" },
      { status: 404 },
    );
  }

  // Inject workspace branding if user belongs to a company
  const targetCompanyId = context.user.companyId || context.user.workspaceId;
  console.log("[User/Me] Target company ID:", targetCompanyId);
  if (targetCompanyId) {
    try {
      const company = await companyService.getCompany(targetCompanyId);
      console.log("[User/Me] Fetched company:", company);
      if (company) {
        if (company.companyBanner) context.user.bannerUrl = company.companyBanner;
        if (company.companyLogo) context.user.companyLogo = company.companyLogo;
        context.user.companyName = company.companyName;
        context.user.slug = company.slug; // Inject workspace slug for Profile display
        context.user.brandColor = company.brandColor || "#D4642C";
        
        // Ensure enterprise admin credentials and status are properly set
        if (company.adminUid === context.uid || company.id === context.uid || context.user.role === "enterprise") {
          context.user.role = "enterprise";
          context.user.status = company.status || company.approvalStatus || "active";
          context.user.subscriptionStatus = company.subscriptionStatus || "active";
        }
        
        // Inject integration settings so LeadForm and layout can read them
        if (company.isIntegrationEnabled !== undefined) {
          context.user.isIntegrationEnabled = company.isIntegrationEnabled;
        }
        if (company.zapierWebhookUrl) {
          context.user.zapierWebhookUrl = company.zapierWebhookUrl;
        }
      }
    } catch (e) {
      console.warn("Could not fetch company branding for user", e);
    }
  }

  return NextResponse.json(success(context.user));
});

export const PATCH = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const updates = await request.json();

  await userService.updateProfile(context.uid, updates);

  return NextResponse.json(success({ message: "Profile updated" }));
});

export const DELETE = apiAdapter(async (request) => {
  const context = await resolveAuth(request);

  await userService.deleteUser(context.uid);

  return NextResponse.json(success({ message: "Account deleted successfully" }));
});

