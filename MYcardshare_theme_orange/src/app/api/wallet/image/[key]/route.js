import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import walletService from "@/backend/services/wallet.service";

/**
 * Serve hosted images for Wallet Passes
 * GET /api/wallet/image/[key]
 */
export const GET = apiAdapter(async (request, { params }) => {
  const { key } = await params;
  const imageData = walletService.getImageByKey(key);

  if (!imageData) {
    return NextResponse.json(
      { success: false, error: "Wallet image cache expired or not found." },
      { status: 404 },
    );
  }

  const matches = imageData.match(/^data:([^;]+);base64,(.+)$/);
  if (!matches) {
    return NextResponse.json(
      { success: false, error: "Cached image data is corrupt." },
      { status: 400 },
    );
  }

  const contentType = matches[1];
  const buffer = Buffer.from(matches[2], "base64");

  return new Response(buffer, {
    headers: {
      "Content-Type": contentType,
      "Cache-Control": "public, max-age=31536000",
      "Access-Control-Allow-Origin": "*",
    },
  });
});
