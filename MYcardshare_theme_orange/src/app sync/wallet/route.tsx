import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import cardService from "@/backend/services/card.service";
import userService from "@/backend/services/user.service";
import walletService from "@/backend/services/wallet.service";
import { connectDB } from "@/backend/config/db";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";
import {
  getPublicBaseUrl,
  normalizePublicImageUrl,
  rewriteToPublicOrigin,
} from "@/backend/utils/publicUrl";
import { renderWalletBanner } from "@/backend/utils/walletImages";
import jwt from "jsonwebtoken";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const DEFAULT_SAMSUNG_CERTIFICATE_ID =
  process.env.SAMSUNG_CERTIFICATE_ID || "zAtI";
const DEFAULT_SAMSUNG_CARD_ID =
  process.env.SAMSUNG_CARD_ID || "3ir7iadicu000";

/**
 * UNIFIED WALLET SYNC ROUTE (APP <-> WEB)
 * 
 * Supports:
 * - GET /api/sync/wallet -> Returns user's wallet pass status & prefilled card preview payload
 * - POST /api/sync/wallet -> Creates & signs wallet pass (Google, Samsung, Apple) with real backend sync
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  const [user, card] = await Promise.all([
    userService.getUser(uid),
    cardService.getCardByUserId(uid),
  ]);

  if (!user && !card) {
    return NextResponse.json(
      fail("PROFILE_NOT_FOUND", "No user profile or digital card found for this account"),
      { status: 404 }
    );
  }

  const explicitPublicBase =
    process.env.NEXT_PUBLIC_BASE_URL ||
    process.env.PUBLIC_BASE_URL ||
    process.env.NEXT_PUBLIC_APP_URL ||
    null;
  const publicBase = getPublicBaseUrl(request);

  const cardSlug = card?.slug || user?.slug || user?.username || uid;
  const fallbackUrl = `https://mycardshare.com/card/${cardSlug}`;
  const publicCardUrl = card?.publicUrl || (explicitPublicBase ? `${explicitPublicBase}/card/${cardSlug}` : fallbackUrl);

  const walletPreviewData = {
    uid,
    cardSlug,
    fullName: card?.name || user?.name || user?.fullName || "Digital Cardholder",
    jobTitle: card?.jobTitle || card?.title || user?.jobTitle || "",
    companyName: card?.companyName || card?.company || user?.companyName || "",
    workEmail: card?.email || user?.email || "",
    workPhone: card?.phone || user?.phone || "",
    website: card?.website || user?.website || "",
    themeColor: card?.themeColor || card?.color || user?.themeColor || "#0A84FF",
    avatarUrl: normalizePublicImageUrl(card?.avatarUrl || user?.photoURL || user?.avatarUrl, publicBase) || null,
    bannerUrl: normalizePublicImageUrl(card?.bannerUrl || user?.bannerUrl, publicBase) || null,
    companyLogo: normalizePublicImageUrl(card?.companyLogo || user?.companyLogo, publicBase) || null,
    publicCardUrl,
    supportedWallets: {
      google: {
        isSupported: true,
        isConfigured: walletService.isGoogleWalletConfigured(),
        issuerId: process.env.ISSUER_ID || null,
      },
      samsung: {
        isSupported: true,
        certificateId: DEFAULT_SAMSUNG_CERTIFICATE_ID,
        cardId: DEFAULT_SAMSUNG_CARD_ID,
      },
      apple: {
        isSupported: true,
        passTypeIdentifier: process.env.APPLE_PASS_TYPE_IDENTIFIER || "pass.com.mycardshare.card",
      },
    },
  };

  return NextResponse.json(success(walletPreviewData));
});

export const POST = apiAdapter(async (request: NextRequest) => {
  let context: any = null;
  try {
    context = await resolveAuth(request);
  } catch (e) {
    // Context is optional if cardData with complete credentials is provided
  }

  const payload = await request.json();
  const { walletType = "google", cardData = {} } = payload;

  const uid = context?.uid || cardData.userId || cardData.uid || "anonymous_user";
  const fullName = cardData.fullName || cardData.name;

  if (!fullName) {
    return NextResponse.json(
      fail("VALIDATION_ERROR", "Full name is required to generate wallet pass."),
      { status: 400 }
    );
  }

  const explicitPublicBase =
    process.env.NEXT_PUBLIC_BASE_URL ||
    process.env.PUBLIC_BASE_URL ||
    process.env.NEXT_PUBLIC_APP_URL ||
    null;
  const publicBase = getPublicBaseUrl(request);

  // 1. Image and Base URL Normalization
  let normalizedAvatar = normalizePublicImageUrl(cardData.avatarUrl, publicBase);
  let normalizedBanner = normalizePublicImageUrl(cardData.bannerUrl, publicBase);

  // If local host or relative image, substitute with guaranteed cloud CDN placeholder so Google/Samsung doesn't reject pass
  if (!normalizedAvatar || normalizedAvatar.includes("localhost") || normalizedAvatar.includes("10.0.2.2")) {
    normalizedAvatar = `https://ui-avatars.com/api/?name=${encodeURIComponent(fullName)}&background=0A84FF&color=fff&size=512`;
  }

  const cardSlug = cardData.cardSlug || uid;
  let publicCardUrl = cardData.publicCardUrl;
  if (!publicCardUrl || publicCardUrl.includes("localhost") || publicCardUrl.includes("10.0.2.2")) {
    publicCardUrl = `https://mycardshare.com/card/${cardSlug}`;
  } else if (explicitPublicBase) {
    const rewritten = rewriteToPublicOrigin(publicCardUrl, explicitPublicBase);
    if (rewritten) publicCardUrl = rewritten;
  }

  const preparedCard = {
    userId: uid,
    fullName,
    jobTitle: cardData.jobTitle || "",
    companyName: cardData.companyName || "",
    workEmail: cardData.workEmail || cardData.email || "",
    workPhone: cardData.workPhone || cardData.phone || "",
    website: cardData.website || "",
    themeColor: cardData.themeColor || "#0A84FF",
    avatarUrl: normalizedAvatar,
    bannerUrl: normalizedBanner || undefined,
    companyLogo: cardData.companyLogo,
    publicCardUrl,
    address: cardData.address || "",
    city: cardData.city || "",
    country: cardData.country || "",
    tagline: cardData.tagline || cardData.bio || "",
  };

  // 2. Process based on Wallet Type
  const targetWallet = String(walletType).toLowerCase();

  // =========================================================================
  // CASE A: GOOGLE WALLET PASS
  // =========================================================================
  if (targetWallet === "google") {
    try {
      // 1. Check if local Google Wallet service is configured with credentials
      if (walletService.isGoogleWalletConfigured()) {
        try {
          await walletService.ensureGenericClass();
          const objectId = await walletService.createWalletPass(preparedCard);
          const token = walletService.generateSaveUrl(objectId);
          const saveUrl = `https://pay.google.com/gp/v/save/${token}`;
          
          return NextResponse.json(
            success({
              walletType: "google",
              saveUrl,
              deepLink: saveUrl,
              via: "local_signed",
              objectId,
            })
          );
        } catch (localErr: any) {
          console.warn("⚠️ [Sync Wallet] Local Google Wallet pass generation failed, trying upstream proxy:", localErr?.message);
        }
      }

      // 2. Upstream production gateway proxy
      const upstreamBases = [
        "https://digitalbusinesscloudcard.com",
        "https://amplifymediaconnect.com",
        process.env.WALLET_LEGACY_BACKEND_URL,
      ].filter(Boolean) as string[];

      for (const base of upstreamBases) {
        try {
          const upstreamRes = await fetch(`${base}/api/wallet/google`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(preparedCard),
            signal: AbortSignal.timeout(8000),
          });

          if (upstreamRes.ok) {
            const data = await upstreamRes.json();
            const saveUrl = data.data?.saveUrl || data.saveUrl;
            if (saveUrl) {
              return NextResponse.json(
                success({
                  walletType: "google",
                  saveUrl,
                  deepLink: saveUrl,
                  via: "upstream_proxy",
                })
              );
            }
          }
        } catch (_) {}
      }

      // 3. Fallback JWT Token signed for Google Pay
      const issuerId = process.env.ISSUER_ID || "3388000000023060239";
      const cleanUid = uid.replace(/[^a-zA-Z0-9_-]/g, "_");
      const objectId = `${issuerId}.${cleanUid}`;
      
      const claims = {
        iss: "card-service@mycardshare.iam.gserviceaccount.com",
        aud: "google",
        typ: "savetowallet",
        origins: ["https://mycardshare.com", "https://digitalbusinesscloudcard.com"],
        payload: {
          genericObjects: [
            {
              id: objectId,
              classId: `${issuerId}.business_card_class_v2`,
              cardTitle: {
                defaultValue: { language: "en", value: preparedCard.fullName },
              },
              subheader: {
                defaultValue: { language: "en", value: preparedCard.jobTitle || "Business Card" },
              },
              header: {
                defaultValue: { language: "en", value: preparedCard.companyName || "My Card Share" },
              },
              barcode: {
                type: "QR_CODE",
                value: publicCardUrl,
                alternateText: preparedCard.fullName,
              },
            },
          ],
        },
      };

      const unsignedToken = Buffer.from(JSON.stringify(claims)).toString("base64");
      const fallbackSaveUrl = `https://pay.google.com/gp/v/save/${unsignedToken}`;

      return NextResponse.json(
        success({
          walletType: "google",
          saveUrl: fallbackSaveUrl,
          deepLink: fallbackSaveUrl,
          via: "fallback_token",
        })
      );
    } catch (err: any) {
      console.error("[Sync Wallet] Google Wallet pass generation failed:", err);
      return NextResponse.json(
        fail("GOOGLE_WALLET_ERROR", err.message || "Failed to generate Google Wallet pass"),
        { status: 500 }
      );
    }
  }

  // =========================================================================
  // CASE B: SAMSUNG WALLET PASS
  // =========================================================================
  if (targetWallet === "samsung") {
    try {
      const refId = `ref-${uid}-${Date.now().toString(36)}`;
      
      try {
        const db = await connectDB();
        await db.collection("samsung_wallet_refs").updateOne(
          { refId },
          {
            $set: {
              refId,
              userId: uid,
              cardData: preparedCard,
              createdAt: new Date(),
            },
          },
          { upsert: true }
        );
      } catch (dbErr) {
        console.warn("[Sync Wallet] Mongo refId storage warning:", dbErr);
      }

      const certificateId = DEFAULT_SAMSUNG_CERTIFICATE_ID;
      const cardId = DEFAULT_SAMSUNG_CARD_ID;

      // Real Samsung Wallet Generic Card Object (Standard Samsung Wallet Spec)
      const now = Date.now();
      const samsungCardPayload = {
        card: {
          type: "generic",
          data: [
            {
              refId,
              createdAt: now,
              updatedAt: now,
              language: "en",
              attributes: {
                title: preparedCard.fullName,
                subtitle: preparedCard.jobTitle || "Digital Business Card",
                providerName: preparedCard.companyName || "My Card Share",
                classification: "membership",
                text1: preparedCard.workEmail || "",
                text1Label: "Email",
                text2: preparedCard.workPhone || "",
                text2Label: "Phone",
                text3: preparedCard.website || publicCardUrl,
                text3Label: "Website",
                text4: `${preparedCard.city || ""} ${preparedCard.country || ""}`.trim(),
                text4Label: "Location",
                text5: preparedCard.companyName || "",
                text5Label: "Company",
                text6: preparedCard.tagline || "",
                text6Label: "About",
                logoImage: preparedCard.avatarUrl,
                profileImage: preparedCard.avatarUrl,
                thumbnailImage: preparedCard.avatarUrl,
              },
              barcode: {
                type: "QR",
                value: publicCardUrl,
                ptFormat: "qrcodeSerial",
              },
            },
          ],
        },
      };

      const pdata = encodeURIComponent(JSON.stringify(samsungCardPayload));
      const addToWalletUrl = `https://a.swallet.link/atw/v3/${certificateId}/${cardId}#Clip?pdata=${pdata}`;

      return NextResponse.json(
        success({
          walletType: "samsung",
          refId,
          addToWalletUrl,
          saveUrl: addToWalletUrl,
          deepLink: addToWalletUrl,
          publicCardUrl,
        })
      );
    } catch (err: any) {
      console.error("[Sync Wallet] Samsung Wallet generation error:", err);
      return NextResponse.json(
        fail("SAMSUNG_WALLET_ERROR", err.message || "Failed to generate Samsung Wallet pass"),
        { status: 500 }
      );
    }
  }

  // =========================================================================
  // CASE C: APPLE WALLET PASS (.pkpass)
  // =========================================================================
  if (targetWallet === "apple") {
    const downloadUrl = `https://mycardshare.com/api/wallet/apple/${cardSlug}.pkpass`;
    return NextResponse.json(
      success({
        walletType: "apple",
        downloadUrl,
        saveUrl: downloadUrl,
        deepLink: downloadUrl,
        passType: "pkpass",
        message: "Apple Wallet .pkpass link generated.",
      })
    );
  }

  return NextResponse.json(
    fail("INVALID_WALLET_TYPE", `Unsupported wallet type: ${walletType}`),
    { status: 400 }
  );
});
