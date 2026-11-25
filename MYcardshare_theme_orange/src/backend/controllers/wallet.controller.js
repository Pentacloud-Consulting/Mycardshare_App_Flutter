import walletService from "../services/wallet.service";
import { success } from "../utils/apiResponse";
import { catchAsync, AppError } from "../middleware/error";

const walletController = {
  // ============================================
  // GOOGLE WALLET ENDPOINTS
  // ============================================
  createGooglePass: catchAsync(async (req, res) => {
    const cardData = req.body;
    if (!cardData.fullName) {
      throw new AppError("Full name is required for wallet passes.", 400);
    }

    console.log("🎟️ Processing Google Wallet request for:", cardData.fullName);

    await walletService.ensureGenericClass();
    const objectId = await walletService.createWalletPass(cardData);
    const token = walletService.generateSaveUrl(objectId);
    const saveUrl = `https://pay.google.com/gp/v/save/${token}`;

    res.json(success({ saveUrl }));
  }),

  serveHostedImage: catchAsync(async (req, res) => {
    const key = req.params.key;
    const imageData = walletService.getImageByKey(key);

    if (!imageData) {
      throw new AppError("Wallet image cache expired or not found.", 404);
    }

    const matches = imageData.match(/^data:([^;]+);base64,(.+)$/);
    if (!matches) throw new AppError("Cached image data is corrupt.", 400);

    const contentType = matches[1];
    const buffer = Buffer.from(matches[2], "base64");

    res.set("Content-Type", contentType);
    res.set("Cache-Control", "public, max-age=31536000");
    res.set("Access-Control-Allow-Origin", "*");
    res.send(buffer);
  }),

  getWalletHealth: catchAsync(async (req, res) => {
    const store = walletService.getImageStore();
    res.json(
      success({
        status: "online",
        imagesStored: store.size,
        keys: Array.from(store.keys()),
      }),
    );
  }),

  // ============================================
  // APPLE WALLET ENDPOINTS (Fallbacks)
  // ============================================
  createApplePass: catchAsync(async (req, res) => {
    const cardData = req.body;
    if (!cardData.fullName || !cardData.publicCardUrl) {
      throw new AppError("Missing required fields for Apple pass.", 400);
    }

    res.json(
      success({
        message: "Apple Pass generation ready. Use download endpoint.",
        mockMode: true,
      }),
    );
  }),
};

export default walletController;
