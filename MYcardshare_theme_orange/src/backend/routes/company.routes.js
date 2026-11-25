import express from "express";
const router = express.Router();
import companyController from "../controllers/company.controller";
import validate from "../middleware/validate";
import {
  createCompanySchema,
  crmConfigSchema,
  updateCompanySchema,
  voucherSchema,
} from "../schemas/company.schema";
import {
  verifyFirebaseToken,
  checkCompanySuspended,
  verifyCompanyAccess,
  requireAdmin,
  checkSubscription,
  resolveUserContext,
} from "../middleware/auth";
import { firestoreDb, admin } from "../config/firebase";

// PUBLIC ROUTES
router.get("/:companyId/public-branding", companyController.getPublicBranding);
router.post(
  "/validate-voucher",
  validate(voucherSchema),
  companyController.validateVoucher,
);

// SECURE ROUTES
router.post(
  "/create",
  validate(createCompanySchema),
  companyController.createCompany,
); // Admin signup

// All subsequent routes require Authentication
router.use(verifyFirebaseToken(admin));
router.use(resolveUserContext(firestoreDb));

router.patch(
  "/crm-config",
  checkCompanySuspended(firestoreDb),
  validate(crmConfigSchema),
  companyController.updateCrmConfig,
);

router.get(
  "/:companyId",
  verifyCompanyAccess(firestoreDb),
  companyController.getCompany,
);

router.put(
  "/:companyId",
  verifyCompanyAccess(firestoreDb),
  requireAdmin,
  checkSubscription(firestoreDb),
  validate(updateCompanySchema),
  companyController.updateCompany,
);

router.post(
  "/:companyId/logo",
  verifyCompanyAccess(firestoreDb),
  requireAdmin,
  companyController.uploadLogo,
);

router.post(
  "/:companyId/banner",
  verifyCompanyAccess(firestoreDb),
  requireAdmin,
  companyController.uploadBanner,
);

router.get(
  "/:companyId/employees",
  verifyCompanyAccess(firestoreDb),
  requireAdmin,
  companyController.listEmployees,
);

router.get(
  "/:companyId/employees/:userId",
  verifyCompanyAccess(firestoreDb),
  requireAdmin,
  companyController.getEmployeeProfile,
);

router.post(
  "/:companyId/invite",
  verifyCompanyAccess(firestoreDb),
  requireAdmin,
  companyController.sendInvitation,
);

router.patch("/users/:userId/role", companyController.updateUserRole);

export default router;
