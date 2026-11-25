/**
 * Authentication Middleware for Multi-Tenant Architecture
 * Provides access control and data isolation
 */

/**
 * Resolve User Context Middleware
 * Consolidates lookup and enrichment into a single atomic operation.
 * Sets req.user (auth context) and req.userData (Firestore profile context).
 */
const resolveUserContext = (db) => {
  return async (req, res, next) => {
    try {
      if (!req.user || !req.user.uid) return next();

      const userDoc = await db.collection("users").doc(req.user.uid).get();
      if (userDoc.exists) {
        const data = userDoc.data();
        req.userData = data;

        // Map roles for internal consistency
        req.user.companyId = data.companyId || null;
        if (data.role === "admin") req.user.role = "company_admin";
        else if (data.role === "employee") req.user.role = "agent";
        else if (data.role) req.user.role = data.role;
      }
      next();
    } catch (error) {
      console.error("❌ [Auth] Context Resolution Failed:", error);
      res
        .status(500)
        .json({ success: false, error: "Identity resolution failed" });
    }
  };
};

/**
 * Verify Company Access Middleware
 * Uses pre-loaded req.user context to minimize I/O.
 */
const verifyCompanyAccess = (db) => {
  return async (req, res, next) => {
    try {
      const { companyId } = req.params;
      const { uid, companyId: userCompanyId, role } = req.user || {};

      if (!uid) {
        return res
          .status(401)
          .json({ success: false, error: "Authentication required" });
      }

      if (role === "master_admin") return next(); // Platform admins bypass

      if (!companyId || userCompanyId !== companyId) {
        return res.status(403).json({
          success: false,
          error: "Access denied: Unauthorized tenant boundary",
        });
      }

      next();
    } catch (error) {
      res
        .status(500)
        .json({ success: false, error: "Boundary verification failed" });
    }
  };
};

/**
 * Require Admin Middleware
 * Ensures user is a company admin or super_admin (admin management).
 * company_admin stored in Firestore as role 'admin'; super_admin as 'super_admin'.
 */
const requireAdmin = (req, res, next) => {
  try {
    if (!req.userData) {
      return res.status(401).json({
        success: false,
        error: "Authentication required",
      });
    }

    const role = req.userData.role;
    if (role !== "admin" && role !== "super_admin") {
      return res.status(403).json({
        success: false,
        error: "Admin access required",
      });
    }

    next();
  } catch (error) {
    console.error("Error in requireAdmin middleware:", error);
    res.status(500).json({
      success: false,
      error: "Failed to verify admin access",
    });
  }
};

/**
 * Require Master Admin Middleware
 * Ensures user role is 'master_admin'.
 */
const requireMasterAdmin = (req, res, next) => {
  try {
    if (!req.user || req.user.role !== "master_admin") {
      return res.status(403).json({
        success: false,
        error: "Forbidden: master_admin only",
      });
    }
    next();
  } catch (error) {
    console.error("Error in requireMasterAdmin middleware:", error);
    res.status(500).json({
      success: false,
      error: "Failed to verify master admin access",
    });
  }
};

/**
 * Check Subscription Middleware
 * Verifies company subscription is active. super_admin bypasses (can do subscription update).
 * Expects: req.userData (set by verifyCompanyAccess)
 */
const checkSubscription = (db) => {
  return async (req, res, next) => {
    try {
      if (!req.userData || !req.userData.companyId) {
        return next();
      }
      if (req.userData.role === "super_admin") {
        const companyDoc = await db
          .collection("companies")
          .doc(req.userData.companyId)
          .get();
        if (companyDoc.exists) req.companyData = companyDoc.data();
        return next();
      }

      const companyId = req.userData.companyId;

      // Get company document
      const companyDoc = await db.collection("companies").doc(companyId).get();

      if (!companyDoc.exists) {
        return res.status(404).json({
          success: false,
          error: "Company not found",
        });
      }

      const company = companyDoc.data();

      // Check subscription status
      if (company.status !== "active") {
        return res.status(403).json({
          success: false,
          error: "Company subscription is not active",
          subscriptionStatus: company.status,
        });
      }

      // Check subscription expiry
      const subscriptionEndDate = company.subscriptionEndDate.toDate();
      const now = new Date();

      if (now > subscriptionEndDate) {
        // Update status to expired
        await db.collection("companies").doc(companyId).update({
          status: "expired",
        });

        return res.status(403).json({
          success: false,
          error: "Company subscription has expired",
          subscriptionEndDate: subscriptionEndDate.toISOString(),
        });
      }

      // Attach company data to request
      req.companyData = company;

      next();
    } catch (error) {
      console.error("Error in checkSubscription middleware:", error);
      res.status(500).json({
        success: false,
        error: "Failed to verify subscription status",
      });
    }
  };
};

/**
 * Check Company Suspended Middleware
 * If the user's company has isSuspended === true, return 403. Otherwise call next().
 * Do not apply to platform routes. Use on leads create, campaign create, CRM config update, CSV export, CRM retry.
 *
 * Expects: req.user.companyId (set by verifyFirebaseToken / token claims). If no companyId, calls next().
 * When the check passes, sets req.companyData = company (so handlers can reuse and avoid duplicate Firestore reads).
 */
const checkCompanySuspended = (db) => {
  return async (req, res, next) => {
    try {
      if (!db) {
        return next();
      }
      const companyId = req.user?.companyId;
      if (!companyId) {
        return next();
      }
      const companyDoc = await db.collection("companies").doc(companyId).get();
      if (!companyDoc.exists) {
        return next();
      }
      const company = companyDoc.data();
      if (company.isSuspended === true) {
        return res.status(403).json({
          success: false,
          message:
            "Your brokerage account is suspended. Please contact platform support.",
        });
      }
      req.companyData = company;
      next();
    } catch (error) {
      console.error("Error in checkCompanySuspended:", error);
      res.status(500).json({
        success: false,
        error: "Failed to verify company status",
      });
    }
  };
};

/**
 * Verify Firebase ID Token Middleware
 * Validates Firebase authentication token
 *
 * Usage: Add to routes that require Firebase authentication
 * Expects: Authorization header with Bearer token
 */
const verifyFirebaseToken = (admin) => {
  return async (req, res, next) => {
    try {
      const authHeader = req.headers.authorization;

      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({
          success: false,
          error: "No authentication token provided",
        });
      }

      const idToken = authHeader.split("Bearer ")[1];

      // Verify the ID token
      const decodedToken = await admin.auth().verifyIdToken(idToken);

      // Attach user info to request
      req.user = decodedToken;

      next();
    } catch (error) {
      console.error("Error verifying Firebase token:", error);
      res.status(401).json({
        success: false,
        error: "Invalid or expired authentication token",
      });
    }
  };
};

export default {
  resolveUserContext,
  verifyCompanyAccess,
  requireAdmin,
  requireMasterAdmin,
  checkSubscription,
  checkCompanySuspended,
  verifyFirebaseToken,
};
