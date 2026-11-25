/**
 * Server-side URL helpers used by wallet integrations.
 *
 * Wallet services (Google, Samsung, Apple) must fetch profile/banner images
 * from a **publicly reachable HTTPS host**. In local dev our uploads live at
 * `/uploads/user-assets/...` which is fine for the browser but unreachable
 * for Google/Samsung servers.
 *
 * These helpers:
 *   1. Resolve relative paths against an explicit public base URL.
 *   2. Drop localhost / private-IP URLs (they'd cause silent wallet failures).
 *   3. Enforce https:// only (Google Wallet rejects http:// image URLs).
 */

/** Returns the configured public base URL, or null. */
export function getPublicBaseUrl(request) {
  const explicit =
    process.env.NEXT_PUBLIC_BASE_URL ||
    process.env.PUBLIC_BASE_URL ||
    process.env.NEXT_PUBLIC_APP_URL ||
    null;
  if (explicit) return explicit.replace(/\/+$/, "");

  // Request origin is a last-ditch fallback. It might be localhost — if so the
  // downstream normalizer will drop it anyway.
  const origin = request?.nextUrl?.origin || null;
  return origin ? origin.replace(/\/+$/, "") : null;
}

/**
 * Normalize an image/public URL for a third-party wallet service.
 * Returns `null` if the URL cannot be made publicly reachable.
 */
export function normalizePublicImageUrl(url, baseUrl) {
  if (!url || typeof url !== "string") return null;
  const trimmed = url.trim();
  if (!trimmed) return null;
  if (trimmed.startsWith("data:")) return null;

  let absolute = trimmed;
  if (trimmed.startsWith("/")) {
    if (!baseUrl) return null;
    absolute = `${baseUrl.replace(/\/+$/, "")}${trimmed}`;
  } else if (!/^https?:\/\//i.test(trimmed)) {
    return null;
  }

  try {
    const u = new URL(absolute);
    if (isPrivateHost(u.hostname)) return null;
    if (u.protocol !== "https:" && u.protocol !== "http:") return null;
    return u.toString();
  } catch {
    return null;
  }
}

/**
 * Like normalizePublicImageUrl but rewrites localhost → explicit public base
 * when one is configured. Used for the QR `publicCardUrl` on wallet passes
 * so the QR resolves to the live site instead of localhost.
 */
export function rewriteToPublicOrigin(url, explicitPublicBase) {
  if (!url || typeof url !== "string") return null;
  try {
    const u = new URL(url);
    if (!isPrivateHost(u.hostname)) return u.toString();
    if (!explicitPublicBase) return null;
    const base = new URL(explicitPublicBase);
    u.protocol = base.protocol;
    u.host = base.host;
    return u.toString();
  } catch {
    return null;
  }
}

function isPrivateHost(host) {
  const h = (host || "").toLowerCase();
  return (
    h === "localhost" ||
    h === "127.0.0.1" ||
    h === "0.0.0.0" ||
    h.endsWith(".local") ||
    h.startsWith("192.168.") ||
    h.startsWith("10.") ||
    /^172\.(1[6-9]|2\d|3[01])\./.test(h)
  );
}
