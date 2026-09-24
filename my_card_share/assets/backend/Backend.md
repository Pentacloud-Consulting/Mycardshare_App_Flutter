# MyCardShare / DBC Platform — Backend Architecture & API Specification

> **Target File Location**: `public/Md files/Backend.md`
> **Purpose**: End-to-end backend documentation providing comprehensive details on APIs, database schemas, authentication flows, and third-party integrations (Wallets, AI, CRM) specifically tailored for Mobile App (React Native/Flutter/Swift/Kotlin) integration.

---

## 1. Backend Architecture & Tech Stack Overview

The MyCardShare backend is built on a serverless architecture using **Next.js 15 API Routes** acting as the primary API Gateway. It uses a dual-database strategy for optimal performance and security.

### Core Technologies
*   **API Gateway**: Next.js 15 API Routes (`/api/*`)
*   **Authentication**: Firebase Authentication (Client SDKs) + JWT Bearer Token validation on the backend.
*   **Primary Databases**:
    *   **MongoDB**: High-volume, unstructured, or document-heavy data (Digital Cards, Leads captured, Contact Vault, Analytics).
    *   **Firebase Firestore**: Relational, role-based, and transactional data (Users, Roles, Companies, Subscriptions).
    *   **MongoDB GridFS / Firebase Storage**: Binary file storage (Avatars, Card Backgrounds, Voice audio, Scanned Card Images).
*   **AI Integrations**: 
    *   Google Gemini Vision & Audio (Primary OCR and Voice parsing).
    *   Hugging Face (Fallback NLP).
*   **Wallet Integrations**: Apple PassKit, Google Wallet API, Samsung Wallet SDK.

### Backend Request Lifecycle (How the Backend Works)
1.  **Client Request**: Mobile app makes an HTTP request to `/api/path`.
2.  **Auth Middleware**: 
    *   Mobile app passes Firebase ID Token in the `Authorization: Bearer <token>` header.
    *   Backend `verifyFirebaseToken` middleware validates the JWT with Firebase Admin SDK.
    *   Backend fetches the User's Role and Company ID from Firestore.
    *   The `userContext` is attached to the request.
3.  **Controller Logic**: The specific Next.js API route handles the business logic (e.g., querying MongoDB, calling Gemini AI).
4.  **Response**: JSON payload returned to the client.

---

## 2. Database Schemas (Detailed)

The backend splits responsibilities between Firestore and MongoDB. Mobile apps should expect JSON responses matching these structures.

### A. Firestore Models (Accounts & Access Control)

**1. Users Collection (`users`)**
Manages auth state and permissions.
```json
{
  "uid": "FIREBASE_UID",             // Primary Key
  "email": "user@example.com",
  "fullName": "John Doe",
  "role": "individual",              // "master-admin", "enterprise", "employee", "individual"
  "companyId": "comp_12345",         // Optional: Only for "employee" or "enterprise"
  "status": "active",                // "active", "suspended", "pending"
  "createdAt": "2026-09-23T10:00:00Z"
}
```

**2. Companies Collection (`companies`)**
Manages enterprise workspaces.
```json
{
  "companyId": "comp_12345",         // Primary Key
  "companyName": "Acme Realty Group",
  "adminUid": "FIREBASE_ADMIN_UID",
  "companyLogo": "https://storage.../logo.png",
  "brandColor": "#0052FF",
  "isColorLocked": true,             // Forces employees to use brandColor
  "subscriptionPlan": "enterprise_pro",
  "employeeLimit": 100,
  "integrations": {
    "zapierWebhookUrl": "https://hooks.zapier.com/..."
  },
  "status": "active"
}
```

### B. MongoDB Models (Core Data)

**1. Digital Cards Collection (`cards`)**
The main digital business card object.
```json
{
  "_id": "65e8a...",
  "userId": "FIREBASE_UID",          // Foreign Key to Firestore
  "cardSlug": "john-doe-acme",       // Unique URL identifier
  "companyId": "comp_12345",         // If associated with enterprise
  
  // Profile Data
  "fullName": "John Doe",
  "jobTitle": "Senior Broker",
  "companyName": "Acme Realty Group",
  "bio": "Specializing in commercial real estate.",
  "email": "john.doe@acmerealty.com",
  "phone": "+1-555-0199",
  "address": "100 Financial Plaza, NY",
  
  // Media & Design
  "avatarUrl": "https://...",
  "bannerUrl": "https://...",
  "themeColor": "#0A84FF",
  "templateStyle": "modern_glass",
  "userStatus": "Actively Networking", // Pre-defined status badge
  
  // Links
  "socialLinks": [
    { "id": "1", "platform": "linkedin", "url": "https://linkedin.com/in/...", "label": "LinkedIn" }
  ],
  
  // Wallet Links (Generated on the fly)
  "appleWalletPassUrl": "/api/wallet/apple?cardId=65e8a...",
  "googleWalletPassUrl": "https://pay.google.com/gp/v/save/...",
  
  "metrics": {
    "views": 1420,
    "shares": 310
  }
}
```

