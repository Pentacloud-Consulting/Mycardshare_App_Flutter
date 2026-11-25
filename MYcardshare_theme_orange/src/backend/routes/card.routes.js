import express from "express";
const router = express.Router();
import cardController from "../controllers/card.controller";
import { admin, firestoreDb } from "../config/firebase";
import {
  verifyFirebaseToken,
  resolveUserContext,
} from "../middleware/auth";

const auth = [verifyFirebaseToken(admin), resolveUserContext(firestoreDb)];

router.get("/public/:slug", cardController.getCard); // Public view
router.get("/user/:userId", ...auth, cardController.listCardsByUserId);
router.patch("/:userId?", ...auth, cardController.updateCard);
router.delete("/:userId?", ...auth, cardController.deleteCard);

export default router;
