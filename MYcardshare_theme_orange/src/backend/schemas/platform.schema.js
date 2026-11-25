import { z } from "zod";

/**
 * Platform Action Schema
 */
const platformActionSchema = z.object({
  body: z.object({
    isSuspended: z.boolean().optional(),
    action: z.enum(["approve", "reject"]).optional(),
  }),
});

export default {
  platformActionSchema,
};
