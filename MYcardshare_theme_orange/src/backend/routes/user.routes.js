import express from "express";
const router = express.Router();
import userController from "../controllers/user.controller";
import { admin, firestoreDb } from "../config/firebase";
import {
  verifyFirebaseToken,
  resolveUserContext,
} from "../middleware/auth";

const auth = [verifyFirebaseToken(admin), resolveUserContext(firestoreDb)];

router.get("/me", ...auth, userController.getMe);
router.patch("/me", ...auth, userController.updateMe);

export default router;
