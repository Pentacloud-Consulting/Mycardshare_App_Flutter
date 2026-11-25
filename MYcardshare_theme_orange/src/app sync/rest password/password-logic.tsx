import { NextRequest, NextResponse } from "next/server";
import { admin, firestoreDb } from "@/backend/config/firebase";
import { apiAdapter } from "@/backend/utils/api-adapter";
import { success, fail } from "@/backend/utils/apiResponse";

/**
 * UNIFIED REAL PASSWORD POLICY & ACCOUNT CREATION SYNC
 * 
 * Rules matched with website (src/app/signup/page.jsx):
 * 1. At least 8 characters long
 * 2. At least one uppercase letter (A-Z)
 * 3. At least one lowercase letter (a-z)
 * 4. At least one number (0-9)
 * 5. At least one special character (!@#$%^&*(),.?":{}|<>_\-+=[\]\\\/~`)
 * 
 * Endpoints:
 * - POST /api/sync/password-logic?action=validate
 * - POST /api/sync/password-logic?action=create_account
 * - POST /api/sync/password-logic?action=update_password
 */

export interface PasswordValidationResult {
  isValid: boolean;
  score: number; // 0 to 5
  strength: "Empty" | "Weak" | "Fair" | "Good" | "Strong";
  rules: {
    minLength: boolean;
    hasUppercase: boolean;
    hasLowercase: boolean;
    hasNumber: boolean;
    hasSpecialChar: boolean;
  };
  missingRequirements: string[];
}

