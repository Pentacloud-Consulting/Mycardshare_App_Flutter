import express from "express";
const router = express.Router();
import leadController from "../controllers/lead.controller";
import { admin, firestoreDb } from "../config/firebase";
import {
  verifyFirebaseToken,
  resolveUserContext,
  checkCompanySuspended,
} from "../middleware/auth";

// Middleware stack for Lead routes
const leadAuth = [
  verifyFirebaseToken(admin),
  resolveUserContext(firestoreDb),
  checkCompanySuspended(firestoreDb),
];

// Lead Management Routes
router.post("/create", ...leadAuth, leadController.createLead);
router.get("/", ...leadAuth, leadController.listLeads);
router.get("/export", ...leadAuth, leadController.exportLeads);
router.get("/crm-logs", ...leadAuth, leadController.getCrmLogs);
router.patch("/:leadId", ...leadAuth, leadController.updateLead);
router.delete("/:leadId", ...leadAuth, leadController.deleteLead);

export default router;
