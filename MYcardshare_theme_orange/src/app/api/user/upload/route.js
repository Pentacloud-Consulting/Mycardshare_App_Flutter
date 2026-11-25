import { NextResponse } from "next/server";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import userService from "@/backend/services/user.service";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { success, fail } from "@/backend/utils/apiResponse";

// Image uploads write files to disk / GCS — force Node.js runtime so we get
// fs + the full admin SDK rather than the Edge runtime.
export const runtime = "nodejs";
export const dynamic = "force-dynamic";
// Next 14+ App Router honours this for FormData parsing.
export const maxDuration = 60;

const ALLOWED_TYPES = new Set(["avatar", "banner", "logo", "resume", "brochure"]);
const DOC_TYPES = new Set(["resume", "brochure"]);
const DOC_MIMES = /^(application\/(pdf|msword|vnd\.openxmlformats-officedocument\.wordprocessingml\.document))$/i;

// Hard safety ceiling so a bad client can't OOM the server. This is well
// beyond anything a user would ever upload as a profile picture or banner.
const MAX_FILE_BYTES = 50 * 1024 * 1024; // 50 MB

function extFromMime(mime) {
  if (!mime || typeof mime !== "string") return "bin";
  const m = mime.toLowerCase().match(/^image\/([a-z0-9+.-]+)$/);
  if (!m) return "bin";
  const raw = m[1].replace(/[^a-z0-9]/g, "");
  return raw === "jpeg" ? "jpg" : raw || "bin";
}

async function handleMultipart(request, context) {
  const form = await request.formData();
  const type = form.get("type");
  const file = form.get("file") || form.get("image");

  if (typeof type !== "string" || !ALLOWED_TYPES.has(type)) {
    return NextResponse.json(
      fail("BAD_REQUEST", `Unsupported or missing upload type "${type}".`),
      { status: 400 },
    );
  }
  if (!file || typeof file === "string") {
    return NextResponse.json(
      fail("BAD_REQUEST", "Upload must include a file field."),
      { status: 400 },
    );
  }

  // Document uploads (resume, brochure)
  if (DOC_TYPES.has(type)) {
    const isDoc = DOC_MIMES.test(file.type || "") || /\.(pdf|docx?)$/i.test(file.name || "");
    if (!isDoc) {
      return NextResponse.json(
        fail("BAD_REQUEST", "Only PDF, DOC, or DOCX files are allowed for documents."),
        { status: 400 },
      );
    }
    if (file.size > 50 * 1024 * 1024) {
      return NextResponse.json(
        fail("FILE_TOO_LARGE", `File is too large (${Math.round(file.size / 1024 / 1024)} MB). Max is 50 MB.`),
        { status: 413 },
      );
    }
    const buffer = Buffer.from(await file.arrayBuffer());
    const ext = file.name?.split(".").pop()?.toLowerCase() || extFromMime(file.type) || "pdf";
    const resolvedMime = DOC_MIMES.test(file.type || "")
      ? file.type
      : (ext === "docx"
          ? "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          : (ext === "doc" ? "application/msword" : "application/pdf"));
    try {
      const publicUrl = await userService.uploadDocument(context.uid, type, {
        buffer,
        ext,
        contentType: resolvedMime,
      });
      return NextResponse.json(success({ url: publicUrl }));
    } catch (err) {
      console.error(`❌ [Upload] ${type} upload failed for ${context.uid}:`, err);
      throw new AppError(err?.message || "Document upload failed", 500);
    }
  }

  // Image uploads (avatar, banner)
  if (!file.type?.startsWith("image/")) {
    return NextResponse.json(
      fail("BAD_REQUEST", "Only image files are allowed."),
      { status: 400 },
    );
  }
  if (file.size > MAX_FILE_BYTES) {
    return NextResponse.json(
      fail(
        "FILE_TOO_LARGE",
        `Image is too large (${Math.round(file.size / 1024 / 1024)} MB). Max is ${MAX_FILE_BYTES / 1024 / 1024} MB.`,
      ),
      { status: 413 },
    );
  }

  const buffer = Buffer.from(await file.arrayBuffer());
  const ext = extFromMime(file.type);

  try {
    const publicUrl = await userService.uploadImage(context.uid, type, {
      buffer,
      ext,
      contentType: file.type,
    });
    return NextResponse.json(success({ url: publicUrl }));
  } catch (err) {
    console.error(`❌ [Upload] ${type} upload failed for ${context.uid}:`, err);
    throw new AppError(err?.message || "Image upload failed", 500);
  }
}

async function handleJson(request, context) {
  let body;
  try {
    body = await request.json();
  } catch (err) {
    console.error("❌ [Upload] Failed to parse JSON body:", err?.message || err);
    return NextResponse.json(
      fail(
        "BAD_REQUEST",
        "Could not read the uploaded image. For large files, upload as multipart/form-data instead.",
      ),
      { status: 400 },
    );
  }

  const { type, image } = body || {};

  if (!type || !image) {
    return NextResponse.json(
      fail("BAD_REQUEST", "Missing `type` or `image` in upload payload."),
      { status: 400 },
    );
  }
  if (!ALLOWED_TYPES.has(type)) {
    return NextResponse.json(
      fail("BAD_REQUEST", `Unsupported upload type "${type}".`),
      { status: 400 },
    );
  }
  if (typeof image !== "string" || !image.startsWith("data:image/")) {
    return NextResponse.json(
      fail(
        "BAD_REQUEST",
        "Uploaded image must be a base64-encoded data:image/* URL.",
      ),
      { status: 400 },
    );
  }

  try {
    const publicUrl = await userService.uploadImage(context.uid, type, image);
    return NextResponse.json(success({ url: publicUrl }));
  } catch (err) {
    console.error(`❌ [Upload] ${type} upload failed for ${context.uid}:`, err);
    throw new AppError(err?.message || "Image upload failed", 500);
  }
}

export const POST = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const contentType = (request.headers.get("content-type") || "").toLowerCase();

  if (contentType.startsWith("multipart/form-data")) {
    return handleMultipart(request, context);
  }
  return handleJson(request, context);
});
