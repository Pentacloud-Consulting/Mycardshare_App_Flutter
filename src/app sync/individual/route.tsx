import { NextRequest, NextResponse } from "next/server";

/**
 * Next.js Web Backend Sync Route for Individual Profile & Digital Card
 * Endpoint: /api/sync/individual
 *
 * Implements Hierarchical Photo Resolution:
 * card.avatarUrl ➔ user.avatarUrl ➔ user.photoURL ➔ Google picture
 * Prevents missing profile pictures on My Profile & View Card.
 */

interface UserProfile {
  uid: string;
  fullName: string;
  email: string;
  avatarUrl?: string;
  photoURL?: string;
  picture?: string;
  profilePhoto?: string;
  bannerPhoto?: string;
  jobTitle?: string;
  company?: string;
  companyName?: string;
  phone?: string;
  phoneNumber?: string;
  website?: string;
  websiteUrl?: string;
  shortBio?: string;
  networkingStatus?: string;
  cardSlug?: string;
  templateStyle?: string;
}

// In-memory mock store for users & digital business cards
const userProfileStore: Map<string, UserProfile> = new Map([
  [
    "demo_tushti",
    {
      uid: "demo_tushti",
      fullName: "Tushti Dua",
      email: "tushti@mycardshare.com",
      avatarUrl:
        "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&auto=format&fit=crop&q=80",
      jobTitle: "Member",
      company: "MyCardShare Member",
      companyName: "MyCardShare Member",
      networkingStatus: "Actively Networking",
      cardSlug: "tushti-dua",
    },
  ],
]);

export async function GET(request: NextRequest) {
  try {
    const authHeader = request.headers.get("authorization") || "";
    const token = authHeader.replace(/^Bearer\s+/i, "").trim();

    // In a real Firebase Admin setup:
    // const decodedToken = await admin.auth().verifyIdToken(token);
    // const uid = decodedToken.uid;
    // const googlePhoto = decodedToken.picture;

    const uid = token || "demo_tushti";

    let profile = userProfileStore.get(uid);

    if (!profile) {
      // Default / new profile creation with Google fallback
      profile = {
        uid,
        fullName: "Tushti Dua",
        email: "tushti@testmail.com",
        avatarUrl:
          "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&auto=format&fit=crop&q=80",
        photoURL:
          "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&auto=format&fit=crop&q=80",
        jobTitle: "Member",
        company: "MyCardShare Member",
        companyName: "MyCardShare Member",
        networkingStatus: "Actively Networking",
        cardSlug: "tushti-dua",
      };
      userProfileStore.set(uid, profile);
    }

    // ⚡ Hierarchical Resolution:
    // card.avatarUrl ➔ user.avatarUrl ➔ user.photoURL ➔ Google picture
    const resolvedAvatar =
      profile.avatarUrl ||
      profile.profilePhoto ||
      profile.photoURL ||
      profile.picture ||
      null;

    const resolvedProfile = {
      ...profile,
      avatarUrl: resolvedAvatar,
      profilePhoto: resolvedAvatar,
      photoURL: resolvedAvatar,
      picture: resolvedAvatar,
    };

    return NextResponse.json({
      success: true,
      data: {
        profile: resolvedProfile,
        card: resolvedProfile,
      },
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        success: false,
        error: { message: error?.message || "Failed to sync user profile." },
      },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { uid, avatarUrl, photoURL, fullName, jobTitle, company } = body;

    const existing: UserProfile = userProfileStore.get(uid) || {
      uid: uid || "demo_tushti",
      fullName: fullName || "User",
      email: "",
    };

    const resolvedPhoto = avatarUrl || photoURL || existing.avatarUrl;

    const updated: UserProfile = {
      ...existing,
      ...body,
      avatarUrl: resolvedPhoto,
      photoURL: resolvedPhoto,
      profilePhoto: resolvedPhoto,
      updatedAt: new Date().toISOString(),
    };

    userProfileStore.set(updated.uid, updated);

    return NextResponse.json({
      success: true,
      message: "Profile photo and card successfully synced.",
      data: { profile: updated },
    });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: { message: error?.message || "Internal server error." } },
      { status: 500 }
    );
  }
}
