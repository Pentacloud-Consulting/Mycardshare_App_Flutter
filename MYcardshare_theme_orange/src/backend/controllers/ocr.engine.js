// ============================================
// FILE: backend/controllers/ocr.engine.js
// AI-Powered Business Card OCR using Google Gemini
// ============================================

import { GoogleGenerativeAI } from "@google/generative-ai";

let genAI = null;

function getGenAI() {
  if (!genAI && process.env.GEMINI_API_KEY) {
    genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    console.log("✅ Gemini AI client initialized");
  }
  return genAI;
}

const EXTRACTION_PROMPT = `You are a high-precision business card OCR agent. Analyze this business card image and extract contact information.

IMAGE CONTEXT: The image is a center-cropped high-resolution snap of a business card. It may contain common abbreviations.

STRICT EXTRACTION RULES:
1. fullName: The PERSON'S full name ONLY. This is the individual human name (e.g., "Ashfaq Ahmed", "John Smith"). It is NOT the company name. The person's name is usually displayed prominently, often in a larger or bolder font. NEVER put company names, business descriptions, service names, or taglines here. If you see text like "Domestic & International Courier" — that is a company description, NOT a person's name.
2. jobTitle: Position or designation (e.g., "Software Engineer", "Business Development Manager", "MD", "Regional Manager").
3. company: Name of the business entity. Often associated with a logo or text like "Pvt Ltd", "Solutions", "Enterprises", "Express", "Limited".
4. email: Must be a valid email address. Handle common OCR errors: (e) as @, [at] as @.
5. phone: Extract the PRIMARY contact number (first/main number). Handle abbreviations: "Mob:", "Ph:", "W:", "M:". Keep digits and "+" if present.
6. phone2: Extract the SECONDARY contact number if a second phone/mobile number exists on the card. Leave empty if only one number.
7. website: Extract the company website URL.
8. address: Full physical location if present on the card.
9. notes: ONLY include genuinely meaningful additional information found on the card that doesn't fit other fields, such as a company tagline, specific services offered, or unique details. If there is nothing meaningful beyond the standard contact fields, leave this as an EMPTY string. Do NOT put raw OCR text, repeated information, or meaningless fragments here.
10. NORMALIZE: Clean up punctuation, remove random symbols (©, ®, etc.). 
11. INFERENCING: You may reasonably infer a field if 90% of the word is clear (e.g., "Enterpr_ses" -> "Enterprises").

CRITICAL: Distinguish between the PERSON's name and the COMPANY name. A business card always has a person's name — look for the human name, not the organization.

Return ONLY valid JSON:
{
  "fullName": "",
  "jobTitle": "",
  "company": "",
  "email": "",
  "phone": "",
  "phone2": "",
  "website": "",
  "address": "",
  "notes": "",
  "confidence": 0.0
}

Confidence scoring:
- 0.9+: Every field verified and clear.
- 0.7-0.9: Most fields clear, minor noise.
- 0.5-0.7: Blur or orientation issues.
- Below 0.5: Highly unreadable - leave fields empty.`;

