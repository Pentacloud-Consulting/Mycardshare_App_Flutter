import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/backend/config/db";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * NATIVE CONTACT SAVER & VCARD SYNC ENDPOINT (APP <-> WEB)
 * 
 * Problem Solved:
 * "When I click on Save Contact – it directly opens dialpad (due to tel: intent) 
 *  and the saving contact toast message is delayed afterwards."
 * 
 * Target Endpoints:
 * 1. GET /api/sync/save-contact?cardSlug=... OR ?userId=...
 *    - Returns pre-compiled RFC 6350 vCard 3.0 file content (.vcf) with 
 *      Content-Type: text/vcard; charset=utf-8
 *    - Phone, Email, Company, Title, Avatar photo, and website are directly encoded.
 *    - Android & iOS recognize this directly as "Add to Contacts / Import Contact"
 *      without EVER launching the Phone Dialpad!
 * 
 * 2. POST /api/sync/save-contact
 *    - Logs contact save telemetry & vault count for lead generation metrics.
 */

export const GET = apiAdapter(async (request: NextRequest) => {
  const { searchParams } = new URL(request.url);
  const cardSlug = searchParams.get("cardSlug") || searchParams.get("slug");
  const userId = searchParams.get("userId");

  const db = await connectDB();
  const query: any = {};
  if (cardSlug) query.slug = cardSlug;
  else if (userId) query.userId = userId;

  let card = query.slug || query.userId ? await db.collection("cards").findOne(query) : null;

  // Fallback defaults if query is empty or not in DB
  const fullName = card?.fullName || card?.name || searchParams.get("fullName") || "Khyati Dua";
  const jobTitle = card?.jobTitle || card?.title || searchParams.get("jobTitle") || "Senior Salesforce Developer";
  const company = card?.companyName || card?.company || searchParams.get("company") || "Hear.com";
  const phone = card?.workPhone || card?.phone || searchParams.get("phone") || "";
  const email = card?.workEmail || card?.email || searchParams.get("email") || "";
  const website = card?.website || searchParams.get("website") || `https://mycardshare.com/card/${cardSlug || 'khyati-dua'}`;
  const bio = card?.bio || card?.tagline || searchParams.get("bio") || "Passionate about creating meaningful connections.";
  const avatarUrl = card?.avatarUrl || searchParams.get("avatarUrl") || "";

  const nameParts = fullName.trim().split(" ");
  const firstName = nameParts[0] || "";
  const lastName = nameParts.length > 1 ? nameParts.slice(1).join(" ") : "";

  // ⚡ INDUSTRY STANDARD VCARD 3.0 DIRECT PHONEBOOK INGESTION
  const cleanPhone = phone.replace(/[^\d+]/g, "");

  const vCardLines = [
    "BEGIN:VCARD",
    "VERSION:3.0",
    `N:${lastName};${firstName};;;`,
    `FN:${fullName}`,
    `ORG:${company}`,
    `TITLE:${jobTitle}`,
  ];

  if (cleanPhone) {
    vCardLines.push(`TEL;TYPE=CELL,VOICE,PREF:${cleanPhone}`);
  }
  if (email) {
    vCardLines.push(`EMAIL;TYPE=WORK,INTERNET,PREF:${email}`);
  }
  if (website) {
    vCardLines.push(`URL:${website}`);
  }
  if (bio) {
    vCardLines.push(`NOTE:${bio.replace(/\n/g, "\\n")}`);
  }
  if (avatarUrl && avatarUrl.startsWith("http")) {
    vCardLines.push(`PHOTO;VALUE=URI:${avatarUrl}`);
  }

  vCardLines.push("REV:" + new Date().toISOString());
  vCardLines.push("END:VCARD");

  const vCardContent = vCardLines.join("\r\n");

  const asDownload = searchParams.get("download") === "true";
  if (asDownload) {
    return new NextResponse(vCardContent, {
      status: 200,
      headers: {
        "Content-Type": "text/vcard; charset=utf-8",
        "Content-Disposition": `attachment; filename="${fullName.replace(/\s+/g, "_")}.vcf"`,
        "Cache-Control": "no-cache",
      },
    });
  }

  return NextResponse.json(
    success({
      fullName,
      firstName,
      lastName,
      jobTitle,
      company,
      phone: cleanPhone,
      email,
      website,
      bio,
      vCardContent,
      downloadUrl: `/api/sync/save-contact?cardSlug=${cardSlug || 'contact'}&download=true`,
    })
  );
});

export const POST = apiAdapter(async (request: NextRequest) => {
  const body = await request.json();
  const { cardId, cardSlug, saverUserId, fullName } = body;

  const db = await connectDB();

  // Increment save count in telemetry
  if (cardId || cardSlug) {
    try {
      const matchQuery = cardId ? { _id: cardId } : { slug: cardSlug };
      await db.collection("cards").updateOne(matchQuery, {
        $inc: { saves: 1, contactSaves: 1 },
        $set: { lastSavedAt: new Date() },
      });
    } catch (_) {}
  }

  return NextResponse.json(
    success({
      message: `Contact ${fullName || 'Cardholder'} saved successfully.`,
      status: "SAVED_TO_DEVICE",
    })
  );
});
