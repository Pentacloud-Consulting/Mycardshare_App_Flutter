import { NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { firestoreDb } from "@/backend/config/firebase";
import { success } from "@/backend/utils/apiResponse";

export async function GET(request) {
  try {
    const context = await resolveAuth(request);
    const uid = context.uid;

    if (!uid) {
      return NextResponse.json(
        success({
          summary: { activeCampaignsCount: 0, totalScansThisMonth: "0" },
          campaigns: [],
        })
      );
    }

    const snap = await firestoreDb
      .collection("users")
      .doc(uid)
      .collection("campaigns")
      .orderBy("createdAt", "desc")
      .get()
      .catch(() => ({ docs: [] }));

    const campaigns = snap.docs.map((d) => ({
      id: d.id,
      ...d.data(),
    }));

    return NextResponse.json(
      success({
        summary: {
          activeCampaignsCount: campaigns.filter((c) => c.status === "Active").length,
          totalScansThisMonth: "0",
        },
        campaigns,
      })
    );
  } catch (err) {
    return NextResponse.json(
      success({
        summary: { activeCampaignsCount: 0, totalScansThisMonth: "0" },
        campaigns: [],
      })
    );
  }
}

export async function POST(request) {
  try {
    const context = await resolveAuth(request);
    const uid = context.uid;
    const body = await request.json().catch(() => ({}));

    if (!uid) {
      return NextResponse.json({ success: false, error: "Unauthorized" }, { status: 401 });
    }

    const docRef = await firestoreDb
      .collection("users")
      .doc(uid)
      .collection("campaigns")
      .add({
        ...body,
        status: "Active",
        createdAt: new Date(),
      });

    return NextResponse.json(success({ campaignId: docRef.id }));
  } catch (err) {
    return NextResponse.json({ success: false, error: "Failed to create" }, { status: 500 });
  }
}
