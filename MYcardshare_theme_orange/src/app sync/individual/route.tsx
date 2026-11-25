import { NextRequest, NextResponse } from "next/server";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import userService from "@/backend/services/user.service";
import cardService from "@/backend/services/card.service";
import { connectDB } from "@/backend/config/db";
import { firestoreDb } from "@/backend/config/firebase";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

/**
 * UNIFIED INDIVIDUAL PORTAL SYNC (APP <-> WEB)
 *
 * GET /api/sync/individual
 * Populates all Flutter Individual UI Screens & Backend Stores:
 * 1. profile: Full card fields, contacts, social links, theme, isPublished, slug, cardUrl.
 * 2. analytics: Total views, unique visitors, shares, leads captured, click breakdown.
 * 3. leads: Captured contacts from "Exchange Contact" form.
 * 4. vault: Saved networking contacts from OCR card scans and QR exchanges.
 * 5. settings: Plan (Pro/Free), NFC toggle, public directory, QR logo.
 */
export const GET = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;

  // 1. Fetch User Record from Firestore (Source of truth for account)
  const user = await userService.getUser(uid);
  if (!user) {
    return NextResponse.json(
      fail("USER_NOT_FOUND", "User profile not found in database"),
      { status: 404 }
    );
  }

  // 2. Fetch Card Document from MongoDB
  const card = await cardService.getCardByUserId(uid);

  // 3. Fetch Leads & Vault from MongoDB
  let leadsList: any[] = [];
  let vaultList: any[] = [];
  let totalViews = card?.views || 0;
  let totalShares = card?.shares || 0;
  let clickBreakdown: Record<string, number> = {
    whatsapp: 0,
    linkedin: 0,
    phone: 0,
    email: 0,
    website: 0,
  };

  try {
    const db = await connectDB();

    // Fetch leads captured via this user's card
    leadsList = await db
      .collection("leads")
      .find({ userId: uid })
      .sort({ createdAt: -1 })
      .limit(50)
      .toArray();

    // Fetch personal saved vault cards
    vaultList = await db
      .collection("vault")
      .find({ userId: uid })
      .sort({ createdAt: -1 })
      .limit(50)
      .toArray();

    // If card has analytics clicks stored
    if (card?.clickBreakdown) {
      clickBreakdown = { ...clickBreakdown, ...card.clickBreakdown };
    }
  } catch (err) {
    console.warn("⚠️ [Individual Sync] Error fetching leads/vault:", err);
  }

  const slug = card?.cardSlug || user?.cardSlug || uid;
  const isPublished =
    card?.cardStatus === "Published" ||
    user?.cardStatus === "Published" ||
    card?.isPublished !== false;

  // Construct Social Links map
  const socialLinksMap: Record<string, any> = {};
  if (Array.isArray(card?.socialLinks)) {
    card.socialLinks.forEach((link: any) => {
      if (link && link.platform) {
        socialLinksMap[link.platform] = link.url || "";
      }
    });
  } else if (card?.socialLinks && typeof card.socialLinks === "object") {
    Object.assign(socialLinksMap, card.socialLinks);
  }

  // Fallback to direct fields
  ["linkedin", "whatsapp", "twitter", "instagram", "github", "facebook", "youtube"].forEach((p) => {
    if ((card as any)?.[p] && !socialLinksMap[p]) {
      socialLinksMap[p] = (card as any)[p];
    }
  });

  // Resolve Avatar: check every possible field name across MongoDB card + Firestore user.
  // Flutter app saves to Firestore as `profilePhoto`, MongoDB as `avatarUrl` — check both.
  const resolvedAvatar =
    card?.avatarUrl ||
    user?.profilePhoto ||    // ← Flutter saveProfile() writes this field
    user?.avatarUrl ||
    user?.photoURL ||
    user?.picture ||
    context.auth?.picture ||
    null;

  // Resolve Banner: same approach
  const resolvedBanner =
    card?.bannerUrl ||
    user?.bannerPhoto ||     // ← Flutter saveProfile() writes this field
    user?.bannerUrl ||
    null;

  // Auto-sync resolved avatar/banner into MongoDB card so future API calls
  // return the correct value without hitting Firestore each time.
  if (resolvedAvatar && (!card?.avatarUrl || card.avatarUrl !== resolvedAvatar)) {
    try {
      const db = await connectDB();
      await db.collection("cards").updateOne(
        { userId: uid },
        { $set: { avatarUrl: resolvedAvatar, lastUpdated: new Date() } },
        { upsert: false }
      );
    } catch (_) {}
  }
  if (resolvedBanner && (!card?.bannerUrl || card.bannerUrl !== resolvedBanner)) {
    try {
      const db = await connectDB();
      await db.collection("cards").updateOne(
        { userId: uid },
        { $set: { bannerUrl: resolvedBanner, lastUpdated: new Date() } },
        { upsert: false }
      );
    } catch (_) {}
  }

  return NextResponse.json(
    success({
      // 1. Digital Business Card Profile Model
      profile: {
        uid,
        fullName: card?.fullName || user?.fullName || context.auth?.name || "Digital Cardholder",
        email: card?.email || card?.workEmail || user?.email || context.auth?.email || "",
        phone: card?.phone || card?.workPhone || user?.phone || user?.phoneNumber || "",
        jobTitle: card?.jobTitle || user?.jobTitle || "",
        company: card?.companyName || user?.companyName || "",
        bio: card?.bio || user?.bio || "",
        cardSlug: slug,
        avatarUrl: resolvedAvatar,
        photoURL: resolvedAvatar,
        bannerUrl: resolvedBanner,
        themeColor: card?.themeColor || user?.themeColor || "#0052FF",
        isPublished,
        socialLinks: socialLinksMap,
        cardUrl: `https://mycardshare.com/card/${slug}`,
      },

      // 2. Analytics Model
      analytics: {
        totalViews,
        uniqueVisitors: Math.round(totalViews * 0.78),
        totalShares,
        leadsCaptured: leadsList.length,
        clickBreakdown,
      },

      // 3. Leads List
      leads: leadsList.map((l) => ({
        leadId: l._id.toString(),
        name: l.fullName || l.name || "Contact",
        email: l.email || "",
        phone: l.mobile || l.phone || "",
        note: l.notes || l.note || "",
        capturedAt: l.createdAt
          ? new Date(l.createdAt).toISOString()
          : new Date().toISOString(),
      })),

      // 4. Vault Saved Cards List
      vault: vaultList.map((v) => ({
        id: v._id.toString(),
        contactName: v.fullName || v.contactName || "Saved Contact",
        company: v.company || v.companyName || "",
        jobTitle: v.jobTitle || "",
        email: v.email || "",
        phone: v.phone || v.mobile || "",
        cardSlug: v.cardSlug || null,
        avatarUrl: v.cardImageUrl || v.avatarUrl || null,
      })),

      // 5. Settings Model
      settings: {
        plan: user?.subscriptionPlan || "Pro",
        enableNfc: user?.enableNfc ?? true,
        publicDirectoryListing: user?.publicDirectoryListing ?? true,
        qrCodeLogoEnabled: user?.qrCodeLogoEnabled ?? true,
      },

      syncedAt: new Date().toISOString(),
    })
  );
});

