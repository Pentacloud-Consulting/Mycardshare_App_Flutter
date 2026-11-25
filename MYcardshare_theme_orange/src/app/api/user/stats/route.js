import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { connectDB } from "@/backend/config/db";
import { success } from "@/backend/utils/apiResponse";

export const GET = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const userId = context.uid;

  const db = await connectDB();

  // 1. Fetch Card Stats (Views & Status)
  const card = await db.collection("cards").findOne({ userId });

  // 2. Fetch Connections Count (Leads)
  const connectionsCount = await db.collection("leads").countDocuments({
    // In legacy, leads might be tied to companyId or userId
    userId: userId,
  });

  const stats = {
    views: card?.views || 0,
    cardStatus: card?.cardStatus || "Draft",
    connectionsCount: connectionsCount || 0,
    // Add trends if available or simulate for UI feel
    viewsTrend: card?.viewsTrend || "+0%",
    connectionsTrend: "+0%",
  };

  return NextResponse.json(success(stats));
});
