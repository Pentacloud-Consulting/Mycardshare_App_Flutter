/**
 * Company API Endpoints
 * Handles company management for multi-tenant architecture
 */

import express from "express";
const router = express.Router();
import fs from "fs";
import path from "path";
const LOGOS_PATH = path.join(__dirname, '..', 'uploads', 'company-logos');
import { validateCompany, defaultSettings } from "../models/CompanySchema";
import {
    generateVoucherCode,
    generateSlug,
    calculateSubscriptionEndDate,
    isSubscriptionActive
} from "../utils/voucherGenerator";

// Import Auth Middleware
import {
    verifyCompanyAccess,
    requireAdmin,
    checkSubscription,
    checkCompanySuspended,
    verifyFirebaseToken
} from "../middleware/auth";

/** Block master_admin from company dashboard routes (master_admin must not access company dashboard). */
function rejectPlatformAdmin(req, res, next) {
    if (req.user && req.user.role === 'master_admin') {
        return res.status(403).json({ success: false, error: 'Forbidden: master_admin cannot access company dashboard' });
    }
    next();
}

// Note: Firebase Admin SDK should be initialized in server.js
// We'll use it here for Firestore operations
let admin, db, getMongoDb;

const initializeFirebase = (adminInstance, mongoConnFunc) => {
    admin = adminInstance;
    db = admin.firestore();
    getMongoDb = mongoConnFunc;
};

/**
 * POST /api/company/create
 * Create a new company (Admin signup)
 */
router.post('/create', async (req, res) => {
    try {
        const { companyName, companyEmail, companyLogo, companyWebsite, adminUserId, slug, phoneNumber } = req.body;

        const digitsOnly = (v) => (typeof v === 'string' ? v.replace(/\D/g, '') : String(v || '').replace(/\D/g, ''));
        const phoneDigits = digitsOnly(phoneNumber);
        if (!phoneNumber || typeof phoneNumber !== 'string' || !phoneNumber.trim()) {
            return res.status(400).json({ success: false, error: 'Phone number is required' });
        }
        if (phoneDigits.length < 8) {
            return res.status(400).json({ success: false, error: 'Phone number must have at least 8 digits' });
        }

        const companyData = {
            companyName,
            companyEmail,
            adminUserId,
            slug: slug || generateSlug(companyName),
        };

        const validationErrors = validateCompany(companyData);
        if (validationErrors.length > 0) {
            return res.status(400).json({
                success: false,
                errors: validationErrors
            });
        }

        // Check if slug already exists
        const slugQuery = await db.collection('companies')
            .where('slug', '==', companyData.slug)
            .get();

        if (!slugQuery.empty) {
            return res.status(409).json({
                success: false,
                error: 'Company slug already exists. Please choose another.'
            });
        }

        // Generate unique voucher code
        let voucherCode;
        let voucherExists = true;

        while (voucherExists) {
            voucherCode = generateVoucherCode();
            const voucherQuery = await db.collection('companies')
                .where('voucherCode', '==', voucherCode)
                .get();
            voucherExists = !voucherQuery.empty;
        }

        // Create company document
        const companyRef = db.collection('companies').doc();
        const companyId = companyRef.id;

        const subscriptionStartDate = new Date();
        const subscriptionEndDate = calculateSubscriptionEndDate(subscriptionStartDate);

        const company = {
            companyId,
            companyName,
            companyEmail,
            companyLogo: companyLogo || null,
            companyWebsite: companyWebsite || null,
            adminUserId,
            voucherCode,
            slug: companyData.slug,
            subscriptionStartDate: admin.firestore.Timestamp.fromDate(subscriptionStartDate),
            subscriptionEndDate: admin.firestore.Timestamp.fromDate(subscriptionEndDate),
            status: 'active',
            approvalStatus: 'pending',
            isSuspended: true,
            settings: defaultSettings,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        await companyRef.set(company);

        await db.collection('users').doc(adminUserId).set({
            companyId,
            role: 'super_admin',
            phoneNumber: String(phoneNumber || '').trim(),
        }, { merge: true });

        res.status(201).json({
            success: true,
            company: {
                ...company,
                subscriptionStartDate: subscriptionStartDate.toISOString(),
                subscriptionEndDate: subscriptionEndDate.toISOString(),
            }
        });

    } catch (error) {
        console.error('Error creating company:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to create company'
        });
    }
});

