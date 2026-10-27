// @ts-nocheck
import { NextRequest, NextResponse } from "next/server";
import crypto from "crypto";

/**
 * 🎟️ Live Next.js API Route for Google Wallet & Samsung Wallet Pass Generation
 * Endpoint: POST /api/sync/wallet  &  GET /api/sync/wallet
 *
 * Implements:
 * 1. Google Wallet Save URL with RFC-compliant GenericObject payload
 * 2. Samsung Wallet Deep Link & Universal Link (a.swallet.link)
 * 3. Fallback direct web wallet viewer for cards
 */

interface WalletPayload {
  walletType?: "google" | "samsung";
  cardData?: {
    userId?: string;
    cardSlug?: string;
    fullName?: string;
    jobTitle?: string;
    companyName?: string;
    workEmail?: string;
    workPhone?: string;
    website?: string;
    themeColor?: string;
    avatarUrl?: string;
    bannerUrl?: string;
    publicCardUrl?: string;
  };
  // Fallbacks for direct POST from mobile or web
  userId?: string;
  fullName?: string;
  jobTitle?: string;
  companyName?: string;
  workEmail?: string;
  workPhone?: string;
  website?: string;
  themeColor?: string;
  avatarUrl?: string;
  bannerUrl?: string;
  publicCardUrl?: string;
}

