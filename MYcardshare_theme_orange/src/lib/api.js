import { auth } from "@/lib/firebase";

/**
 * Authenticated fetch wrapper.
 * Automatically attaches the Firebase ID token as a Bearer header.
 */
export async function authFetch(url, options = {}) {
  const user = auth.currentUser;
  if (!user) {
    throw new Error("Not authenticated");
  }

  const token = await user.getIdToken();
  const headers = {
    ...options.headers,
    Authorization: `Bearer ${token}`,
  };

  return fetch(url, { ...options, headers });
}

/**
 * API routes use `fail(code, message)` → `{ error: { code, message } }`.
 * UI must never pass that object straight into React text (React #31).
 */
/**
 * Parse JSON from a fetch Response. Plain-text error pages (e.g. HTTP 413
 * "Request Entity Too Large") would otherwise break `res.json()` with a parse error.
 */
export async function parseFetchJson(res) {
  const text = await res.text();
  try {
    return JSON.parse(text);
  } catch {
    const lower = text.toLowerCase();
    const hint =
      res.status === 413 ||
      lower.includes("entity too large") ||
      lower.includes("request entity") ||
      lower.includes("payload too large")
        ? "The request was too large. Use smaller images (under ~2MB each) on the Studio step, then try again."
        : text.slice(0, 180).trim() || `Unexpected response (HTTP ${res.status}).`;
    throw new Error(hint);
  }
}

export function toUserMessage(payload, fallback = "Something went wrong") {
  if (payload == null || payload === "") return fallback;
  if (typeof payload === "string") return payload;
  if (typeof payload === "object" && payload !== null) {
    if (typeof payload.message === "string" && payload.message.length > 0) {
      return payload.message;
    }
    if (payload.message != null) return String(payload.message);
  }
  return fallback;
}
