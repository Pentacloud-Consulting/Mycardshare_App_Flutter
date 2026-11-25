import userService from "../services/user.service";
import { success } from "../utils/apiResponse";
import { catchAsync, AppError } from "../middleware/error";

const userController = {
  /**
   * GET /api/user/me
   */
  getMe: catchAsync(async (req, res) => {
    const uid = req.user?.uid;
    if (!uid) throw new AppError("Authentication required", 401);

    const userData = await userService.getUser(uid);
    if (!userData) throw new AppError("User not found", 404);

    // Include approval status if super_admin
    const response = { ...userData };
    if (userData.role === "super_admin" && req.companyData) {
      response.approvalStatus = req.companyData.approvalStatus;
    }

    res.json(success(response));
  }),

  /**
   * PATCH /api/user/me
   */
  updateMe: catchAsync(async (req, res) => {
    const uid = req.user?.uid;
    const updates = req.body;
    await userService.updateProfile(uid, updates);
    res.json(success({ message: "Profile updated" }));
  }),
};

export default userController;
