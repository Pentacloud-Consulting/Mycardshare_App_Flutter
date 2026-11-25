import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import cardService from "@/backend/services/card.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Public lookup for Digital Business Cards by slug
 * GET /api/cards/public/[slug]
 */
export const GET = apiAdapter(async (request, { params }) => {
  const { slug } = await params;
  const card = await cardService.getCardBySlug(slug);

  if (!card) {
    return NextResponse.json(
      { success: false, error: "Card not found" },
      { status: 404 },
    );
  }

  // Increment views in background (don't await to keep response fast)
  cardService.incrementViews(card._id).catch(err => 
    console.error("Failed to increment card views:", err)
  );

  return NextResponse.json(success(card));
});
