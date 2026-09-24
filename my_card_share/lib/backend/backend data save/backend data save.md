# My Card Share — Backend Data & System Architecture

## 1. Firebase Project & App Credentials

| Property | Value / Configuration |
|---|---|
| **Firebase Project ID** | `business-card-64459` |
| **Firebase Project Number** | `943022881240` |
| **Android Application ID (Package)** | `com.pentacloud.mycardshare` |
| **Debug SHA-1 Fingerprint** | `0C:A8:3B:24:BF:46:D5:52:D6:A7:41:E7:6E:6F:32:A1:14:83:5B:FF` |
| **Web OAuth Client ID** | `943022881240-igar8cpibfem295tuua1lhlkh24n4k4j.apps.googleusercontent.com` |
| **iOS OAuth Client ID** | `943022881240-uab2qbq06cpoc7vb3ur2ioc60su9dag0.apps.googleusercontent.com` |
| **Firebase Storage Bucket** | `business-card-64459.firebasestorage.app` |
| **Firebase Auth Domain** | `business-card-64459.firebaseapp.com` |

---

## 2. System Architecture & Directory Structure

```
lib/backend/
├── firebase_options.dart              # Firebase initialization configuration per platform
├── individual/                        # Individual user auth & data state
│   ├── sign/
│   │   ├── user_sign_up_store.dart    # Individual sign-up persistence
│   │   └── login_identity.dart        # Individual login authentication
│   ├── multiple store/
│   │   └── individual_multi_store.dart # Multi-store for individual user accounts
│   └── reset_password/
│       ├── reset_passowrd.dart        # General reset password store
│       └── individual/
│           └── individual_reset_password.dart # Individual password reset handler
├── enterprise/                        # Enterprise user auth & data state
│   ├── sign/
│   │   ├── user_sign_up_store.dart    # Enterprise sign-up persistence
│   │   └── login_identity.dart        # Enterprise login authentication
│   ├── multiple store/
│   │   └── enterprise_multi_store.dart # Multi-store for enterprise accounts
│   └── reset_password/
│       └── enterprise/
│           └── enterprise_reset_password.dart # Enterprise password reset handler
├── master_admin/                      # Master Admin authentication & control
│   └── login/
│       └── master_admin_login.dart    # Master admin secure login service
├── sign/                              # Real Google Sign-In & Sign-Up Services
│   ├── google_sign.dart               # Real Google Sign-Up service
│   └── google_login.dart              # Real Google Login service
└── backend data save/
    └── backend data save.md           # System architecture & credentials log
```

---

## 3. Data Flow & Authentication Logic

### A. Individual User Flow
1. **Sign Up (`user_sign_up_store.dart`):**
   - User fills details on `signup.dart`.
   - Data stored in `UserSignUpStore` and registered in `IndividualMultiStore`.
   - Syncs to Firestore `users` collection with `role: 'individual'`.
2. **Login (`login_identity.dart`):**
   - Validates email & password against stored credentials.
   - If password is wrong → Triggers popup: *"The password entered is wrong. If forgotten, please click on 'Forgot Password' to reset."*
   - If email is wrong → Triggers popup: *"Email address not found."*
3. **Forgot/Reset Password (`individual_reset_password.dart`):**
   - Verifies registered email, updates password securely across local stores and Firestore.

---

### B. Enterprise User Flow
1. **Sign Up (`user_sign_up_store.dart`):**
   - Enterprise fills company details on `signup.dart`.
   - Data stored in `EnterpriseUserSignUpStore` & registered in `EnterpriseMultiStore`.
   - Syncs to Firestore `users` collection with `role: 'enterprise'`.
2. **Login (`login_identity.dart`):**
   - Validates enterprise credentials.
   - Triggers targeted wrong password or email not found popups from `login_popup.dart`.
3. **Forgot/Reset Password (`enterprise_reset_password.dart`):**
   - Resets enterprise account credentials securely.

---

### C. Master Admin Flow
1. **Master Admin Login (`master_admin_login.dart`):**
   - Authenticates master admin users with `role: 'master_admin'`.
   - Protects admin control panel & system configuration access.

---

### D. Real Google Sign-In & Sign-Up Flow
1. **Google Sign-Up (`google_sign.dart`):**
   - Triggers OS-native Google Account Picker.
   - Obtains OAuth credentials and authenticates with Firebase Auth.
   - Auto-provisions user document in Firestore `users` collection.
   - Saves record locally in `UserSignUpStore` / `EnterpriseUserSignUpStore`.
2. **Google Login (`google_login.dart`):**
   - Authenticates via Google OAuth + Firebase Auth.
   - Checks role in Firestore, verifies login portal match, and logs user in seamlessly.

---

## 4. Card Slug & Dynamic QR Code Architecture

### A. Core Concept
- **Card Slug (`cardSlug`):** Unique username / URL alias generated automatically or custom-set by user (e.g. `john-doe` or `zuhaib-developer`).
- **Dynamic Share URL Format:** `https://mycardshare.com/card/$cardSlug`
- **QR Code Generation:** Dynamic URL string encoded on-the-fly via `qr_flutter` widget (`QrImageView(data: "https://mycardshare.com/card/$cardSlug")`). No static QR images stored in DB.
- **Service Implementation:** [`IndividualQRService`](file:///c:/Users/zuhaib/OneDrive/Desktop/Projects/My%20Card%20Share/my_card_share/lib/backend/individual/qr%20scan/individual_qr_service.dart) located in `lib/backend/individual/qr scan/individual_qr_service.dart`.

### B. End-to-End Workflow Sequence
1. **Target URL Construction:** `shareUrl = "https://mycardshare.com/card/" + cardSlug`
2. **Dynamic QR Rendering:**
   ```dart
   import 'package:qr_flutter/qr_flutter.dart';
   
   QrImageView(
     data: IndividualQRService.generateShareUrl(cardSlug),
     version: QrVersions.auto,
     size: 200.0,
   );
   ```
3. **Scan & Data Retrieval Flow:**
   - Visitor scans QR Code or taps NFC card (NDEF URI: `https://mycardshare.com/card/$cardSlug`).
   - App / Web triggers `IndividualQRService.instance.fetchCardBySlug(slug)`.
   - Queries Firestore `users` collection where `cardSlug == slug`.
   - Increments profile view count in Firestore (`views: FieldValue.increment(1)`).
   - Returns full real `IndividualProfileData` (Name, Job Title, Company, Bio, Photos, Social Links, Website, Status) and renders public card view.

### C. Technical Summary Matrix
| Feature | Implementation / Key Field |
|---|---|
| **Identifier** | `cardSlug` (Firestore `users` collection) |
| **Public URL Format** | `https://mycardshare.com/card/[cardSlug]` |
| **Flutter Service File** | `lib/backend/individual/qr scan/individual_qr_service.dart` |
| **QR Code Encoding** | Dynamic URL String: `https://mycardshare.com/card/[slug]` |
| **Flutter QR Widget** | `QrImageView(data: shareUrl)` |
| **NFC Payload** | NDEF URI (`https://mycardshare.com/card/[slug]`) |
| **View Count Sync** | Firestore `views: FieldValue.increment(1)` on fetch |
