import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { success } from "@/backend/utils/apiResponse";

/**
 * Create Apple Wallet Pass (Mock/Placeholder)
 * POST /api/wallet/apple
 */
export const POST = apiAdapter(async (request) => {
  const cardData = await request.json();

  if (!cardData.fullName || !cardData.publicCardUrl) {
    return NextResponse.json(
      { success: false, error: "Missing required fields for Apple pass." },
      { status: 400 },
    );
  }

  return NextResponse.json(
    success({
      message: "Apple Pass generation ready. Use download endpoint.",
      mockMode: true,
    }),
  );
});