**2. Leads Collection (`leads`)**
Data captured when someone fills out the "Exchange Contact" form on a card.
```json
{
  "_id": "66f1b...",
  "cardId": "65e8a...",              // Card where lead was captured
  "userId": "FIREBASE_UID",          // Owner of the card
  "companyId": "comp_12345",         // Inherited from card owner
  "fullName": "Sarah Jenkins",
  "email": "sarah.j@prospective.com",
  "mobile": "+1-555-9876",
  "company": "Jenkins Logistics",
  "notes": "Met at conference.",
  "capturedVia": "public_card_form", // "public_card_form", "ocr_scan", "voice_ai"
  "crmSyncStatus": "synced"          // "pending", "synced", "failed"
}
```

**3. Contact Vault Collection (`vault`)**
Cards the user has scanned (OCR) or manually saved.
```json
{
  "_id": "67a2c...",
  "userId": "FIREBASE_UID",          // Owner who scanned the card
  "fullName": "Robert Chen",
  "jobTitle": "Managing Director",
  "company": "Apex Global",
  "email": "r.chen@apex.com",
  "phone": "+1-555-4321",
  "cardImageUrl": "/api/images/gridfs_123", // Original scanned image
  "source": "ocr_gemini"             // "ocr_gemini", "voice_ai", "manual"
}
```

---

## 3. Comprehensive API Directory for Mobile App Integration

Base URL: `https://api.mycardshare.com` (or local equivalent).
**Authentication**: Most endpoints require the header `Authorization: Bearer <Firebase_ID_Token>`.

### A. Authentication & User Profile
Mobile apps handle Firebase Login natively, then sync with the backend.

*   **`GET /api/user/me`**
    *   **Headers**: Bearer Token
    *   **Response**: `{ "user": { "uid": "...", "role": "...", "companyId": "..." }, "card": { ...CardObject } }`
    *   **Usage**: Call immediately after Firebase login to get full routing context.

*   **`PATCH /api/user/me`**
    *   **Headers**: Bearer Token
    *   **Body**: `{ "fullName": "New Name" }`
    *   **Response**: `200 OK`

*   **`POST /api/user/upload`**
    *   **Headers**: Bearer Token, `Content-Type: multipart/form-data`
    *   **Body**: File upload (`file` field).
    *   **Response**: `{ "url": "https://..." }`
    *   **Usage**: Uploading avatars or banners.

### B. Digital Card Management

*   **`GET /api/cards`**
    *   **Headers**: Bearer Token
    *   **Response**: `{ "card": { ...CardObject } }`

*   **`PATCH /api/cards`**
    *   **Headers**: Bearer Token
    *   **Body**: `{ "jobTitle": "New Title", "socialLinks": [...] }`
    *   **Response**: `{ "success": true, "card": { ... } }`
    *   **Usage**: Saving edits from the mobile app profile editor.

*   **`GET /api/cards/public/[slug]`**
    *   **Headers**: None (Public)
    *   **Response**: `{ "card": { ... } }`
    *   **Usage**: Fetching data to render a card when scanning an NFC tag or QR code.

### C. Lead Generation & Exchange

*   **`POST /api/leads/create`**
    *   **Headers**: None (Public)
    *   **Body**: `{ "cardId": "...", "fullName": "...", "email": "...", "mobile": "...", "notes": "..." }`
    *   **Response**: `201 Created`
    *   **Usage**: Submitted by the "Exchange Contact" modal on the public card. This endpoint also triggers CRM webhooks (Zapier/Salesforce) internally.

*   **`GET /api/leads`**
    *   **Headers**: Bearer Token
    *   **Response**: `{ "leads": [ { ...LeadObject } ] }`
    *   **Usage**: Populating the Leads tab in the mobile app.

### D. AI Scanner & Contact Vault

*   **`POST /api/ocr/extract`**
    *   **Headers**: Bearer Token
    *   **Body**: `{ "image": "base64_encoded_string_or_url" }`
    *   **Response**: `{ "extractedData": { "fullName": "...", "company": "...", "email": "...", "phone": "..." } }`
    *   **Backend Flow**: Sends image to Google Gemini Vision. Gemini returns JSON. Backend parses and returns it to the app for user verification before saving.

*   **`POST /api/voice-extract`**
    *   **Headers**: Bearer Token
    *   **Body**: `multipart/form-data` containing audio file OR `{ "transcript": "text string" }` if using device native speech-to-text.
    *   **Response**: `{ "extractedData": { "fullName": "...", "company": "...", "notes": "..." } }`
    *   **Backend Flow**: Transcribes audio (if needed), sends text to Gemini/HuggingFace to extract structured contact entities.

*   **`POST /api/vault`**
    *   **Headers**: Bearer Token
    *   **Body**: `{ "fullName": "...", "email": "...", "source": "ocr_gemini", "cardImageUrl": "..." }`
    *   **Response**: `201 Created`
    *   **Usage**: Saves the verified OCR/Voice result into the user's Rolodex.

*   **`GET /api/vault`**
    *   **Headers**: Bearer Token
    *   **Response**: `{ "contacts": [ { ...VaultObject } ] }`

### E. Digital Wallets Integration

