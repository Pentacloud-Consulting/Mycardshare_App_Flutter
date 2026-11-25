import { NextResponse } from "next/server";
import { fail } from "./apiResponse";

/**
 * Next.js API Adapter
 * Wraps async handlers to provide unified error handling and response formatting.
 */
export const apiAdapter = (handler) => {
  return async (request, context) => {
    try {
      return await handler(request, context);
    } catch (err) {
      // Log with stack trace for debugging — the caller only ever sees the
      // sanitized JSON below.
      console.error(`❌ [API Adapter] Error:`, err?.stack || err);

      const statusCode = Number.isFinite(err?.statusCode)
        ? err.statusCode
        : 500;
      const message = err?.message || "Internal Server Error";

      // Handle Zod Errors
      if (err?.name === "ZodError" && Array.isArray(err.errors)) {
        return NextResponse.json(
          fail(
            "VALIDATION_ERROR",
            err.errors.map((e) => ({
              path: Array.isArray(e.path) ? e.path.join(".") : String(e.path),
              message: e.message,
            })),
          ),
          { status: 400 },
        );
      }

      // Handle Operational Errors (AppError)
      if (err?.isOperational) {
        const code =
          typeof err.status === "string" && err.status.length > 0
            ? err.status.toUpperCase()
            : "ERROR";
        return NextResponse.json(fail(code, message), {
          status: statusCode,
        });
      }

      // Default Error
      return NextResponse.json(
        fail(
          "INTERNAL_ERROR",
          process.env.NODE_ENV === "production"
            ? "An unexpected error occurred"
            : message,
        ),
        { status: statusCode },
      );
    }
  };
};

export class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith("4") ? "fail" : "error";
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}
