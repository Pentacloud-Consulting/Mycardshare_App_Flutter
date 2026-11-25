import { NextRequest, NextResponse } from "next/server";
import cardService from "@/backend/services/card.service";
import companyService from "@/backend/services/company.service";
import { connectDB } from "@/backend/config/db";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

/**
 * PUBLIC SCAN REDIRECT & RESOLUTION ENGINE
 * 
 * GET /api/sync/slug/scan?slug=zuhaib-khan
 * 
 * Used by Mobile App (Deep Link / QR Scanner) and Web Page to inspect scanned card metadata:
 * - Detects Role: 'individual', 'enterprise', 'employee'
 * - Enforces Brand Lock: Injects verified Enterprise branding (Logo, Banner, Hex BrandColor)
 * - Deep Link Handlers: Returns custom scheme 'mycardshare://card/<slug>' for native app opening
 * - Increments Live Views counter atomically
 */
export const GET = apiAdapter(async (request: NextRequest) => {
  const { searchParams } = new URL(request.url);
  const slug = searchParams.get("slug")?.trim().toLowerCase();
  const userAgent = request.headers.get("user-agent") || "";
  const isMobileClient = /android|iphone|ipad|ipod|mobile/i.test(userAgent);

  if (!slug) {
    return NextResponse.json(fail("SLUG_REQUIRED", "Query parameter 'slug' is required"), { status: 400 });
  }

  // 1. Fetch Digital Card by Slug or UserId
  const card = await cardService.getCardBySlug(slug);

  if (!card) {
    return NextResponse.json(fail("CARD_NOT_FOUND", `Card with slug '${slug}' does not exist or is inactive`), { status: 404 });
  }

  if (card.cardStatus && card.cardStatus !== "Published") {
    return NextResponse.json(fail("CARD_UNPUBLISHED", "This digital business card is currently set to Draft or Offline"), { status: 403 });
  }

  // 2. Increment Real-time Views (+1)
  cardService.incrementViews(card._id).catch((err) =>
    console.error(`[Scan Resolver] Failed to increment views for ${slug}:`, err)
  );

  // 3. Detect Profile Type (Individual vs Employee vs Company)
  let profileType: "individual" | "employee" | "enterprise" = "individual";
  let companyData: any = null;

  const targetCompanyId = card.companyId || card.workspaceId;
  if (targetCompanyId) {
    profileType = "employee";
    try {
      companyData = await companyService.getCompany(targetCompanyId);
    } catch (e) {
      console.warn("Could not fetch company details for employee card", e);
    }
  }

  // 4. Enforce Enterprise Brand Lock if applicable
  let themeColor = card.themeColor || "#0052FF";
  let isColorLocked = false;
  let companyName = card.companyName || "";
  let companyLogo = card.companyLogo || null;
  let bannerUrl = card.bannerUrl || null;

  if (companyData) {
    companyName = companyData.companyName || companyName;
    if (companyData.companyLogo) companyLogo = companyData.companyLogo;
    if (companyData.companyBanner && !bannerUrl) bannerUrl = companyData.companyBanner;

    if (companyData.isColorLocked && companyData.brandColor) {
      themeColor = companyData.brandColor;
      isColorLocked = true;
    }
  }

  // 5. Structure Social Links Array/Map
  const socialLinksMap: Record<string, string> = {};
  if (Array.isArray(card.socialLinks)) {
    card.socialLinks.forEach((item: any) => {
      if (item?.platform && item?.url) socialLinksMap[item.platform] = item.url;
    });
  } else if (card.socialLinks && typeof card.socialLinks === "object") {
    Object.assign(socialLinksMap, card.socialLinks);
  }

  // Normalize Direct fields
  ["whatsapp", "linkedin", "twitter", "instagram", "github", "facebook", "youtube", "website", "calendly"].forEach((platform) => {
    if (card[platform] && !socialLinksMap[platform]) {
      socialLinksMap[platform] = card[platform];
    }
  });

  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || "https://mycardshare.com";

  return NextResponse.json(
    success({
      slug,
      profileType,
      targetScreen: (profileType as string) === "enterprise"
        ? "EnterpriseScannedCardScreen"
        : "ScannedProfileViewScreen",

      // Deep Linking Data
      deepLinks: {
        appSchemeUrl: `mycardshare://card/${slug}`,
        universalWebUrl: `${baseUrl}/card/${slug}`,
        shouldOpenNativeApp: isMobileClient,
      },

      // Full Profile Payload (Synced between Flutter UI & Web UI)
      profile: {
        uid: card.userId,
        fullName: card.fullName || "Professional",
        jobTitle: card.jobTitle || "",
        companyName,
        bio: card.bio || "",
        email: card.email || card.workEmail || "",
        phone: card.phone || card.workPhone || "",
        website: card.website || "",
        address: card.address || "",
        city: card.city || "",
        country: card.country || "",
        avatarUrl: card.avatarUrl || null,
        bannerUrl,
        companyLogo,
        themeColor,
        isColorLocked,
        userStatus: card.userStatus || "Actively Networking",
        socialLinks: socialLinksMap,
        cardUrl: `${baseUrl}/card/${slug}`,
        views: (card.views || 0) + 1,
      },

      // Quick Connect Buttons Actions
      actionUrls: {
        vCardDownloadUrl: `${baseUrl}/api/cards/vcard/${slug}`,
        googleWalletUrl: card.googleWalletPassUrl || `${baseUrl}/api/wallet/google?cardId=${card._id}`,
        appleWalletUrl: card.appleWalletPassUrl || `${baseUrl}/api/wallet/apple?cardId=${card._id}`,
        leadCaptureEndpoint: `${baseUrl}/api/leads/create`,
      },
    })
  );
});