async function extractBusinessCard(base64Image) {
  if (!process.env.GEMINI_API_KEY) {
    console.error("❌ GEMINI_API_KEY not configured");
    return { success: false, error: "Gemini API key not configured" };
  }

  const client = getGenAI();
  if (!client) {
    console.error("❌ Failed to initialize Gemini client");
    return { success: false, error: "Failed to initialize Gemini client" };
  }

  try {
    console.log("🤖 Starting Gemini business card extraction...");

    // gemini-flash-latest: Automatically points to the most optimal flash model for the API key
    // Supports vision/image input for business card OCR
    const model = client.getGenerativeModel({
      model: "gemini-flash-latest",
      generationConfig: {
        temperature: 0.1,
        topP: 0.95,
        topK: 40,
        responseMimeType: "application/json",
      },
    });

    let imageData = base64Image;
    let mimeType = "image/png";

    if (base64Image.startsWith("data:")) {
      const matches = base64Image.match(/^data:([^;]+);base64,(.+)$/);
      if (matches) {
        mimeType = matches[1];
        imageData = matches[2];
      }
    }

    const imagePart = {
      inlineData: {
        data: imageData,
        mimeType: mimeType,
      },
    };

    console.log("📤 Sending image to Gemini Vision API...");

    // Auto-retry with backoff for rate limit (429) and overload (503) errors
    let result;
    let lastError;
    const retryableModels = ["gemini-flash-latest", "gemini-3.5-flash"];

    for (const modelName of retryableModels) {
      const currentModel = client.getGenerativeModel({
        model: modelName,
        generationConfig: {
          temperature: 0.1,
          topP: 0.95,
          topK: 40,
          responseMimeType: "application/json",
        },
      });

      for (let attempt = 1; attempt <= 3; attempt++) {
        try {
          result = await currentModel.generateContent([EXTRACTION_PROMPT, imagePart]);
          break; // success
        } catch (retryErr) {
          lastError = retryErr;
          const isRetryable =
            retryErr.message?.includes("429") ||
            retryErr.message?.includes("503") ||
            retryErr.message?.toLowerCase().includes("quota") ||
            retryErr.message?.toLowerCase().includes("overloaded") ||
            retryErr.message?.toLowerCase().includes("unavailable") ||
            retryErr.message?.toLowerCase().includes("high demand");
          if (isRetryable && attempt < 3) {
            const waitMs = attempt * 3000; // 3s, 6s
            console.log(
              `⏳ ${modelName} unavailable (attempt ${attempt}/3), retrying in ${waitMs / 1000}s...`,
            );
            await new Promise((r) => setTimeout(r, waitMs));
          } else if (!isRetryable) {
            throw retryErr;
          }
        }
      }
      if (result) break; // got a result, stop trying models
      console.log(`⚠️ ${modelName} failed after 3 attempts, trying fallback model...`);
    }
    if (!result) throw lastError;

    const response = await result.response;
    const text = response.text();

    console.log("📥 Gemini raw response:", text);

    let cleanedText = text.trim();
    cleanedText = cleanedText
      .replace(/^```json\s*/i, "")
      .replace(/^```\s*/i, "")
      .replace(/\s*```$/i, "")
      .trim();

    let extracted;
    try {
      extracted = JSON.parse(cleanedText);
    } catch (parseErr) {
      const jsonMatch = cleanedText.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        extracted = JSON.parse(jsonMatch[0]);
      } else {
        throw new Error(
          "Could not extract JSON from Gemini response: " +
            cleanedText.slice(0, 200),
        );
      }
    }

    console.log("✅ Gemini extraction successful:", extracted);

    const normalized = {
      fullName: extracted.fullName || "",
      jobTitle: extracted.jobTitle || "",
      company: extracted.company || "",
      email: extracted.email || "",
      phone: extracted.phone || "",
      phone2: extracted.phone2 || "",
      website: extracted.website || "",
      address: extracted.address || "",
      notes: extracted.notes || "",
      confidence: Math.min(1, Math.max(0, extracted.confidence || 0.5)),
    };

    return {
      success: true,
      data: normalized,
      confidence: normalized.confidence,
    };
  } catch (error) {
    console.error("❌ Gemini extraction error:", error);
    const isRetryable =
      error.message?.includes("429") ||
      error.message?.includes("503") ||
      error.message?.includes("quota") ||
      error.message?.includes("high demand") ||
      error.message?.includes("Unavailable");
    if (isRetryable) {
      return { success: false, error: "AI service temporarily unavailable. Please try again in a moment.", retryable: true };
    }
    return { success: false, error: error.message || "Failed to extract data" };
  }
}

export { extractBusinessCard };
export default { extractBusinessCard };
