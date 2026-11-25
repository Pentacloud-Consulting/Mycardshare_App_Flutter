/**
 * Platform API Endpoints
 * For master_admin only. Do not allow cross-role access.
 */

import express from "express";
const router = express.Router();
import { verifyFirebaseToken } from "../middleware/auth";

const ROLE = { MASTER_ADMIN: 'master_admin' };

let admin;
let db;

const initializeFirebase = (adminInstance) => {
  admin = adminInstance;
  db = admin.firestore();
};

/** Resolve effective role: from token or Firestore (so master_admin signup without custom claims still works). */
async function ensureMasterAdmin(req, res) {
  if (!req.user || !req.user.uid) {
    res.status(401).json({ success: false, error: 'Authentication required' });
    return false;
  }
  if (req.user.role === ROLE.MASTER_ADMIN) return true;
  try {
    const userDoc = await db.collection('users').doc(req.user.uid).get();
    const role = userDoc.exists ? (userDoc.data() || {}).role : null;
    if (role === ROLE.MASTER_ADMIN) return true;
  } catch (_) {}
  res.status(403).json({ success: false, error: 'Forbidden: master_admin only' });
  return false;
}

/**
 * GET /api/platform/companies
 * List all companies (master_admin only). Includes super admin email per company. Excludes crmConfig, sensitive data, leads.
 */
router.get('/companies',
  (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
  async (req, res) => {
    try {
      if (!(await ensureMasterAdmin(req, res))) return;

      const snapshot = await db.collection('companies').get();
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
            const [authUser, userDoc] = await Promise.all([
              admin.auth().getUser(adminUserId).catch(() => null),
              db.collection('users').doc(adminUserId).get()
            ]);
            if (authUser && authUser.email) superAdminEmail = authUser.email;
            if (userDoc.exists && userDoc.data().phoneNumber) superAdminPhoneNumber = userDoc.data().phoneNumber;
          } catch (_) {}
        }
        companies.push({
          companyId: doc.id,
          companyName: data.companyName ?? null,
          subscriptionStart: subscriptionStart ? subscriptionStart.toISOString() : null,
          subscriptionEnd: subscriptionEnd ? subscriptionEnd.toISOString() : null,
          isSuspended: data.isSuspended === true,
          superAdminEmail,
          superAdminPhoneNumber
        });
      }

      return res.json({ success: true, companies });
    } catch (error) {
      console.error('Error listing platform companies:', error);
      return res.status(500).json({ success: false, error: 'Failed to list companies' });
    }
  }
);

/**
 * GET /api/platform/super-admins
 * List all users with role === "super_admin" (master_admin only).
 * Returns: userId, email, phoneNumber, companyId, companyName. No sensitive fields.
 */
