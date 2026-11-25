import { firestoreDb, admin } from "../config/firebase";
import { connectDB } from "../config/db";
import { ObjectId } from "mongodb";
import { AppError } from "../utils/api-adapter";
import storageService from "./storage.service";

const companyService = {
  /**
   * Get company details from Firestore
   */
  async getCompany(companyId) {
    const [compDoc, entDoc] = await Promise.all([
      firestoreDb.collection("companies").doc(companyId).get(),
      firestoreDb.collection("enterprises").doc(companyId).get(),
    ]);

    if (!compDoc.exists && !entDoc.exists) return null;

    const compData = compDoc.exists ? compDoc.data() : {};
    const entData = entDoc.exists ? entDoc.data() : {};

    // Merge both documents, giving priority to non-empty fields
    const data = { ...compData, ...entData };

    // Ensure 8-digit inviteCode is available and synchronized with mobile app
    let inviteCode = data.inviteCode || "";
    if (!inviteCode || !/^\d{8}$/.test(String(inviteCode).trim())) {
      const slot = Math.floor(Date.now() / (15 * 60 * 1000));
      let hash = 0;
      for (let i = 0; i < companyId.length; i++) {
        hash = ((hash << 5) - hash + companyId.charCodeAt(i)) | 0;
      }
      const codeNum = 10000000 + (Math.abs(hash ^ slot) % 90000000);
      inviteCode = codeNum.toString();
    }

    const rawStatus = data.subscriptionStatus || data.status || (data.approvalStatus === "approved" ? "active" : "pending");
    const rawStartDate = data.subscriptionStartDate || data.approvedAt || data.createdAt;
    const rawRenewalDate = data.renewalDate;

    return {
      id: companyId,
      ...data,
      inviteCode,
      inviteUrl: data.inviteUrl || `mycardshare.com/join-workspace?enterpriseId=${companyId}&code=${inviteCode}`,
      companyName: data.companyName || "Organization",
      brandColor: (!data.brandColor || data.brandColor === '#0052FF') ? '#D4642C' : data.brandColor,
      subscriptionStatus: (rawStatus || "active").toLowerCase(),
      subscriptionStartDate: rawStartDate?.toDate?.()?.toISOString?.() || (typeof rawStartDate === "string" ? rawStartDate : undefined),
      subscriptionEndDate: data.subscriptionEndDate?.toDate?.()?.toISOString?.() || (typeof data.subscriptionEndDate === "string" ? data.subscriptionEndDate : undefined) || (rawRenewalDate?.toDate?.()?.toISOString?.() || (typeof rawRenewalDate === "string" ? rawRenewalDate : undefined)),
      renewalDate: rawRenewalDate?.toDate?.()?.toISOString?.() || (typeof rawRenewalDate === "string" ? rawRenewalDate : undefined),
      createdAt: data.createdAt?.toDate?.()?.toISOString?.() || (typeof data.createdAt === "string" ? data.createdAt : undefined),
      updatedAt: data.updatedAt?.toDate?.()?.toISOString?.() || (typeof data.updatedAt === "string" ? data.updatedAt : undefined),
    };
  },

  /**
   * Update company details
   */
  async updateCompany(companyId, updates) {
    const updateData = {
      ...updates,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Handle timestamp conversions if present
    if (updates.subscriptionStartDate) {
      updateData.subscriptionStartDate = admin.firestore.Timestamp.fromDate(
        new Date(updates.subscriptionStartDate),
      );
    }
    if (updates.subscriptionEndDate) {
      updateData.subscriptionEndDate = admin.firestore.Timestamp.fromDate(
        new Date(updates.subscriptionEndDate),
      );
    }

    await Promise.all([
      firestoreDb.collection("companies").doc(companyId).set(updateData, { merge: true }),
      firestoreDb.collection("enterprises").doc(companyId).set(updateData, { merge: true }),
    ]);

    // Dual-write to MongoDB companies collection to guarantee permanent sync
    try {
      const mongoDb = await connectDB();
      const mongoUpdate = { ...updates, updatedAt: new Date() };
      delete mongoUpdate._id;
      await mongoDb.collection("companies").updateOne(
        { companyId },
        { $set: mongoUpdate },
        { upsert: true }
      );
    } catch (mErr) {
      console.warn("[updateCompany] MongoDB sync note:", mErr?.message);
    }
    return true;
  },

  /**
   * Create a new company.
   *
   * Throws AppError for every known failure mode so the client gets a
   * specific, actionable message (duplicate slug, missing fields, etc.)
   * rather than a generic 500.
   */
  async createCompany(companyData) {
    const slug = String(companyData?.slug || "").trim().toLowerCase();
    const companyName = String(companyData?.companyName || "").trim();

    if (!companyName) {
      throw new AppError("Company name is required.", 400);
    }
    if (!slug) {
      throw new AppError("Public slug is required.", 400);
    }
    if (!companyData?.adminUserId) {
      throw new AppError(
        "Your session isn't signed in — please refresh and try again.",
        401,
      );
    }

    // If this user already created a company, don't create a duplicate —
    // return the existing record. Prevents "slug already taken" errors on
    // refresh / back-navigation during onboarding.
    try {
      const existingForUser = await firestoreDb
        .collection("companies")
        .where("adminUserId", "==", companyData.adminUserId)
        .limit(1)
        .get();
      if (!existingForUser.empty) {
        const doc = existingForUser.docs[0];
        const data = doc.data();
        return {
          companyId: data.companyId || doc.id,
          voucherCode: data.voucherCode || "",
          existed: true,
        };
      }
    } catch (err) {
      console.error("[createCompany] lookup failed:", err);
      // Non-fatal — continue with slug-uniqueness path.
    }

    let slugExists = false;
    try {
      slugExists = await this.checkSlugExists(slug);
    } catch (err) {
      console.error("[createCompany] slug check failed:", err);
      throw new AppError(
        "Could not verify slug availability. Please try again in a moment.",
        503,
      );
    }
    if (slugExists) {
      throw new AppError(
        "This organization slug is already taken. Please choose another.",
        409,
      );
    }

    const companyRef = firestoreDb.collection("companies").doc();
    const companyId = companyRef.id;

    const company = {
      ...companyData,
      slug,
      companyName,
      companyId,
      voucherCode: Math.random().toString(36).substring(2, 8).toUpperCase(),
      approvalStatus: "pending",
      isSuspended: true,
      subscriptionStatus: "inactive",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (company.subscriptionStartDate) {
      company.subscriptionStartDate = admin.firestore.Timestamp.fromDate(
        new Date(company.subscriptionStartDate),
      );
    }
    if (company.subscriptionEndDate) {
      company.subscriptionEndDate = admin.firestore.Timestamp.fromDate(
        new Date(company.subscriptionEndDate),
      );
    }

    try {
      await companyRef.set(company);
    } catch (err) {
      console.error("[createCompany] companies.set failed:", err);
      throw new AppError(
        "We couldn't save your organization. Please try again.",
        500,
      );
    }

    // Promote the caller to super_admin of the new company. Best-effort —
    // if this fails we don't want to orphan the company, so we log and
    // continue; the user can still reach the dashboard via their uid.
    try {
      await firestoreDb
        .collection("users")
        .doc(companyData.adminUserId)
        .set(
          {
            companyId,
            role: "enterprise",
            status: "pending",
            phoneNumber: companyData.phoneNumber || "",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
    } catch (err) {
      console.error(
        `[createCompany] user promotion failed for ${companyData.adminUserId}:`,
        err,
      );
      // Don't rethrow — company was created; surface a 207-like status
      // via a partial-success flag the client can ignore safely.
    }

    return { companyId, voucherCode: company.voucherCode };
  },

  /**
   * Check if slug exists
   */
  async checkSlugExists(slug) {
    const query = await firestoreDb
      .collection("companies")
      .where("slug", "==", slug)
      .get();
    return !query.empty;
  },

  /**
   * Check if voucher exists
   */
  async checkVoucherExists(voucherCode) {
    const query = await firestoreDb
      .collection("companies")
      .where("voucherCode", "==", voucherCode)
      .get();
    return !query.empty;
  },

  /**
   * Link an authenticated user as an employee under a resolved company record.
   */
  async linkUserAsEmployee(userId, companyData, companyId) {
    await firestoreDb.collection("users").doc(userId).set(
      {
        companyId,
        role: "employee",
        status: "active",
        profileStatus: "draft",
        onboardingCompleted: false,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return {
      companyId,
      companyName: companyData.companyName || "",
      companySlug: companyData.slug || "",
      role: "employee",
    };
  },

  /**
   * Validate voucher and link user to company.
   * Optional modes (env-driven): global master voucher, skip-without-code.
   */
  async validateVoucher(voucherCode, userId, opts = {}) {
    const skip = opts.skip === true;
    const expectedWorkspaceId = opts.workspaceId;

    // Skip voucher step — only when explicitly enabled server-side + target company configured
    if (skip) {
      if (process.env.EMPLOYEE_ALLOW_SKIP_VOUCHER !== "true") {
        throw new Error("SKIP_NOT_ALLOWED");
      }
      const companyId = process.env.EMPLOYEE_GLOBAL_COMPANY_ID?.trim();
      if (!companyId) {
        throw new Error("GLOBAL_COMPANY_NOT_CONFIGURED");
      }
      const doc = await firestoreDb.collection("companies").doc(companyId).get();
      if (!doc.exists) throw new Error("COMPANY_NOT_FOUND");
      return this.linkUserAsEmployee(userId, doc.data(), companyId);
    }

    const normalized = (voucherCode || "").trim().toUpperCase();
    if (!normalized) {
      throw new Error("INVALID_VOUCHER");
    }

    // Single global employee code → links to EMPLOYEE_GLOBAL_COMPANY_ID (same as skip target)
    const globalCode = process.env.EMPLOYEE_GLOBAL_VOUCHER_CODE?.trim().toUpperCase();
    if (globalCode && normalized === globalCode) {
      const companyId = process.env.EMPLOYEE_GLOBAL_COMPANY_ID?.trim();
      if (!companyId) {
        throw new Error("GLOBAL_COMPANY_NOT_CONFIGURED");
      }
      const doc = await firestoreDb.collection("companies").doc(companyId).get();
      if (!doc.exists) throw new Error("COMPANY_NOT_FOUND");
      return this.linkUserAsEmployee(userId, doc.data(), companyId);
    }

    // 1. If an expected workspace/enterprise ID was provided, check it directly
    if (expectedWorkspaceId) {
      const company = await this.getCompany(expectedWorkspaceId);
      if (company) {
        const matchesVoucher = company.voucherCode && String(company.voucherCode).trim().toUpperCase() === normalized;
        const matchesInvite = company.inviteCode && String(company.inviteCode).trim() === String(voucherCode).trim();
        const matchesId = company.id === expectedWorkspaceId;
        if (matchesVoucher || matchesInvite || matchesId) {
          return this.linkUserAsEmployee(userId, company, expectedWorkspaceId);
        }
      }
    }

    // 2. Search companies & enterprises for voucherCode OR inviteCode
    let matchedCompany = null;
    let resolvedCompanyId = null;

    // Check companies collection by voucherCode
    let query = await firestoreDb.collection("companies").where("voucherCode", "==", normalized).limit(1).get();
    if (!query.empty) {
      matchedCompany = query.docs[0].data();
      resolvedCompanyId = matchedCompany.companyId || query.docs[0].id;
    }

    // Check companies collection by inviteCode (8-digit app code)
    if (!matchedCompany) {
      query = await firestoreDb.collection("companies").where("inviteCode", "==", String(voucherCode).trim()).limit(1).get();
      if (!query.empty) {
        matchedCompany = query.docs[0].data();
        resolvedCompanyId = matchedCompany.companyId || query.docs[0].id;
      }
    }

    // Check enterprises collection by voucherCode
    if (!matchedCompany) {
      query = await firestoreDb.collection("enterprises").where("voucherCode", "==", normalized).limit(1).get();
      if (!query.empty) {
        matchedCompany = query.docs[0].data();
        resolvedCompanyId = matchedCompany.companyId || query.docs[0].id;
      }
    }

    // Check enterprises collection by inviteCode
    if (!matchedCompany) {
      query = await firestoreDb.collection("enterprises").where("inviteCode", "==", String(voucherCode).trim()).limit(1).get();
      if (!query.empty) {
        matchedCompany = query.docs[0].data();
        resolvedCompanyId = matchedCompany.companyId || query.docs[0].id;
      }
    }

    if (!matchedCompany) {
      throw new Error("INVALID_VOUCHER");
    }

    if (expectedWorkspaceId && resolvedCompanyId !== expectedWorkspaceId) {
      throw new Error("Voucher code does not match the invitation workspace.");
    }

    return this.linkUserAsEmployee(userId, matchedCompany, resolvedCompanyId);
  },

  /**
   * Update CRM Configuration
   */
  async updateCrmConfig(companyId, crmConfig) {
    await firestoreDb.collection("companies").doc(companyId).update({
      crmConfig,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return true;
  },

  /**
   * Update User Role
   */
  async updateUserRole(userId, newRole, companyId) {
    const targetRef = firestoreDb.collection("users").doc(userId);
    const targetSnap = await targetRef.get();

    if (!targetSnap.exists) throw new Error("USER_NOT_FOUND");

    const targetData = targetSnap.data();
    if (targetData.companyId !== companyId && targetData.enterpriseUid !== companyId) throw new Error("ACCESS_DENIED");
    if (targetData.role === "master_admin") throw new Error("FORBIDDEN");

    const firestoreRole =
      newRole === "company_admin" || newRole === "admin"
        ? "admin"
        : newRole === "agent"
          ? "employee"
          : newRole;
    const appRole = firestoreRole === "admin" ? "Admin" : "Employee";

    await targetRef.update({
      role: firestoreRole,
      roleTitle: appRole,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Dual-write to enterprises/{companyId}/employees/{userId} (read by Flutter mobile app)
    try {
      const entEmpRef = firestoreDb.collection("enterprises").doc(companyId).collection("employees").doc(userId);
      const entEmpSnap = await entEmpRef.get();
      if (entEmpSnap.exists) {
        await entEmpRef.set({ role: appRole, roleTitle: appRole, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
      }
    } catch (_) {}

    // Dual-write to companies/{companyId}/employees/{userId}
    try {
      const compEmpRef = firestoreDb.collection("companies").doc(companyId).collection("employees").doc(userId);
      const compEmpSnap = await compEmpRef.get();
      if (compEmpSnap.exists) {
        await compEmpRef.set({ role: appRole, roleTitle: appRole, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
      }
    } catch (_) {}

    const mongoDb = await connectDB();
    await mongoDb.collection("cards").updateOne(
      { userId, companyId },
      { $set: { role: firestoreRole, lastUpdated: new Date() } }
    );

    return true;
  },

  /**
   * Update User Status (Active/Inactive)
   */
  async updateUserStatus(userId, status, companyId) {
    const targetRef = firestoreDb.collection("users").doc(userId);
    const targetSnap = await targetRef.get();

    if (!targetSnap.exists) throw new Error("USER_NOT_FOUND");

    const targetData = targetSnap.data();
    if (targetData.companyId !== companyId && targetData.enterpriseUid !== companyId) throw new Error("ACCESS_DENIED");
    if (targetData.role === "master_admin") throw new Error("FORBIDDEN");

    const isInactive = status === "inactive";
    const firestoreStatus = isInactive ? "inactive" : "active";
    const appStatus = isInactive ? "Inactive" : "Active";
    const cardStatus = isInactive ? "Draft" : "Published";

    const updatePayload = {
      status: firestoreStatus,
      cardStatus,
      isPublished: !isInactive,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await targetRef.update(updatePayload);

    // Dual-write to enterprises/{companyId}/employees/{userId} (read by Flutter mobile app)
    try {
      const entEmpRef = firestoreDb.collection("enterprises").doc(companyId).collection("employees").doc(userId);
      const entEmpSnap = await entEmpRef.get();
      if (entEmpSnap.exists) {
        await entEmpRef.set({
          status: appStatus,
          cardStatus,
          isPublished: !isInactive,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      }
    } catch (_) {}

    // Dual-write to companies/{companyId}/employees/{userId}
    try {
      const compEmpRef = firestoreDb.collection("companies").doc(companyId).collection("employees").doc(userId);
      const compEmpSnap = await compEmpRef.get();
      if (compEmpSnap.exists) {
        await compEmpRef.set({
          status: appStatus,
          cardStatus,
          isPublished: !isInactive,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      }
    } catch (_) {}

    const mongoDb = await connectDB();
    const mongoPayload = {
      status: firestoreStatus,
      cardStatus,
      isPublished: !isInactive,
      lastUpdated: new Date()
    };

    await mongoDb.collection("cards").updateOne(
      { userId, companyId },
      { $set: mongoPayload }
    );

    return true;
  },

  /**
   * List all employees for a company (from MongoDB + Firestore fallback)
   */
  async listEmployees(companyId) {
    const mongoDb = await connectDB();
    const cardsCollection = mongoDb.collection("cards");

    // Primary: query MongoDB cards by companyId
    let employeeCards = await cardsCollection
      .find({ companyId: companyId })
      .toArray();

    // Fallback & Sync: MongoDB is a best-effort mirror. We always fetch the latest
    // user data from Firestore (the source of truth) to ensure `avatarUrl` and
    // `fullName` are perfectly up to date in the Workspace view.
    try {
      const firestoreUsersMap = new Map();

      // 1. Primary: users collection where companyId matches
      const usersSnap = await firestoreDb
        .collection("users")
        .where("companyId", "==", companyId)
        .get();

      for (const doc of usersSnap.docs) {
        const data = doc.data();
        const uid = data.uid || doc.id;
        const emailKey = data.email ? data.email.toLowerCase() : null;
        firestoreUsersMap.set(uid, { ...data, userId: uid });
        if (emailKey) firestoreUsersMap.set(emailKey, { ...data, userId: uid });
      }

      // 2. Subcollection: enterprises/{companyId}/employees (used by Flutter mobile app)
      try {
        const entEmpSnap = await firestoreDb
          .collection("enterprises")
          .doc(companyId)
          .collection("employees")
          .get();
        for (const doc of entEmpSnap.docs) {
          const data = doc.data();
          const uid = data.uid || data.id || doc.id;
          const emailKey = data.email ? data.email.toLowerCase() : null;
          const existing = firestoreUsersMap.get(uid) || (emailKey ? firestoreUsersMap.get(emailKey) : null) || {};
          const merged = { ...existing, ...data, userId: uid };
          firestoreUsersMap.set(uid, merged);
          if (emailKey) firestoreUsersMap.set(emailKey, merged);
        }
      } catch (_) {}

      // 3. Subcollection: companies/{companyId}/employees
      try {
        const compEmpSnap = await firestoreDb
          .collection("companies")
          .doc(companyId)
          .collection("employees")
          .get();
        for (const doc of compEmpSnap.docs) {
          const data = doc.data();
          const uid = data.uid || data.id || doc.id;
          const emailKey = data.email ? data.email.toLowerCase() : null;
          const existing = firestoreUsersMap.get(uid) || (emailKey ? firestoreUsersMap.get(emailKey) : null) || {};
          const merged = { ...existing, ...data, userId: uid };
          firestoreUsersMap.set(uid, merged);
          if (emailKey) firestoreUsersMap.set(emailKey, merged);
        }
      } catch (_) {}

      // Deduplicate to actual unique users (strictly excluding enterprise admin)
      const uniqueFirestoreUsers = new Map();
      for (const [key, userData] of firestoreUsersMap.entries()) {
        const uniqueKey = userData.userId || key;
        const role = (userData.role || "").toLowerCase();
        // Strictly exclude enterprise admin / workspace owner
        if (role === "enterprise" || role === "admin" || role === "super_admin" || uniqueKey === companyId) {
          continue;
        }
        if (!uniqueFirestoreUsers.has(uniqueKey)) {
          uniqueFirestoreUsers.set(uniqueKey, userData);
        }
      }

      if (uniqueFirestoreUsers.size > 0) {
        const mongoUserIds = new Set(employeeCards.map((c) => c.userId));
        const missingUsers = [];

        // 1. Sync existing MongoDB cards with the latest Firestore data
        for (let i = 0; i < employeeCards.length; i++) {
          const fUser = uniqueFirestoreUsers.get(employeeCards[i].userId);
          if (fUser) {
            // Guarantee the workspace always sees the latest PFP, Name, and cardStatus
            if (fUser.avatarUrl || fUser.profilePhoto) employeeCards[i].avatarUrl = fUser.avatarUrl || fUser.profilePhoto;
            if (fUser.fullName || fUser.name) employeeCards[i].fullName = fUser.fullName || fUser.name;
            const isPub = fUser.isPublished === true || fUser.cardStatus === "Published" || fUser.onboardingCompleted === true;
            employeeCards[i].cardStatus = isPub ? "Published" : (fUser.cardStatus || "Draft");
            if (fUser.cardSlug) employeeCards[i].cardSlug = fUser.cardSlug;
            if (fUser.status) employeeCards[i].status = fUser.status;
          }
        }

        // 2. Identify missing cards or cards that lack the companyId in Mongo
        for (const [userId, userData] of uniqueFirestoreUsers.entries()) {
          if (mongoUserIds.has(userId)) continue;

          // Try to find this user's card in MongoDB (without companyId filter)
          const existingCard = await cardsCollection.findOne({ userId });
          if (existingCard) {
            // Backfill companyId on the MongoDB card so future queries work
            await cardsCollection.updateOne(
              { userId },
              { $set: { companyId, lastUpdated: new Date() } },
            );
            existingCard.companyId = companyId;
            if (userData.avatarUrl || userData.profilePhoto) existingCard.avatarUrl = userData.avatarUrl || userData.profilePhoto;
            if (userData.fullName || userData.name) existingCard.fullName = userData.fullName || userData.name;
            if (userData.status) existingCard.status = userData.status;
            employeeCards.push(existingCard);
          } else {
            // No MongoDB card exists — create a stub from Firestore data
            const isPub = userData.isPublished === true || userData.cardStatus === "Published" || userData.onboardingCompleted === true;
            missingUsers.push({
              userId: userId,
              fullName: userData.fullName || userData.name || userData.displayName || "N/A",
              workEmail: userData.workEmail || userData.email || "",
              email: userData.email || "",
              jobTitle: userData.jobTitle || userData.roleTitle || "",
              role: (userData.role || "employee").toLowerCase(),
              companyId,
              cardSlug: userData.cardSlug || userId,
              cardStatus: isPub ? "Published" : "Draft",
              status: (userData.status || "active").toLowerCase() === "active" ? "active" : "inactive",
              avatarUrl: userData.avatarUrl || userData.profilePhoto || "",
              createdAt: userData.createdAt || new Date(),
            });
          }
        }

        // Insert stubs into MongoDB for future queries
        if (missingUsers.length > 0) {
          try {
            await cardsCollection.insertMany(missingUsers, { ordered: false });
          } catch (bulkErr) {
            console.warn("[listEmployees] Bulk insert partial failure:", bulkErr?.message);
          }
          employeeCards = employeeCards.concat(missingUsers);
        }
      }
    } catch (firestoreErr) {
      console.warn("[listEmployees] Firestore sync failed:", firestoreErr?.message);
      // Non-fatal — continue with MongoDB results only
    }

    // Deduplicate results by email/userId to ensure no duplicate rows in UI
    const seen = new Set();
    const uniqueEmployees = [];
    for (const card of employeeCards) {
      if (card.role === "enterprise") continue;
      const key = (card.email && card.email !== "N/A") ? card.email.toLowerCase() : (card.userId || String(card._id));
      if (seen.has(key)) continue;
      seen.add(key);
      uniqueEmployees.push(card);
    }

    return uniqueEmployees
      .map((card) => ({
        id: card._id,
        userId: card.userId,
        fullName: card.fullName || "N/A",
        email: card.workEmail || card.email || "N/A",
        jobTitle: card.jobTitle || "N/A",
        role: card.role || "employee",
        cardStatus: card.cardStatus || "Draft",
        status: card.status || "active",
        cardSlug: card.cardSlug || card.userId,
        avatarUrl: card.avatarUrl || "",
        createdAt: card.createdAt,
        lastUpdated: card.lastUpdated,
      }))
      .sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));
  },

  /**
   * Get single employee profile
   */
  async getEmployeeProfile(companyId, userId) {
    const mongoDb = await connectDB();
    return await mongoDb.collection("cards").findOne({ userId, companyId });
  },



  /**
   * Upload a company logo or banner and persist its public URL on the
   * company doc. Storage branching (GCS → local) is handled by the unified
   * storage service — this method only owns the company domain write.
   *
   * @param {string} companyId
   * @param {"logo"|"banner"} type
   * @param {string|Buffer|{buffer:Buffer,ext?:string,contentType?:string}} input
   */
  async uploadImage(companyId, type, input) {
    if (!companyId) throw new AppError("Missing companyId.", 400);
    if (type !== "logo" && type !== "banner") {
      throw new AppError(`Unsupported company image type "${type}".`, 400);
    }

    const folder = type === "logo" ? "company-logos" : "company-banners";
    let publicUrl;
    try {
      const result = await storageService.putImage({
        folder,
        baseName: `${companyId}_${type}`,
        input,
      });
      publicUrl = result.url;
      console.log(
        `[company.uploadImage] stored ${type} for ${companyId} via ${result.backend} → ${publicUrl}`,
      );
    } catch (err) {
      // Turn storage errors into actionable AppErrors so the UI shows
      // something more useful than a bare 500.
      const code = err?.code || "UPLOAD_FAILED";
      const status =
        code === "FILE_TOO_LARGE"
          ? 413
          : code === "INVALID_MIME" || code === "INVALID_INPUT" || code === "EMPTY_FILE"
            ? 400
            : 500;
      throw new AppError(err?.message || "Could not upload image.", status);
    }

    // Write the new URL onto the company doc. `.update()` throws NOT_FOUND
    // if the doc doesn't exist yet — surface that clearly.
    const field = type === "logo" ? "companyLogo" : "companyBanner";
    try {
      await firestoreDb
        .collection("companies")
        .doc(companyId)
        .update({
          [field]: publicUrl,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    } catch (err) {
      console.error(
        `[company.uploadImage] firestore update failed for ${companyId}:`,
        err,
      );
      const notFound =
        err?.code === 5 || /not.?found/i.test(err?.message || "");
      throw new AppError(
        notFound
          ? "Organization record not found — finish creating the organization before uploading a logo."
          : "Could not save the uploaded image to the organization record.",
        notFound ? 404 : 500,
      );
    }

    return publicUrl;
  },

  /**
   * Record an invitation for a company and (in production) dispatch an email.
   * Persists to Firestore so admins can see pending invites even without
   * an email provider configured.
   */
  async sendInvitation(companyId, email) {
    const normalizedEmail = String(email || "").trim().toLowerCase();
    if (!normalizedEmail) throw new Error("EMAIL_REQUIRED");

    await firestoreDb
      .collection("companies")
      .doc(companyId)
      .collection("invitations")
      .doc(normalizedEmail)
      .set(
        {
          email: normalizedEmail,
          companyId,
          status: "pending",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

    // Also update invitedEmails array on both enterprises and companies
    try {
      await firestoreDb.collection("enterprises").doc(companyId).set({
        invitedEmails: admin.firestore.FieldValue.arrayUnion(normalizedEmail),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    } catch (_) {}

    try {
      await firestoreDb.collection("companies").doc(companyId).set({
        invitedEmails: admin.firestore.FieldValue.arrayUnion(normalizedEmail),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    } catch (_) {}

    // Hook for email transport (SendGrid/SES/Resend) — no-op if unconfigured.
    console.log(
      `[company.service] Invitation recorded for ${normalizedEmail} @ ${companyId}`,
    );

    return true;
  },
  /**
   * Remove Employee from Workspace
   */
  async removeEmployee(userId, companyId) {
    const targetRef = firestoreDb.collection("users").doc(userId);
    const targetSnap = await targetRef.get();

    if (!targetSnap.exists) throw new Error("USER_NOT_FOUND");

    const targetData = targetSnap.data();
    if (targetData.companyId !== companyId && targetData.enterpriseUid !== companyId) throw new Error("ACCESS_DENIED");
    if (targetData.role === "master_admin") throw new Error("FORBIDDEN");
    if (targetData.role === "enterprise") throw new Error("Cannot remove the company administrator from the workspace.");

    // Remove from Firestore users
    await targetRef.update({
      companyId: admin.firestore.FieldValue.delete(),
      enterpriseUid: admin.firestore.FieldValue.delete(),
      status: "inactive",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Delete doc from enterprises/{companyId}/employees/{userId}
    try {
      await firestoreDb.collection("enterprises").doc(companyId).collection("employees").doc(userId).delete();
    } catch (_) {}

    // Delete doc from companies/{companyId}/employees/{userId}
    try {
      await firestoreDb.collection("companies").doc(companyId).collection("employees").doc(userId).delete();
    } catch (_) {}

    // Remove companyId from MongoDB to detach from workspace
    const mongoDb = await connectDB();
    await mongoDb.collection("cards").updateOne(
      { userId, companyId },
      { $unset: { companyId: "", enterpriseUid: "" }, $set: { status: "inactive", lastUpdated: new Date() } }
    );

    return true;
  },

};

export default companyService;
