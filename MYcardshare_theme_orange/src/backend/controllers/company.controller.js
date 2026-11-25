import companyService from "../services/company.service";
import { success } from "../utils/apiResponse";
import { catchAsync, AppError } from "../middleware/error";

const companyController = {
  /**
   * POST /api/company/create
   */
  createCompany: catchAsync(async (req, res) => {
    const result = await companyService.createCompany(req.body);
    res.status(201).json(success(result));
  }),

  /**
   * GET /api/company/:companyId
   */
  getCompany: catchAsync(async (req, res) => {
    const { companyId } = req.params;
    const company = await companyService.getCompany(companyId);
    if (!company) throw new AppError("Company not found", 404);
    res.json(success(company));
  }),

  /**
   * PUT /api/company/:companyId
   */
  updateCompany: catchAsync(async (req, res) => {
    const { companyId } = req.params;
    const { updates } = req.body;
    await companyService.updateCompany(companyId, updates);
    res.json(success({ message: "Company updated successfully" }));
  }),

  /**
   * PATCH /api/company/crm-config
   */
  updateCrmConfig: catchAsync(async (req, res) => {
    const { companyId } = req.user;
    const config = req.body;
    if (!companyId) throw new AppError("Company context required", 400);
    await companyService.updateCrmConfig(companyId, config);
    res.json(success({ message: "CRM configuration updated" }));
  }),

  /**
   * GET /api/company/:companyId/employees
   */
  listEmployees: catchAsync(async (req, res) => {
    const { companyId } = req.params;
    const employees = await companyService.listEmployees(companyId);
    res.json(success({ employees }));
  }),

  /**
   * DELETE /api/company/:companyId/employees/:userId
   */
  removeEmployee: catchAsync(async (req, res) => {
    const { companyId, userId } = req.params;
    await companyService.removeEmployee(companyId, userId);
    res.json(success({ message: "Employee removed successfully" }));
  }),

  /**
   * GET /api/company/:companyId/employees/:userId
   */
  getEmployeeProfile: catchAsync(async (req, res) => {
    const { companyId, userId } = req.params;
    const profile = await companyService.getEmployeeProfile(companyId, userId);
    if (!profile) throw new AppError("Profile not found", 404);
    res.json(success(profile));
  }),

  /**
   * POST /api/company/:companyId/logo
   */
  uploadLogo: catchAsync(async (req, res) => {
    const { companyId } = req.params;
    const { logoBase64 } = req.body;
    if (!logoBase64) throw new AppError("Logo data required", 400);
    const logoUrl = await companyService.uploadImage(
      companyId,
      "logo",
      logoBase64,
    );
    res.json(success({ logoUrl }));
  }),

  /**
   * POST /api/company/:companyId/banner
   */
  uploadBanner: catchAsync(async (req, res) => {
    const { companyId } = req.params;
    const { bannerBase64 } = req.body;
    if (!bannerBase64) throw new AppError("Banner data required", 400);
    const bannerUrl = await companyService.uploadImage(
      companyId,
      "banner",
      bannerBase64,
    );
    res.json(success({ bannerUrl }));
  }),

  /**
   * POST /api/company/:companyId/invite
   */
  sendInvitation: catchAsync(async (req, res) => {
    const { companyId } = req.params;
    const { email } = req.body;
    if (!email) throw new AppError("Email required", 400);
    await companyService.sendInvitation(companyId, email);
    res.json(success({ message: `Invitation sent to ${email}` }));
  }),

  /**
   * PATCH /api/company/users/:userId/role
   */
  updateUserRole: catchAsync(async (req, res) => {
    const { userId } = req.params;
    const { role: newRole } = req.body;
    const { companyId, role: callerRole } = req.user;

    if (callerRole !== "super_admin") {
      throw new AppError("Only super_admin can update roles", 403);
    }

    await companyService.updateUserRole(userId, newRole, companyId);
    res.json(
      success({ message: "User role updated successfully", role: newRole }),
    );
  }),

  /**
   * POST /api/company/validate-voucher
   */
  validateVoucher: catchAsync(async (req, res) => {
    const { voucherCode, companyId } = req.body;
    const result = await companyService.validateVoucher(voucherCode, companyId);
    res.json(success(result));
  }),

  /**
   * GET /api/company/:companyId/public-branding
   */
  getPublicBranding: catchAsync(async (req, res) => {
    const { companyId } = req.params;
    const branding = await companyService.getPublicBranding(companyId);
    if (!branding) throw new AppError("Company branding not found", 404);
    res.json(success(branding));
  }),
};

export default companyController;
