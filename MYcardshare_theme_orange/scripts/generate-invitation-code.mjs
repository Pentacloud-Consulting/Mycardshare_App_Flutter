#!/usr/bin/env node
/**
 * Prints a random secret for ENTERPRISE_REGISTRATION_MASTER_KEY (Vercel / .env).
 *
 * Usage: node scripts/generate-invitation-code.mjs
 */
import { randomBytes } from "node:crypto";

const secret = randomBytes(32).toString("hex");
console.log("\nPaste this into your environment as ENTERPRISE_REGISTRATION_MASTER_KEY:\n");
console.log(secret);
console.log(
  "\nThen users must enter the same value in the enterprise onboarding “Invitation code” field when creating an organization.\n",
);
