import { NextResponse } from "next/server";
import fs from "fs";
import path from "path";
import jwt from "jsonwebtoken";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { connectDB } from "@/backend/config/db";
import { success } from "@/backend/utils/apiResponse";
import {
  getPublicBaseUrl,
  normalizePublicImageUrl,
  rewriteToPublicOrigin,
} from "@/backend/utils/publicUrl";
import { renderWalletBanner } from "@/backend/utils/walletImages";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * Samsung Wallet integration.
 *
 *   POST /api/wallet/samsung       → build the *user's* Samsung card payload
 *                                    server-side and return a ready-to-open
 *                                    Samsung Wallet URL. Every card reflects
 *                                    the signed-in user's own profile data,
 *                                    never a hardcoded template default.
 *
 *   GET  /api/wallet/samsung?refId →  fallback callback used by Samsung when
 *   GET  /api/wallet/samsung/<id>     the partner portal is configured in
 *                                     refId mode. Returns the user card JSON.
 *
 * Samsung's template IDs (CERTIFICATE_ID + CARD_ID) are *merchant-level*
 * identifiers and the same for all users — that's correct. The per-user data
 * must ride on the URL (cdata/pdata) or via a refId callback, which is the
 * bug we're fixing here.
 */

// Template IDs registered with Samsung for this workspace. Can be overridden
// via env so prod can rotate without a code change.
const DEFAULT_CERTIFICATE_ID =
  process.env.SAMSUNG_CERTIFICATE_ID || "zAtI";
const DEFAULT_CARD_ID =
  process.env.SAMSUNG_CARD_ID || "3ir7iadicu000";

/**
 * Resolve a user's card slug into a public URL at request time so the QR on
 * the Samsung card always points at the live site.
 */
function resolveCardUrl(data, request) {
  const explicitBase =
    process.env.NEXT_PUBLIC_BASE_URL ||
    process.env.PUBLIC_BASE_URL ||
    process.env.NEXT_PUBLIC_APP_URL ||
    null;
  const publicBase = getPublicBaseUrl(request);

  if (data?.publicCardUrl) {
    const rewritten = rewriteToPublicOrigin(data.publicCardUrl, explicitBase);
    if (rewritten) return rewritten;
  }

  const slug = data?.cardSlug || data?.slug || data?.uid || "";
  if (publicBase && slug) return `${publicBase}/card/${slug}`;
  return explicitBase ? `${explicitBase}/card/${slug}` : "";
}

function buildAttributes(data, request) {
  const publicBase = getPublicBaseUrl(request);

  const avatar = normalizePublicImageUrl(data.avatarUrl, publicBase);
  // Prefer the wallet-darkened banner (if the async renderer produced one
  // earlier in the request) so the card mirrors the live preview.
  const bannerSource =
    data.__walletBannerPath || data.bannerUrl || data.companyBanner;
  const banner = normalizePublicImageUrl(bannerSource, publicBase);
  const logo =
    normalizePublicImageUrl(data.companyLogo, publicBase) || avatar;

  const email = (data.workEmail || data.email || "").trim();
  const phone = (data.workPhone || data.phone || data.phoneNumber || "").trim();
  const website = (data.website || "").trim();
  const location = [data.address, data.city, data.country]
    .map((p) => (p || "").trim())
    .filter(Boolean)
    .join(", ");

  // title / subtitle / providerName already cover name + role + company, so
  // don't repeat them in text1–6. Use those detail slots as clean,
  // label-style contact rows instead — the real business-card layout.
  //   text1 → EMAIL
  //   text2 → PHONE
  //   text3 → WEBSITE
  //   text4 → LOCATION (address / city / country)
  //   text5 → company (fallback context line shown in the detail view)
  //   text6 → tagline / notes (optional — leave empty when unused)
  const attributes = {
    title: data.fullName || "Digital Business Card",
    subtitle: data.jobTitle || "Business Professional",
    providerName: data.companyName || "Digital Business Cloud Card",
    classification: "membership",
    text1: email,
    text1Label: "Email",
    text2: phone,
    text2Label: "Phone",
    text3: website,
    text3Label: "Website",
    text4: location,
    text4Label: "Location",
    text5: data.companyName || "",
    text5Label: "Company",
    text6: (data.tagline || "").trim(),
    text6Label: "About",
  };

  if (logo) attributes.logoImage = logo;
  if (banner) attributes.bgImage = banner;
  if (avatar) {
    attributes.profileImage = avatar;
    attributes.thumbnailImage = avatar;
  }

  return attributes;
}

/**
 * Build the Samsung Generic-card payload for a given user. This is the same
 * shape the refId-callback GET handler returns, kept in one place so every
 * delivery path (cdata, pdata, callback) shows identical user data.
 */
function buildCardPayload({ refId, data, request, createdAt, updatedAt }) {
  const cardUrl = resolveCardUrl(data, request);
  const safeRefId = refId || data?.uid || `ref-${Date.now()}`;
  const now = updatedAt || Date.now();
  return {
    card: {
      type: "generic",
      data: [
        {
          refId: safeRefId,
          createdAt: createdAt || now,
          updatedAt: now,
          language: "en",
          attributes: buildAttributes(data, request),
          barcode: {
            type: "QR",
            value: cardUrl || safeRefId,
            ptFormat: "qrcodeSerial",
          },
        },
      ],
    },
  };
}

