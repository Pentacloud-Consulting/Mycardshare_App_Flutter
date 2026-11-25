import express from "express";
const router = express.Router();
import walletController from "../controllers/wallet.controller";
import { strictLimiter, apiLimiter } from "../middleware/rateLimit";

// Google Wallet Routes
router.post(
  "/create-google-pass",
  strictLimiter,
  walletController.createGooglePass,
);
router.get("/image/:key", apiLimiter, walletController.serveHostedImage);
router.get("/image-health", apiLimiter, walletController.getWalletHealth);

// Apple Wallet Routes
router.post(
  "/apple-create-pass",
  strictLimiter,
  walletController.createApplePass,
);

// Basic Health
router.get("/", (req, res) =>
  res.json({ status: "online", service: "Wallet API" }),
);

export default router;
