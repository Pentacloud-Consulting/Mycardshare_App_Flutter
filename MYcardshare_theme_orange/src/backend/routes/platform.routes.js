import express from "express";
const router = express.Router();
import platformController from "../controllers/platform.controller";
import validate from "../middleware/validate";
import { platformActionSchema } from "../schemas/platform.schema";
import {
  verifyFirebaseToken,
  resolveUserContext,
  requireMasterAdmin,
} from "../middleware/auth";
import { firestoreDb, admin } from "../config/firebase";

// ALL PLATFORM ROUTES REQUIRE MASTER_ADMIN ROLE
router.use(verifyFirebaseToken(admin));
router.use(resolveUserContext(firestoreDb));
router.use(requireMasterAdmin);

router.get("/companies", platformController.listCompanies);
router.get("/super-admins", platformController.listSuperAdmins);
router.get("/companies/pending", platformController.listPendingCompanies);

router.patch(
  "/companies/:companyId/suspend",
  validate(platformActionSchema),
  platformController.suspendCompany,
);

router.patch(
  "/companies/:companyId/approval",
  validate(platformActionSchema),
  platformController.updateApproval,
);

export default router;
