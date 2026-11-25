import { firestoreDb } from "../config/firebase";
import { connectDB } from "../config/db";

const campaignService = {
  async createCampaign(companyId, campaignData) {
    const data = {
      ...campaignData,
      companyId,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    // 1. Write to enterprises/{companyId}/campaigns (read by Flutter mobile app)
    const entRef = await firestoreDb
      .collection("enterprises")
      .doc(companyId)
      .collection("campaigns")
      .add(data);

    // 2. Dual-write to companies/{companyId}/campaigns
    try {
      await firestoreDb
        .collection("companies")
        .doc(companyId)
        .collection("campaigns")
        .doc(entRef.id)
        .set(data);
    } catch (_) {}

    // 3. Mirror to MongoDB campaigns
    try {
      const db = await connectDB();
      await db.collection("campaigns").insertOne({
        ...data,
        _id: entRef.id,
      });
    } catch (_) {}

    return entRef.id;
  },

  async listCampaigns(companyId, options = {}) {
    const campaignsMap = new Map();

    // 1. Query enterprises/{companyId}/campaigns (used by Flutter mobile app)
    try {
      let entRef = firestoreDb.collection("enterprises").doc(companyId).collection("campaigns");
      if (options.activeOnly) entRef = entRef.where("isActive", "==", true);
      const entSnap = await entRef.get();
      for (const doc of entSnap.docs) {
        campaignsMap.set(doc.id, { _id: doc.id, id: doc.id, ...doc.data() });
      }
    } catch (_) {}

    // 2. Query companies/{companyId}/campaigns
    try {
      let compRef = firestoreDb.collection("companies").doc(companyId).collection("campaigns");
      if (options.activeOnly) compRef = compRef.where("isActive", "==", true);
      const compSnap = await compRef.get();
      for (const doc of compSnap.docs) {
        if (!campaignsMap.has(doc.id)) {
          campaignsMap.set(doc.id, { _id: doc.id, id: doc.id, ...doc.data() });
        }
      }
    } catch (_) {}

    // 3. Query MongoDB campaigns
    try {
      const db = await connectDB();
      const mongoQuery = { companyId };
      if (options.activeOnly) mongoQuery.isActive = true;
      const mongoList = await db.collection("campaigns").find(mongoQuery).toArray();
      for (const c of mongoList) {
        const idStr = c._id?.toString() || c.id;
        if (!campaignsMap.has(idStr)) {
          campaignsMap.set(idStr, { ...c, id: idStr, _id: idStr });
        }
      }
    } catch (_) {}

    return Array.from(campaignsMap.values());
  },

  async getCampaign(companyId, campaignId) {
    // Check enterprises first
    const entDoc = await firestoreDb
      .collection("enterprises")
      .doc(companyId)
      .collection("campaigns")
      .doc(campaignId)
      .get();
    if (entDoc.exists) return { id: entDoc.id, ...entDoc.data() };

    const compDoc = await firestoreDb
      .collection("companies")
      .doc(companyId)
      .collection("campaigns")
      .doc(campaignId)
      .get();
    if (compDoc.exists) return { id: compDoc.id, ...compDoc.data() };

    throw new Error("CAMPAIGN_NOT_FOUND");
  },

  async updateCampaign(companyId, campaignId, updates) {
    const patchData = {
      ...updates,
      updatedAt: new Date(),
    };

    try {
      await firestoreDb
        .collection("enterprises")
        .doc(companyId)
        .collection("campaigns")
        .doc(campaignId)
        .set(patchData, { merge: true });
    } catch (_) {}

    try {
      await firestoreDb
        .collection("companies")
        .doc(companyId)
        .collection("campaigns")
        .doc(campaignId)
        .set(patchData, { merge: true });
    } catch (_) {}

    try {
      const db = await connectDB();
      await db.collection("campaigns").updateOne(
        { $or: [{ _id: campaignId }, { id: campaignId }] },
        { $set: patchData }
      );
    } catch (_) {}

    return true;
  },

  async deleteCampaign(companyId, campaignId) {
    try {
      await firestoreDb
        .collection("enterprises")
        .doc(companyId)
        .collection("campaigns")
        .doc(campaignId)
        .delete();
    } catch (_) {}

    try {
      await firestoreDb
        .collection("companies")
        .doc(companyId)
        .collection("campaigns")
        .doc(campaignId)
        .delete();
    } catch (_) {}

    try {
      const db = await connectDB();
      await db.collection("campaigns").deleteOne({
        $or: [{ _id: campaignId }, { id: campaignId }]
      });
    } catch (_) {}

    return true;
  },
};

export default campaignService;
