import { NextResponse } from "next/server";
import { apiAdapter, AppError } from "@/backend/utils/api-adapter";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { success } from "@/backend/utils/apiResponse";

let genAI = null;
function getGenAI() {
  if (!genAI && process.env.GEMINI_API_KEY) {
    genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  }
  return genAI;
}

const EXTRACTION_PROMPT = `Extract contact information from the transcript below.

Rules:
1. full_name: The person's FULL NAME. Look for phrases like "my name is", "I am", "this is". This is CRITICAL - never leave empty if a name is mentioned.
2. email: Valid email. Convert spoken "at" to "@", "dot" to ".".
3. primary_number: First phone/mobile number mentioned. Keep ALL digits exactly as spoken.
4. secondary_number: Second phone number if mentioned.
5. company: Organization or company name.
6. job_title: Role, designation, or profession (e.g. "developer", "manager").
7. website: URL if mentioned.
8. address: Physical address if mentioned.
9. notes: ALL other information that doesn't fit above fields - experience, skills, interests, ambitions, hobbies. NEVER leave empty if extra info exists.

Return ONLY valid JSON:
{"full_name":"","email":"","primary_number":"","secondary_number":"","company":"","job_title":"","website":"","address":"","notes":""}`;

/**
 * Hugging Face Inference API — uses open-source models (no Gemini quota needed)
 */
async function extractWithHuggingFace(transcript) {
  const HF_KEY = process.env.HUGGINGFACE_API_KEY;
  if (!HF_KEY) return null;

  // Mistral Instruct requires [INST] tags for proper instruction following
  const hfPrompt = `<s>[INST] ${EXTRACTION_PROMPT}\n\nTranscript:\n"${transcript}"\n\nRespond with ONLY the JSON object, nothing else. [/INST]`;

  // Try multiple HF models in order of preference
  const models = [
    "mistralai/Mistral-7B-Instruct-v0.3",
    "microsoft/Phi-3-mini-4k-instruct",
  ];

  for (const model of models) {
    try {
      console.log(`🤗 Trying HF model: ${model}`);
      const res = await fetch(
        `https://api-inference.huggingface.co/models/${model}`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${HF_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            inputs: hfPrompt,
            parameters: {
              max_new_tokens: 500,
              temperature: 0.1,
              return_full_text: false,
            },
          }),
        }
      );

      if (!res.ok) {
        const errText = await res.text();
        console.warn(`⚠️ HF ${model} returned ${res.status}: ${errText}`);
        continue;
      }

      const data = await res.json();
      const rawText = Array.isArray(data)
        ? data[0]?.generated_text || ""
        : data?.generated_text || "";

      // Extract JSON from the response
      const jsonMatch = rawText.match(/\{[\s\S]*?\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        console.log(`✅ HF extraction successful via ${model}`);
        return parsed;
      }
    } catch (err) {
      console.warn(`⚠️ HF model ${model} failed:`, err.message);
    }
  }

  return null; // All HF models failed
}

/**
 * Gemini extraction — used as fallback or for audio processing
 */
