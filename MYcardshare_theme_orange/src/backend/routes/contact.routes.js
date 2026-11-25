import express from "express";
const router = express.Router();
import { connectDB } from "../config/db";
import { ObjectId } from "mongodb";
import { success, fail } from "../utils/apiResponse";

router.post("/", async (req, res) => {
  try {
    const data = req.body;
    if (!data.userId)
      return res.status(400).json(fail("VALIDATION_ERROR", "userId required"));
    const db = await connectDB();
    const result = await db
      .collection("scannedContacts")
      .insertOne({ ...data, createdAt: new Date() });
    res.json(success({ _id: result.insertedId }));
  } catch (error) {
    res.status(500).json(fail("DB_ERROR", error.message));
  }
});

router.get("/:userId", async (req, res) => {
  try {
    const db = await connectDB();
    const contacts = await db
      .collection("scannedContacts")
      .find({ userId: req.params.userId })
      .sort({ createdAt: -1 })
      .toArray();
    res.json(success(contacts));
  } catch (error) {
    res.status(500).json(fail("DB_ERROR", error.message));
  }
});

router.put("/:id", async (req, res) => {
  try {
    const db = await connectDB();
    delete req.body._id;
    const result = await db
      .collection("scannedContacts")
      .findOneAndUpdate(
        { _id: new ObjectId(req.params.id) },
        { $set: { ...req.body, updatedAt: new Date() } },
        { returnDocument: "after" },
      );
    res.json(success(result));
  } catch (error) {
    res.status(500).json(fail("DB_ERROR", error.message));
  }
});

router.delete("/:id", async (req, res) => {
  try {
    const db = await connectDB();
    await db
      .collection("scannedContacts")
      .deleteOne({ _id: new ObjectId(req.params.id) });
    res.json(success({ deleted: true }));
  } catch (error) {
    res.status(500).json(fail("DB_ERROR", error.message));
  }
});

export default router;
