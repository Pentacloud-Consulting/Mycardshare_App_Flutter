import { z } from "zod";

/**
 * Company Creation Schema
 */
const createCompanySchema = z.object({
  body: z.object({
    companyName: z
      .string()
      .min(2, "Company name must be at least 2 characters."),
    companyEmail: z.string().email("Invalid company email format."),
    adminUserId: z.string().min(1, "Admin User ID is required."),
    phoneNumber: z.string().min(8, "Phone number must be at least 8 digits."),
    companyWebsite: z.string().url().optional().or(z.literal("")),
    slug: z.string().optional(),
    companyLogo: z.string().optional(),
  }),
});

/**
 * CRM Configuration Schema
 */
const crmConfigSchema = z.object({
  body: z.object({
    enabled: z.boolean(),
    webhookUrl: z.string().url().optional().or(z.literal("")),
    secretToken: z.string().optional(),
    zapierEnabled: z.boolean().optional(),
    zapierWebhookUrl: z.string().url().optional().or(z.literal("")),
  }),
});

/**
 * Company Update Schema
 */
const updateCompanySchema = z.object({
  params: z.object({
    companyId: z.string().min(1),
  }),
  body: z.object({
    updates: z.object({
      companyName: z.string().optional(),
      slug: z.string().optional(),
      companyEmail: z.string().email().optional(),
      companyLogo: z.string().optional(),
      companyBanner: z.string().optional(),
      themeColor: z
        .string()
        .regex(/^#[0-9A-F]{6}$/i)
        .optional(),
      companyWebsite: z.string().url().optional(),
      settings: z.any().optional(),
      subscriptionStartDate: z.string().optional(),
      subscriptionEndDate: z.string().optional(),
    }),
  }),
});

/**
 * Voucher Validation Schema
 */
const voucherSchema = z.object({
  body: z.object({
    voucherCode: z.string().min(1, "Voucher code is required."),
    companyId: z.string().min(1, "Company ID is required."),
  }),
});

export default {
  createCompanySchema,
  crmConfigSchema,
  updateCompanySchema,
  voucherSchema,
};
