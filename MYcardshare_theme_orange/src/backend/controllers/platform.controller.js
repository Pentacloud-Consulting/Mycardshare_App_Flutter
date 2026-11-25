import platformService from "../services/platform.service";
import { success } from "../utils/apiResponse";
import { catchAsync, AppError } from "../middleware/error";

const platformController = {
  /**
   * GET /api/platform/companies
   */
  listCompanies: catchAsync(async (req, res) => {
    const companies = await platformService.listCompanies();
    res.json(success({ companies }));
  }),

  /**
   * GET /api/platform/super-admins
   */
  listSuperAdmins: catchAsync(async (req, res) => {
    const superAdmins = await platformService.listSuperAdmins();
    res.json(success({ superAdmins }));
  }),

  /**
   * GET /api/platform/companies/pending
   */
  listPendingCompanies: catchAsync(async (req, res) => {
    const companies = await platformService.listCompanies();
    const pending = companies.filter((c) => c.approvalStatus === "pending");
    res.json(success({ companies: pending }));
  }),

  /**
   * PATCH /api/platform/companies/:companyId/suspend
   */
  suspendCompany: catchAsync(async (req, res) => {
    const { companyId } = req.params;
    const { isSuspended } = req.body;

    await platformService.updateCompanyStatus(companyId, { isSuspended });
    res.json(success({ message: "Company suspension updated", isSuspended }));
  }),

  /**
   * PATCH /api/platform/companies/:companyId/approval
   */
  updateApproval: catchAsync(async (req, res) => {
    const { companyId } = req.params;
    const { action } = req.body;

    const updates =
      action === "approve"
        ? { approvalStatus: "approved", isSuspended: false }
        : { approvalStatus: "rejected", isSuspended: true };

    await platformService.updateCompanyStatus(companyId, updates);
    res.json(success({ message: `Company ${action}d successfully`, action }));
  }),
};

export default platformController;
