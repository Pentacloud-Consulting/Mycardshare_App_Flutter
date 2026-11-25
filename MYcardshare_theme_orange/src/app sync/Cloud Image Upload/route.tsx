import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { admin } from "@/backend/config/firebase";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";
import fs from "fs";
import path from "path";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * CLOUD IMAGE UPLOAD & MEDIA SYNC (APP <-> WEB)
 * 
 * Supports:
 * - POST /api/sync/cloud-upload
 *   Modes:
 *   1. Base64 Upload: { imageBase64, category: "avatar"|"banner"|"logo"|"card_photo", format: "jpeg"|"png" }
 *   2. Multipart Form Upload: formData containing "file", "category"
 * 
 * Target Storage:
 *   - Primary: Firebase Storage Bucket (https://storage.googleapis.com/<bucket>/...)
 *   - Local Fallback: /public/uploads/<category>/...
 * 
 * Database Updates:
 *   - Auto-updates MongoDB `cards` or `users` collection based on category
 */

export const POST = apiAdapter(async (request: NextRequest) => {
  let context: any = null;
  try {
    context = await resolveAuth(request);
  } catch (e) {
    // Auth optional for demo uploads, but recommended
  }

  const uid = context?.uid || "anonymous_upload";
  const contentType = request.headers.get("content-type") || "";

  let buffer: Buffer;
  let mimeType = "image/jpeg";
  let extension = "jpg";
  let category = "avatar"; // "avatar" | "banner" | "logo" | "card_photo"

  // =========================================================================
  // 1. EXTRACT DATA (MULTIPART FORM OR JSON BASE64)
  // =========================================================================
  if (contentType.includes("multipart/form-data")) {
    const formData = await request.formData();
    const file = formData.get("file") as File | null;
    category = (formData.get("category") as string) || "avatar";

    if (!file) {
      throw new AppError("No file uploaded in form-data", 400);
    }

    const bytes = await file.arrayBuffer();
    buffer = Buffer.from(bytes);
    mimeType = file.type || "image/jpeg";
    extension = mimeType.split("/")[1] || "jpg";
  } else {
    const json = await request.json();
    const { imageBase64, category: cat = "avatar" } = json;
    category = cat;

    if (!imageBase64) {
      throw new AppError("No imageBase64 provided in payload", 400);
    }

    const matches = imageBase64.match(/^data:image\/([a-zA-Z+]+);base64,(.+)$/);
    if (matches) {
      extension = matches[1] === "jpeg" ? "jpg" : matches[1];
      mimeType = `image/${matches[1]}`;
      buffer = Buffer.from(matches[2], "base64");
    } else {
      buffer = Buffer.from(imageBase64, "base64");
    }
  }

  // Enforce Max File Size (10MB)
  if (buffer.length > 10 * 1024 * 1024) {
    throw new AppError("Image size exceeds maximum limit of 10MB", 400);
  }

  const timestamp = Date.now();
  const fileName = `${category}/${uid}_${timestamp}.${extension}`;
  let publicUrl = "";

  // =========================================================================
  // 2. UPLOAD TO FIREBASE STORAGE (OR LOCAL /PUBLIC/UPLOADS FALLBACK)
  // =========================================================================
  let storageMode = "firebase_storage";

  try {
    let bucket = null;
    if (admin && admin.storage) {
      bucket = admin.storage().bucket();
    }

    if (bucket && bucket.name) {
      const blob = bucket.file(fileName);
      await blob.save(buffer, {
        metadata: {
          contentType: mimeType,
          cacheControl: "public, max-age=31536000",
        },
      });

      // Make publicly readable
      try {
        await blob.makePublic();
      } catch (e) {
        // Uniform bucket access might be enabled
      }

      publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
    } else {
      throw new Error("Firebase storage bucket not available");
    }
  } catch (err: any) {
    console.warn("[Cloud Upload] Firebase Storage fallback to local uploads:", err.message);
    storageMode = "local_filesystem";

    const uploadDir = path.join(process.cwd(), "public", "uploads", category);
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }

    const localFilePath = path.join(uploadDir, `${uid}_${timestamp}.${extension}`);
    fs.writeFileSync(localFilePath, buffer);

    const baseUrl =
      process.env.NEXT_PUBLIC_BASE_URL ||
      process.env.PUBLIC_BASE_URL ||
      "https://mycardshare.com";
    publicUrl = `${baseUrl}/uploads/${category}/${uid}_${timestamp}.${extension}`;
  }

  // =========================================================================
  // 3. AUTO-UPDATE USER & CARD DOCUMENT
  // =========================================================================
  if (context?.uid) {
    try {
      const db = await connectDB();
      const updateField: Record<string, string> = {};

      if (category === "avatar") {
        updateField.avatarUrl = publicUrl;
        updateField.photoURL = publicUrl;
      } else if (category === "banner") {
        updateField.bannerUrl = publicUrl;
      } else if (category === "logo") {
        updateField.companyLogo = publicUrl;
      }

      if (Object.keys(updateField).length > 0) {
        await Promise.all([
          db.collection("cards").updateOne({ userId: uid }, { $set: updateField }),
          db.collection("users").updateOne({ uid }, { $set: updateField }),
        ]);
      }
    } catch (dbErr: any) {
      console.warn("[Cloud Upload] DB field update warning:", dbErr.message);
    }
  }

  return NextResponse.json(
    success({
      url: publicUrl,
      publicUrl,
      category,
      storageMode,
      bytes: buffer.length,
      mimeType,
      message: "Image uploaded and synced successfully.",
    })
  );
});
