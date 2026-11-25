import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { admin } from "@/backend/config/firebase";

export const dynamic = "force-dynamic";

export const POST = apiAdapter(async (request, { params }) => {
  const { type } = await params;

  if (type === "profile-image") {
    const { imageBase64, type: imgType, userId } = await request.json();
    if (!imageBase64 || !imgType || !userId) {
      return NextResponse.json(
        { success: false, error: "Missing fields" },
        { status: 400 },
      );
    }

    try {
      const { putImage } = await import("@/backend/services/storage.service");
      const { url } = await putImage({
        folder: imgType,
        baseName: `${userId}_${Date.now()}`,
        input: imageBase64
      });
      return NextResponse.json({ success: true, url });
    } catch (err) {
      return NextResponse.json({ success: false, error: err.message }, { status: 500 });
    }
  }

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
