import express from "express";
const router = express.Router();
import ocrController from "../controllers/ocr.controller";
import { admin, firestoreDb } from "../config/firebase";
import { verifyFirebaseToken } from "../middleware/auth";

router.post("/extract", verifyFirebaseToken(admin), ocrController.extract);

export default router;
