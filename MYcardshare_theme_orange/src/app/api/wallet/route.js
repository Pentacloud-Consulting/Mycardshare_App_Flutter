import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import walletService from "@/backend/services/wallet.service";
import { success } from "@/backend/utils/apiResponse";

/**
 * Wallet API Health
 * GET /api/wallet
 */
export const GET = apiAdapter(async () => {
  const store = walletService.getImageStore();
  return NextResponse.json(
    success({
      status: "online",
      service: "Wallet API",
      imagesStored: store.size,
      keys: Array.from(store.keys()),
    }),
  );
});
