import { firestoreDb, admin } from "../config/firebase";

const platformService = {
  /**
   * List all companies with super-admin context
   */
  async listCompanies() {
    const { connectDB } = await import("../config/db");
    const mongoDb = await connectDB();
    const [snapshot, cardsSnapshot] = await Promise.all([
      firestoreDb.collection("companies").get(),
      mongoDb.collection("cards").find({}, { projection: { companyId: 1, workspaceId: 1 } }).toArray()
    ]);

    const memberCounts = {};
    for (const card of cardsSnapshot) {
      const id = card.companyId || card.workspaceId;
      if (id) {
        memberCounts[id] = (memberCounts[id] || 0) + 1;
      }
    }

    const companies = [];

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const subscriptionStart = data.subscriptionStartDate?.toDate?.();
      const subscriptionEnd = data.subscriptionEndDate?.toDate?.();
      let superAdminEmail = null;
      let superAdminPhoneNumber = null;

      const adminUserId = data.adminUserId;
      if (adminUserId) {
        try {
          // Fetch Auth user and Firestore user in parallel
          const [authUser, userDoc] = await Promise.all([
            admin
              .auth()
              .getUser(adminUserId)
              .catch(() => null),
            firestoreDb.collection("users").doc(adminUserId).get(),
          ]);

          if (authUser && authUser.email) superAdminEmail = authUser.email;
          if (userDoc.exists && userDoc.data().phoneNumber) {
            superAdminPhoneNumber = userDoc.data().phoneNumber;
          }
        } catch (err) {
          console.warn(
            `⚠️ Failed to fetch admin context for user ${adminUserId}`,
          );
        }
      }

      companies.push({
        companyId: doc.id,
        companyName: data.companyName ?? null,
        subscriptionStart: subscriptionStart
          ? subscriptionStart.toISOString()
          : null,
        subscriptionEnd: subscriptionEnd ? subscriptionEnd.toISOString() : null,
        subscriptionStartDate: data.subscriptionStartDate?.toDate?.()?.toISOString?.() || null,
        renewalDate: data.renewalDate?.toDate?.()?.toISOString?.() || null,
        isSuspended: data.isSuspended === true,
        approvalStatus: data.approvalStatus || "pending",
        superAdminEmail,
        superAdminPhoneNumber,
        totalMembers: memberCounts[doc.id] || 0,
        slug: data.slug || null,
      });
    }

    return companies;
  },

  /**
   * List all super_admins across the platform
   */
  async listSuperAdmins() {
    const snapshot = await firestoreDb
      .collection("users")
      .where("role", "==", "super_admin")
      .get();

    const list = [];
    for (const doc of snapshot.docs) {
      const data = doc.data();
      const userId = doc.id;
      const companyId = data.companyId || null;
      let email = null;
      let companyName = null;

      try {
        const authUser = await admin
          .auth()
          .getUser(userId)
          .catch(() => null);
        if (authUser && authUser.email) email = authUser.email;
      } catch (_) {}

      if (companyId) {
        try {
          const companyDoc = await firestoreDb
            .collection("companies")
            .doc(companyId)
            .get();
          if (companyDoc.exists) {
            companyName = companyDoc.data().companyName ?? null;
          }
        } catch (_) {}
      }

      list.push({
        userId,
        email,
        phoneNumber: data.phoneNumber ?? null,
        companyId,
        companyName,
      });
    }

    return list;
  },

  /**
   * List all individual standalone users (no companyId)
   */
  async listIndividuals() {
    const { connectDB } = await import("../config/db");
    const mongoDb = await connectDB();

    const [usersSnap, cards] = await Promise.all([
      firestoreDb.collection("users").get(),
      mongoDb.collection("cards").find({}).toArray()
    ]);

    const cardMap = {};
    for (const card of cards) {
      if (card.userId) cardMap[card.userId] = card;
    }

    const individuals = [];
    for (const doc of usersSnap.docs) {
      const data = doc.data();
      const userId = doc.id;

      // Skip company users and master admins
      if (data.companyId) continue;
      const role = (data.role || "").toLowerCase();
      if (role === "master-admin" || role === "master_admin" || role === "super_admin" || role === "platform_admin") {
        continue;
      }

      const card = cardMap[userId] || {};
      const status = data.status || (card.cardStatus === "Published" ? "active" : "draft");

      individuals.push({
        id: userId,
        userId,
        fullName: data.displayName || data.fullName || card.fullName || "Individual User",
        email: data.email || card.workEmail || card.email || "",
        phoneNumber: data.phoneNumber || data.phone || card.phone || "",
        role: "individual",
        status: status.toLowerCase(),
        cardStatus: card.cardStatus || "Draft",
        cardSlug: card.slug || card.cardSlug || userId,
        avatarUrl: data.avatarUrl || data.photoURL || card.avatarUrl || null,
        themeColor: card.themeColor || "#0A84FF",
        views: card.views || 0,
        shares: card.shares || 0,
        createdAt: data.createdAt?.toDate?.()?.toISOString?.() || card.createdAt || new Date().toISOString(),
      });
    }

    return individuals;
  },

  /**
   * Update Company Approval/Suspension Status.
   * When approvalStatus changes, also update the admin user's status field
   * so the RBAC gate in the portal layout responds correctly.
   */
  async updateCompanyStatus(companyId, statusUpdates) {
    let ref = firestoreDb.collection("companies").doc(companyId);
    let doc = await ref.get();

    if (!doc.exists) {
      const byField = await firestoreDb
        .collection("companies")
        .where("companyId", "==", companyId)
        .limit(1)
        .get();
      if (!byField.empty) {
        doc = byField.docs[0];
        ref = doc.ref;
      } else {
        const bySlug = await firestoreDb
          .collection("companies")
          .where("slug", "==", companyId)
          .limit(1)
          .get();
        if (!bySlug.empty) {
          doc = bySlug.docs[0];
          ref = doc.ref;
        }
      }
    }

    if (!doc.exists) throw new Error("COMPANY_NOT_FOUND");

    const resolvedCompanyId = doc.id;

    // Convert Date objects to Firestore Timestamps for subscription fields
    const firestoreUpdates = { ...statusUpdates };
    if (firestoreUpdates.subscriptionStartDate instanceof Date) {
      firestoreUpdates.subscriptionStartDate = admin.firestore.Timestamp.fromDate(firestoreUpdates.subscriptionStartDate);
    }
    if (firestoreUpdates.renewalDate instanceof Date) {
      firestoreUpdates.renewalDate = admin.firestore.Timestamp.fromDate(firestoreUpdates.renewalDate);
    }

    await ref.update({
      ...firestoreUpdates,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Mirror to MongoDB companies collection if exists
    try {
      const { connectDB } = await import("../config/db");
      const mongoDb = await connectDB();
      await mongoDb.collection("companies").updateOne(
        { $or: [{ _id: resolvedCompanyId }, { id: resolvedCompanyId }, { companyId: resolvedCompanyId }, { slug: companyId }] },
        {
          $set: {
            status: statusUpdates.status || (statusUpdates.approvalStatus === "approved" ? "active" : "rejected"),
            approvalStatus: statusUpdates.approvalStatus,
            isSuspended: Boolean(statusUpdates.isSuspended),
            updatedAt: new Date(),
          },
        }
      );
    } catch (_) {}

    // Mirror approval status to the admin user's document
    if (statusUpdates.approvalStatus) {
      const companyData = doc.data();
      const adminUserId = companyData.adminUserId;
      if (adminUserId) {
        try {
          await firestoreDb
            .collection("users")
            .doc(adminUserId)
            .set(
              {
                companyId,
                status: statusUpdates.approvalStatus === "approved" ? "active" : statusUpdates.approvalStatus,
                approvalStatus: statusUpdates.approvalStatus,
                role: "enterprise",
                isSuspended: Boolean(statusUpdates.isSuspended),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              { merge: true },
            );
          console.log(
            `[platform] Updated user ${adminUserId} status → ${statusUpdates.approvalStatus}`,
          );
        } catch (err) {
          console.error(
            `[platform] Failed to update admin user status for ${adminUserId}:`,
            err,
          );
          // Non-fatal — company status was updated successfully
        }
      }
    }

    // Cascade employee status when company is suspended or inactive
    let cascadeStatus = null;
    if (statusUpdates.isSuspended === true || ['suspended', 'expired', 'inactive'].includes(statusUpdates.subscriptionStatus)) {
      cascadeStatus = 'inactive';
    } else if (statusUpdates.isSuspended === false || statusUpdates.subscriptionStatus === 'active') {
      cascadeStatus = 'active';
    }

    if (cascadeStatus) {
      try {
        const { connectDB } = await import("../config/db");
        const mongoDb = await connectDB();
        
        // 1. Update all users in Firestore
        const usersSnap = await firestoreDb.collection("users").where("companyId", "==", companyId).get();
        if (!usersSnap.empty) {
          const batch = firestoreDb.batch();
          usersSnap.docs.forEach(uDoc => {
            if (uDoc.data().role !== "master_admin") {
              const uPayload = {
                status: cascadeStatus,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              };
              if (cascadeStatus === 'inactive') {
                uPayload.cardStatus = "Draft";
              }
              batch.update(uDoc.ref, uPayload);
            }
          });
          await batch.commit();
        }

        // 2. Update all cards in MongoDB
        const mongoPayload = { status: cascadeStatus, lastUpdated: new Date() };
        if (cascadeStatus === 'inactive') {
          mongoPayload.cardStatus = "Draft";
        }
        await mongoDb.collection("cards").updateMany(
          { companyId },
          { $set: mongoPayload }
        );
        console.log(`[platform] Cascaded ${cascadeStatus} status to all employees of company ${companyId}`);
      } catch (err) {
        console.error(`[platform] Failed to cascade status for company ${companyId}:`, err);
      }
    }

    return true;
  },

  /**
   * List all individual (non-enterprise) users.
   * An "individual" is any user who does NOT have a companyId —
   * i.e. they registered standalone and are not part of any workspace.
   *
   * PERF: Uses batch Firebase Auth lookup + single MongoDB query
   * instead of per-user sequential calls.
   */
  async listIndividuals() {
    const { connectDB } = await import("../config/db");
    const mongoDb = await connectDB();

    // 1. Fetch all Firestore users in one shot
    const snapshot = await firestoreDb.collection("users").get();

    // 2. Filter to individuals first (fast, in-memory)
    const individualDocs = [];
    for (const doc of snapshot.docs) {
      const data = doc.data();
      if (data.companyId) continue;
      if (["master_admin", "platform_admin", "super_admin"].includes(data.role)) continue;
      individualDocs.push({ id: doc.id, data });
    }

    if (individualDocs.length === 0) return [];

    const userIds = individualDocs.map((d) => d.id);

    // 3. Batch Firebase Auth lookup (max 100 per call)
    const emailMap = {};
    try {
      const chunks = [];
      for (let i = 0; i < userIds.length; i += 100) {
        chunks.push(userIds.slice(i, i + 100));
      }
      const results = await Promise.all(
        chunks.map((chunk) =>
          admin.auth().getUsers(chunk.map((uid) => ({ uid }))).catch(() => ({ users: [] }))
        )
      );
      for (const result of results) {
        for (const u of result.users || []) {
          if (u.email) emailMap[u.uid] = u.email;
        }
      }
    } catch (_) {}

    // 4. Single MongoDB query to fetch all cards for these users
    const cardMap = {};
    try {
      const cards = await mongoDb
        .collection("cards")
        .find({ userId: { $in: userIds } })
        .toArray();
      for (const card of cards) {
        cardMap[card.userId] = card;
      }
    } catch (_) {}

    // 5. Assemble results (pure in-memory, instant)
    const individuals = individualDocs.map(({ id: userId, data }) => {
      const cardData = cardMap[userId] || null;
      const email = emailMap[userId] || data.email || data.workEmail || cardData?.workEmail || "N/A";

      return {
        id: userId,
        userId,
        fullName: data.fullName || data.displayName || cardData?.fullName || "N/A",
        email,
        username: data.cardSlug || cardData?.cardSlug || userId,
        phone: data.phoneNumber || cardData?.phoneNumber || null,
        createdAt: data.createdAt?.toDate?.()?.toISOString?.() || data.createdAt || null,
        profileStatus: data.cardStatus === "Published" || cardData?.cardStatus === "Published" ? "ACTIVE" : "DRAFT",
        cardSlug: data.cardSlug || cardData?.cardSlug || null,
        avatarUrl: data.avatarUrl || cardData?.avatarUrl || null,
        role: data.role || "individual",
      };
    });

    return individuals;
  },

  /**
   * Delete an individual user and all related data.
   * Removes: Firebase Auth account, Firestore user doc, MongoDB card + leads.
   */
  async deleteIndividual(userId) {
    if (!userId) throw new Error("MISSING_USER_ID");

    const { connectDB } = await import("../config/db");
    const mongoDb = await connectDB();

    // Verify the user is actually an individual (no companyId)
    const userDoc = await firestoreDb.collection("users").doc(userId).get();
    if (userDoc.exists) {
      const userData = userDoc.data();
      if (userData.companyId) {
        throw new Error("USER_IS_NOT_INDIVIDUAL");
      }
    }

    // 1. Delete from Firebase Auth
    try {
      await admin.auth().deleteUser(userId);
      console.log(`[platform] Deleted Firebase Auth user: ${userId}`);
    } catch (err) {
      console.warn(`[platform] Could not delete Auth user ${userId}:`, err?.message);
    }

    // 2. Delete from Firestore users collection
    try {
      await firestoreDb.collection("users").doc(userId).delete();
      console.log(`[platform] Deleted Firestore user doc: ${userId}`);
    } catch (err) {
      console.warn(`[platform] Could not delete Firestore user ${userId}:`, err?.message);
    }

    // 3. Delete card from MongoDB
    try {
      await mongoDb.collection("cards").deleteMany({ userId });
      console.log(`[platform] Deleted MongoDB cards for: ${userId}`);
    } catch (err) {
      console.warn(`[platform] Could not delete cards for ${userId}:`, err?.message);
    }

    // 4. Delete leads from MongoDB
    try {
      await mongoDb.collection("leads").deleteMany({ userId });
      console.log(`[platform] Deleted MongoDB leads for: ${userId}`);
    } catch (err) {
      console.warn(`[platform] Could not delete leads for ${userId}:`, err?.message);
    }

    return true;
  },
};

export default platformService;
