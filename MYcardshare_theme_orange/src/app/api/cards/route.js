import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import cardService from "@/backend/services/card.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Manage current user's card
 * PATCH /api/cards
 * DELETE /api/cards
 */

export const PATCH = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const cardData = await request.json();

  const result = await cardService.createOrUpdateCard(context.uid, cardData);

  return NextResponse.json(
    success({
      message: result.created ? "Card created" : "Card updated",
      id: result.id,
    }),
  );
});

export const DELETE = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  await cardService.deleteCard(context.uid);

  return NextResponse.json(success({ message: "Card deleted" }));
});
