import rateLimit from "express-rate-limit";
import { fail } from "../utils/apiResponse";

/**
 * Standard API Rate Limiter
 * Suitable for generic data read requests
 */
const apiLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 100, // Limit each IP to 100 requests per windowMs
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  handler: (req, res) => {
    const errorRes = fail(
      "TOO_MANY_REQUESTS",
      "You have exceeded the rate limit for this endpoint.",
    );
    res.status(429).json(errorRes);
  },
});

/**
 * Stricter Rate Limiter for Authentication or Wallet Generation Endpoints
 */
const strictLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 15, // Limit each IP to 15 requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    const errorRes = fail(
      "TOO_MANY_REQUESTS",
      "Security rate limit exceeded. Please try again later.",
    );
    res.status(429).json(errorRes);
  },
});

export default {
  apiLimiter,
  strictLimiter,
};
