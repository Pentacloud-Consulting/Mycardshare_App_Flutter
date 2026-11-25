import path from "node:path";
import fs from "node:fs";
import fsp from "node:fs/promises";
import crypto from "node:crypto";
import { firestoreDb } from "@/backend/config/firebase";

/**
 * Unified storage layer for every file upload in the app.
 *
 * ORDER OF OPERATIONS (per put):
 *   1. If a Firebase Storage bucket exists AND is reachable → write to GCS
 *      and return a public `https://storage.googleapis.com/...` URL.
 *   2. Otherwise write to `public/uploads/<folder>/` on the local disk and
 *      return a relative `/uploads/<folder>/...` URL that Next.js serves
 *      automatically (works on every non-serverless host).
 *   3. As a last resort (read-only filesystem AND no usable bucket — i.e.
 *      Vercel with no Storage provisioned) persist the bytes to a Firestore
 *      blob document and return `/api/images/<docId>` which reads it back.
 *      Image payloads are resized with `sharp` to fit Firestore's 1 MiB
 *      per-document limit.
 *
 * This means uploads *always* succeed as long as Firestore is reachable.
 */

/** Max bytes accepted by the service. 50 MB covers profile/banner comfortably. */
export const MAX_UPLOAD_BYTES = 50 * 1024 * 1024;

/** Allowed MIME types per upload kind. */
const ALLOWED_MIME = {
  image: /^image\/(jpeg|jpg|png|gif|webp|avif|svg\+xml)$/i,
  document: /^(application\/(pdf|msword|vnd\.openxmlformats-officedocument\.wordprocessingml\.document))$/i,
};

/**
 * True when we're on a read-only serverless runtime whose project filesystem
 * can't be written to — currently just Vercel Functions. This is a *hint*,
 * not a gate: we still **try** the local write and only give up if it
 * actually fails, so an incorrectly-set flag never blocks a working upload.
 */
function probablyServerless() {
  return !!process.env.VERCEL;
}

/**
 * Wait for the async bucket-probe kicked off at Firebase-admin init.
 * Returns the resolved bucket handle, or `null` if no bucket is usable.
 */
async function getUsableBucket() {
  if (global.gcsBucket) return global.gcsBucket;
  if (global.gcsBucketReady?.then) {
    try {
      await global.gcsBucketReady;
    } catch {
      /* probe errors are already logged at init */
    }
  }
  return global.gcsBucket || null;
}

function extFromContentType(contentType) {
  if (!contentType || typeof contentType !== "string") return "bin";
  const m = contentType.toLowerCase().match(/^image\/([a-z0-9+.-]+)$/);
  if (!m) return "bin";
  const raw = m[1].replace(/[^a-z0-9]/g, "");
  return raw === "jpeg" ? "jpg" : raw || "bin";
}

function extFromDocMime(contentType) {
  if (!contentType) return "bin";
  const lower = contentType.toLowerCase();
  if (lower.includes("pdf")) return "pdf";
  if (lower.includes("wordprocessingml")) return "docx";
  if (lower.includes("msword")) return "doc";
  return "bin";
}

function contentTypeFromExt(ext) {
  const e = (ext || "").toLowerCase();
  if (!e || e === "bin") return "application/octet-stream";
  if (e === "pdf") return "application/pdf";
  if (e === "docx") return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
  if (e === "doc") return "application/msword";
  return `image/${e === "jpg" ? "jpeg" : e}`;
}

/**
 * Sanitize a filename part: strip directory traversal, reserved chars, and
 * anything that isn't alphanum/hyphen/underscore/dot.
 */
function sanitizeName(name) {
  return String(name || "")
    .replace(/[^a-zA-Z0-9_.-]/g, "_")
    .replace(/_+/g, "_")
    .replace(/^\.+/, "")
    .slice(0, 120);
}

