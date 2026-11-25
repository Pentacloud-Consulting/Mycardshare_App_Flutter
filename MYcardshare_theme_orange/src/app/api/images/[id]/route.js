import { NextResponse } from "next/server";
import { readImageFromFirestore } from "@/backend/services/storage.service";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";
export const maxDuration = 30;

/**
 * Serve an image blob stored in the Firestore `image_blobs` collection.
 *
 * This is the read-side of the "Firestore fallback" storage backend used
 * when neither GCS nor the local filesystem is writable (i.e. Vercel
 * functions without a provisioned Storage bucket). Callers get a
 * `/api/images/<docId>` URL back from the upload service and can use it
 * anywhere a normal image URL would go.
 */
export async function GET(_req, { params }) {
  const { id } = await params;

  try {
    const blob = await readImageFromFirestore(id);
    if (!blob) {
      return NextResponse.json(
        { success: false, error: { code: "NOT_FOUND", message: "Image not found." } },
        { status: 404 },
      );
    }

    return new NextResponse(blob.buffer, {
      status: 200,
      headers: {
        "Content-Type": blob.contentType,
        "Content-Length": String(blob.buffer.length),
        // Images are immutable once uploaded (new upload → new id), so we
        // can cache aggressively at the CDN layer.
        "Cache-Control": "public, max-age=31536000, immutable",
      },
    });
  } catch (err) {
    console.error(`[GET /api/images/${id}]`, err);
    return NextResponse.json(
      {
        success: false,
        error: {
          code: "READ_FAILED",
          message: err?.message || "Failed to load image.",
        },
      },
      { status: 500 },
    );
  }
}
