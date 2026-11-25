import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { admin } from "@/backend/config/firebase";

export const dynamic = "force-dynamic";

/**
 * Handle File Uploads for profile images and banners
 * POST /api/storage/profile-image
 */
export const POST = apiAdapter(async (request, { params }) => {
  const type = await params.type;

  if (type === "profile-image") {
    const { imageBase64, type: imgType, userId } = await request.json();
    if (!imageBase64 || !imgType || !userId) {
      return NextResponse.json(
        { success: false, error: "Missing fields" },
        { status: 400 },
      );
    }

    const matches = imageBase64.match(/^data:image\/([a-zA-Z+]+);base64,(.+)$/);
    if (!matches) {
      return NextResponse.json(
        { success: false, error: "Invalid image format" },
        { status: 400 },
      );
    }

    const buffer = Buffer.from(matches[2], "base64");
    const fileName = `${imgType}/${userId}_${Date.now()}.${matches[1]}`;
    if (!admin)
      return NextResponse.json(
        { error: "Firebase not configured" },
        { status: 500 },
      );
    const bucket = admin.storage().bucket();
    const blob = bucket.file(fileName);

    await blob.save(buffer, {
      metadata: { contentType: `image/${matches[1]}` },
    });

    const url = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
    return NextResponse.json({ success: true, url });
  }

  // Handle multipart form data for other document types if needed
  if (type === "document") {
    const formData = await request.formData();
    const file = formData.get("file");

    if (!file) {
      return NextResponse.json(
        { success: false, error: "No file provided" },
        { status: 400 },
      );
    }

    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);

    const fileName = `documents/${Date.now()}_${file.name}`;
    if (!admin)
      return NextResponse.json(
        { error: "Firebase not configured" },
        { status: 500 },
      );
    const bucket = admin.storage().bucket();
    const blob = bucket.file(fileName);

    await blob.save(buffer, {
      metadata: { contentType: file.type },
    });

    const url = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
    return NextResponse.json({ success: true, url });
  }

  return NextResponse.json(
    { success: false, error: "Invalid storage type" },
    { status: 404 },
  );
});