/**
 * Normalize an input into { buffer, ext, contentType }.
 *
 * Accepts:
 *   • `Buffer` / `Uint8Array` (raw bytes — you must pass `contentType`)
 *   • `{ buffer, ext?, contentType? }`
 *   • A `data:<mime>;base64,...` string (legacy JSON clients)
 */
function normalizeInput(input, fallbackContentType) {
  if (Buffer.isBuffer(input)) {
    const contentType = fallbackContentType || "application/octet-stream";
    return { buffer: input, ext: extFromContentType(contentType), contentType };
  }
  if (input instanceof Uint8Array) {
    const contentType = fallbackContentType || "application/octet-stream";
    return {
      buffer: Buffer.from(input),
      ext: extFromContentType(contentType),
      contentType,
    };
  }
  if (input && typeof input === "object" && input.buffer) {
    const buffer = Buffer.isBuffer(input.buffer)
      ? input.buffer
      : Buffer.from(input.buffer);
    const contentType =
      input.contentType ||
      fallbackContentType ||
      contentTypeFromExt(input.ext);
    const ext = sanitizeName(input.ext || extFromContentType(contentType));
    return { buffer, ext, contentType };
  }
  if (typeof input === "string" && input.startsWith("data:")) {
    const comma = input.indexOf(",");
    if (comma === -1) {
      const err = new Error("Malformed data URL");
      err.code = "INVALID_INPUT";
      throw err;
    }
    const meta = input.substring(0, comma);
    const payload = input.substring(comma + 1);
    const match = meta.match(/^data:([^;]+);base64$/);
    const contentType = match ? match[1] : "application/octet-stream";
    const buffer = Buffer.from(payload, "base64");
    return { buffer, ext: extFromContentType(contentType), contentType };
  }
  const err = new Error(
    "Unsupported upload input — expected Buffer, { buffer, contentType }, or a data: URL",
  );
  err.code = "INVALID_INPUT";
  throw err;
}

/**
 * Persist an image and return its public URL.
 *
 * @param {Object} opts
 * @param {string}  opts.folder     Folder segment (e.g. "user-avatars"). Sanitized.
 * @param {string}  opts.baseName   Base filename WITHOUT extension. Sanitized.
 * @param {*}       opts.input      Buffer | { buffer, ext, contentType } | data URL
 * @param {string} [opts.contentType]  Optional override when input is a raw Buffer.
 * @returns {Promise<{ url: string, backend: "gcs" | "local", path: string }>}
 */