router.get('/super-admins',
  (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
  async (req, res) => {
    try {
      if (!(await ensureMasterAdmin(req, res))) return;

      const snapshot = await db.collection('users')
        .where('role', '==', 'super_admin')
        .get();

      const list = [];
      for (const doc of snapshot.docs) {
        const data = doc.data();
        const userId = doc.id;
        const companyId = data.companyId || null;
        let email = null;
        let companyName = null;

        try {
          const authUser = await admin.auth().getUser(userId).catch(() => null);
          if (authUser && authUser.email) email = authUser.email;
        } catch (_) {}

        if (companyId) {
          try {
            const companyDoc = await db.collection('companies').doc(companyId).get();
            if (companyDoc.exists) {
              const c = companyDoc.data();
              companyName = c.companyName ?? null;
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

      return res.json({ success: true, superAdmins: list });
    } catch (error) {
      console.error('Error listing super admins:', error);
      return res.status(500).json({ success: false, error: 'Failed to list super admins' });
    }
  }
);

/**
 * GET /api/platform/companies/pending
 * List companies with approvalStatus === "pending" (master_admin only).
 * Returns: companyId, companyName, createdAt, superAdminEmail, superAdminPhoneNumber.
 */
router.get('/companies/pending',
  (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
  async (req, res) => {
    try {
      if (!(await ensureMasterAdmin(req, res))) return;

      const snapshot = await db.collection('companies')
        .where('approvalStatus', '==', 'pending')
        .get();

      const pending = [];
      for (const doc of snapshot.docs) {
        const data = doc.data();
        const companyId = data.companyId ?? doc.id;
        const adminUserId = data.adminUserId;
        let superAdminEmail = null;
        let superAdminPhoneNumber = null;

        if (adminUserId) {
          try {
            const [authUser, userDoc] = await Promise.all([
              admin.auth().getUser(adminUserId).catch(() => null),
              db.collection('users').doc(adminUserId).get()
            ]);
            if (authUser && authUser.email) superAdminEmail = authUser.email;
            if (userDoc.exists) {
              const u = userDoc.data();
              if (u.phoneNumber) superAdminPhoneNumber = u.phoneNumber;
            }
          } catch (_) {
            // leave superAdminEmail / superAdminPhoneNumber as null
          }
        }

        const createdAt = data.createdAt;
        pending.push({
          companyId,
          companyName: data.companyName ?? null,
          createdAt: createdAt && typeof createdAt.toDate === 'function' ? createdAt.toDate().toISOString() : null,
          superAdminEmail,
          superAdminPhoneNumber
        });
      }

      return res.json({ success: true, companies: pending });
    } catch (error) {
      console.error('Error listing pending companies:', error);
      return res.status(500).json({ success: false, error: 'Failed to list pending companies' });
    }
  }
);

/**
 * PATCH /api/platform/companies/:companyId/suspend
 * Set company suspension state (master_admin only).
 * Body: { isSuspended: boolean }
 */
router.patch('/companies/:companyId/suspend',
  (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
  async (req, res) => {
    try {
      if (!(await ensureMasterAdmin(req, res))) return;

      const { companyId } = req.params;
      const { isSuspended } = req.body;

      if (companyId == null || companyId === '') {
        return res.status(400).json({ success: false, error: 'companyId is required' });
      }
      if (typeof isSuspended !== 'boolean') {
        return res.status(400).json({ success: false, error: 'isSuspended must be a boolean' });
      }

      const ref = db.collection('companies').doc(companyId);
      const doc = await ref.get();
      if (!doc.exists) {
        return res.status(404).json({ success: false, error: 'Company not found' });
      }

      await ref.update({
        isSuspended,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      return res.json({ success: true, message: 'Company suspension updated', isSuspended });
    } catch (error) {
      console.error('Error updating company suspend:', error);
      return res.status(500).json({ success: false, error: 'Failed to update suspension' });
    }
  }
);

/**
 * PATCH /api/platform/companies/:companyId/approve
 * Set approvalStatus to "approved" and isSuspended to false (master_admin only).
 */
router.patch('/companies/:companyId/approve',
  (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
  async (req, res) => {
    try {
      if (!(await ensureMasterAdmin(req, res))) return;
      const { companyId } = req.params;
      if (!companyId) {
        return res.status(400).json({ success: false, error: 'companyId is required' });
      }
      const ref = db.collection('companies').doc(companyId);
      const snap = await ref.get();
      if (!snap.exists) {
        return res.status(404).json({ success: false, error: 'Company not found' });
      }
      await ref.update({
        approvalStatus: 'approved',
        isSuspended: false,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      return res.json({ success: true, message: 'Company approved' });
    } catch (error) {
      console.error('Error approving company:', error);
      return res.status(500).json({ success: false, error: 'Failed to approve company' });
    }
  }
);

/**
 * PATCH /api/platform/companies/:companyId/reject
 * Set approvalStatus to "rejected" (master_admin only).
 */
router.patch('/companies/:companyId/reject',
  (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
  async (req, res) => {
    try {
      if (!(await ensureMasterAdmin(req, res))) return;
      const { companyId } = req.params;
      if (!companyId) {
        return res.status(400).json({ success: false, error: 'companyId is required' });
      }
      const ref = db.collection('companies').doc(companyId);
      const snap = await ref.get();
      if (!snap.exists) {
        return res.status(404).json({ success: false, error: 'Company not found' });
      }
      await ref.update({
        approvalStatus: 'rejected',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      return res.json({ success: true, message: 'Company rejected' });
    } catch (error) {
      console.error('Error rejecting company:', error);
      return res.status(500).json({ success: false, error: 'Failed to reject company' });
    }
  }
);

/**
 * PATCH /api/platform/companies/:companyId/approval
 * Set approval state by action: "approve" | "reject" (master_admin only).
 * Body: { action: "approve" | "reject" }
 */
router.patch('/companies/:companyId/approval',
  (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
  async (req, res) => {
    try {
      if (!(await ensureMasterAdmin(req, res))) return;
      const companyId = req.params.companyId;
      if (!companyId) {
        return res.status(400).json({ success: false, error: 'companyId is required' });
      }
      const { action } = req.body || {};
      if (action !== 'approve' && action !== 'reject') {
        return res.status(400).json({ success: false, error: 'body.action must be "approve" or "reject"' });
      }
      const ref = db.collection('companies').doc(companyId);
      const snap = await ref.get();
      if (!snap.exists) {
        return res.status(404).json({ success: false, error: 'Company not found' });
      }
      if (action === 'approve') {
        await ref.update({
          approvalStatus: 'approved',
          isSuspended: false,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        return res.json({ success: true, message: 'Company approved', action: 'approve' });
      }
      await ref.update({
        approvalStatus: 'rejected',
        isSuspended: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      return res.json({ success: true, message: 'Company rejected', action: 'reject' });
    } catch (error) {
      console.error('Error updating company approval:', error);
      return res.status(500).json({ success: false, error: 'Failed to update approval' });
    }
  }
);

export default { router, initializeFirebase };
