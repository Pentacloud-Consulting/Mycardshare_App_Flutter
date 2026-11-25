import { NextResponse } from "next/server";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import ocrEngine from "@/backend/controllers/ocr.engine";
import { success } from "@/backend/utils/apiResponse";

export const POST = apiAdapter(async (request) => {
  const { image } = await request.json();

  if (!image) {
    throw new AppError("No image provided", 400);
  }

  if (!image.startsWith("data:image/")) {
    throw new AppError("Invalid image format. Expected base64 data URL.", 400);
  }

  const result = await ocrEngine.extractBusinessCard(image);

  if (result.success) {
    // Spread result.data so fields (fullName, email, phone, etc.) sit directly
    // inside the success envelope's `data` property.  The frontend reads them
    // as result.data.fullName, result.data.email, etc.
    return NextResponse.json(
      success({
        ...result.data,
        confidence: result.confidence,
        source: "gemini-ai",
      }),
    );
  } else {
    throw new AppError(
      result.error || "OCR extraction failed",
      result.retryable ? 429 : 500,
    );
  }
});