export function validatePasswordPolicy(password: string): PasswordValidationResult {
  if (!password || typeof password !== "string") {
    return {
      isValid: false,
      score: 0,
      strength: "Empty",
      rules: {
        minLength: false,
        hasUppercase: false,
        hasLowercase: false,
        hasNumber: false,
        hasSpecialChar: false,
      },
      missingRequirements: [
        "Password must be at least 8 characters long",
        "At least one uppercase letter (A-Z)",
        "At least one lowercase letter (a-z)",
        "At least one number (0-9)",
        "At least one special character (!@#$%^&*...)",
      ],
    };
  }

  const minLength = password.length >= 8;
  const hasUppercase = /[A-Z]/.test(password);
  const hasLowercase = /[a-z]/.test(password);
  const hasNumber = /[0-9]/.test(password);
  const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>_\-+=[\]\\\/~`]/.test(password);

  const checks = [minLength, hasUppercase, hasLowercase, hasNumber, hasSpecialChar];
  const score = checks.filter(Boolean).length;

  const strengthMap: Record<number, "Weak" | "Fair" | "Good" | "Strong"> = {
    0: "Weak",
    1: "Weak",
    2: "Weak",
    3: "Fair",
    4: "Good",
    5: "Strong",
  };

  const missing: string[] = [];
  if (!minLength) missing.push("At least 8 characters");
  if (!hasUppercase) missing.push("At least one uppercase letter (A-Z)");
  if (!hasLowercase) missing.push("At least one lowercase letter (a-z)");
  if (!hasNumber) missing.push("At least one number (0-9)");
  if (!hasSpecialChar) missing.push("At least one special character (!@#$%^&*...)");

  const isValid = minLength && hasUppercase && hasNumber && hasSpecialChar;

  return {
    isValid,
    score,
    strength: strengthMap[score] || "Weak",
    rules: {
      minLength,
      hasUppercase,
      hasLowercase,
      hasNumber,
      hasSpecialChar,
    },
    missingRequirements: missing,
  };
}

export const POST = apiAdapter(async (request: NextRequest) => {
  const { searchParams } = new URL(request.url);
  const action = searchParams.get("action") || "validate";
  const body = await request.json();

  const { password, confirmPassword, email, fullName, role = "individual", companyName } = body;

  // =========================================================================
  // 1. ACTION: VALIDATE PASSWORD (Instant real-time checks on mobile keystroke)
  // =========================================================================
  if (action === "validate") {
    const analysis = validatePasswordPolicy(password || "");
    const doMatch = confirmPassword !== undefined ? password === confirmPassword : true;

    return NextResponse.json(
      success({
        ...analysis,
        passwordsMatch: doMatch,
      })
    );
  }

  // =========================================================================
  // 2. ACTION: CREATE ACCOUNT WITH PASSWORD ENFORCEMENT
  // =========================================================================
  if (action === "create_account") {
    if (!email || !password) {
      return NextResponse.json(
        fail("CREDENTIALS_REQUIRED", "Email and password are required to create an account."),
        { status: 400 }
      );
    }

    // Match validation
    if (confirmPassword && password !== confirmPassword) {
      return NextResponse.json(
        fail("PASSWORD_MISMATCH", "Passwords do not match."),
        { status: 400 }
      );
    }

    // Strict Password Policy
    const validation = validatePasswordPolicy(password);
    if (!validation.isValid) {
      return NextResponse.json(
        fail(
          "WEAK_PASSWORD_POLICY",
          `Password must be at least 8 characters and include at least one uppercase letter, one number, and one special character. Missing: ${validation.missingRequirements.join(", ")}`
        ),
        { status: 422 }
      );
    }

    // Clean & normalize email
    const normalizedEmail = email.trim().toLowerCase();

    // Check if user already exists in Firebase
    try {
      const existingUser = await admin.auth().getUserByEmail(normalizedEmail);
      if (existingUser) {
        return NextResponse.json(
          fail("USER_ALREADY_EXISTS", "An account with this email already exists."),
          { status: 409 }
        );
      }
    } catch (e: any) {
      // 'auth/user-not-found' means email is available, which is expected.
      if (e.code !== "auth/user-not-found") {
        console.warn("⚠️ Firebase user check error:", e?.message);
      }
    }

    // Create Firebase User
    let newFirebaseUser: any = null;
    try {
      newFirebaseUser = await admin.auth().createUser({
        email: normalizedEmail,
        password: password,
        displayName: fullName || (normalizedEmail.split("@")[0]),
        emailVerified: false,
      });
    } catch (authErr: any) {
      console.error("❌ Firebase Auth user creation error:", authErr);
      return NextResponse.json(
        fail("FIREBASE_AUTH_ERROR", authErr.message || "Failed to create user in Firebase Auth"),
        { status: 500 }
      );
    }

    const uid = newFirebaseUser.uid;
    const now = new Date();

    // Create Document in Firestore 'users' collection
    await firestoreDb.collection("users").doc(uid).set({
      uid,
      email: normalizedEmail,
      displayName: fullName || normalizedEmail.split("@")[0],
      role: role === "enterprise" ? "admin" : role, // "admin" or "individual"
      accountType: role,
      companyName: companyName || "",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      source: "mobile_app_sync",
      isEmailVerified: false,
      status: "active",
    }, { merge: true });

    return NextResponse.json(
      success(
        {
          uid,
          email: normalizedEmail,
          displayName: fullName || normalizedEmail.split("@")[0],
          role,
          message: "Account successfully created with verified password policy.",
        },
        "User account created successfully"
      ),
      { status: 201 }
    );
  }

  // =========================================================================
  // 3. ACTION: UPDATE / CHANGE PASSWORD (Profile or Security Settings)
  // =========================================================================
  if (action === "update_password") {
    const { uid, newPassword, confirmNewPassword } = body;

    if (!uid || !newPassword) {
      return NextResponse.json(
        fail("MISSING_DATA", "User ID and new password are required."),
        { status: 400 }
      );
    }

    if (confirmNewPassword && newPassword !== confirmNewPassword) {
      return NextResponse.json(
        fail("PASSWORD_MISMATCH", "New passwords do not match."),
        { status: 400 }
      );
    }

    const validation = validatePasswordPolicy(newPassword);
    if (!validation.isValid) {
      return NextResponse.json(
        fail(
          "WEAK_PASSWORD_POLICY",
          `Password must be at least 8 characters and include at least one uppercase letter, one number, and one special character. Missing: ${validation.missingRequirements.join(", ")}`
        ),
        { status: 422 }
      );
    }

    try {
      await admin.auth().updateUser(uid, {
        password: newPassword,
      });

      await firestoreDb.collection("users").doc(uid).set({
        passwordUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      return NextResponse.json(
        success({ uid }, "Password updated successfully.")
      );
    } catch (err: any) {
      return NextResponse.json(
        fail("PASSWORD_UPDATE_FAILED", err.message || "Failed to update user password"),
        { status: 500 }
      );
    }
  }

  return NextResponse.json(fail("INVALID_ACTION", "Supported actions: validate, create_account, update_password"), { status: 400 });
});
