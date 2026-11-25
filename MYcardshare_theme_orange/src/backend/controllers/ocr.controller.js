import ocrService from "../services/ocr.service";
import { success } from "../utils/apiResponse";
import { catchAsync, AppError } from "../middleware/error";

const ocrController = {
  /**
   * POST /api/ocr/extract
   */
  extract: catchAsync(async (req, res) => {
    const { image } = req.body;

    if (!image) throw new AppError("No image provided", 400);

    if (!image.startsWith("data:image/")) {
      throw new AppError("Invalid image format", 400);
    }

    const result = await ocrService.extractCard(image);

    if (result.success) {
      res.json(
        success({
          data: result.data,
          confidence: result.confidence,
          source: "gemini-ai",
        }),
      );
    } else {
      throw new AppError(result.error, result.retryable ? 429 : 500);
    }
  }),
};

export default ocrController;
