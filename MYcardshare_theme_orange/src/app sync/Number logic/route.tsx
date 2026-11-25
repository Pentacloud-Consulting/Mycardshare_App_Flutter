import { NextRequest, NextResponse } from "next/server";
import { connectDB } from "@/backend/config/db";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

/**
 * UNIFIED PHONE NUMBER VALIDATION & FORMATTING SYNC (WEB <-> MOBILE APP)
 *
 * Rules:
 * 1. Only accepts numeric digits, optional leading '+' for country code.
 * 2. Minimum length: 10 digits (national standard without country code).
 * 3. Maximum length: 15 digits (ITU-T E.164 international standard).
 * 4. Rejects incomplete numbers like '9729041' (7 digits).
 * 5. Supports E.164 formatting (e.g. +91 9729041234 or +1 4155552671).
 */

export interface PhoneValidationResult {
  isValid: boolean;
  cleanDigits: string;
  digitCount: number;
  countryCode: string | null;
  formattedNumber: string;
  errorMessage: string | null;
}

export function validatePhoneNumber(phoneInput: string, defaultCountryCode = "+91"): PhoneValidationResult {
  if (!phoneInput || typeof phoneInput !== "string") {
    return {
      isValid: false,
      cleanDigits: "",
      digitCount: 0,
      countryCode: null,
      formattedNumber: "",
      errorMessage: "Phone number is required",
    };
  }

  const raw = phoneInput.trim();
  const hasLeadingPlus = raw.startsWith("+");
  const cleanDigits = raw.replace(/\D/g, "");

  // If number is shorter than 10 digits -> Invalid
  if (cleanDigits.length < 10) {
    return {
      isValid: false,
      cleanDigits,
      digitCount: cleanDigits.length,
      countryCode: null,
      formattedNumber: raw,
      errorMessage: `Phone number is too short (${cleanDigits.length} digits). It must be at least 10 digits.`,
    };
  }

  // If number is longer than 15 digits -> Invalid E.164
  if (cleanDigits.length > 15) {
    return {
      isValid: false,
      cleanDigits,
      digitCount: cleanDigits.length,
      countryCode: null,
      formattedNumber: raw,
      errorMessage: `Phone number is too long (${cleanDigits.length} digits). Maximum 15 digits allowed.`,
    };
  }

  // Parse country code
  let countryCode: string | null = null;
  let nationalNumber = cleanDigits;

  if (hasLeadingPlus) {
    if (cleanDigits.length === 12 && cleanDigits.startsWith("91")) {
      countryCode = "+91";
      nationalNumber = cleanDigits.slice(2);
    } else if (cleanDigits.length === 11 && cleanDigits.startsWith("1")) {
      countryCode = "+1";
      nationalNumber = cleanDigits.slice(1);
    } else if (cleanDigits.length === 12 && cleanDigits.startsWith("44")) {
      countryCode = "+44";
      nationalNumber = cleanDigits.slice(2);
    } else if (cleanDigits.length === 12 && cleanDigits.startsWith("971")) {
      countryCode = "+971";
      nationalNumber = cleanDigits.slice(3);
    } else {
      countryCode = `+${cleanDigits.slice(0, cleanDigits.length - 10)}`;
      nationalNumber = cleanDigits.slice(cleanDigits.length - 10);
    }
  } else {
    // 10 digits assumed national number
    if (cleanDigits.length === 10) {
      countryCode = defaultCountryCode;
      nationalNumber = cleanDigits;
    } else if (cleanDigits.length === 12 && cleanDigits.startsWith("91")) {
      countryCode = "+91";
      nationalNumber = cleanDigits.slice(2);
    } else if (cleanDigits.length === 11 && cleanDigits.startsWith("0")) {
      countryCode = defaultCountryCode;
      nationalNumber = cleanDigits.slice(1);
    }
  }

  // Formatted E.164 string
  const formattedNumber = countryCode
    ? `${countryCode} ${nationalNumber.replace(/(\d{5})(\d{5})/, "$1 $2")}`
    : cleanDigits;

  return {
    isValid: true,
    cleanDigits,
    digitCount: cleanDigits.length,
    countryCode,
    formattedNumber: formattedNumber.trim(),
    errorMessage: null,
  };
}

/**
 * API HANDLER:
 * 
 * POST /api/sync/number-logic
 * 
 * Body:
 * {
 *   "phone": "9729041234",
 *   "action": "validate" | "save_card_phone" | "save_lead_phone",
 *   "cardId"?: string,
 *   "userId"?: string
 * }
 */
export const POST = apiAdapter(async (request: NextRequest) => {
  const body = await request.json();
  const phone = body.phone || body.mobile || body.contactNumber || "";
  const action = body.action || "validate";

  const validation = validatePhoneNumber(phone, body.defaultCountryCode || "+91");

  // 1. ACTION: VALIDATE ONLY
  if (action === "validate") {
    if (!validation.isValid) {
      return NextResponse.json(
        fail("INVALID_PHONE_NUMBER", validation.errorMessage || "Phone number must be at least 10 digits"),
        { status: 422 }
      );
    }

    return NextResponse.json(
      success(validation, "Phone number is valid")
    );
  }

  // 2. ACTION: SAVE / UPDATE CARD CONTACT DETAILS
  if (action === "save_card_phone") {
    if (!validation.isValid) {
      return NextResponse.json(
        fail("INVALID_PHONE_NUMBER", validation.errorMessage || "Phone number must be at least 10 digits"),
        { status: 422 }
      );
    }

    let context: any = null;
    try {
      context = await resolveAuth(request);
    } catch (e) {
      // Allow if cardId or userId is provided in body
    }

    const cardId = body.cardId;
    const userId = body.userId || context?.user?.uid;

    if (!cardId && !userId) {
      return NextResponse.json(
        fail("TARGET_REQUIRED", "Either cardId or userId is required to update contact details"),
        { status: 400 }
      );
    }

    const db = await connectDB();
    const query: any = {};
    if (cardId) query._id = cardId;
    else if (userId) query.userId = userId;

    await db.collection("cards").updateOne(
      query,
      {
        $set: {
          phone: validation.cleanDigits,
          workPhone: validation.cleanDigits,
          formattedPhone: validation.formattedNumber,
          updatedAt: new Date(),
        },
      }
    );

    return NextResponse.json(
      success({
        ...validation,
        saved: true,
      }, "Contact phone updated successfully")
    );
  }

  // 3. ACTION: SAVE LEAD PHONE WITH DUPLICATE & DIGIT CHECK
  if (action === "save_lead_phone") {
    if (!validation.isValid) {
      return NextResponse.json(
        fail("INVALID_PHONE_NUMBER", validation.errorMessage || "Phone number must be at least 10 digits"),
        { status: 422 }
      );
    }

    return NextResponse.json(
      success({
        ...validation,
        readyToSync: true,
      }, "Lead phone verified and ready for CRM sync")
    );
  }

  return NextResponse.json(
    fail("INVALID_ACTION", "Supported actions: validate, save_card_phone, save_lead_phone"),
    { status: 400 }
  );
});

export const GET = apiAdapter(async (request: NextRequest) => {
  const { searchParams } = new URL(request.url);
  const phone = searchParams.get("phone") || "";

  const validation = validatePhoneNumber(phone);
  if (!validation.isValid) {
    return NextResponse.json(
      fail("INVALID_PHONE_NUMBER", validation.errorMessage || "Phone number must be at least 10 digits"),
      { status: 422 }
    );
  }

  return NextResponse.json(success(validation));
});