/** Try to load Samsung partner signing credentials (optional). */
function loadSamsungSigner() {
  const partnerId = process.env.SAMSUNG_PARTNER_ID;
  const cardId = process.env.SAMSUNG_CARD_ID || DEFAULT_CARD_ID;

  let privateKey = process.env.SAMSUNG_PRIVATE_KEY || "";
  if (!privateKey && process.env.SAMSUNG_PRIVATE_KEY_PATH) {
    try {
      const p = path.resolve(process.env.SAMSUNG_PRIVATE_KEY_PATH);
      if (fs.existsSync(p)) privateKey = fs.readFileSync(p, "utf8");
    } catch {
      privateKey = "";
    }
  }

  if (!partnerId || !privateKey) return null;
  return { partnerId, cardId, privateKey };
}

/**
 * Build the final Samsung "Add to Wallet" URL for a user card payload.
 * Prefers the signed cdata flow when partner credentials are configured,
 * otherwise falls back to pdata (URL-encoded JSON) using the public template.
 */
function buildAddToWalletUrl(cardPayload) {
  const signer = loadSamsungSigner();

  if (signer) {
    const now = Math.floor(Date.now() / 1000);
    const token = jwt.sign(
      {
        iat: now,
        exp: now + 300,
        partnerId: signer.partnerId,
        cdata: cardPayload,
      },
      signer.privateKey,
      { algorithm: "RS256" },
    );
    return `https://a.swallet.link/atw/v3/${signer.cardId}#Clip?cdata=${encodeURIComponent(
      token,
    )}`;
  }

  // Unsigned fallback — Samsung's public template accepts JSON via pdata. This
  // guarantees the card renders the current user's data even when no signing
  // key is configured yet.
  const pdata = encodeURIComponent(JSON.stringify(cardPayload));
  return `https://a.swallet.link/atw/v3/${DEFAULT_CERTIFICATE_ID}/${DEFAULT_CARD_ID}#Clip?pdata=${pdata}`;
}

export const GET = apiAdapter(async (request) => {
  const { searchParams } = new URL(request.url);
  let refId = searchParams.get("refId");

  if (!refId) {
    const segments = new URL(request.url).pathname.split("/");
    refId = segments[segments.length - 1];
    if (refId === "samsung") refId = null;
  }

  if (!refId) {
    return NextResponse.json(
      { success: false, error: "Missing refId" },
      { status: 400 },
    );
  }

  const db = await connectDB();
  const refDoc = await db
    .collection("samsung_wallet_refs")
    .findOne({ refId });

  if (!refDoc) {
    return NextResponse.json(
      { success: false, error: "Ref not found" },
      { status: 404 },
    );
  }

  const payload = buildCardPayload({
    refId,
    data: refDoc.cardData || {},
    request,
    createdAt: refDoc.createdAt ? refDoc.createdAt.getTime() : undefined,
  });

  return NextResponse.json(success(payload));
});

export const POST = apiAdapter(async (request) => {
  const body = await request.json();
  const { refId: incomingRefId, formData } = body || {};

  if (!formData) {
    return NextResponse.json(
      { success: false, error: "Missing formData" },
      { status: 400 },
    );
  }

  const refId =
    incomingRefId ||
    `ref-${formData.uid || "user"}-${Date.now().toString(36)}`;

  // Resolve the public card URL at submit time so we store an absolute,
  // publicly-resolvable value — even if NEXT_PUBLIC_BASE_URL is changed later
  // the stored record stays valid.
  const publicCardUrl =
    resolveCardUrl(formData, request) || formData.publicCardUrl || "";

  // Pre-render a darkened, wallet-sized banner (1032×336 with gradient) so
  // both the current save and any later refId callback serve the same
  // readable hero image.
  let walletBannerPath = null;
  if (formData.bannerUrl) {
    try {
      walletBannerPath = await renderWalletBanner(formData.bannerUrl);
    } catch (err) {
      console.warn(
        "[Samsung Wallet] banner pre-processing skipped:",
        err?.message || err,
      );
    }
  }

  const enrichedData = {
    ...formData,
    publicCardUrl,
    ...(walletBannerPath ? { __walletBannerPath: walletBannerPath } : {}),
  };

  // Persist the user's card data so Samsung's refId callback keeps working
  // if the partner portal is ever wired up to use it.
  try {
    const db = await connectDB();
    await db.collection("samsung_wallet_refs").updateOne(
      { refId },
      {
        $set: {
          refId,
          cardData: enrichedData,
          createdAt: new Date(),
        },
      },
      { upsert: true },
    );
  } catch (e) {
    // Persistence is best-effort; the URL still carries the data via pdata/cdata.
    console.error("Samsung wallet ref persistence failed:", e?.message || e);
  }

  const cardPayload = buildCardPayload({
    refId,
    data: enrichedData,
    request,
  });
  const addToWalletUrl = buildAddToWalletUrl(cardPayload);

  return NextResponse.json(
    success({
      refId,
      stored: true,
      publicCardUrl,
      addToWalletUrl,
    }),
  );
});
