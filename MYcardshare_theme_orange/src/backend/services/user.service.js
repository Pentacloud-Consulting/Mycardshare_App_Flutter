import { firestoreDb, admin } from "../config/firebase";
import { connectDB } from "../config/db";
import cardService from "./card.service";
import storageService from "./storage.service";
import companyService from "./company.service";
import { AppError } from "../utils/api-adapter";

const userService = {
  async getUser(uid) {
    if (!firestoreDb) throw new Error("FIRESTORE_NOT_INITIALIZED");
    const doc = await firestoreDb.collection("users").doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  },

  async updateProfile(uid, data) {
    if (!firestoreDb) throw new Error("FIRESTORE_NOT_INITIALIZED");

    // 1. Update Firestore
    const firestoreData = { ...data };
    if (firestoreData.cardStatus) {
      firestoreData.isPublished = (firestoreData.cardStatus === 'Published');
      firestoreData.profileStatus = firestoreData.cardStatus.toLowerCase();
    }

    // Validation: Required fields
    if (firestoreData.fullName !== undefined && (!firestoreData.fullName || firestoreData.fullName.trim() === "")) {
      throw new Error("FULL_NAME_REQUIRED");
    }

    // Safeguard: strip massive base64 strings if they ever slip through.
    // The dedicated /api/user/upload endpoint is the only correct path
    // for image bytes, so a data: URL here is always a client bug.
    if (
      typeof firestoreData.avatarUrl === "string" &&
      firestoreData.avatarUrl.startsWith("data:")
    ) {
      console.warn(
        "[User Service] Stripping base64 avatarUrl from profile update",
      );
      delete firestoreData.avatarUrl;
    }
    if (
      typeof firestoreData.bannerUrl === "string" &&
      firestoreData.bannerUrl.startsWith("data:")
    ) {
      console.warn(
        "[User Service] Stripping base64 bannerUrl from profile update",
      );
      delete firestoreData.bannerUrl;
    }

    // Firestore rejects `undefined` values outright, so drop them.
    Object.keys(firestoreData).forEach((key) => {
      if (firestoreData[key] === undefined) delete firestoreData[key];
    });

    const existingUserSnap = await firestoreDb.collection("users").doc(uid).get();
    const existingUser = existingUserSnap.exists ? existingUserSnap.data() : {};

    // Enforce Company Name for Employees
    if (existingUser.companyId && existingUser.role === "employee") {
      const company = await companyService.getCompany(existingUser.companyId);
      if (company && company.companyName) {
        firestoreData.companyName = company.companyName;
        data.companyName = company.companyName;
      }
    }

    // Slug Uniqueness Check — reject if another user already owns it
    if (firestoreData.cardSlug) {
      try {
        const db = await connectDB();
        const cardsCollection = db.collection("cards");
        const slug = firestoreData.cardSlug.trim().toLowerCase();
        firestoreData.cardSlug = slug;
        data.cardSlug = slug;

        // Check MongoDB for another user with the same slug
        const existing = await cardsCollection.findOne({ cardSlug: slug, userId: { $ne: uid } });
        if (existing) {
          throw new Error("SLUG_TAKEN");
        }

        // Also check Firestore for another user with the same slug
        const firestoreConflict = await firestoreDb
          .collection("users")
          .where("cardSlug", "==", slug)
          .limit(2)
          .get();
        const conflictDocs = firestoreConflict.docs.filter((d) => d.id !== uid);
        if (conflictDocs.length > 0) {
          throw new Error("SLUG_TAKEN");
        }
      } catch (err) {
        if (err.message === "SLUG_TAKEN") {
          throw new AppError("This URL slug is already taken. Please choose a different one.", 400);
        }
        console.error("⚠️ [User Service] Slug uniqueness check failed:", err);
      }
    }

    await firestoreDb
      .collection("users")
      .doc(uid)
      .set(
        {
          ...firestoreData,
          updatedAt: new Date(),
        },
        { merge: true },
      );

    // 2. Sync to MongoDB (for Dashboard Stats/Legacy compatibility)
    try {
      const db = await connectDB();

      // Map UI names to MongoDB field names if necessary
      const mongoUpdate = {
        companyId: data.companyId || existingUser.companyId,
        role: data.role || existingUser.role,
        status: data.status || existingUser.status || "active",
        profileStatus: data.profileStatus || existingUser.profileStatus || "draft",
        fullName: data.fullName,
        jobTitle: data.jobTitle,
        companyName: data.companyName,
        bio: data.bio,
        cardSlug: data.cardSlug,
        cardLayout: data.cardLayout,
        workPhone: data.workPhone,
        workEmail: data.workEmail,
        website: data.website,
        address: data.address,
        city: data.city,
        country: data.country,
        avatarUrl: data.avatarUrl,
        bannerUrl: data.bannerUrl,
        themeColor: data.themeColor,
        skills: data.skills,
        linkedin: data.linkedin,
        twitter: data.twitter,
        instagram: data.instagram,
        facebook: data.facebook,
        whatsapp: data.whatsapp,
        github: data.github,
        youtube: data.youtube,
        calendly: data.calendly,
        networkingStatus: data.networkingStatus,
        focusAreas: data.focusAreas,
        primaryHQ: data.primaryHQ,
        cardStatus: data.cardStatus,
        experience: data.experience,
        resumeUrl: data.resumeUrl,
        brochureUrl: data.brochureUrl,
        lastUpdated: new Date(),
      };

      // Remove undefined fields
      Object.keys(mongoUpdate).forEach(
        (key) => mongoUpdate[key] === undefined && delete mongoUpdate[key],
      );

      await db.collection("cards").updateOne(
        { userId: uid },
        {
          $set: mongoUpdate,
          $setOnInsert: { createdAt: new Date(), views: 0 },
        },
        { upsert: true },
      );
    } catch (mongoErr) {
      console.error("⚠️ [User Service] MongoDB sync failed:", mongoErr);
      // Don't throw, Firestore is primary
    }

    return true;
  },

  /**
   * Upload a profile image (avatar or banner) and persist its public URL to
   * both Firestore (primary) and MongoDB (best-effort mirror).
   *
   * Accepts any of:
   *   • a `data:image/*;base64,…` data URL (legacy JSON uploader)
   *   • a raw `Buffer` + `ext` / `contentType` (multipart FormData uploader)
   *
   * All filesystem / GCS branching is delegated to `storage.service` — this
   * method is purely concerned with the user domain (Firestore write,
   * Mongo mirror, field mapping).
   */
  async uploadImage(uid, type, input) {
    if (!firestoreDb) throw new Error("FIRESTORE_NOT_INITIALIZED");
    if (!uid) throw new Error("MISSING_USER");
    if (type !== "avatar" && type !== "banner" && type !== "logo") {
      throw new Error(`INVALID_IMAGE_TYPE: ${type}`);
    }

    const folder = type === "avatar" ? "user-avatars" : type === "logo" ? "user-logos" : "user-banners";
    const { url: publicUrl, backend } = await storageService.putImage({
      folder,
      baseName: `${uid}_${type}`,
      input,
    });
    console.log(
      `[user.uploadImage] stored ${type} for ${uid} via ${backend} → ${publicUrl}`,
    );

    const field = type === "avatar" ? "avatarUrl" : type === "logo" ? "companyLogo" : "bannerUrl";
    try {
      await firestoreDb
        .collection("users")
        .doc(uid)
        .set(
          {
            [field]: publicUrl,
            updatedAt: new Date(),
          },
          { merge: true },
        );
    } catch (err) {
      console.error("❌ [user.uploadImage] Firestore write failed:", err);
      throw new Error(`FIRESTORE_WRITE_FAILED: ${err.message}`);
    }

    // Mirror to MongoDB — best-effort so a Mongo outage doesn't break uploads.
    try {
      const db = await connectDB();
      await db.collection("cards").updateOne(
        { userId: uid },
        {
          $set: { [field]: publicUrl, lastUpdated: new Date() },
          $setOnInsert: { createdAt: new Date(), views: 0 },
        },
        { upsert: true },
      );
    } catch (mongoErr) {
      console.error(
        "⚠️ [user.uploadImage] MongoDB mirror failed:",
        mongoErr?.message || mongoErr,
      );
    }

    return publicUrl;
  },

  /**
   * Upload a document (resume or brochure) and persist its public URL to
   * both Firestore (primary) and MongoDB (best-effort mirror).
   *
   * @param {string} uid     Firebase user ID
   * @param {string} type    "resume" or "brochure"
   * @param {{ buffer: Buffer, ext: string, contentType: string }} input
   * @returns {Promise<string>} The public URL of the uploaded document
   */
  async uploadDocument(uid, type, input) {
    if (!firestoreDb) throw new Error("FIRESTORE_NOT_INITIALIZED");
    if (!uid) throw new Error("MISSING_USER");
    if (type !== "resume" && type !== "brochure") {
      throw new Error(`INVALID_DOCUMENT_TYPE: ${type}`);
    }

    const { putDocument } = await import("./storage.service.js");
    const folder = "user-documents";
    const { url: publicUrl, backend } = await putDocument({
      folder,
      baseName: `${uid}_${type}`,
      input,
    });
    console.log(
      `[user.uploadDocument] stored ${type} for ${uid} via ${backend} → ${publicUrl}`,
    );

    const field = type === "resume" ? "resumeUrl" : "brochureUrl";
    try {
      await firestoreDb
        .collection("users")
        .doc(uid)
        .set(
          {
            [field]: publicUrl,
            updatedAt: new Date(),
          },
          { merge: true },
        );
    } catch (err) {
      console.error("❌ [user.uploadDocument] Firestore write failed:", err);
      throw new Error(`FIRESTORE_WRITE_FAILED: ${err.message}`);
    }

    // Mirror to MongoDB
    try {
      const db = await connectDB();
      await db.collection("cards").updateOne(
        { userId: uid },
        {
          $set: { [field]: publicUrl, lastUpdated: new Date() },
          $setOnInsert: { createdAt: new Date(), views: 0 },
        },
        { upsert: true },
      );
    } catch (mongoErr) {
      console.error(
        "⚠️ [user.uploadDocument] MongoDB mirror failed:",
        mongoErr?.message || mongoErr,
      );
    }

    return publicUrl;
  },

  /**
   * Permanent account deletion
   */
  async deleteUser(uid) {
    if (!firestoreDb || !admin) throw new Error("FIREBASE_NOT_INITIALIZED");

    console.log(`🗑️ [User Service] Starting deletion for user: ${uid}`);

    // 1. Delete Card from MongoDB
    try {
      await cardService.deleteCard(uid);
      console.log(`✅ MongoDB card deleted for ${uid}`);
    } catch (err) {
      console.error(`⚠️ Error deleting MongoDB card for ${uid}:`, err.message);
    }

    // 2. Delete Firestore Document
    await firestoreDb.collection("users").doc(uid).delete();
    console.log(`✅ Firestore user document deleted for ${uid}`);

    // 3. Delete Firebase Auth User
    await admin.auth().deleteUser(uid);
    console.log(`✅ Firebase Auth user deleted for ${uid}`);

    return true;
  },
};

export default userService;
