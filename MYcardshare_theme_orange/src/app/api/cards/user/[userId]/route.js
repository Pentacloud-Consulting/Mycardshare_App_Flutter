import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import cardService from "@/backend/services/card.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * GET cards for a specific user
 * GET /api/cards/user/[userId]
 */
export const GET = apiAdapter(async (request, { params }) => {
  await resolveAuth(request); // Verify logged in
  const { userId } = await params;
  const cards = await cardService.getCardByUserId(userId);

  return NextResponse.json(success(cards ? [cards] : []));
});