export async function putImage({ folder, baseName, input, contentType }) {
  if (!folder) throw new Error("MISSING_FOLDER");
  if (!baseName) throw new Error("MISSING_NAME");

  const { buffer, ext, contentType: resolvedContentType } = normalizeInput(
    input,
    contentType,
  );

  if (!buffer.length) {
    const err = new Error("Uploaded file is empty.");
    err.code = "EMPTY_FILE";
    throw err;
  }
  if (buffer.length > MAX_UPLOAD_BYTES) {
    const err = new Error(
      `File exceeds the ${Math.round(MAX_UPLOAD_BYTES / 1024 / 1024)} MB limit.`,
    );
    err.code = "FILE_TOO_LARGE";
    throw err;
  }
  if (!ALLOWED_MIME.image.test(resolvedContentType)) {
    const err = new Error(
      `Unsupported image type "${resolvedContentType}". Upload a JPEG, PNG, GIF, WebP, AVIF, or SVG.`,
    );
    err.code = "INVALID_MIME";
    throw err;
  }

  const safeFolder = sanitizeName(folder) || "misc";
  const safeBase = sanitizeName(baseName) || `upload_${Date.now()}`;
  const fileName = `${safeBase}_${Date.now()}.${ext}`;

  // ───── Try GCS first ──────────────────────────────────────────────────
  const bucket = await getUsableBucket();
  let cloudError = null;
  if (bucket) {
    try {
      const blob = bucket.file(`${safeFolder}/${fileName}`);
      await blob.save(buffer, {
        contentType: resolvedContentType,
        resumable: buffer.length > 5 * 1024 * 1024,
        metadata: {
          contentType: resolvedContentType,
          cacheControl: "public, max-age=86400",
        },
      });
      return {
        url: `https://storage.googleapis.com/${bucket.name}/${safeFolder}/${fileName}`,
        backend: "gcs",
        path: `${safeFolder}/${fileName}`,
      };
    } catch (err) {
      cloudError = err;
      console.error(
        `[storage] GCS upload failed for ${safeFolder}/${fileName}:`,
        err?.message || err,
      );
      // fall through to local
    }
  }

  // ───── Local fallback ────────────────────────────────────────────────
  // Always attempt the local write. It succeeds on every non-serverless
  // host (dev machine, VM, container, self-hosted Next.js, etc.) so this
  // is the backstop that makes uploads "just work" without any config.
  try {
    const dir = path.join(process.cwd(), "public", "uploads", safeFolder);
    if (!fs.existsSync(dir)) await fsp.mkdir(dir, { recursive: true });
    await fsp.writeFile(path.join(dir, fileName), buffer);
    if (cloudError) {
      console.warn(
        `[storage] Wrote ${safeFolder}/${fileName} locally — GCS was unavailable (${cloudError.message}).`,
      );
    } else if (!bucket) {
      console.log(
        `[storage] Wrote ${safeFolder}/${fileName} locally — no Firebase Storage bucket configured.`,
      );
    }
    return {
      url: `/api/uploads/${safeFolder}/${fileName}`,
      backend: "local",
      path: `${safeFolder}/${fileName}`,
    };
  } catch (localErr) {
    console.warn(
      `[storage] Local write unavailable for ${safeFolder}/${fileName} (${localErr?.code || localErr?.message}). Falling through to Firestore blob store.`,
    );

    // ───── Firestore blob fallback ──────────────────────────────────────
    // Used when neither GCS nor the local FS is usable (i.e. Vercel with
    // no Storage bucket). Firestore docs cap at 1 MiB, so images are
    // shrunk with sharp until they fit.
    try {
      const stored = await putImageInFirestore({
        folder: safeFolder,
        baseName: safeBase,
        ext,
        buffer,
        contentType: resolvedContentType,
      });
      if (cloudError) {
        console.warn(
          `[storage] Stored ${safeFolder}/${fileName} in Firestore fallback — GCS was unavailable (${cloudError.message}).`,
        );
      } else {
        console.log(
          `[storage] Stored ${safeFolder}/${fileName} in Firestore fallback (no bucket / no writable FS).`,
        );
      }
      return stored;
    } catch (fsErr) {
      console.error(
        `[storage] Firestore blob fallback failed for ${safeFolder}/${fileName}:`,
        fsErr?.message || fsErr,
      );

      const err = new Error(
        cloudError
          ? `All storage backends failed. GCS error: ${cloudError.message}. Firestore fallback: ${fsErr.message}.`
          : `All storage backends failed (${fsErr.message}). Check Firestore connectivity or configure FIREBASE_STORAGE_BUCKET.`,
      );
      err.code = "STORAGE_UNAVAILABLE";
      err.cause = cloudError || fsErr;
      throw err;
    }
  }
}

/**
 * Persist image bytes in a Firestore document and return a URL that can
 * stream them back. This is the final fallback used when no GCS bucket is
 * configured and the local filesystem is read-only (i.e. Vercel functions).
 *
 * Firestore caps each document at 1 MiB (including field names), and
 * base64 inflation adds ~33%. We resize with sharp until the encoded
 * payload comfortably fits (~650 KiB of raw image).
 */
