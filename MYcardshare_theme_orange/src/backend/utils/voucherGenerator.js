/**
 * Voucher Code Generator Utility
 * Generates unique voucher codes for company employee signups
 */

import crypto from "crypto";

/**
 * Generate a unique voucher code
 * Format: XXXX-XXXX-XXXX (12 characters, alphanumeric)
 * 
 * @returns {string} Unique voucher code
 */
const generateVoucherCode = () => {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const segments = 3;
    const segmentLength = 4;

    const code = [];

    for (let i = 0; i < segments; i++) {
        let segment = '';
        for (let j = 0; j < segmentLength; j++) {
            const randomIndex = crypto.randomInt(0, characters.length);
            segment += characters[randomIndex];
        }
        code.push(segment);
    }

    return code.join('-');
};

/**
 * Generate a URL-friendly slug from company name
 * 
 * @param {string} companyName - Company name
 * @returns {string} URL-friendly slug
 */
const generateSlug = (companyName) => {
    return companyName
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9]+/g, '-') // Replace non-alphanumeric with hyphens
        .replace(/^-+|-+$/g, ''); // Remove leading/trailing hyphens
};

/**
 * Validate voucher code format
 * 
 * @param {string} code - Voucher code to validate
 * @returns {boolean} True if valid format
 */
const isValidVoucherFormat = (code) => {
    const voucherRegex = /^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$/;
    return voucherRegex.test(code);
};

/**
 * Calculate subscription end date (1 year from start)
 * 
 * @param {Date} startDate - Subscription start date
 * @returns {Date} Subscription end date
 */
const calculateSubscriptionEndDate = (startDate = new Date()) => {
    const endDate = new Date(startDate);
    endDate.setFullYear(endDate.getFullYear() + 1);
    return endDate;
};

/**
 * Check if subscription is active
 * 
 * @param {Date} endDate - Subscription end date
 * @returns {boolean} True if subscription is active
 */
const isSubscriptionActive = (endDate) => {
    return new Date() < new Date(endDate);
};

export default {
    generateVoucherCode,
    generateSlug,
    isValidVoucherFormat,
    calculateSubscriptionEndDate,
    isSubscriptionActive,
};
