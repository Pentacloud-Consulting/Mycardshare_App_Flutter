import { fail } from "../utils/apiResponse";

/**
 * Global Error Handling Middleware
 */
const errorHandler = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || "error";

  // Log error for internal tracking
  console.error(`❌ [Error Handler] ${err.name}: ${err.message}`);
  if (process.env.NODE_ENV !== "production") {
    console.error(err.stack);
  }

  // Handle Zod Validation Errors
  if (err.name === "ZodError") {
    return res.status(400).json(
      fail(
        "VALIDATION_ERROR",
        err.errors.map((e) => ({
          path: e.path.join("."),
          message: e.message,
        })),
      ),
    );
  }

  // Handle Firebase Auth Errors
  if (err.code && err.code.startsWith("auth/")) {
    return res.status(401).json(fail("AUTH_ERROR", err.message));
  }

  // Handle MongoDB Errors
  if (err.name === "MongoError" || err.name === "MongoServerError") {
    if (err.code === 11000) {
      return res
        .status(409)
        .json(fail("DUPLICATE_ERROR", "Resource already exists"));
    }
  }

  // Default Standardized Response
  res
    .status(err.statusCode)
    .json(
      fail(
        err.isOperational ? err.status.toUpperCase() : "INTERNAL_ERROR",
        process.env.NODE_ENV === "production" && !err.isOperational
          ? "An unexpected error occurred"
          : err.message,
      ),
    );
};

/**
 * operationalError utility
 */
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith("4") ? "fail" : "error";
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * CatchAsync wrapper to eliminate try/catch boilerplate
 */
const catchAsync = (fn) => {
  return (req, res, next) => {
    return Promise.resolve(fn(req, res, next)).catch((err) => {
      if (next) return next(err);
      throw err;
    });
  };
};

export { errorHandler, AppError, catchAsync };

export default {
  errorHandler,
  AppError,
  catchAsync,
};
