import { admin, firestoreDb } from "../config/firebase";
import { AppError } from "../utils/api-adapter";
import { isMasterAdmin, isEnterprise } from "../../lib/roles";

/**
 * Resolve User identity and context for Next.js App Router
 */
export const resolveAuth = async (request) => {
  const authHeader = request.headers.get("authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new AppError("Authentication required", 401);
  }

  const token = authHeader.split("Bearer ")[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);

    // Enrich with database profile
    const userDoc = await firestoreDb
      .collection("users")
      .doc(decodedToken.uid)
      .get();
    let userData = userDoc.exists ? userDoc.data() : null;

    // Fallback for Individual users whose data might be in 'cards' (Legacy mapped)
    if (!userData) {
      const cardDoc = await firestoreDb
        .collection("cards")
        .where("userId", "==", decodedToken.uid)
        .limit(1)
        .get();
      if (!cardDoc.empty) {
        userData = cardDoc.docs[0].data();
        if (!userData.role) userData.role = "standard";
        userData.uid = decodedToken.uid;
      }
    }

    // Ensure companyId is resolved for enterprise users
    if (userData && !userData.companyId) {
      if (isEnterprise(userData.role)) {
        userData.companyId = decodedToken.uid;
      } else {
        try {
          const entDoc = await firestoreDb.collection("enterprises").doc(decodedToken.uid).get();
          if (entDoc.exists) {
            userData.companyId = decodedToken.uid;
            userData.role = "enterprise";
          } else {
            const compDoc = await firestoreDb.collection("companies").doc(decodedToken.uid).get();
            if (compDoc.exists) {
              userData.companyId = decodedToken.uid;
              userData.role = "enterprise";
            }
          }
        } catch (_) {}
      }
    }

    // Auto-initialize new user if no profile found at all
    const googlePhoto = decodedToken.picture || decodedToken.photoURL || null;

    if (!userData) {
      userData = {
        uid: decodedToken.uid,
        email: decodedToken.email,
        displayName: decodedToken.name || "",
        fullName: decodedToken.name || "",
        avatarUrl: googlePhoto,
        photoURL: googlePhoto,
        role: "standard",
        onboardingCompleted: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      await firestoreDb.collection("users").doc(decodedToken.uid).set(userData);
    } else if (googlePhoto && !userData.avatarUrl && !userData.photoURL) {
      // Sync Google Profile Picture into existing profile if missing
      userData.avatarUrl = googlePhoto;
      userData.photoURL = googlePhoto;
      await firestoreDb.collection("users").doc(decodedToken.uid).set(
        {
          avatarUrl: googlePhoto,
          photoURL: googlePhoto,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    // Recognize master admin by email or custom claims
    if (decodedToken.email && (decodedToken.email.toLowerCase() === "admin@pentcloud.me" || decodedToken.admin === true)) {
      if (userData) {
        userData.role = "master-admin";
      }
    }

    return {
      auth: decodedToken, // Original Firebase token data
      user: userData, // Firestore profile data
      uid: decodedToken.uid,
    };
  } catch (error) {
    console.error("❌ [Auth Resolver] Verification failed:", error);
    throw new AppError("Invalid or expired session", 401);
  }
};

/**
 * Guard for Admin access (enterprise admin OR master admin)
 */
export const requireAdmin = (userContext) => {
  const role = userContext.user?.role;
  if (!role || (!isMasterAdmin(role) && !isEnterprise(role))) {
    throw new AppError("Admin access required", 403);
  }
};

/**
 * Guard for Suspended Company
 */
export const checkCompanySuspended = async (userContext) => {
  const companyId = userContext.user?.companyId;
  if (!companyId) return;

  const companyDoc = await firestoreDb
    .collection("companies")
    .doc(companyId)
    .get();
  if (companyDoc.exists) {
    const company = companyDoc.data();
    if (company.isSuspended === true) {
      throw new AppError(
        "Your brokerage account is suspended. Please contact platform support.",
        403,
      );
    }
    return company;
  }
};

/**
 * Guard for Master Admin access (Platform Guardians)
 * Supports: super_admin, master_admin, platform_admin
 */
export const requireMasterAdmin = (userContext) => {
  if (!userContext.user || !isMasterAdmin(userContext.user.role)) {
    throw new AppError("Master admin access required", 403);
  }
};
