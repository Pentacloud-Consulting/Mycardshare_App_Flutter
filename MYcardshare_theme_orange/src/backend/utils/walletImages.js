import path from "node:path";
import fs from "node:fs/promises";
import crypto from "node:crypto";
import sharp from "sharp";

/**
 * Google Wallet hero-image recommended dimensions (3.07 : 1 aspect).
 * @see https://developers.google.com/wallet/generic/resources/images
 */
const HERO_WIDTH = 1032;
const HERO_HEIGHT = 336;

const CACHE_DIR_SEGMENTS = ["public", "uploads", "wallet-banners"];
const PUBLIC_URL_PREFIX = "/uploads/wallet-banners";

/**
 * Convert a possibly-relative image URL to a local file path or an HTTP(S)
 * URL we can fetch with Node's global `fetch`.
 */
function resolveFetchSource(sourceUrl) {
  if (!sourceUrl || typeof sourceUrl !== "string") return null;
  const trimmed = sourceUrl.trim();
  if (!trimmed) return null;
  if (trimmed.startsWith("data:")) return { kind: "data", value: trimmed };
  if (trimmed.startsWith("/")) {
    return {
      kind: "local",
      value: path.join(process.cwd(), "public", trimmed.replace(/^\/+/, "")),
    };
  }
  if (/^https?:\/\//i.test(trimmed)) {
    return { kind: "http", value: trimmed };
  }
  return null;
}

async function readSourceBytes(source) {
  if (source.kind === "local") {
    return fs.readFile(source.value);
  }
  if (source.kind === "http") {
    const res = await fetch(source.value, {
      signal: AbortSignal.timeout(15_000),
    });
    if (!res.ok) {
      throw new Error(
        `Failed to fetch banner (${res.status} ${res.statusText}) from ${source.value}`,
      );
    }
    return Buffer.from(await res.arrayBuffer());
  }
  if (source.kind === "data") {
    const commaIdx = source.value.indexOf(",");
    if (commaIdx === -1) throw new Error("Malformed data: URL");
    return Buffer.from(source.value.slice(commaIdx + 1), "base64");
  }
  throw new Error(`Unsupported banner source kind: ${source.kind}`);
}

/**
 * Vertical dark gradient matching the live profile-card preview — light at
 * the top, deep at the bottom so overlaid text (name, subtitle) stays
 * readable on any banner.
 */
function buildOverlaySvg() {
  return Buffer.from(
    `<svg xmlns="http://www.w3.org/2000/svg" width="${HERO_WIDTH}" height="${HERO_HEIGHT}">
      <defs>
        <linearGradient id="shade" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#05070A" stop-opacity="0.15"/>
          <stop offset="55%" stop-color="#05070A" stop-opacity="0.55"/>
          <stop offset="100%" stop-color="#05070A" stop-opacity="0.85"/>
        </linearGradient>
      </defs>
      <rect width="100%" height="100%" fill="url(#shade)"/>
    </svg>`,
  );
}

/**
 * Render a wallet-optimized banner: cropped to Google Wallet's recommended
 * hero aspect ratio and darkened with a vertical gradient for legibility.
 *
 * Results are cached to `public/uploads/wallet-banners/<hash>.jpg` so
 * repeated wallet saves don't re-process the same image.
 *
 * @param {string} sourceUrl  Absolute URL or a `/uploads/...` relative path.
 * @returns {Promise<string|null>} Relative public path, or `null` on failure.
 */
export async function renderWalletBanner(sourceUrl) {
  const source = resolveFetchSource(sourceUrl);
  if (!source) return null;

  const cacheDir = path.join(process.cwd(), ...CACHE_DIR_SEGMENTS);
  await fs.mkdir(cacheDir, { recursive: true });

  const hash = crypto
    .createHash("sha1")
    .update(sourceUrl)
    .digest("hex")
    .slice(0, 16);
  const fileName = `${hash}.jpg`;
  const absPath = path.join(cacheDir, fileName);
  const publicPath = `${PUBLIC_URL_PREFIX}/${fileName}`;

  try {
    await fs.access(absPath);
    return publicPath;
  } catch {
    // not cached yet
  }

  let inputBuffer;
  try {
    inputBuffer = await readSourceBytes(source);
  } catch (err) {
    console.error(
      "[walletImages] could not read banner source:",
      err?.message || err,
    );
    return null;
  }

  try {
    await sharp(inputBuffer)
      .resize(HERO_WIDTH, HERO_HEIGHT, { fit: "cover", position: "center" })
      .composite([{ input: buildOverlaySvg(), blend: "over" }])
      .jpeg({ quality: 84, mozjpeg: true })
      .toFile(absPath);
    return publicPath;
  } catch (err) {
    console.error(
      "[walletImages] banner darken failed:",
      err?.message || err,
    );
    return null;
  }
}
