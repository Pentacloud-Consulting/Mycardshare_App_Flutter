"use client";

/**
 * Single source of truth for building share / public URLs across the app.
 *
 * Resolution order for the origin:
 *   1. NEXT_PUBLIC_BASE_URL          — primary override (set on the platform)
 *   2. NEXT_PUBLIC_APP_URL           — alternative naming
 *   3. window.location.origin        — current browser origin (dev/prod detected live)
 *   4. "https://digitalbusinesscloudcard.com" — static fallback for SSR/worker contexts
 *
 * Why this matters:
 *  - On localhost, builds sharing a raw `http://localhost:3003/card/<slug>` link
 *    which nobody else can open. Setting NEXT_PUBLIC_BASE_URL in `.env.local`
 *    (e.g. to the production domain) makes every share link point there instead.
 *  - Wallet passes embed the same URL in their QR; consistency matters.
 */
const STATIC_FALLBACK = "https://digitalbusinesscloudcard.com";

function stripTrailingSlashes(url) {
  return typeof url === "string" ? url.replace(/\/+$/, "") : url;
}

function normalizePublicOrigin(raw) {
  if (!raw || typeof raw !== "string") return null;

  const trimmed = raw.trim();
  if (!trimmed) return null;

  // Allow env values like "mycardshare.id" or "www.mycardshare.id" (no scheme).
  const withScheme = /^https?:\/\//i.test(trimmed)
    ? trimmed
    : `https://${trimmed.replace(/^\/+/, "")}`;

  try {
    // If someone accidentally provides a full URL with a path, keep only the origin.
    const u = new URL(withScheme);
    return stripTrailingSlashes(u.origin);
  } catch {
    // Last resort: best-effort cleanup (still ensures scheme).
    return stripTrailingSlashes(withScheme);
  }
}

function isLocalhostOrPrivateHost(hostname) {
  const h = (hostname || "").toLowerCase();
  return (
    h === "localhost" ||
    h === "127.0.0.1" ||
    h === "0.0.0.0" ||
    h.endsWith(".local") ||
    h.startsWith("10.") ||
    h.startsWith("192.168.") ||
    /^172\.(1[6-9]|2\d|3[01])\./.test(h)
  );
}

/** Returns the public origin (no trailing slash, no path). */
export function getPublicOrigin() {
  const envOrigin =
    (typeof process !== "undefined" &&
      (process.env.NEXT_PUBLIC_BASE_URL ||
        process.env.NEXT_PUBLIC_APP_URL)) ||
    null;

  // In the browser we want the URL to be dynamic per-host (Vercel preview domains,
  // custom domains, etc). Only fall back to env overrides when running on localhost.
  if (typeof window !== "undefined" && window.location?.origin) {
    const origin = stripTrailingSlashes(window.location.origin);
    try {
      const u = new URL(origin);
      if (!isLocalhostOrPrivateHost(u.hostname)) return origin;
    } catch {
      return origin;
    }
  }

  // SSR / workers / localhost dev fallback: allow env override.
  const normalizedEnv = normalizePublicOrigin(envOrigin);
  if (normalizedEnv) return normalizedEnv;

  return STATIC_FALLBACK;
}

/**
 * Build the public URL for a user's card.
 * @param {string | null | undefined} slug — the user's cardSlug
 */
export function getCardShareUrl(slug) {
  const origin = getPublicOrigin();
  const clean = (slug || "").toString().trim();
  return clean ? `${origin}/card/${clean}` : `${origin}/card/preview`;
}

/**
 * Build the signup URL, optionally pre-filled with a company voucher code.
 * @param {string | null | undefined} voucher
 */
export function getSignupUrl(voucher) {
  const origin = getPublicOrigin();
  const v = (voucher || "").toString().trim();
  return v ? `${origin}/signup?voucher=${encodeURIComponent(v)}` : `${origin}/signup`;
}

/**
 * Build the universal workspace join URL compatible with both Web and Mobile App deep links.
 */
export function getWorkspaceJoinUrl(enterpriseId, code, voucher) {
  const origin = getPublicOrigin();
  const eid = (enterpriseId || "").toString().trim();
  const c = (code || "").toString().trim();
  const v = (voucher || "").toString().trim();
  const qs = new URLSearchParams();
  if (eid) {
    qs.set("enterpriseId", eid);
    qs.set("workspaceId", eid);
  }
  if (c) qs.set("code", c);
  if (v) qs.set("voucher", v);
  return `${origin}/join-workspace?${qs.toString()}`;
}
