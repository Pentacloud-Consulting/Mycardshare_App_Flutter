import { NextResponse } from "next/server";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { resolveAuth } from "@/backend/middleware/auth-handler";
import { admin, firestoreDb } from "@/backend/config/firebase";
import { success, fail } from "@/backend/utils/apiResponse";

/**
 * POST /api/profile/change-password
 * Body: { currentPassword, newPassword }
 *
 * Flow:
 *  1. Verify the caller via Firebase ID token (resolveAuth)
 *  2. Verify the current password by calling Firebase REST signInWithPassword
 *  3. Update the password via Firebase Admin SDK
 *  4. Record `passwordLastChanged` in Firestore
 */
export const POST = apiAdapter(async (request) => {
  const context = await resolveAuth(request);
  const { currentPassword, newPassword } = await request.json();

  // ── Validation ────────────────────────────────────────────
  if (!currentPassword || !newPassword) {
    return NextResponse.json(
      fail("VALIDATION_ERROR", "Current password and new password are required"),
      { status: 400 }
    );
  }

  if (newPassword.length < 6) {
    return NextResponse.json(
      fail("VALIDATION_ERROR", "New password must be at least 6 characters"),
      { status: 400 }
    );
  }

  if (currentPassword === newPassword) {
    return NextResponse.json(
      fail("VALIDATION_ERROR", "New password must be different from current password"),
      { status: 400 }
    );
  }

  // ── Verify current password via Firebase REST API ─────────
  const email = context.auth.email || context.user?.email;
  if (!email) {
    return NextResponse.json(
      fail("AUTH_ERROR", "Unable to determine account email"),
      { status: 400 }
    );
  }

  // Use the Firebase Auth REST API to verify the current password
  const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY || "AIzaSyAozLiTvq8XjweAkMVetSyE5BqmWrc54Qw";
  try {
    const verifyRes = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email,
          password: currentPassword,
          returnSecureToken: false,
        }),
      }
    );

    if (!verifyRes.ok) {
      const errorData = await verifyRes.json().catch(() => ({}));
      const errorMsg = errorData?.error?.message || "";

      if (errorMsg.includes("INVALID_PASSWORD") || errorMsg.includes("INVALID_LOGIN_CREDENTIALS")) {
        return NextResponse.json(
          fail("AUTH_ERROR", "Current password is incorrect"),
          { status: 401 }
        );
      }
      if (errorMsg.includes("TOO_MANY_ATTEMPTS")) {
        return NextResponse.json(
          fail("RATE_LIMIT", "Too many attempts. Please try again later"),
          { status: 429 }
        );
      }

      return NextResponse.json(
        fail("AUTH_ERROR", "Unable to verify current password"),
        { status: 400 }
      );
    }
  } catch (err) {
    console.error("Password verification error:", err);
    return NextResponse.json(
      fail("AUTH_ERROR", "Unable to verify current password"),
      { status: 500 }
    );
  }

  // ── Update password via Firebase Admin SDK ────────────────
  try {
    await admin.auth().updateUser(context.uid, {
      password: newPassword,
    });
  } catch (err) {
    console.error("Password update error:", err);
    return NextResponse.json(
      fail("UPDATE_ERROR", "Failed to update password. Please try again"),
      { status: 500 }
    );
  }

  // ── Record timestamp in Firestore ─────────────────────────
  try {
    await firestoreDb.collection("users").doc(context.uid).update({
      passwordLastChanged: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (err) {
    // Non-critical — password was already changed successfully
    console.warn("Failed to record passwordLastChanged:", err);
  }

  return NextResponse.json(success({ message: "Password changed successfully" }));
});