*   **`GET /api/wallet/apple?cardId=[cardId]`**
    *   **Headers**: None (Public)
    *   **Response**: Returns `application/vnd.apple.pkpass` binary file.
    *   **Backend Flow**: Uses `passkit-generator` (Node.js). It takes the Card data, generates a `pass.json`, signs it with the Apple Developer Certificates (stored securely on the server), bundles it with icons/QR codes, and streams the `.pkpass` file.
    *   **Mobile Usage**: iOS app can intercept this download and prompt "Add to Apple Wallet".

*   **`GET /api/wallet/google?cardId=[cardId]`**
    *   **Headers**: None (Public)
    *   **Response**: `{ "saveUrl": "https://pay.google.com/gp/v/save/eyJ..." }`
    *   **Backend Flow**: Backend constructs a Google Wallet generic pass JSON object, signs it with the Google Service Account JWT, and returns the signed URL.
    *   **Mobile Usage**: App opens the `saveUrl` in the browser or native Google Wallet SDK.

*   **Samsung Wallet**
    *   Currently implemented via Web intents or Samsung Pay SDK if applicable, typically involving generating a `.wgt` or linking to a registered Samsung Pass campaign.

### F. Enterprise & Master Admin API (Briefly)
Mobile apps built for Enterprise Admins will use these:
*   `GET /api/company/[companyId]/employees` (List team)
*   `POST /api/company/[companyId]/invite` (Add team member)
*   `GET /api/enterprise/leads` (Aggregated company leads)
*   `GET /api/enterprise/analytics` (Company performance)

---

## 4. Third-Party Integrations Deep Dive

### A. Gemini AI (Business Card Scanner)
When the mobile app calls `/api/ocr/extract`, the backend securely calls the `gemini-1.5-flash` or `gemini-2.0-flash-lite` API.
**Prompt Example used by Backend:**
> "Extract contact information from this business card image. Return strictly valid JSON with the following keys: fullName, jobTitle, company, email, phone, website, address. If a field is missing, return null."

### B. CRM Webhooks & Sync
When a new Lead is created (`POST /api/leads/create`), the backend checks if the associated user or enterprise company has `zapierWebhookUrl` or `hubspotApiKey` configured.
If enabled, the Next.js API performs an asynchronous background POST request to the CRM endpoint with the lead payload. If it fails, the error is logged to `crmSyncLogs` for retry.

### C. QR Code Generation
QR codes are not stored as image files. The mobile app and backend generate them dynamically using libraries (like `qrcode.react` or native mobile QR generators) pointing to the public card URL: `https://mycardshare.com/card/[cardSlug]`.

---

## 5. Security & Mobile Implementation Notes

1.  **Biometrics**: Mobile apps should implement FaceID / TouchID locally to unlock the app, but network requests still rely on the Firebase JWT.
2.  **Token Refresh**: Firebase Client SDKs automatically refresh the JWT. Always use `await auth().currentUser.getIdToken()` before making an API call to ensure the token isn't expired.
3.  **Offline Support**: Mobile apps should cache `GET /api/cards` locally (using SQLite, WatermelonDB, or AsyncStorage) so the user's QR code can be displayed even without internet access.
4.  **VCard Generation**: The "Save Contact" button on the public profile relies on a dynamic vCard 3.0 string. The mobile app can generate this locally on the device or hit a backend endpoint that streams `text/vcard` for native contacts import.

---

## 6. Environment Variables & Configuration

To properly connect the mobile application to the backend services, the backend relies on the following environment variables. Ensure these are securely configured in your production environment (e.g., Vercel, AWS).

### Database & Server Settings
*   `MONGODB_URI`: Connection string for the MongoDB cluster (e.g., `mongodb+srv://...`).
*   `PORT`: Port number for local development (default: `3000`).
*   `FRONTEND_URL`: URL of the deployed frontend (e.g., `https://dbc-square.vercel.app`).
*   `BACKEND_URL`: Base API URL (e.g., `http://localhost:3000/api`).
*   `NEXT_PUBLIC_BASE_URL`: Public base URL for the application.
*   `JWT_SECRET`: Secret key used for signing internal JSON Web Tokens.

### Digital Wallet Integrations
*   **Google Wallet**:
    *   `ISSUER_ID`: Google Wallet Issuer ID.
    *   `GOOGLE_APPLICATION_CREDENTIALS`: Path to the Google Service Account JSON key (`./google-wallet-key.json`).
*   **Samsung Wallet**:
    *   `SAMSUNG_PARTNER_ID`: Samsung Wallet Partner ID.
    *   `SAMSUNG_CARD_ID`: Identifier for the Samsung Wallet Pass.
    *   `SAMSUNG_PARTNER_CODE`: Partner authorization code.
    *   `SAMSUNG_PRIVATE_KEY_PATH`: Path to the PEM private key for Samsung integration (`./samsung-private-key.pem`).

### AI Integrations
*   `GEMINI_API_KEY`: API key for Google Gemini (used for OCR and primary voice extraction).
*   `HUGGINGFACE_API_KEY`: API key for Hugging Face (used as a fallback for Whisper voice transcription).
