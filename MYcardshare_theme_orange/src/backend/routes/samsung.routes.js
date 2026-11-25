import express from "express";
const router = express.Router();
import { firestoreDb } from "../config/firebase";
import samsungLib from "../utils/samsungLib";
import { success, fail } from "../utils/apiResponse";

const cardDataStore = {};

// Cleanup memory store every hour
setInterval(
  () => {
    const now = Date.now();
    Object.keys(cardDataStore).forEach((key) => {
      if (now - cardDataStore[key].savedAt > 24 * 60 * 60 * 1000)
        delete cardDataStore[key];
    });
  },
  60 * 60 * 1000,
);

router.post("/save-card-data", async (req, res) => {
  const { refId, formData } = req.body;
  if (!refId || !formData)
    return res
      .status(400)
      .json(fail("MISSING_DATA", "refId and formData are required"));

  cardDataStore[refId] = { ...formData, savedAt: Date.now() };

  if (firestoreDb) {
    try {
      await firestoreDb
        .collection("samsung_cards")
        .doc(refId)
        .set({ ...formData, savedAt: Date.now() });
    } catch (e) {
      console.error("Firestore save failed", e);
    }
  }
  res.json(success({ refId }));
});

router.get("/cards/:cardId/:refId", async (req, res) => {
  const { refId } = req.params;
  let userData = cardDataStore[refId];

  if (!userData && firestoreDb) {
    const doc = await firestoreDb.collection("samsung_cards").doc(refId).get();
    if (doc.exists) userData = doc.data();
  }

  const safe = userData || { fullName: "User", companyName: "Pentacloud" };
  const now = Date.now();

  res.json(
    success({
      card: {
        type: "generic",
        data: [
          {
            refId,
            createdAt: now,
            updatedAt: now,
            attributes: {
              title: "Digital Business Card",
              providerName: safe.companyName,
              text1: safe.fullName,
              text2: safe.jobTitle,
              text5: safe.workEmail,
              text6: safe.workPhone,
            },
          },
        ],
      },
    }),
  );
});

router.post("/cards/:cardId/:refId", (req, res) =>
  res.json(success({ resultCode: "0", resultMessage: "SUCCESS" })),
);

router.post("/create-pass", async (req, res) => {
  try {
    const cardData = req.body;
    if (!cardData.fullName || !cardData.publicCardUrl)
      return res
        .status(400)
        .json(fail("VALIDATION_ERROR", "Missing fullName or publicCardUrl"));

    const cdata = samsungLib.createSamsungCdata(cardData);
    const url = samsungLib.generateSamsungWalletUrl(cdata);
    res.json(success({ addToWalletUrl: url }));
  } catch (error) {
    res.status(500).json(fail("SAMSUNG_ERROR", error.message));
  }
});

export default router;