/**
 * PATCH /api/company/crm-config
 * Update company CRM config (webhook, etc.). company_admin or super_admin; master_admin not allowed.
 */
router.patch('/crm-config',
    (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
    (req, res, next) => checkCompanySuspended(db)(req, res, next),
    async (req, res) => {
        try {
            const user = req.user;
            if (!user) {
                return res.status(401).json({ success: false, error: 'Authentication required' });
            }
            const { companyId, role } = user;
            if (!companyId) {
                return res.status(400).json({ success: false, error: 'Company ID is required' });
            }
            if (role === 'master_admin') {
                return res.status(403).json({ success: false, error: 'Forbidden: master_admin cannot update CRM config' });
            }
            const allowedRoles = ['company_admin', 'super_admin'];
            if (!role || !allowedRoles.includes(role)) {
                return res.status(403).json({ success: false, error: 'Forbidden: only company_admin or super_admin can update CRM config' });
            }

            const { enabled, webhookUrl, secretToken, zapierEnabled, zapierWebhookUrl } = req.body || {};

            if (typeof enabled !== 'boolean') {
                return res.status(400).json({ success: false, error: 'enabled must be a boolean' });
            }
            if (enabled) {
                if (typeof webhookUrl !== 'string' || !webhookUrl.trim()) {
                    return res.status(400).json({ success: false, error: 'webhookUrl is required when enabled is true' });
                }
                try {
                    new URL(webhookUrl.trim());
                } catch (_) {
                    return res.status(400).json({ success: false, error: 'webhookUrl must be a valid URL' });
                }
            }

            if (zapierEnabled !== undefined && typeof zapierEnabled !== 'boolean') {
                return res.status(400).json({ success: false, error: 'zapierEnabled must be a boolean' });
            }
            if (zapierEnabled) {
                if (typeof zapierWebhookUrl !== 'string' || !zapierWebhookUrl.trim()) {
                    return res.status(400).json({ success: false, error: 'zapierWebhookUrl is required when zapierEnabled is true' });
                }
                try {
                    new URL(zapierWebhookUrl.trim());
                } catch (_) {
                    return res.status(400).json({ success: false, error: 'zapierWebhookUrl must be a valid URL' });
                }
            }

            const crmConfig = {
                enabled,
                webhookUrl: webhookUrl != null ? String(webhookUrl).trim() : '',
                secretToken: secretToken != null ? String(secretToken) : null,
                zapierEnabled: zapierEnabled === true,
                zapierWebhookUrl: zapierWebhookUrl != null ? String(zapierWebhookUrl).trim() : '',
            };

            const companyRef = db.collection('companies').doc(companyId);
            await companyRef.set(
                { crmConfig, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
                { merge: true }
            );

            return res.status(200).json({ success: true, message: 'CRM config updated' });
        } catch (error) {
            console.error('Error updating CRM config:', error);
            return res.status(500).json({ success: false, error: error.message || 'Failed to update CRM config' });
        }
    }
);

/**
 * PATCH /api/company/users/:userId/role
 * Update a user's role within the same company. super_admin only; company_admin cannot access.
 * Body: { role: "agent" | "company_admin" }
 * Target user must belong to caller's companyId. Cannot modify master_admin.
 */
router.patch('/users/:userId/role',
    (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
    async (req, res) => {
        try {
            const caller = req.user;
            if (!caller) {
                return res.status(401).json({ success: false, error: 'Authentication required' });
            }
            if (caller.role !== 'super_admin') {
                return res.status(403).json({ success: false, error: 'Forbidden: only super_admin can update user role' });
            }
            const callerCompanyId = caller.companyId;
            if (!callerCompanyId) {
                return res.status(400).json({ success: false, error: 'Company ID is required' });
            }

            const { userId } = req.params;
            const { role: newRole } = req.body || {};
            if (!userId) {
                return res.status(400).json({ success: false, error: 'userId is required' });
            }
            const allowedRoles = ['agent', 'company_admin'];
            if (!newRole || !allowedRoles.includes(newRole)) {
                return res.status(400).json({ success: false, error: 'role must be "agent" or "company_admin"' });
            }

            const targetRef = db.collection('users').doc(userId);
            const targetSnap = await targetRef.get();
            if (!targetSnap.exists) {
                return res.status(404).json({ success: false, error: 'User not found' });
            }
            const targetData = targetSnap.data();
            if (targetData.companyId !== callerCompanyId) {
                return res.status(403).json({ success: false, error: 'Target user does not belong to your company' });
            }
            if (targetData.role === 'master_admin') {
                return res.status(403).json({ success: false, error: 'Cannot modify master_admin role' });
            }

            const firestoreRole = newRole === 'company_admin' ? 'admin' : newRole === 'agent' ? 'employee' : newRole;
            await targetRef.update({
                role: firestoreRole,
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

            return res.status(200).json({ success: true, message: 'User role updated', role: newRole });
        } catch (error) {
            console.error('Error updating user role:', error);
            return res.status(500).json({ success: false, error: 'Failed to update user role' });
        }
    }
);

/**
 * GET /api/company/:companyId
 * Get company details
 * Secured: Company Access Only
 */
router.get('/:companyId',
    (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
    rejectPlatformAdmin,
    (req, res, next) => verifyCompanyAccess(db)(req, res, next),
    async (req, res) => {
        try {
            // req.userData is set by verifyCompanyAccess
            const { companyId } = req.params;

            // Get company document
            const companyDoc = await db.collection('companies').doc(companyId).get();

            if (!companyDoc.exists) {
                return res.status(404).json({
                    success: false,
                    error: 'Company not found'
                });
            }

            const company = companyDoc.data();

            res.json({
                success: true,
                company: {
                    ...company,
                    subscriptionStartDate: company.subscriptionStartDate?.toDate().toISOString(),
                    subscriptionEndDate: company.subscriptionEndDate?.toDate().toISOString(),
                    createdAt: company.createdAt?.toDate().toISOString(),
                    updatedAt: company.updatedAt?.toDate().toISOString(),
                }
            });

        } catch (error) {
            console.error('Error fetching company:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to fetch company'
            });
        }
    });

/**
 * GET /api/company/:companyId/public-branding
 * PUBLIC endpoint to fetch company branding info (logo, banner, color) for employee cards
 * No authentication required
 */
router.get('/:companyId/public-branding', async (req, res) => {
    try {
        const { companyId } = req.params;
        const companyDoc = await db.collection('companies').doc(companyId).get();

        if (!companyDoc.exists) {
            return res.status(404).json({ success: false, error: 'Company not found' });
        }

        const data = companyDoc.data();
        res.json({
            success: true,
            branding: {
                companyName: data.companyName,
                companyLogo: data.companyLogo,
                companyBanner: data.companyBanner || data.bannerUrl, // Fallback to old field names if necessary
                themeColor: data.themeColor || '#1e293b'
            }
        });
    } catch (error) {
        console.error('Error fetching public branding:', error);
        res.status(500).json({ success: false, error: 'Internal server error' });
    }
});

/**
 * PUT /api/company/:companyId
 * Update company details (Admin only)
 * Secured: Admin Only + Subscription Check
 */
router.put('/:companyId',
    (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
    rejectPlatformAdmin,
    (req, res, next) => verifyCompanyAccess(db)(req, res, next),
    requireAdmin,
    (req, res, next) => checkSubscription(db)(req, res, next),
    async (req, res) => {
        try {
            const { companyId } = req.params;
            const { updates } = req.body || {};
            const role = req.user?.role;

            const hasSubscriptionUpdate = updates.subscriptionStartDate !== undefined || updates.subscriptionEndDate !== undefined;
            if (hasSubscriptionUpdate && role !== 'super_admin') {
                return res.status(403).json({
                    success: false,
                    error: 'Only Super Admin can modify subscription details.'
                });
            }

            const baseAllowedFields = ['companyName', 'slug', 'companyEmail', 'companyLogo', 'companyBanner', 'themeColor', 'companyWebsite', 'settings'];
            const subscriptionFields = ['subscriptionStartDate', 'subscriptionEndDate'];
            const allowedFields = baseAllowedFields.concat(role === 'super_admin' ? subscriptionFields : []);
            const updateData = {};

            for (const field of allowedFields) {
                if (updates[field] === undefined) continue;
                if (subscriptionFields.includes(field)) {
                    const val = updates[field];
                    const date = val && (typeof val.toDate === 'function') ? val.toDate() : new Date(val);
                    if (!isNaN(date.getTime())) {
                        updateData[field] = admin.firestore.Timestamp.fromDate(date);
                    }
                } else {
                    updateData[field] = updates[field];
                }
            }

            updateData.updatedAt = admin.firestore.FieldValue.serverTimestamp();

            await db.collection('companies').doc(companyId).update(updateData);

            res.json({
                success: true,
                message: 'Company updated successfully'
            });

        } catch (error) {
            console.error('Error updating company:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to update company'
            });
        }
    });

/**
 * POST /api/company/:companyId/logo
 * Upload logo to GCS (Admin only)
 */
router.post('/:companyId/logo',
    (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
    rejectPlatformAdmin,
    (req, res, next) => verifyCompanyAccess(db)(req, res, next),
    requireAdmin,
    async (req, res) => {
        try {
            const { companyId } = req.params;
            const { logoBase64, fileName } = req.body;

            if (!logoBase64) {
                return res.status(400).json({ success: false, error: 'No logo data provided' });
            }

            // Extract base64 data
            const matches = logoBase64.match(/^data:image\/([a-zA-Z+]+);base64,(.+)$/);
            if (!matches) {
                return res.status(400).json({ success: false, error: 'Invalid image format' });
            }

            const ext = matches[1];
            const data = matches[2];
            const buffer = Buffer.from(data, 'base64');
            const safeName = `${companyId}_logo_${Date.now()}.${ext}`;
            const contentType = `image/${ext}`;

            let publicUrl;
            if (global.gcsBucket) {
                const blob = global.gcsBucket.file(`company-logos/${safeName}`);
                await new Promise((resolve, reject) => {
                    const stream = blob.createWriteStream({ resumable: false, metadata: { contentType } });
                    stream.on('error', reject);
                    stream.on('finish', resolve);
                    stream.end(buffer);
                });
                publicUrl = `https://storage.googleapis.com/${global.gcsBucket.name}/company-logos/${safeName}`;
                console.log(`✅ Logo uploaded to GCS for ${companyId}: ${publicUrl}`);
            } else {
                if (!fs.existsSync(LOGOS_PATH)) fs.mkdirSync(LOGOS_PATH, { recursive: true });
                fs.writeFileSync(path.join(LOGOS_PATH, safeName), buffer);
                const backendUrl = (process.env.BACKEND_URL || 'https://digitalbusinesscloudcard.com').replace(/\/$/, '');
                publicUrl = `${backendUrl}/uploads/company-logos/${safeName}`;
                console.log(`⚠️  GCS unavailable — logo saved locally: ${publicUrl}`);
            }

            // Update Firestore
            await db.collection('companies').doc(companyId).update({
                companyLogo: publicUrl,
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

            res.json({
                success: true,
                logoUrl: publicUrl
            });

        } catch (error) {
            console.error('Error uploading logo:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to upload logo: ' + error.message
            });
        }
    });

/**
 * POST /api/company/:companyId/banner
 * Upload banner image to GCS (Admin only)
 */
router.post('/:companyId/banner',
    (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
    rejectPlatformAdmin,
    (req, res, next) => verifyCompanyAccess(db)(req, res, next),
    requireAdmin,
    async (req, res) => {
        try {
            const { companyId } = req.params;
            const { bannerBase64, fileName } = req.body;

            if (!bannerBase64) {
                return res.status(400).json({ success: false, error: 'No banner data provided' });
            }

            // Extract base64 data
            const matches = bannerBase64.match(/^data:image\/([a-zA-Z+]+);base64,(.+)$/);
            if (!matches) {
                return res.status(400).json({ success: false, error: 'Invalid image format' });
            }

            const ext = matches[1];
            const data = matches[2];
            const buffer = Buffer.from(data, 'base64');
            const safeName = `${companyId}_banner_${Date.now()}.${ext}`;
            const contentType = `image/${ext}`;

            let publicUrl;
            if (global.gcsBucket) {
                const blob = global.gcsBucket.file(`company-banners/${safeName}`);
                await new Promise((resolve, reject) => {
                    const stream = blob.createWriteStream({ resumable: false, metadata: { contentType } });
                    stream.on('error', reject);
                    stream.on('finish', resolve);
                    stream.end(buffer);
                });
                publicUrl = `https://storage.googleapis.com/${global.gcsBucket.name}/company-banners/${safeName}`;
                console.log(`✅ Banner uploaded to GCS for ${companyId}: ${publicUrl}`);
            } else {
                if (!fs.existsSync(LOGOS_PATH)) fs.mkdirSync(LOGOS_PATH, { recursive: true });
                fs.writeFileSync(path.join(LOGOS_PATH, safeName), buffer);
                const backendUrl = (process.env.BACKEND_URL || 'https://digitalbusinesscloudcard.com').replace(/\/$/, '');
                publicUrl = `${backendUrl}/uploads/company-logos/${safeName}`;
                console.log(`⚠️  GCS unavailable — banner saved locally: ${publicUrl}`);
            }

            // Update Firestore
            await db.collection('companies').doc(companyId).update({
                companyBanner: publicUrl,
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

            res.json({
                success: true,
                bannerUrl: publicUrl
            });

        } catch (error) {
            console.error('Error uploading banner:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to upload banner: ' + error.message
            });
        }
    });

/**
 * GET /api/company/:companyId/employees
 * Get all employees for a company (Admin only)
 * Secured: Admin Only
 */
router.get('/:companyId/employees',
    (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
    rejectPlatformAdmin,
    (req, res, next) => verifyCompanyAccess(db)(req, res, next),
    requireAdmin,
    async (req, res) => {
        try {
            const { companyId } = req.params;

            if (!getMongoDb) {
                throw new Error('MongoDB connection function not initialized');
            }

            const mongoDb = await getMongoDb();
            const cardsCollection = mongoDb.collection('cards');

            // Find all cards linked to this company
            const employeeCards = await cardsCollection.find({ companyId: companyId }).toArray();

            const employees = employeeCards.map(card => ({
                id: card._id,
                userId: card.userId,
                fullName: card.fullName || 'N/A',
                email: card.workEmail || card.email || 'N/A',
                jobTitle: card.jobTitle || 'N/A',
                role: card.role || 'employee',
                cardStatus: card.cardStatus || 'Draft',
                slug: card.cardSlug || card.userId, // Added slug for direct viewing
                createdAt: card.createdAt,
                lastUpdated: card.lastUpdated
            }));

            // Sort by creation date (newest first)
            employees.sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));

            res.json({
                success: true,
                employees
            });

        } catch (error) {
            console.error('Error fetching employees from MongoDB:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to fetch employees'
            });
        }
    });

/**
 * GET /api/company/:companyId/employees/:userId
 * Get full profile of a single employee
 * Secured: Admin Only
 */
router.get('/:companyId/employees/:userId',
    (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
    rejectPlatformAdmin,
    (req, res, next) => verifyCompanyAccess(db)(req, res, next),
    requireAdmin,
    async (req, res) => {
        try {
            const { companyId, userId } = req.params;

            if (!getMongoDb) {
                throw new Error('MongoDB connection function not initialized');
            }

            const mongoDb = await getMongoDb();
            const cardsCollection = mongoDb.collection('cards');

            const card = await cardsCollection.findOne({ userId: userId, companyId: companyId });

            if (!card) {
                return res.status(404).json({ success: false, error: 'Employee profile not found' });
            }

            res.json({ success: true, profile: card });

        } catch (error) {
            console.error('Error fetching employee profile:', error);
            res.status(500).json({ success: false, error: 'Failed to fetch employee profile' });
        }
    });

/**
 * DELETE /api/company/:companyId/employees/:userId
 * Remove an employee from the company
 * Secured: Admin Only
 */
router.delete('/:companyId/employees/:userId',
    (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
    rejectPlatformAdmin,
    (req, res, next) => verifyCompanyAccess(db)(req, res, next),
    requireAdmin,
    async (req, res) => {
        try {
            const { companyId, userId } = req.params;

            // 1. Unlink in Firestore (Users collection)
            const userRef = db.collection('users').doc(userId);
            const userDoc = await userRef.get();

            if (!userDoc.exists) {
                return res.status(404).json({ success: false, error: 'User not found' });
            }

            if (userDoc.data().companyId !== companyId) {
                return res.status(400).json({ success: false, error: 'User does not belong to this company' });
            }

            await userRef.update({
                companyId: admin.firestore.FieldValue.delete(),
                role: admin.firestore.FieldValue.delete() // Remove admin/employee role context
            });

            // 2. Update in MongoDB (Cards collection)
            if (getMongoDb) {
                const mongoDb = await getMongoDb();
                const cardsCollection = mongoDb.collection('cards');
                await cardsCollection.updateOne(
                    { userId: userId, companyId: companyId },
                    {
                        $set: {
                            companyId: null,
                            cardStatus: 'private', // Revert to private/personal card
                            lastUpdated: new Date()
                        }
                    }
                );
            }

            res.json({
                success: true,
                message: 'Employee removed successfully'
            });

        } catch (error) {
            console.error('Error removing employee:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to remove employee'
            });
        }
    });

/**
 * POST /api/company/:companyId/invite
 * Invite a new member
 * Secured: Admin Only
 */
router.post('/:companyId/invite',
    (req, res, next) => verifyFirebaseToken(admin)(req, res, next),
    rejectPlatformAdmin,
    (req, res, next) => verifyCompanyAccess(db)(req, res, next),
    requireAdmin,
    async (req, res) => {
        try {
            const { companyId } = req.params;
            const { email } = req.body;

            if (!email) {
                return res.status(400).json({ success: false, error: 'Email is required' });
            }

            // In a real app, this would send an email via SendGrid/AWS SES
            // and create a record in an 'invitations' collection.
            console.log(`📧 Sending invitation to ${email} for company ${companyId}`);

            // Simulate delay
            await new Promise(resolve => setTimeout(resolve, 500));

            res.json({
                success: true,
                message: `Invitation sent to ${email}`
            });

        } catch (error) {
            console.error('Error sending invitation:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to send invitation'
            });
        }
    });

/**
 * POST /api/company/validate-voucher
 * Validate voucher code for employee signup
 * Accepts companyId and voucherCode
 */
router.post('/validate-voucher', async (req, res) => {
    try {
        const { voucherCode, companyId } = req.body;

        if (!voucherCode || !companyId) {
            return res.status(400).json({
                success: false,
                error: 'Voucher code and company ID are required'
            });
        }

        // Find company by ID
        const companyDoc = await db.collection('companies').doc(companyId).get();

        if (!companyDoc.exists) {
            return res.status(404).json({
                success: false,
                error: 'Company not found'
            });
        }

        const company = companyDoc.data();

        // Validate voucher code matches this company
        if (company.voucherCode !== voucherCode) {
            return res.status(401).json({
                success: false,
                error: 'Invalid voucher code for this company'
            });
        }

        // Check subscription status
        const subscriptionEndDate = company.subscriptionEndDate?.toDate();
        const isActive = isSubscriptionActive(subscriptionEndDate);

        if (!isActive || company.status !== 'active') {
            return res.status(403).json({
                success: false,
                error: 'Company subscription has expired. Please contact your administrator.'
            });
        }

        res.json({
            success: true,
            company: {
                companyId: company.companyId,
                companyName: company.companyName,
                companyLogo: company.companyLogo,
                companyWebsite: company.companyWebsite,
                voucherCode: company.voucherCode,
                subscriptionActive: isActive,
                subscriptionEndDate: subscriptionEndDate?.toISOString(),
                settings: company.settings,
            }
        });

    } catch (error) {
        console.error('Error validating voucher:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to validate voucher'
        });
    }
});

/**
 * GET /api/company/check-slug/:slug
 * Check if company slug is available
 */
router.get('/check-slug/:slug', async (req, res) => {
    try {
        const { slug } = req.params;

        const slugQuery = await db.collection('companies')
            .where('slug', '==', slug)
            .limit(1)
            .get();

        res.json({
            success: true,
            available: slugQuery.empty
        });

    } catch (error) {
        console.error('Error checking slug:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to check slug availability'
        });
    }
});

export default { router, initializeFirebase };
