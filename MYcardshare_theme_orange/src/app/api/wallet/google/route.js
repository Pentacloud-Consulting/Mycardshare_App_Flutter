import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import walletService from "@/backend/services/wallet.service";
import { fail, success } from "@/backend/utils/apiResponse";
import { env } from "@/backend/config/env";
import {
  getPublicBaseUrl,
  normalizePublicImageUrl,
  rewriteToPublicOrigin,
} from "@/backend/utils/publicUrl";
import { renderWalletBanner } from "@/backend/utils/walletImages";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * Create a Google Wallet pass.
 *
 * Strategy:
 *  1. If this deployment has local Google Wallet credentials (ISSUER_ID +
 *     service-account JSON), generate the pass in-process.
 *  2. Otherwise proxy the request to the battle-tested legacy backend
 *     (WALLET_LEGACY_BACKEND_URL, defaulting to the production host the
 *     original React web app calls) which already has credentials wired up.
 *
 * This keeps the Google Wallet tile working in every environment — local,
 * preview, and prod — without forcing every deployment to carry the
 * service-account key.
 */
export const POST = apiAdapter(async (request) => {
  const cardData = await request.json();

  if (!cardData?.fullName) {
    return NextResponse.json(
      { success: false, error: "Full name is required for wallet passes." },
      { status: 400 },
    );
  }

  // Resolve a public base URL so relative image paths become fetchable.
  const explicitPublicBase =
    process.env.NEXT_PUBLIC_BASE_URL ||
    process.env.PUBLIC_BASE_URL ||
    process.env.NEXT_PUBLIC_APP_URL ||
    null;
  const publicBase = getPublicBaseUrl(request);

  const normalizedAvatar = normalizePublicImageUrl(
    cardData.avatarUrl,
    publicBase,
  );

  // Pre-process the banner for wallet use: crop to the Wallet hero aspect
  // ratio and bake in a dark vertical gradient so Wallet's overlaid text
  // stays readable against any banner. This mirrors the darkened treatment
  // used by the live card preview.
  let processedBannerPath = null;
  if (cardData.bannerUrl) {
    try {
      processedBannerPath = await renderWalletBanner(cardData.bannerUrl);
    } catch (err) {
      console.warn(
        "[Wallet] banner pre-processing skipped:",
        err?.message || err,
      );
    }
  }

  const normalizedBanner = normalizePublicImageUrl(
    processedBannerPath || cardData.bannerUrl,
    publicBase,
  );

  cardData.avatarUrl = normalizedAvatar || undefined;
  cardData.bannerUrl = normalizedBanner || undefined;

  if (cardData.publicCardUrl) {
    const rewritten = rewriteToPublicOrigin(
      cardData.publicCardUrl,
      explicitPublicBase,
    );
    if (rewritten) {
      cardData.publicCardUrl = rewritten;
    } else if (!explicitPublicBase) {
      console.warn(
        "[Wallet] publicCardUrl resolves to localhost and no NEXT_PUBLIC_BASE_URL/PUBLIC_BASE_URL is set — the QR on the pass will not work outside this machine.",
      );
    }
  }

  if (!normalizedAvatar) {
    console.warn(
      "[Wallet] Avatar dropped — set NEXT_PUBLIC_BASE_URL to a public HTTPS host or enable GCS uploads so Google can fetch it.",
    );
  }
  if (!normalizedBanner) {
    console.warn(
      "[Wallet] Banner dropped — set NEXT_PUBLIC_BASE_URL to a public HTTPS host or enable GCS uploads so Google can fetch it.",
    );
  }

  // ── Path 1: Local credentials available ──────────────────────────────
  if (walletService.isGoogleWalletConfigured()) {
    try {
      console.log(
        "🎟️ [API] Google Wallet (local) for:",
        cardData.fullName,
      );
      await walletService.ensureGenericClass();
      const objectId = await walletService.createWalletPass(cardData);
      const token = walletService.generateSaveUrl(objectId);
      const saveUrl = `https://pay.google.com/gp/v/save/${token}`;
      return NextResponse.json(success({ saveUrl, via: "local" }));
    } catch (err) {
      const errMsg = err?.message || String(err);
      const errStatus = err?.response?.status || err?.code;
      console.error(
        "[Wallet] local generation failed:",
        errMsg,
        errStatus ? `(status: ${errStatus})` : "",
      );

      // If we get a permission / auth error, surface it immediately
      // instead of falling through to the (potentially broken) legacy proxy.
      if (
        errStatus === 403 ||
        errStatus === 401 ||
        /permission|forbidden|insufficientPermissions|caller does not have|disabled|has not been used/i.test(errMsg)
      ) {
        // Extract the enable-API URL from Google's error message if present
        const enableUrlMatch = errMsg.match(/(https:\/\/console\.developers\.google\.com\S+)/);
        const actionUrl = enableUrlMatch
          ? enableUrlMatch[1]
          : "https://console.developers.google.com/apis/api/walletobjects.googleapis.com/overview";

        return NextResponse.json(
          fail(
            "WALLET_PERMISSION_ERROR",
            errMsg.includes("disabled") || errMsg.includes("has not been used")
              ? `Google Wallet API is not enabled. Please enable it at: ${actionUrl} — then wait a minute and try again.`
              : "Google Wallet API permission denied. The service account needs the 'Google Wallet Object Issuer' role in Google Cloud IAM. " +
                "Go to console.cloud.google.com → IAM → find your service account → add role 'Google Wallet Object Issuer'.",
          ),
          { status: 403 },
        );
      }
      // fall through to legacy backend for other errors
    }
  } else {
    console.warn(
      "[Wallet] Local credentials not configured (no key file + ISSUER_ID). Will try legacy proxy.",
    );
  }

  // ── Path 2: Proxy to legacy backend ──────────────────────────────────
  const legacyBase = (
    process.env.WALLET_LEGACY_BACKEND_URL ||
    env.WALLET_LEGACY_BACKEND_URL ||
    "https://digitalbusinesscloudcard.com"
  ).replace(/\/+$/, "");

  try {
    console.log(
      "🎟️ [API] Google Wallet (legacy proxy →",
      legacyBase,
      ") for:",
      cardData.fullName,
    );

    const upstream = await fetch(`${legacyBase}/api/create-wallet-pass`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        userId: cardData.userId || `mycardshare-`,
        fullName: cardData.fullName,
        jobTitle: cardData.jobTitle,
        companyName: cardData.companyName,
        workEmail: cardData.workEmail,
        workPhone: cardData.workPhone,
        website: cardData.website,
        address: cardData.address,
        city: cardData.city,
        country: cardData.country,
        themeColor: cardData.themeColor || "#1e293b",
        avatarUrl: cardData.avatarUrl,
        bannerUrl: cardData.bannerUrl,
        publicCardUrl: cardData.publicCardUrl,
      }),
      // Abort quickly if legacy host is unreachable
      signal: AbortSignal.timeout(15_000),
    });

    const payload = await upstream.json().catch(() => ({}));

    if (!upstream.ok || !payload?.saveUrl) {
      return NextResponse.json(
        fail(
          "WALLET_UPSTREAM_FAILED",
          payload?.error ||
            "Google Wallet upstream did not return a save URL.",
        ),
        { status: 502 },
      );
    }

    return NextResponse.json(
      success({
        saveUrl: payload.saveUrl,
        objectId: payload.objectId || null,
        via: "legacy",
      }),
    );
  } catch (err) {
    console.error("[Wallet] legacy proxy failed:", err?.message);
    return NextResponse.json(
      fail(
        "WALLET_NOT_CONFIGURED",
        "Google Wallet is temporarily unavailable. Please try again in a moment.",
      ),
      { status: 503 },
    );
  }
});
