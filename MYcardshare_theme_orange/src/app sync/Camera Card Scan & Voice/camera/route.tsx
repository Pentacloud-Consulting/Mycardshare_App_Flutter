import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import ocrEngine from "@/backend/controllers/ocr.engine";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * CAMERA CARD SCAN SYNC (OCR Business Card Extraction & Auto Vault Persistence)
 * 
 * Supports:
 * - POST /api/sync/camera-card-scan
 *   Payload:
 *     - image: base64 data URL (e.g. "data:image/jpeg;base64,...")
 *     - saveToVault: boolean (optional, auto-saves to user's MongoDB contacts & Firestore)
 *     - role: "individual" | "employee" | "enterprise" (optional)
 *     - enterpriseId: string (if employee, dual-syncs to enterprise leads)
 */
export const POST = apiAdapter(async (request: NextRequest) => {
  let context: any = null;
  try {
    context = await resolveAuth(request);
  } catch (authErr) {
    // Allows extraction without token, but saving to vault requires auth
  }

  const body = await request.json();
  const { image, saveToVault = false, role = "individual", enterpriseId } = body;

  if (!image) {
    throw new AppError("No image provided for card scan.", 400);
  }

  if (!image.startsWith("data:image/")) {
    throw new AppError("Invalid image format. Expected base64 data URL.", 400);
  }

  // 1. Run AI OCR Engine (Google Gemini Vision + Fallback Regex)
  const extractionResult = await ocrEngine.extractBusinessCard(image);

  if (!extractionResult.success) {
    return NextResponse.json(
      fail(
        "OCR_FAILED",
        extractionResult.error || "Failed to extract business card details.",
      ),
      { status: extractionResult.retryable ? 429 : 500 }
    );
  }

  const extractedData = extractionResult.data;
  let savedRecord = null;

  // 2. Dual-Sync / Auto-save to Vault if requested & user authenticated
  if (saveToVault && context?.uid) {
    try {
      const db = await connectDB();
      const contactDoc = {
        userId: context.uid,
        fullName: extractedData.fullName || "Scanned Contact",
        jobTitle: extractedData.jobTitle || "",
        company: extractedData.company || "",
        email: extractedData.email || "",
        phone: extractedData.phone || "",
        phone2: extractedData.phone2 || "",
        website: extractedData.website || "",
        address: extractedData.address || "",
        notes: extractedData.notes || "",
        cardImageUrl: extractedData.cardImageUrl || null,
        confidence: extractionResult.confidence || 0.9,
        source: "ocr_camera_scan",
        role,
        createdAt: new Date(),
      };

      const result = await db.collection("contacts").insertOne(contactDoc);
      savedRecord = { ...contactDoc, _id: result.insertedId };

      // If user is Employee or Enterprise, also sync as a Lead
      if (role === "employee" && enterpriseId) {
        await db.collection("leads").insertOne({
          enterpriseId,
          capturedByUserId: context.uid,
          leadName: extractedData.fullName,
          leadEmail: extractedData.email,
          leadPhone: extractedData.phone,
          leadCompany: extractedData.company,
          leadJobTitle: extractedData.jobTitle,
          source: "employee_camera_card_scan",
          status: "NEW",
          createdAt: new Date(),
        });
      }
    } catch (dbErr: any) {
      console.warn("[Camera Card Sync] DB save warning:", dbErr.message);
    }
  }

  return NextResponse.json(
    success({
      extracted: {
        fullName: extractedData.fullName || "",
        jobTitle: extractedData.jobTitle || "",
        company: extractedData.company || "",
        email: extractedData.email || "",
        phone: extractedData.phone || "",
        phone2: extractedData.phone2 || "",
        website: extractedData.website || "",
        address: extractedData.address || "",
        notes: extractedData.notes || "",
        confidence: extractionResult.confidence || 0.9,
      },
      savedRecord,
      source: "gemini_vision_ocr",
    })
  );
});

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const db = await connectDB();

  const ocrContacts = await db
    .collection("contacts")
    .find({ userId: context.uid, source: "ocr_camera_scan" })
    .sort({ createdAt: -1 })
    .limit(50)
    .toArray();

  return NextResponse.json(
    success({
      totalScans: ocrContacts.length,
      contacts: ocrContacts,
    })
  );
});
