import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { connectDB } from "@/backend/config/db";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

let genAI: any = null;
function getGenAI() {
  if (!genAI && process.env.GEMINI_API_KEY) {
    genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  }
  return genAI;
}

const VOICE_PROMPT = `Extract contact information from the transcript below.
Rules:
1. fullName: Person's full name. Look for phrases like "meet", "save", "contact is", "this is".
2. email: Valid email. Convert spoken "at" to "@", "dot" to ".".
3. phone: Primary phone number. Extract all continuous digits.
4. phone2: Secondary phone if mentioned.
5. company: Organization or company name.
6. jobTitle: Role or designation.
7. website: URL if spoken.
8. address: Physical address/city if mentioned.
9. notes: Summary of context or remarks.

Return ONLY valid JSON:
{"fullName":"","email":"","phone":"","phone2":"","company":"","jobTitle":"","website":"","address":"","notes":""}`;

/**
 * Regex Fallback parser when LLM key is absent or offline
 */
function parseVoiceRegex(transcript: string) {
  const emailMatch = transcript.match(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/);
  const phoneMatch = transcript.match(/(\+?\d[\d\s-]{8,}\d)/);
  
  // Basic name heuristic if user said "Save [Name]" or "Meet [Name]"
  let name = "";
  const nameMatch = transcript.match(/(?:save|meet|this is|contact is|add)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)/i);
  if (nameMatch) {
    name = nameMatch[1];
  }

  return {
    fullName: name,
    email: emailMatch ? emailMatch[0] : "",
    phone: phoneMatch ? phoneMatch[0].replace(/\s+/g, "") : "",
    phone2: "",
    company: "",
    jobTitle: "",
    website: "",
    address: "",
    notes: transcript,
  };
}

/**
 * VOICE ADD SYNC (Natural Speech-to-Contact AI Parsing & Vault Persistence)
 * 
 * Supports:
 * - POST /api/sync/voice-add
 *   Payload:
 *     - transcript: string (raw voice speech recognized from mobile microphone)
 *     - saveToVault: boolean (optional)
 *     - role: "individual" | "employee" | "enterprise"
 *     - enterpriseId: string (if employee, dual-syncs to enterprise CRM leads)
 */
export const POST = apiAdapter(async (request: NextRequest) => {
  let context: any = null;
  try {
    context = await resolveAuth(request);
  } catch (e) {
    // Auth optional for extraction preview
  }

  const body = await request.json();
  const { transcript, saveToVault = false, role = "individual", enterpriseId } = body;

  if (!transcript || typeof transcript !== "string" || transcript.trim().length === 0) {
    throw new AppError("No speech transcript provided. Say something like 'Save Rahul, CEO at Acme Corp, phone 9876543210'", 400);
  }

  let parsedData: any = null;

  // 1. Try Gemini AI Extraction
  const ai = getGenAI();
  if (ai) {
    try {
      const model = ai.getGenerativeModel({
        model: "gemini-1.5-flash",
        generationConfig: {
          responseMimeType: "application/json",
          temperature: 0.1,
        },
      });

      const response = await model.generateContent([
        { text: VOICE_PROMPT },
        { text: `Voice Transcript: "${transcript}"` },
      ]);

      const jsonText = response.response.text();
      parsedData = JSON.parse(jsonText);
    } catch (aiErr: any) {
      console.warn("[Voice Sync] Gemini parsing failed, using regex fallback:", aiErr.message);
    }
  }

  // Fallback if AI didn't return
  if (!parsedData || !parsedData.fullName) {
    parsedData = parseVoiceRegex(transcript);
  }

  let savedRecord = null;

  // 2. Dual-Sync / Auto-save to Vault if requested & user authenticated
  if (saveToVault && context?.uid) {
    try {
      const db = await connectDB();
      const contactDoc = {
        userId: context.uid,
        fullName: parsedData.fullName || "Voice Contact",
        jobTitle: parsedData.jobTitle || "",
        company: parsedData.company || "",
        email: parsedData.email || "",
        phone: parsedData.phone || "",
        phone2: parsedData.phone2 || "",
        website: parsedData.website || "",
        address: parsedData.address || "",
        notes: parsedData.notes || transcript,
        raw_transcript: transcript,
        source: "voice_add",
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
          leadName: parsedData.fullName,
          leadEmail: parsedData.email,
          leadPhone: parsedData.phone,
          leadCompany: parsedData.company,
          leadJobTitle: parsedData.jobTitle,
          notes: parsedData.notes,
          source: "employee_voice_add",
          status: "NEW",
          createdAt: new Date(),
        });
      }
    } catch (dbErr: any) {
      console.warn("[Voice Sync] DB save warning:", dbErr.message);
    }
  }

  return NextResponse.json(
    success({
      extracted: parsedData,
      rawTranscript: transcript,
      savedRecord,
      source: "gemini_voice_ai",
    })
  );
});

export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const db = await connectDB();

  const voiceContacts = await db
    .collection("contacts")
    .find({ userId: context.uid, source: "voice_add" })
    .sort({ createdAt: -1 })
    .limit(50)
    .toArray();

  return NextResponse.json(
    success({
      totalVoiceNotes: voiceContacts.length,
      contacts: voiceContacts,
    })
  );
});
