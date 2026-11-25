import { extractBusinessCard } from "../controllers/ocr.engine";

const ocrService = {
  async extractCard(imageData) {
    return await extractBusinessCard(imageData);
  },
};

export default ocrService;