async function extractWithGemini(promptParts) {
  const client = getGenAI();
  if (!client) return null;

  const voiceModels = ["gemini-2.0-flash-lite", "gemini-2.5-flash"];

  for (const modelName of voiceModels) {
    const currentModel = client.getGenerativeModel({
      model: modelName,
      generationConfig: {
        temperature: 0.1,
        topP: 0.95,
        topK: 40,
        responseMimeType: "application/json",
      },
    });

    for (let attempt = 1; attempt <= 2; attempt++) {
      try {
        const result = await currentModel.generateContent(promptParts);
        const response = await result.response;
        const text = response.text().trim()
          .replace(/^```json\s*/i, "").replace(/^```\s*/i, "")
          .replace(/\s*```$/i, "").trim();

        const parsed = JSON.parse(text);
        console.log(`✅ Gemini extraction successful via ${modelName}`);
        return parsed;
      } catch (retryErr) {
        const isRetryable =
          retryErr.message?.includes("429") ||
          retryErr.message?.includes("503") ||
          retryErr.message?.toLowerCase().includes("quota") ||
          retryErr.message?.toLowerCase().includes("unavailable") ||
          retryErr.message?.toLowerCase().includes("high demand");
        if (isRetryable && attempt < 2) {
          console.log(`⏳ ${modelName} limited, retrying...`);
          await new Promise(r => setTimeout(r, 3000));
        } else if (!isRetryable) {
          throw retryErr;
        }
      }
    }
    console.log(`⚠️ ${modelName} exhausted, trying next...`);
  }

  return null;
}

function normalizeExtracted(extracted, transcript) {
  const notes = extracted.notes || "";
  // If notes is empty but we have extra transcript info, store the full transcript
  const finalNotes = notes || (transcript ? `Voice transcript: ${transcript}` : "");

  return {
    fullName: extracted.full_name || extracted.fullName || "",
    email: extracted.email || "",
    phone: extracted.primary_number || extracted.phone || "",
    phone2: extracted.secondary_number || extracted.phone2 || "",
    company: extracted.company || "",
    jobTitle: extracted.job_title || extracted.jobTitle || "",
    website: extracted.website || "",
    address: extracted.address || "",
    notes: finalNotes,
    raw_transcript: transcript || "Audio processed directly",
  };
}

export const POST = apiAdapter(async (request) => {
  let transcript = "";
  let audioBuffer = null;
  let audioMimeType = "";

  const contentType = request.headers.get("content-type") || "";

  if (contentType.includes("multipart/form-data")) {
    const formData = await request.formData();
    const audioFile = formData.get("audio");
    transcript = formData.get("transcript") || "";

    if (audioFile && audioFile instanceof Blob) {
      audioBuffer = Buffer.from(await audioFile.arrayBuffer());
      audioMimeType = (audioFile.type || "audio/webm").split(";")[0];
      console.log(`🎤 Received audio: ${audioBuffer.length} bytes, type: ${audioMimeType}`);
    }
  } else {
    const body = await request.json();
    transcript = body.transcript || "";
  }

  if (!transcript && !audioBuffer) {
    throw new AppError("No transcript or audio provided", 400);
  }

  console.log(`🎙️ Processing voice ${audioBuffer ? "audio" : "transcript"}...`);

  // ── Strategy: Text transcript available → try HF first, then Gemini ──
  if (transcript && transcript.trim().length > 10) {
    // 1. Try Hugging Face (open-source, generous quota)
    try {
      const hfResult = await extractWithHuggingFace(transcript);
      if (hfResult && (hfResult.full_name || hfResult.email || hfResult.primary_number)) {
        return NextResponse.json(success({
          ...normalizeExtracted(hfResult, transcript),
          source: "voice-hf",
        }));
      }
    } catch (hfErr) {
      console.warn("⚠️ HF extraction failed:", hfErr.message);
    }

    // 2. Fallback to Gemini text-only extraction
    try {
      const geminiResult = await extractWithGemini([
        { text: EXTRACTION_PROMPT },
        { text: `Transcript:\n"${transcript}"` },
      ]);
      if (geminiResult) {
        return NextResponse.json(success({
          ...normalizeExtracted(geminiResult, transcript),
          source: "voice-gemini",
        }));
      }
    } catch (gemErr) {
      console.warn("⚠️ Gemini text extraction failed:", gemErr.message);
    }
  }

  // ── Strategy: Audio only → must use Gemini (supports audio input) ──
  if (audioBuffer) {
    const promptParts = [
      { text: EXTRACTION_PROMPT },
      {
        inlineData: {
          data: audioBuffer.toString("base64"),
          mimeType: audioMimeType,
        },
      },
    ];
    if (transcript) {
      promptParts.push({ text: `Browser transcript hint: "${transcript}"` });
    }

    try {
      const geminiResult = await extractWithGemini(promptParts);
      if (geminiResult) {
        return NextResponse.json(success({
          ...normalizeExtracted(geminiResult, transcript),
          source: "voice-audio-gemini",
        }));
      }
    } catch (audioErr) {
      console.error("❌ Gemini audio extraction failed:", audioErr.message);
    }
  }

  // ── Ultimate Fallback: Local regex parsing (no AI needed) ──
  if (transcript && transcript.trim().length > 5) {
    console.log("🔧 All AI services unavailable — using local regex extraction...");
    const t = transcript.trim();
    const result = { full_name: "", email: "", primary_number: "", secondary_number: "", company: "", job_title: "", website: "", address: "", notes: "" };

    // Extract name: "my name is X", "I am X", "this is X", "name X"
    const nameMatch = t.match(/(?:my name is|i am|i'm|this is|name)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)/i);
    if (nameMatch) result.full_name = nameMatch[1].trim();

    // Extract email
    const emailMatch = t.match(/[a-zA-Z0-9._%+-]+\s*(?:@|at)\s*[a-zA-Z0-9.-]+\s*(?:\.|dot)\s*(?:com|in|org|net|co|io)/i);
    if (emailMatch) {
      result.email = emailMatch[0]
        .replace(/\s*at\s*/gi, "@")
        .replace(/\s*dot\s*/gi, ".")
        .replace(/\s+/g, "")
        .toLowerCase();
    }

    // Extract phone numbers (sequences of 7+ digits, possibly with spaces)
    const phoneMatches = t.match(/\b[\d\s]{7,15}\b/g);
    if (phoneMatches) {
      const phones = phoneMatches.map(p => p.replace(/\s/g, "")).filter(p => p.length >= 7);
      if (phones[0]) result.primary_number = phones[0];
      if (phones[1]) result.secondary_number = phones[1];
    }

    // Extract job title keywords
    const jobMatch = t.match(/(?:i am a|i'm a|i work as|designation is|role is|position is)\s+([^,.]+)/i);
    if (jobMatch) result.job_title = jobMatch[1].trim();
    else {
      // Look for common job keywords
      const jobKeywords = t.match(/\b(developer|engineer|manager|designer|director|consultant|analyst|architect|lead|CEO|CTO|founder)\b/i);
      if (jobKeywords) result.job_title = jobKeywords[1];
    }

    // Extract company
    const companyMatch = t.match(/(?:company is|work at|working at|from|organization is)\s+([^,.]+)/i);
    if (companyMatch) result.company = companyMatch[1].trim();

    // Everything else goes to notes
    result.notes = t;

    console.log("✅ Local regex extraction:", result);
    return NextResponse.json(success({
      ...normalizeExtracted(result, transcript),
      source: "voice-local",
    }));
  }

  throw new AppError(
    "No transcript available and AI services are unavailable. Please try again.",
    503
  );
});