async function putImageInFirestore({
  folder,
  baseName,
  ext,
  buffer,
  contentType,
}) {
  if (!firestoreDb) {
    throw new Error("Firestore is not initialized.");
  }

  const FIRESTORE_LIMIT = 650 * 1024; // keep well under the 1 MiB cap

  let finalBuffer = buffer;
  let finalContentType = contentType;
  let finalExt = ext;

  if (buffer.length > FIRESTORE_LIMIT) {
    try {
      const sharp = (await import("sharp")).default;

      const attempts = [
        { width: 1600, quality: 82 },
        { width: 1400, quality: 78 },
        { width: 1200, quality: 75 },
        { width: 1000, quality: 72 },
        { width: 800, quality: 70 },
      ];

      for (const { width, quality } of attempts) {
        const compressed = await sharp(buffer, { failOn: "none" })
          .rotate()
          .resize({ width, withoutEnlargement: true })
          .jpeg({ quality, mozjpeg: true })
          .toBuffer();
        if (compressed.length <= FIRESTORE_LIMIT) {
          finalBuffer = compressed;
          finalContentType = "image/jpeg";
          finalExt = "jpg";
          break;
        }
        finalBuffer = compressed;
        finalContentType = "image/jpeg";
        finalExt = "jpg";
      }

      if (finalBuffer.length > FIRESTORE_LIMIT) {
        throw new Error(
          `Image is too large to store (${Math.round(finalBuffer.length / 1024)} KiB after compression).`,
        );
      }
    } catch (sharpErr) {
      if (sharpErr.message?.startsWith("Image is too large")) throw sharpErr;
      console.warn(
        "[storage] sharp compression failed, storing raw bytes:",
        sharpErr?.message || sharpErr,
      );
    }
  }

  const docId = `${Date.now()}-${crypto.randomBytes(6).toString("hex")}`;
  await firestoreDb.collection("image_blobs").doc(docId).set({
    folder,
    baseName,
    ext: finalExt,
    contentType: finalContentType,
    size: finalBuffer.length,
    data: finalBuffer.toString("base64"),
    createdAt: new Date().toISOString(),
  });

  return {
    url: `/api/images/${docId}`,
    backend: "firestore",
    path: `image_blobs/${docId}`,
  };
}

/**
 * Read an image blob back from Firestore.
 * Used by `/api/images/[id]/route.js`.
 */
export async function readImageFromFirestore(id) {
  if (!firestoreDb) return null;
  if (!id || typeof id !== "string") return null;
  if (!/^[A-Za-z0-9_-]+$/.test(id)) return null;
  const snap = await firestoreDb.collection("image_blobs").doc(id).get();
  if (!snap.exists) return null;
  const data = snap.data();
  if (!data?.data) return null;
  return {
    buffer: Buffer.from(data.data, "base64"),
    contentType: data.contentType || "application/octet-stream",
  };
}

/**
 * Human-readable health of the storage layer — handy for a `/api/storage/status`
 * probe so you can check whether GCS is live without opening a terminal.
 */
export async function getStorageStatus() {
  const bucket = await getUsableBucket();
  // Probe the local uploads folder by actually trying to create it — more
  // honest than guessing from env vars.
  let localWritable = false;
  try {
    const dir = path.join(process.cwd(), "public", "uploads");
    if (!fs.existsSync(dir)) await fsp.mkdir(dir, { recursive: true });
    await fsp.access(dir, fs.constants.W_OK);
    localWritable = true;
  } catch {
    localWritable = false;
  }
  const firestoreReady = !!firestoreDb;
  return {
    gcs: {
      ready: !!bucket,
      bucket: bucket?.name || null,
    },
    local: {
      enabled: localWritable,
      folder: "/public/uploads",
    },
    firestoreBlobs: {
      ready: firestoreReady,
      note: firestoreReady
        ? "Active final fallback. Stores images as base64 in the `image_blobs` collection and serves them from /api/images/<id>."
        : "Firestore is not initialized.",
    },
    mode: bucket
      ? "gcs"
      : localWritable
        ? "local"
        : firestoreReady
          ? "firestore"
          : "none",
    maxUploadMB: Math.round(MAX_UPLOAD_BYTES / 1024 / 1024),
    probablyServerless: probablyServerless(),
  };
}