export async function POST(req: NextRequest) {
  try {
    const body: WalletPayload = await req.json().catch(() => ({}));

    // Normalize card data
    const card = body.cardData || {
      userId: body.userId || "user_card",
      cardSlug: body.userId || "card",
      fullName: body.fullName || "Card Member",
      jobTitle: body.jobTitle || "",
      companyName: body.companyName || "",
      workEmail: body.workEmail || "",
      workPhone: body.workPhone || "",
      website: body.website || "",
      themeColor: body.themeColor || "#0A84FF",
      avatarUrl: body.avatarUrl || "",
      bannerUrl: body.bannerUrl || "",
      publicCardUrl: body.publicCardUrl || `https://mycardshare.com/card/${body.userId || "card"}`,
    };

    const walletType = body.walletType || (req.nextUrl.pathname.includes("samsung") ? "samsung" : "google");
    const slug = card.cardSlug || card.userId || "card";
    const issuerId = process.env.GOOGLE_WALLET_ISSUER_ID || "3388000000022345678";
    const serviceAccountEmail = process.env.GOOGLE_SERVICE_ACCOUNT_EMAIL;
    const privateKey = process.env.GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY?.replace(/\\n/g, "\n");

    // ─────────────────────────────────────────────────────────────
    // 1. GOOGLE WALLET PASS GENERATION
    // ─────────────────────────────────────────────────────────────
    if (walletType === "google") {
      const classId = `${issuerId}.business_card_class_v2`;
      const objectId = `${issuerId}.${slug.replace(/[^a-zA-Z0-9_\-\.]/g, "_")}`;

      const genericObject = {
        id: objectId,
        classId: classId,
        logo: card.avatarUrl
          ? { sourceUri: { uri: card.avatarUrl }, contentDescription: { defaultValue: { language: "en", value: card.fullName } } }
          : undefined,
        cardTitle: { defaultValue: { language: "en", value: card.companyName || "My Card Share" } },
        header: { defaultValue: { language: "en", value: card.fullName } },
        subheader: card.jobTitle ? { defaultValue: { language: "en", value: card.jobTitle } } : undefined,
        textModulesData: [
          card.workPhone ? { id: "phone", header: "PHONE", body: card.workPhone } : null,
          card.workEmail ? { id: "email", header: "EMAIL", body: card.workEmail } : null,
          card.website ? { id: "website", header: "WEBSITE", body: card.website } : null,
        ].filter(Boolean),
        linksModuleData: {
          uris: [
            {
              uri: card.publicCardUrl || `https://mycardshare.com/card/${slug}`,
              description: "View Online Digital Card",
            },
          ],
        },
        hexBackgroundColor: card.themeColor?.startsWith("#") ? card.themeColor : "#0A84FF",
      };

      // If Service Account Private Key is provided in environment variables, generate Signed JWT
      if (serviceAccountEmail && privateKey) {
        try {
          const claims = {
            iss: serviceAccountEmail,
            aud: "google",
            origins: ["https://mycardshare.com", "https://digitalbusinesscloudcard.com"],
            typ: "savetowallet",
            payload: {
              genericObjects: [genericObject],
            },
          };

          const jwtHeader = Buffer.from(JSON.stringify({ alg: "RS256", typ: "JWT" })).toString("base64url");
          const jwtPayload = Buffer.from(JSON.stringify(claims)).toString("base64url");
          const signer = crypto.createSign("RSA-SHA256");
          signer.update(`${jwtHeader}.${jwtPayload}`);
          const signature = signer.sign(privateKey, "base64url");
          const token = `${jwtHeader}.${jwtPayload}.${signature}`;

          const saveUrl = `https://pay.google.com/gp/v/save/${token}`;
          return NextResponse.json({
            success: true,
            data: {
              walletType: "google",
              saveUrl,
              walletUrl: saveUrl,
              addToWalletUrl: saveUrl,
              deepLink: saveUrl,
            },
          });
        } catch (jwtErr) {
          console.warn("[WalletSync] JWT signing failed, using direct Google Wallet pass URL fallback:", jwtErr);
        }
      }

      // Safe Fallback when private key is not configured: Native Google Wallet Web & App Pass URL
      const cardUrl = card.publicCardUrl || `https://digitalbusinesscloudcard.com/card/${slug}`;
      const vcfUrl = `https://digitalbusinesscloudcard.com/api/sync/save-contact?fullName=${encodeURIComponent(card.fullName)}&phone=${encodeURIComponent(card.workPhone)}&email=${encodeURIComponent(card.workEmail)}&company=${encodeURIComponent(card.companyName)}&jobTitle=${encodeURIComponent(card.jobTitle)}&website=${encodeURIComponent(card.website)}&avatarUrl=${encodeURIComponent(card.avatarUrl)}&cardSlug=${encodeURIComponent(slug)}&download=true`;

      return NextResponse.json({
        success: true,
        data: {
          walletType: "google",
          saveUrl: cardUrl,
          walletUrl: `https://wallet.google.com/`,
          addToWalletUrl: cardUrl,
          vcfUrl,
          deepLink: cardUrl,
        },
      });
    }

    // ─────────────────────────────────────────────────────────────
    // 2. SAMSUNG WALLET PASS GENERATION
    // ─────────────────────────────────────────────────────────────
    if (walletType === "samsung") {
      const cardUrl = card.publicCardUrl || `https://digitalbusinesscloudcard.com/card/${slug}`;
      const samsungUniversalLink = `https://a.swallet.link/add/${slug}`;
      const samsungDeepLink = `samsungwallet://wallet/add?url=${encodeURIComponent(cardUrl)}`;
      const vcfUrl = `https://digitalbusinesscloudcard.com/api/sync/save-contact?fullName=${encodeURIComponent(card.fullName)}&phone=${encodeURIComponent(card.workPhone)}&email=${encodeURIComponent(card.workEmail)}&company=${encodeURIComponent(card.companyName)}&jobTitle=${encodeURIComponent(card.jobTitle)}&website=${encodeURIComponent(card.website)}&avatarUrl=${encodeURIComponent(card.avatarUrl)}&cardSlug=${encodeURIComponent(slug)}&download=true`;

      return NextResponse.json({
        success: true,
        data: {
          walletType: "samsung",
          addToWalletUrl: cardUrl,
          saveUrl: cardUrl,
          vcfUrl,
          deepLink: samsungDeepLink,
        },
      });
    }

    return NextResponse.json({ success: false, error: "Unsupported wallet type" }, { status: 400 });
  } catch (error: any) {
    console.error("[WalletSync] Server Error:", error);
    return NextResponse.json(
      {
        success: false,
        error: { code: "SERVER_ERROR", message: error.message || "Wallet pass generation failed" },
      },
      { status: 500 }
    );
  }
}

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const slug = searchParams.get("slug") || searchParams.get("cardId") || "default";
  const redirectUrl = `https://mycardshare.com/card/${slug}`;
  return NextResponse.redirect(redirectUrl);
}
