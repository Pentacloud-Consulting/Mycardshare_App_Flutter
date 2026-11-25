/**
 * MongoDB Schema Definitions for Digital Business Card Application
 * Database: business_cards
 *
 * These are the expected document structures stored in MongoDB.
 * Since we're using the native MongoDB driver (not Mongoose),
 * validation is done at the application level.
 */

/**
 * Collection: cards
 *
 * Stores user digital business card data.
 *
 * @typedef {Object} CardDocument
 * @property {string} userId - Firebase UID (unique, required)
 * @property {string} email - User's email address
 * @property {string} fullName - Full name displayed on card
 * @property {string} [jobTitle] - Job title/position
 * @property {string} [companyName] - Company/organization name
 * @property {string} [workEmail] - Business email
 * @property {string} [workPhone] - Business phone number
 * @property {string} [website] - Website URL
 * @property {string} [address] - Street address
 * @property {string} [city] - City
 * @property {string} [country] - Country
 * @property {string} [aboutMe] - Bio/description
 * @property {string} [avatarUrl] - Profile picture (base64 or URL)
 * @property {string} [bannerUrl] - Banner image (base64 or URL)
 * @property {string} [themeColor] - Hex color code for card theme
 * @property {string} [linkedin] - LinkedIn profile URL
 * @property {string} [twitter] - Twitter/X profile URL
 * @property {string} [facebook] - Facebook profile URL
 * @property {string} [instagram] - Instagram profile URL
 * @property {string} [whatsapp] - WhatsApp URL/Number
 * @property {string} [github] - GitHub profile URL
 * @property {string} [youtube] - YouTube channel URL
 * @property {string} [calendly] - Calendly link
 * @property {string} [networkingStatus] - Networking status
 * @property {Array<string>} [focusAreas] - Focus areas/keywords
 * @property {string} [primaryHQ] - Primary headquarters/location
 * @property {Array<{name: string, url: string}>} [certificates] - Uploaded certificates
 * @property {string} [brochureUrl] - Brochure/CV file (base64 or URL)
 * @property {string} [brochureName] - Brochure filename
 * @property {string} [experience] - Experience matrix text
 * @property {string} cardSlug - Unique URL slug for public card
 * @property {string} cardStatus - 'Draft' | 'Published'
 * @property {boolean} [isDeleted] - Soft delete flag (default: false)
 * @property {string} [deletedAt] - ISO date string when card was soft deleted
 * @property {string} [deleteExpiresAt] - ISO date string when card will be permanently deleted (24h after deletedAt)
 * @property {string} createdAt - ISO date string
 * @property {string} lastUpdated - ISO date string
 */

/**
 * Indexes:
 * - { userId: 1 } - unique
 * - { cardSlug: 1 } - sparse (allows nulls, but unique when present)
 */

// Example document structure for reference:
const exampleCard = {
  userId: "firebase_uid_abc123",
  email: "user@example.com",
  fullName: "John Doe",
  jobTitle: "Software Engineer",
  companyName: "Tech Corp",
  workEmail: "john@techcorp.com",
  workPhone: "+1-555-0123",
  website: "https://johndoe.com",
  address: "123 Main St",
  city: "San Francisco",
  country: "USA",
  aboutMe: "Passionate developer with 10+ years experience",
  avatarUrl: "data:image/jpeg;base64,/9j/4AAQ...",
  bannerUrl: "data:image/png;base64,iVBORw0...",
  themeColor: "#6366f1",
  linkedin: "https://linkedin.com/in/johndoe",
  twitter: "https://twitter.com/johndoe",
  certificates: [
    { name: "AWS_Certificate.pdf", url: "data:application/pdf;base64,..." },
  ],
  brochureUrl: "data:application/pdf;base64,...",
  brochureName: "John_Doe_CV.pdf",
  cardSlug: "john-doe-abc123",
  cardStatus: "Published",
  isDeleted: false,
  deletedAt: null,
  deleteExpiresAt: null,
  createdAt: "2026-01-17T10:00:00.000Z",
  lastUpdated: "2026-01-17T14:30:00.000Z",
};

export default { exampleCard };