/**
 * Persist a document file (PDF, DOC, DOCX) and return its public URL.
 * Documents skip the Firestore blob fallback (too large) — only GCS or local.
 *
 * @param {Object} opts
 * @param {string}  opts.folder     Folder segment (e.g. "user-documents"). Sanitized.
 * @param {string}  opts.baseName   Base filename WITHOUT extension. Sanitized.
 * @param {*}       opts.input      { buffer, ext, contentType }
 * @returns {Promise<{ url: string, backend: "gcs" | "local", path: string }>}
 */
export async function putDocument({ folder, baseName, input }) {
  if (!folder) throw new Error("MISSING_FOLDER");
  if (!baseName) throw new Error("MISSING_NAME");

  const buffer = Buffer.isBuffer(input.buffer) ? input.buffer : Buffer.from(input.buffer);
  const ext = sanitizeName(input.ext || extFromDocMime(input.contentType)) || "pdf";
  const resolvedContentType = (input.contentType && ALLOWED_MIME.document.test(input.contentType))
    ? input.contentType
    : contentTypeFromExt(ext);

  if (!buffer.length) {
    const err = new Error("Uploaded file is empty.");
    err.code = "EMPTY_FILE";
    throw err;
  }
  if (buffer.length > MAX_UPLOAD_BYTES) {
    const err = new Error(
      `File exceeds the ${Math.round(MAX_UPLOAD_BYTES / 1024 / 1024)} MB limit.`,
    );
    err.code = "FILE_TOO_LARGE";
    throw err;
  }
  if (!ALLOWED_MIME.document.test(resolvedContentType)) {
    const err = new Error(
      `Unsupported document type "${resolvedContentType}". Upload a PDF, DOC, or DOCX.`,
    );
    err.code = "INVALID_MIME";
    throw err;
  }

  const safeFolder = sanitizeName(folder) || "misc";
  const safeBase = sanitizeName(baseName) || `upload_${Date.now()}`;
  const fileName = `${safeBase}_${Date.now()}.${ext}`;

  // ───── Try GCS first ──────────────────────────────────────────────────
  const bucket = await getUsableBucket();
  if (bucket) {
    try {
      const blob = bucket.file(`${safeFolder}/${fileName}`);
      await blob.save(buffer, {
        contentType: resolvedContentType,
        resumable: buffer.length > 5 * 1024 * 1024,
        metadata: {
          contentType: resolvedContentType,
          contentDisposition: `attachment; filename="${fileName}"`,
          cacheControl: "public, max-age=86400",
        },
      });
      return {
        url: `https://storage.googleapis.com/${bucket.name}/${safeFolder}/${fileName}`,
        backend: "gcs",
        path: `${safeFolder}/${fileName}`,
      };
    } catch (err) {
      console.error(
        `[storage] GCS doc upload failed for ${safeFolder}/${fileName}:`,
        err?.message || err,
      );
      // fall through to local
    }
  }

  // ───── Local fallback ────────────────────────────────────────────────
  try {
    const dir = path.join(process.cwd(), "public", "uploads", safeFolder);
    if (!fs.existsSync(dir)) await fsp.mkdir(dir, { recursive: true });
    await fsp.writeFile(path.join(dir, fileName), buffer);
    return {
      url: `/api/uploads/${safeFolder}/${fileName}`,
      backend: "local",
      path: `${safeFolder}/${fileName}`,
    };
  } catch (localErr) {
    const err = new Error(
      `Document upload failed — filesystem not writable and no GCS bucket configured (${localErr.message}).`,
    );
    err.code = "STORAGE_UNAVAILABLE";
    throw err;
  }
}

export default {
  putImage,
  putDocument,
  getStorageStatus,
  readImageFromFirestore,
  MAX_UPLOAD_BYTES,
};
