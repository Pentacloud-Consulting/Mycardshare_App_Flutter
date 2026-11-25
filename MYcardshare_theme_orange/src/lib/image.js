"use client";

/**
 * Client-side image helpers so our upload endpoints never see a 413.
 *
 * The base64-over-JSON approach inflates file size by ~33% and trips
 * Next.js / edge body-size limits for anything larger than ~2MB raw.
 * We downscale to a sensible max dimension and re-encode as JPEG or PNG,
 * then return the data URL. Nothing server-side has to change.
 */

/**
 * Default knobs that give good quality for avatars / banners / logos.
 *
 * JPEG is used across the board so the output is 5-10x smaller than PNG.
 * The uploader route accepts JSON + base64, and base64 inflates size by ~33%,
 * so keeping the raw file under ~1 MB keeps the JSON body safely under the
 * Next.js route-handler body limit (~2 MB in dev, ~4.5 MB on Vercel).
 */
const DEFAULTS = {
  avatar: { maxDim: 800, quality: 0.85, mime: "image/jpeg" },
  banner: { maxDim: 1600, quality: 0.82, mime: "image/jpeg" },
  logo: { maxDim: 768, quality: 0.85, mime: "image/jpeg" },
  generic: { maxDim: 1200, quality: 0.82, mime: "image/jpeg" },
};

/** Max bytes we'll POST. ~1.2 MB base64 ≈ ~900 KB raw, safely under any limit. */
const MAX_DATA_URL_BYTES = 1_200_000;

/**
 * Read + downscale + recompress a File. Returns a data URL ready to POST.
 *
 * @param {File} file
 * @param {"avatar"|"banner"|"logo"|"generic"} kind
 * @returns {Promise<string>}
 */
export async function readAndCompressImage(file, kind = "generic") {
  if (!file) throw new Error("No file provided.");
  if (!file.type?.startsWith("image/")) {
    throw new Error("Only image files are allowed.");
  }

  const cfg = DEFAULTS[kind] || DEFAULTS.generic;

  // Read as data URL (kept as fallback if canvas work fails).
  const rawDataUrl = await new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result));
    reader.onerror = () => reject(new Error("Failed to read file."));
    reader.readAsDataURL(file);
  });

  try {
    const img = await loadImage(rawDataUrl);

    // First pass at the caller-preferred dimensions.
    let out = encode(img, cfg.maxDim, cfg.mime, cfg.quality);

    // Aggressive second / third pass if the payload is still too big.
    // Each pass shrinks dimensions and drops quality until we fit.
    let dim = cfg.maxDim;
    let quality = cfg.quality;
    while (out && out.length > MAX_DATA_URL_BYTES && dim > 320) {
      dim = Math.max(320, Math.round(dim * 0.8));
      quality = Math.max(0.6, quality - 0.08);
      out = encode(img, dim, cfg.mime, quality);
    }

    // Final guard: if for any reason the "compressed" version is still
    // larger than what we read (e.g. tiny already-compressed image), return
    // the original so we don't bloat.
    if (!out || out.length > rawDataUrl.length) return rawDataUrl;

    return out;
  } catch {
    return rawDataUrl;
  }
}

function encode(img, maxDim, mime, quality) {
  const { width, height } = fitInside(img.width, img.height, maxDim);
  const canvas = document.createElement("canvas");
  canvas.width = width;
  canvas.height = height;
  const ctx = canvas.getContext("2d");
  if (!ctx) return null;

  // JPEG has no alpha channel — paint white so transparent pixels don't
  // turn black.
  if (mime === "image/jpeg") {
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0, width, height);
  }
  ctx.drawImage(img, 0, 0, width, height);
  return canvas.toDataURL(mime, quality);
}

function loadImage(src) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve(img);
    img.onerror = () => reject(new Error("Failed to decode image."));
    img.src = src;
  });
}

function fitInside(w, h, maxDim) {
  if (w <= maxDim && h <= maxDim) return { width: w, height: h };
  const scale = Math.min(maxDim / w, maxDim / h);
  return { width: Math.round(w * scale), height: Math.round(h * scale) };
}

/** Approx size in MB of a data URL (for client-side gating / logging). */
export function dataUrlMegabytes(dataUrl) {
  if (typeof dataUrl !== "string") return 0;
  const commaIdx = dataUrl.indexOf(",");
  const b64 = commaIdx >= 0 ? dataUrl.slice(commaIdx + 1) : dataUrl;
  return (b64.length * 0.75) / (1024 * 1024);
}
