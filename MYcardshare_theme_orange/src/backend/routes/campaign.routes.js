import express from "express";
const router = express.Router();
import campaignController from "../controllers/campaign.controller";
import { admin, firestoreDb } from "../config/firebase";
import {
  verifyFirebaseToken,
  resolveUserContext,
  checkCompanySuspended,
} from "../middleware/auth";

const auth = [verifyFirebaseToken(admin), resolveUserContext(firestoreDb)];

const companyAuth = [...auth, checkCompanySuspended(firestoreDb)];

router.post("/", ...companyAuth, campaignController.createCampaign);
router.get("/", ...auth, campaignController.listCampaigns);
router.patch("/:campaignId", ...companyAuth, campaignController.updateCampaign);
router.delete(
  "/:campaignId",
  ...companyAuth,
  campaignController.deleteCampaign,
);

export default router;
