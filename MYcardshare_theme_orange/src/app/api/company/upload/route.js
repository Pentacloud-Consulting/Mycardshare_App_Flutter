import { NextResponse } from "next/server";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import companyService from "@/backend/services/company.service";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { success, fail } from "@/backend/utils/apiResponse";

// Image uploads must run on the full Node runtime (GCS SDK + fs).
export const runtime = "nodejs";
export const dynamic = "force-dynamic";
export const maxDuration = 60;

const ALLOWED_TYPES = new Set(["logo", "banner"]);
const MAX_FILE_BYTES = 50 * 1024 * 1024; // 50 MB

async function handleMultipart(request, context) {
  const form = await request.formData();
  const type = form.get("type");
  const companyId = form.get("companyId");
  const file = form.get("file") || form.get("image");

  if (typeof type !== "string" || !ALLOWED_TYPES.has(type)) {
    return NextResponse.json(
      fail("BAD_REQUEST", `Unsupported or missing upload type "${type}".`),
      { status: 400 },
    );
  }
  if (!companyId || typeof companyId !== "string") {
    return NextResponse.json(
      fail("BAD_REQUEST", "Missing companyId."),
      { status: 400 },
    );
  }
  if (!file || typeof file === "string") {
    return NextResponse.json(
      fail("BAD_REQUEST", "Upload must include a file field."),
      { status: 400 },
    );
  }
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
  try {
    const publicUrl = await companyService.uploadImage(companyId, type, {
      buffer,
      contentType: file.type,
    });
    return NextResponse.json(success({ url: publicUrl }));
  } catch (err) {
    console.error(
      `❌ [Company Upload] ${type} upload failed for ${companyId} / ${context.uid}:`,
      err,
    );
    if (err instanceof AppError) throw err;
    throw new AppError(err?.message || "Image upload failed", 500);
  }
}

async function handleJson(request, context) {
  let body;
  try {
    body = await request.json();
  } catch (err) {
    console.error(
      "❌ [Company Upload] Failed to parse JSON body:",
      err?.message || err,
    );
    return NextResponse.json(
      fail(
        "BAD_REQUEST",
        "Could not read the uploaded image. For large files, upload as multipart/form-data instead.",
      ),
      { status: 400 },
    );
  }

  const { type, image, companyId } = body || {};

  if (!type || !image || !companyId) {
    return NextResponse.json(
      fail("BAD_REQUEST", "Missing `type`, `image`, or `companyId`."),
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
    const publicUrl = await companyService.uploadImage(companyId, type, image);
    return NextResponse.json(success({ url: publicUrl }));
  } catch (err) {
    console.error(
      `❌ [Company Upload] ${type} upload failed for ${companyId} / ${context.uid}:`,
      err,
    );
    if (err instanceof AppError) throw err;
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