/**
 * PATCH /api/sync/individual
 *
 * Universal Individual Action Dispatcher:
 * - action: "update_profile" | "toggle_publish" | "add_vault_card" | "delete_vault_card"
 */
export const PATCH = apiAdapter(async (request: NextRequest) => {
  const context = await resolveAuth(request);
  const uid = context.uid;
  const body = await request.json();

  if (!body || typeof body !== "object") {
    return NextResponse.json(
      fail("INVALID_PAYLOAD", "Request body must be a valid JSON object"),
      { status: 400 }
    );
  }

  const db = await connectDB();
  const action = body.action || "update_profile";

  switch (action) {
    // ── 1. Toggle Publish Status ────────────────────────────────────
    case "toggle_publish": {
      const isPublished = Boolean(body.isPublished);
      const cardStatus = isPublished ? "Published" : "Draft";

      await firestoreDb.collection("users").doc(uid).set(
        { cardStatus, isPublished, updatedAt: new Date() },
        { merge: true }
      );

      await db.collection("cards").updateOne(
        { userId: uid },
        { $set: { cardStatus, isPublished, lastUpdated: new Date() } }
      );

      return NextResponse.json(
        success({ message: `Card ${isPublished ? "published" : "unpublished"} successfully` })
      );
    }

    // ── 2. Add Scanned Card to Vault ────────────────────────────────
    case "add_vault_card": {
      const cardData = body.card || body;
      if (!cardData.contactName && !cardData.fullName) {
        return NextResponse.json(
          fail("NAME_REQUIRED", "Contact name is required to save to vault"),
          { status: 400 }
        );
      }

      const vaultDoc = {
        userId: uid,
        fullName: cardData.contactName || cardData.fullName,
        company: cardData.company || "",
        jobTitle: cardData.jobTitle || "",
        email: cardData.email || "",
        phone: cardData.phone || "",
        cardSlug: cardData.cardSlug || null,
        cardImageUrl: cardData.avatarUrl || cardData.cardImageUrl || null,
        source: cardData.source || "manual",
        createdAt: new Date(),
      };

      const result = await db.collection("vault").insertOne(vaultDoc);
      return NextResponse.json(
        success({ message: "Card saved to vault successfully", id: result.insertedId })
      );
    }

    // ── 3. Delete Card from Vault ───────────────────────────────────
    case "delete_vault_card": {
      const { id } = body;
      if (!id) {
        return NextResponse.json(
          fail("ID_REQUIRED", "Vault card id is required"),
          { status: 400 }
        );
      }

      const { ObjectId } = await import("mongodb");
      await db.collection("vault").deleteOne({ _id: new ObjectId(id), userId: uid });
      return NextResponse.json(
        success({ message: "Card removed from vault successfully" })
      );
    }

    // ── 4. Update Profile & Card Settings (Default) ─────────────────
    default: {
      const updates = body.updates || body;
      delete updates.action;

      if (updates.cardSlug) {
        updates.cardSlug = String(updates.cardSlug)
          .trim()
          .toLowerCase()
          .replace(/[^a-z0-9-_]/g, "");
      }

      // Convert socialLinks object to array format for MongoDB if needed
      let formattedSocialLinks = updates.socialLinks;
      if (updates.socialLinks && !Array.isArray(updates.socialLinks) && typeof updates.socialLinks === "object") {
        formattedSocialLinks = Object.entries(updates.socialLinks).map(([platform, url], index) => ({
          id: String(index + 1),
          platform,
          url: String(url),
          label: platform.toUpperCase(),
        }));
      }

      // 1. Update Firestore Profile
      await userService.updateProfile(uid, updates);

      // 2. Update MongoDB Digital Business Card
      await cardService.createOrUpdateCard(uid, {
        fullName: updates.fullName,
        jobTitle: updates.jobTitle,
        companyName: updates.company,
        bio: updates.bio,
        cardSlug: updates.cardSlug,
        email: updates.email,
        phone: updates.phone,
        avatarUrl: updates.avatarUrl,
        bannerUrl: updates.bannerUrl,
        themeColor: updates.themeColor,
        socialLinks: formattedSocialLinks || [],
        cardStatus: updates.isPublished === false ? "Draft" : "Published",
        lastUpdated: new Date(),
      });

      return NextResponse.json(
        success({ message: "Digital business card and profile updated successfully" })
      );
    }
  }
});
