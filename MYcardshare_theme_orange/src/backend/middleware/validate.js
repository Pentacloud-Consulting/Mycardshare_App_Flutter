import { fail } from "../utils/apiResponse";

/**
 * Zod validation middleware
 * @param {import('zod').AnyZodObject} schema
 */
const validate = (schema) => (req, res, next) => {
  try {
    const result = schema.safeParse({
      body: req.body,
      query: req.query,
      params: req.params,
    });

    if (!result.success) {
      return res.status(400).json(
        fail(
          "VALIDATION_ERROR",
          result.error.errors.map((e) => ({
            path: e.path.join("."),
            message: e.message,
          })),
        ),
      );
    }

    // Replace req with parsed data (handles type coercion)
    req.body = result.data.body || req.body;
    req.query = result.data.query || req.query;
    req.params = result.data.params || req.params;

    next();
  } catch (error) {
    return res.status(500).json(fail("INTERNAL_ERROR", error.message));
  }
};

export default validate;
