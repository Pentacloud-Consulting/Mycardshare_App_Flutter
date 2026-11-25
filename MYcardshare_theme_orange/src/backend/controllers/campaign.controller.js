import campaignService from "../services/campaign.service";
import { success } from "../utils/apiResponse";
import { catchAsync, AppError } from "../middleware/error";

const campaignController = {
  /**
   * POST /api/campaigns
   */
  createCampaign: catchAsync(async (req, res) => {
    // Support master-admin creating campaigns for any company
    // Prioritize body.companyId if provided (common for master-admin), fallback to user's own companyId
    const companyId = req.body?.companyId || req.user?.companyId;
    const { name, description, budget, startDate, endDate, area, imageUrl } = req.body;

    if (!name) throw new AppError("Name is required", 400);
    if (!companyId) throw new AppError("companyId is required", 400);

    const campaignId = await campaignService.createCampaign(companyId, {
      name,
      description,
      budget,
      startDate,
      endDate,
      area: area || "",
      imageUrl: imageUrl || "",
    });

    res.status(201).json(success({ campaignId }));
  }),

  /**
   * GET /api/campaigns
   */
  listCampaigns: catchAsync(async (req, res) => {
    const { companyId } = req.user || {};
    const activeOnly = req.query?.activeOnly === 'true' || req.query?.activeOnly === true;
    
    // Individuals or users without a company don't have campaigns
    if (!companyId) {
      return res.json(success([]));
    }
    
    const campaigns = await campaignService.listCampaigns(companyId, { activeOnly });
    res.json(success(campaigns));
  }),

  /**
   * PATCH /api/campaigns/:campaignId
   */
  updateCampaign: catchAsync(async (req, res) => {
    // Support master-admin updating campaigns for any company
    const companyId = req.body?.companyId || req.query?.companyId || req.user?.companyId;
    const { campaignId } = req.params;
    const updates = req.body;

    if (!companyId) throw new AppError("companyId is required", 400);

    await campaignService.updateCampaign(companyId, campaignId, updates);
    res.json(success({ message: "Campaign updated" }));
  }),

  /**
   * DELETE /api/campaigns/:campaignId
   */
  deleteCampaign: catchAsync(async (req, res) => {
    // Support master-admin deleting campaigns for any company
    const companyId = req.query?.companyId || req.user?.companyId;
    const { campaignId } = req.params;

    if (!companyId) throw new AppError("companyId is required", 400);

    await campaignService.deleteCampaign(companyId, campaignId);
    res.json(success({ message: "Campaign deleted" }));
  }),
};

export default campaignController;
