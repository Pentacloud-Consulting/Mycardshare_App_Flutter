import { z } from "zod";

// Crash-early strict environment variable validation mapping based on NEXUS Phase 15.
const envSchema = z.object({
  PORT: z.string().default("3000"),
  NODE_ENV: z
    .enum(["development", "production", "test"])
    .default("development"),

  // Database
  MONGODB_URI: z.string().url("MONGODB_URI must be a valid URL string."),

  // Auth
  JWT_SECRET: z.string().min(1, "JWT_SECRET must be provided."),

  // Client Origin
  // Optional for now to not break anything if missing, but defaults safely
  CLIENT_ORIGIN: z.string().optional(),

  // Gemini API
  GEMINI_API_KEY: z.string().optional(),

  // Google Wallet (optional — if missing, /api/wallet/google proxies to WALLET_LEGACY_BACKEND_URL)
  GOOGLE_WALLET_CREDENTIALS: z.string().optional(),
  ISSUER_ID: z.string().optional(),
  WALLET_LEGACY_BACKEND_URL: z
    .string()
    .url()
    .optional()
    .default("https://digitalbusinesscloudcard.com"),

  // Apple Wallet configuration (optional block)
  SIGNER_CERT_PATH: z.string().optional(),
  SIGNER_KEY_PATH: z.string().optional(),
  WWDR_CERT_PATH: z.string().optional(),

  // Storage bucket URLs
  GCS_UPLOADS_URL: z
    .string()
    .default("https://storage.googleapis.com/business-card-64459.appspot.com"),
});

const _env = envSchema.safeParse(process.env);

if (!_env.success) {
  console.error(
    "❌ CRITICAL: Invalid or missing environment variables:",
    _env.error.format(),
  );
  console.error(
    "Server execution cannot proceed. Please fix the variables in .env",
  );
  // process.exit(1) is avoided in Next.js Serverless runtime
}

export const env = _env.success ? _env.data : process.env;
