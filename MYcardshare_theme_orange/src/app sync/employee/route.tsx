import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import companyService from "@/backend/services/company.service";
import cardService from "@/backend/services/card.service";
import userService from "@/backend/services/user.service";
import { firestoreDb } from "@/backend/config/firebase";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

/**
 * EMPLOYEE PROFILE & CARD SYNC (APP <-> WEB)
 *
 * GET /app-sync/employee or GET /api/sync/employee
 * Fetches:
 * - Employee User Data & Role
 * - Enterprise Company Branding (Logo, Banner, Brand Color, Brand Color Lock)
 * - Employee's Digital Business Card
 */
export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  // 1. Fetch employee profile from Firestore
  const user = await userService.getUser(uid);
  if (!user) {
    return NextResponse.json(fail("USER_NOT_FOUND", "Employee profile not found"), { status: 404 });
  }

  const companyId = user.companyId || context.user?.companyId;
  let companyData: any = null;

  // 2. Fetch Corporate Workspace branding & policies if linked
  if (companyId) {
    try {
      companyData = await companyService.getCompany(companyId);
    } catch (err) {
      console.warn("⚠️ [Employee Sync] Could not fetch linked company:", err);
    }
  }

  // 3. Fetch employee digital card from MongoDB
  let card = await cardService.getCardByUserId(uid);

  // If company enforces color or banner lock, override in payload representation
  if (card && companyData) {
    if (companyData.isColorLocked && companyData.brandColor) {
      card.themeColor = companyData.brandColor;
      card.isColorLocked = true;
    }
    if (companyData.companyLogo && !card.companyLogo) {
      card.companyLogo = companyData.companyLogo;
    }
    if (companyData.companyBanner && !card.bannerUrl) {
      card.bannerUrl = companyData.companyBanner;
    }
    card.companyName = companyData.companyName || card.companyName;
  }

  return NextResponse.json(
    success({
      user,
      card,
      company: companyData
        ? {
            companyId: companyData.id || companyId,
            companyName: companyData.companyName,
            brandColor: companyData.brandColor,
            isColorLocked: Boolean(companyData.isColorLocked),
            companyLogo: companyData.companyLogo,
            companyBanner: companyData.companyBanner,
            status: companyData.status,
          }
        : null,
      syncedAt: new Date().toISOString(),
    })
  );
});

/**
 * PATCH /app-sync/employee or PATCH /api/sync/employee
 *
 * Updates employee profile details while respecting enterprise brand lock rules.
 */
export const PATCH = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;
  const body = await request.json();

  if (!body || typeof body !== "object") {
    return NextResponse.json(fail("INVALID_PAYLOAD", "Request body must be a valid JSON object"), { status: 400 });
  }

  const currentUser = await userService.getUser(uid);
  const companyId = currentUser?.companyId || context.user?.companyId;

  let companyData: any = null;
  if (companyId) {
    companyData = await companyService.getCompany(companyId);
  }

  // Enforce Corporate Branding Lock
  if (companyData?.isColorLocked && companyData?.brandColor) {
    body.themeColor = companyData.brandColor;
    body.isColorLocked = true;
  }

  if (companyData?.companyName) {
    body.companyName = companyData.companyName;
  }

  // Normalize slug if updated
  if (body.cardSlug) {
    body.cardSlug = String(body.cardSlug)
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9-_]/g, "");
  }

  // 1. Update user profile
  await userService.updateProfile(uid, {
    ...body,
    companyId: companyId || currentUser?.companyId,
    role: "employee",
  });

  // 2. Update card representation
  await cardService.createOrUpdateCard(uid, {
    fullName: body.fullName,
    jobTitle: body.jobTitle,
    companyName: companyData?.companyName || body.companyName,
    companyId: companyId || null,
    bio: body.bio,
    cardSlug: body.cardSlug,
    email: body.email || body.workEmail,
    phone: body.phone || body.workPhone,
    website: body.website,
    address: body.address,
    city: body.city,
    country: body.country,
    avatarUrl: body.avatarUrl,
    bannerUrl: companyData?.companyBanner || body.bannerUrl,
    companyLogo: companyData?.companyLogo || body.companyLogo,
    themeColor: companyData?.isColorLocked ? companyData.brandColor : body.themeColor,
    isColorLocked: Boolean(companyData?.isColorLocked),
    templateStyle: body.templateStyle || "corporate_clean",
    userStatus: body.userStatus || "Active Member",
    cardStatus: body.cardStatus || "Published",
    socialLinks: body.socialLinks || [],
    lastUpdated: new Date(),
  });

  const updatedUser = await userService.getUser(uid);
  const updatedCard = await cardService.getCardByUserId(uid);

  return NextResponse.json(
    success({
      message: "Employee profile and corporate card synced successfully",
      user: updatedUser,
      card: updatedCard,
      company: companyData,
      syncedAt: new Date().toISOString(),
    })
  );
});
