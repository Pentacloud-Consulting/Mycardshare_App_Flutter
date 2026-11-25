import { connectDB } from "../config/db";
import { firestoreDb } from "../config/firebase";
import companyService from "./company.service";

const cardService = {
  async getCardBySlug(slug) {
    const db = await connectDB();
    // Try matching by custom slug first
    let card = await db.collection("cards").findOne({ cardSlug: slug });
    
    // If not found, try matching by userId as a fallback
    if (!card) {
      card = await db.collection("cards").findOne({ userId: slug });
    }

    // If not found, try Firestore fallback
    if (!card && firestoreDb) {
      try {
        const uSnap = await firestoreDb.collection("users").where("cardSlug", "==", slug).limit(1).get();
        if (!uSnap.empty) {
          const uid = uSnap.docs[0].id;
          card = await db.collection("cards").findOne({ userId: uid });
        }
      } catch (e) {
        console.warn("Could not fetch card from Firestore fallback", e);
      }
    }

    // Normalize Published status
    if (card && (card.cardStatus === "Published" || card.isPublished === true || card.cardStatus === "active" || card.cardStatus === "Live")) {
      card.cardStatus = "Published";
    }

    // Ensure cardLayout is present (fallback to Firestore user profile if legacy card record)
    if (card && !card.cardLayout && card.userId && firestoreDb) {
      try {
        const uSnap = await firestoreDb.collection("users").doc(card.userId).get();
        if (uSnap.exists && uSnap.data().cardLayout) {
          card.cardLayout = uSnap.data().cardLayout;
        }
      } catch (e) {
        console.warn("Could not fetch cardLayout from user doc", e);
      }
    }
    
    // Inject workspace branding if card belongs to a company
    const targetCompanyId = card && (card.companyId || card.workspaceId);
    if (targetCompanyId) {
      try {
        const company = await companyService.getCompany(targetCompanyId);
        if (company) {
          if (company.companyBanner) card.bannerUrl = company.companyBanner;
          if (company.companyLogo) card.companyLogo = company.companyLogo;
          card.companyName = company.companyName;
        }
      } catch (e) {
        console.warn("Could not fetch company branding for public card", e);
      }
    }

    return card;
  },

  async incrementViews(cardId) {
    const db = await connectDB();
    const result = await db.collection("cards").findOneAndUpdate(
      { _id: cardId },
      { $inc: { views: 1 } },
      { returnDocument: "after" }
    );
    const card = result?.value || result;
    if (card?.companyId) {
      try {
        const { firestoreDb } = await import("../config/firebase");
        if (firestoreDb) {
          const { FieldValue } = await import("firebase-admin/firestore");
          // Dual sync to Firestore enterprise doc
          firestoreDb.collection("enterprises").doc(card.companyId).set({
            views: FieldValue.increment(1),
            lastViewedAt: FieldValue.serverTimestamp()
          }, { merge: true }).catch(() => {});

          // Dual sync to employee doc if userId exists
          if (card.userId) {
            firestoreDb.collection("enterprises").doc(card.companyId)
              .collection("employees").doc(card.userId)
              .set({
                views: FieldValue.increment(1),
                updatedAt: FieldValue.serverTimestamp()
              }, { merge: true }).catch(() => {});

            firestoreDb.collection("users").doc(card.userId)
              .set({
                views: FieldValue.increment(1),
                updatedAt: FieldValue.serverTimestamp()
              }, { merge: true }).catch(() => {});
          }
        }
      } catch (_) {}
    }
  },

  async getCardByUserId(userId) {
    const db = await connectDB();
    return await db.collection("cards").findOne({ userId });
  },

  async createOrUpdateCard(userId, cardData) {
    const db = await connectDB();
    const collection = db.collection("cards");

    const existing = await collection.findOne({ userId });

    const cardDoc = {
      ...cardData,
      userId,
      updatedAt: new Date(),
    };

    if (existing) {
      await collection.updateOne({ userId }, { $set: cardDoc });
      return { id: existing._id, created: false };
    } else {
      cardDoc.createdAt = new Date();
      const result = await collection.insertOne(cardDoc);
      return { id: result.insertedId, created: true };
    }
  },

  async deleteCard(userId) {
    const db = await connectDB();
    return await db.collection("cards").deleteOne({ userId });
  },

  async cleanupExpiredCards() {
    const db = await connectDB();
    const collection = db.collection("cards");
    const now = new Date();
    const result = await collection.deleteMany({
      isDeleted: true,
      deleteExpiresAt: { $lt: now.toISOString() },
    });
    return result.deletedCount;
  },
};

export default cardService;
