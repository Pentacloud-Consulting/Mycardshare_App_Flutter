import leadService from "../services/lead.service";
import { success } from "../utils/apiResponse";
import { catchAsync, AppError } from "../middleware/error";

const leadController = {
  /**
   * POST /api/leads/create
   */
  createLead: catchAsync(async (req, res) => {
    const user = req.user;
    // Support master-admin creating leads for any company
    const companyId = req.body?.companyId || user.companyId;
    const { uid: agentId } = user;

    const { campaignId, fullName, name, mobile, phone, source, email } = req.body;
    const effectiveName = fullName || name;
    const effectiveMobile = mobile || phone;

    if (!effectiveName || (!effectiveMobile && !email)) {
      throw new AppError("A full name and phone number or email are required.", 400);
    }

    const leadData = {
      ...req.body,
      fullName: effectiveName,
      mobile: effectiveMobile || "",
      companyId,
      campaignId: campaignId || "general",
      agentId,
      source: source || "manual",
      email: email ?? "",
    };

    const leadId = await leadService.createLead(leadData);

    // Handle CRM Webhooks (Non-blocking)
    const crmConfig = req.companyData?.crmConfig;
    if (crmConfig) {
      const payload = { ...leadData, leadId: leadId.toString() };
      if (crmConfig.enabled && crmConfig.webhookUrl) {
        leadService.pushToCrm(
          crmConfig.webhookUrl,
          "custom",
          crmConfig.secretToken,
          payload,
          companyId,
          leadId,
        );
      }
      if (crmConfig.zapierEnabled && crmConfig.zapierWebhookUrl) {
        leadService.pushToCrm(
          crmConfig.zapierWebhookUrl,
          "zapier",
          null,
          payload,
          companyId,
          leadId,
        );
      }
    }

    res.status(200).json(success({ leadId }));
  }),

  /**
   * GET /api/leads
   */
  listLeads: catchAsync(async (req, res) => {
    const { companyId: userCompanyId, uid, role } = req.user;
    const companyId = req.query?.companyId || userCompanyId;
    const query = { companyId };

    if (role === "agent") query.agentId = uid;

    const { campaignId, agentId: filterAgentId, dateFrom, dateTo } = req.query;
    if (campaignId) query.campaignId = campaignId;
    if (["company_admin", "super_admin"].includes(role) && filterAgentId) {
      query.agentId = filterAgentId;
    }

    if (dateFrom || dateTo) {
      query.createdAt = {};
      if (dateFrom) query.createdAt.$gte = new Date(dateFrom);
      if (dateTo) query.createdAt.$lte = new Date(dateTo);
    }

    const leads = await leadService.listLeads(query, req.user);
    res.json(success(leads));
  }),

  /**
   * PATCH /api/leads/:leadId
   */
  updateLead: catchAsync(async (req, res) => {
    const { leadId } = req.params;
    // Support master-admin updating leads for any company
    const companyId = req.body?.companyId || req.query?.companyId || req.user.companyId;
    const updates = req.body;

    await leadService.updateLead(leadId, companyId, updates);
    res.json(success({ message: "Lead updated successfully" }));
  }),

  /**
   * DELETE /api/leads/:leadId
   */
  deleteLead: catchAsync(async (req, res) => {
    const { leadId } = req.params;
    // Support master-admin deleting leads for any company
    const companyId = req.query?.companyId || req.user.companyId;

    await leadService.deleteLead(leadId, companyId);
    res.json(success({ message: "Lead deleted successfully" }));
  }),

  /**
   * GET /api/leads/export
   */
  exportLeads: catchAsync(async (req, res) => {
    const { companyId } = req.user;
    const query = { companyId };

    const { campaignId, agentId, dateFrom, dateTo } = req.query;
    if (campaignId) query.campaignId = campaignId;
    if (agentId) query.agentId = agentId;

    if (dateFrom || dateTo) {
      query.createdAt = {};
      if (dateFrom) query.createdAt.$gte = new Date(dateFrom);
      if (dateTo) query.createdAt.$lte = new Date(dateTo);
    }

    const leads = await leadService.listLeads(query, req.user);

    const escapeCsv = (val) =>
      val ? `"${String(val).replace(/"/g, '""')}"` : '""';
    const headers = [
      "Full Name",
      "Mobile",
      "Email",
      "Nationality",
      "Budget",
      "Property",
      "Campaign",
      "Agent",
      "Created At",
    ];
    const rows = leads.map((l) =>
      [
        l.fullName,
        l.mobile,
        l.email,
        l.nationality,
        l.budgetRange,
        l.propertyType,
        l.campaignId,
        l.agentId,
        l.createdAt,
      ]
        .map(escapeCsv)
        .join(","),
    );

    const csv = [headers.join(","), ...rows].join("\r\n");

    res.setHeader("Content-Type", "text/csv; charset=utf-8");
    res.setHeader(
      "Content-Disposition",
      'attachment; filename="leads_export.csv"',
    );
    res.send(csv);
  }),

  /**
   * GET /api/leads/crm-logs
   */
  getCrmLogs: catchAsync(async (req, res) => {
    const { companyId } = req.user;
    const { connectDB } = await import("../config/db");
    const db = await connectDB();
    const logs = await db
      .collection("crmLogs")
      .find({ companyId })
      .sort({ createdAt: -1 })
      .limit(100)
      .toArray();
    res.json(success(logs));
  }),
};

export default leadController;
