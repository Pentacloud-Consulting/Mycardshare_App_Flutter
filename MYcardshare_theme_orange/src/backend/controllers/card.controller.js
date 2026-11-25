import cardService from "../services/card.service";
import { success } from "../utils/apiResponse";
import { catchAsync, AppError } from "../middleware/error";

const cardController = {
  /**
   * GET /api/cards/public/:slug
   */
  getCard: catchAsync(async (req, res) => {
    const { slug } = req.params;
    const card = await cardService.getCardBySlug(slug);
    if (!card) throw new AppError("Card not found", 404);
    res.json(success(card));
  }),

  /**
   * GET /api/cards/user/:userId
   */
  listCardsByUserId: catchAsync(async (req, res) => {
    const { userId } = req.params;
    const cards = await cardService.getCardByUserId(userId);
    res.json(success(cards ? [cards] : []));
  }),

  /**
   * PATCH /api/cards/:userId?
   */
  updateCard: catchAsync(async (req, res) => {
    const targetUserId = req.params.userId || req.user.uid;
    const cardData = req.body;

    const result = await cardService.createOrUpdateCard(targetUserId, cardData);
    res.json(
      success({
        message: result.created ? "Card created" : "Card updated",
        id: result.id,
      }),
    );
  }),

  /**
   * DELETE /api/cards/:userId?
   */
  deleteCard: catchAsync(async (req, res) => {
    const targetUserId = req.params.userId || req.user.uid;
    await cardService.deleteCard(targetUserId);
    res.json(success({ message: "Card deleted" }));
  }),
};

export default cardController;
