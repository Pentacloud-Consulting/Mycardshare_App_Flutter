# 📱 MyCardShare — Google Play Store Release & Deployment Documentation

> **App Name:** MyCardShare  
> **Package Name (`applicationId`):** `com_pentacloud.mycarshare`  
> **Organization:** Pentacloud Consulting (Google Play Organisation ID: `5594473639367962212`)  
> **Target Track:** Production (Worldwide — 177 Countries + Rest of World)  
> **Release Version:** `1.0.0` (`versionCode: 2`, `targetSdk: 36`, `minSdk: 24`)  
> **Submission Date:** 10 November 2026  
> **Current Status:** Submitted — **Changes in Review** (`Managed publishing off`)

---

## 🗂️ Table of Contents

1. [Project & Account Overview](#1-project--account-overview)
2. [Phase 1: Google Play Console Account Setup & Permissions](#2-phase-1-google-play-console-account-setup--permissions)
3. [Phase 2: Production Keystore Generation & Gradle Signing Setup](#3-phase-2-production-keystore-generation--gradle-signing-setup)
4. [Phase 3: Initial Bundle Build & Package Name Mismatch Resolution](#4-phase-3-initial-bundle-build--package-name-mismatch-resolution)
5. [Phase 4: Google Play App Creation & App Content Declarations](#5-phase-4-google-play-app-creation--app-content-declarations)
6. [Phase 5: Store Settings, Graphics & Listing Setup](#6-phase-5-store-settings-graphics--listing-setup)
7. [Phase 6: Critical Policy Audit — `READ_MEDIA_IMAGES` Removal](#7-phase-6-critical-policy-audit--read_media_images-removal)
8. [Phase 7: Production Track Configuration, Countries & Final Submission](#8-phase-7-production-track-configuration-countries--final-submission)
9. [Phase 8: Post-Submission Behavior & Email Routing](#9-phase-8-post-submission-behavior--email-routing)
10. [Phase 9: Keystore Security Backup & Future Update SOP](#10-phase-9-keystore-security-backup--future-update-sop)

---

## 1. Project & Account Overview

This document records the complete end-to-end process used to configure, sign, troubleshoot, declare, and submit **MyCardShare** (Flutter Android application) to the **Google Play Store**.

| Parameter | Value / Configuration |
|---|---|
| **Public App Name** | `MyCardShare` |
| **Android `applicationId`** | `com_pentacloud.mycarshare` |
| **Android `namespace`** | `com.pentacloud.mycardshare` |
| **Developer Account Type** | Google Play **Organisation Account** (`Pentacloud Consulting`) |
| **Console Admin / Login Email** | `pentacloudmarketingtools@gmail.com` |
| **Public Store Support Email** | `contactus@pentacloudconsulting.com` |
| **Privacy Policy & Deletion URL** | `https://digitalbusinesscloudcard.com/privacy` |
| **Firebase Project** | `business-card-64459` |
| **App Pricing / Type** | App — Free (No Ads) |
| **Android SDK Versions** | `compileSdk = 36`, `targetSdk = 36`, `minSdk = 24` |
| **Final Uploaded Version** | `1.0.0+2` (`versionName: 1.0.0`, `versionCode: 2`) |
| **Final Bundle Size** | `app-release.aab` (`93.7 MB` raw AAB / `~23.2 MB` estimated Play install size) |

---

## 2. Phase 1: Google Play Console Account Setup & Permissions

### 2.1 Why Organisation Account Matters
Unlike new **Personal Developer Accounts** (which Google requires to run a 14-day Closed Testing cycle with 12–20 opted-in testers before unlocking Production), **Pentacloud Consulting** uses a verified **Organisation Account**. This enabled **direct submission to the Production track** without a 14-day testing wait.

### 2.2 Permissions Issue & Resolution During App Creation
When initially attempting to create the app in Google Play Console while logged in as a team member:
- **Blocker Encountered:**  
  `🔒 You need permission to accept the Play app signing Terms of Service`
- **Root Cause:** Google Play only permits the **Account Owner** or a team member with **Administrator (or Release to Production)** permissions to legally accept the initial *Play App Signing Terms of Service*.
- **Resolution:**
  1. Switched to / granted **Admin** permissions via **Settings ➔ Users and permissions** under the Account Owner account.
  2. Accepted **Play App Signing** using Google's default **Use Google-generated key** option so Google Play manages the final distribution signing key while the local keystore acts as the upload key.

---

## 3. Phase 2: Production Keystore Generation & Gradle Signing Setup

Google Play does not accept `.apk` files for new app listings; all releases must be signed **Android App Bundles (`.aab`)**.

### 3.1 Generating the Production Upload Keystore
Because `keytool` was not on the global Windows `PATH`, Android Studio's bundled Java Runtime (`jbr`) was used:

```powershell
# Located keytool at:
# C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe

& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" `
  -genkeypair -v `
  -keystore "my_card_share\android\app\upload-keystore.jks" `
  -storetype JKS `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias upload `
  -dname "CN=Pentacloud, OU=Mobile, O=Pentacloud Consulting, L=Bengaluru, ST=Karnataka, C=IN"
```

After generation, the keystore was migrated from proprietary `JKS` format to the industry-standard `PKCS12` format:

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" `
  -importkeystore `
  -srckeystore "my_card_share\android\app\upload-keystore.jks" `
  -destkeystore "my_card_share\android\app\upload-keystore.jks" `
  -deststoretype pkcs12
```

### 3.2 Configuring `key.properties` and `.gitignore`
1. Created `my_card_share/android/key.properties` containing:
   - `storePassword=<stored locally in key.properties>`
   - `keyPassword=<stored locally in key.properties>`
   - `keyAlias=upload`
   - `storeFile=upload-keystore.jks`
2. Verified & updated `my_card_share/.gitignore` to exclude sensitive signing and credential files from version control:
   - `**/google-services.json`
   - `**/GoogleService-Info.plist`
   - `**/key.properties`
   - `*.keystore`
   - `*.jks`

### 3.3 Gradle Release Signing (`android/app/build.gradle.kts`)
Updated `my_card_share/android/app/build.gradle.kts` to read `key.properties` and bind `signingConfigs.release` to the release build type:
- Loaded `rootProject.file("key.properties")` via `java.util.Properties` and `FileInputStream`.
- Defined `signingConfigs.create("release")` reading `keyAlias`, `keyPassword`, `storeFile`, and `storePassword`.
- Set `buildTypes { release { signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else signingConfigs.getByName("debug") ... } }` with `proguard-android-optimize.txt` enabled.

---

## 4. Phase 3: Initial Bundle Build & Package Name Mismatch Resolution

### 4.1 Building the First App Bundle
Executed from `my_card_share/`:
```powershell
flutter build appbundle --release
```
- Generated initial artifact: `my_card_share/build/app/outputs/bundle/release/app-release.aab` (`93.7 MB`).
- **VS Code Informational Notice Handled:** VS Code displayed a blue info notice (`The build file has been changed and may need reload to make it effective`) after editing `build.gradle.kts`. Confirmed this is a harmless Java/Gradle IDE reload hint and does not affect the built `.aab`.

### 4.2 Resolving Package Name Mismatch (`com.pentacloud.mycardshare` vs `com_pentacloud.mycarshare`)
- **Error Encountered on Play Console Upload:**  
  `Your APK or Android App Bundle needs to have the package name com_pentacloud.mycarshare`
- **Root Cause:** The app listing in Google Play Console had already been initialized by management with the locked package identifier `com_pentacloud.mycarshare` (note the underscore `_` and spelling `mycarshare`), whereas `build.gradle.kts` originally specified `com.pentacloud.mycardshare`. Once created in Play Console, a package name cannot be edited.
- **Exact Fix Applied:**
  1. **`my_card_share/android/app/build.gradle.kts`:**
     - Updated `defaultConfig.applicationId` to `"com_pentacloud.mycarshare"`.
     - Preserved `android.namespace = "com.pentacloud.mycardshare"` so internal Kotlin/Java `R` references and package structure remained intact without breaking code imports.
  2. **`my_card_share/android/app/google-services.json`:**
     - Added a dedicated Android client configuration block matching `"package_name": "com_pentacloud.mycarshare"` alongside the existing client entry (bound to Firebase `mobilesdk_app_id`: `1:943022881240:android:5a64941dbeec389b2e5aad`, `project_id`: `business-card-64459`, OAuth SHA-1 hash & Google Sign-In web client ID).
     - Verified `lib/backend/firebase_options.dart` already pointed to the same Android `appId` and Firebase project credentials.
  3. Rebuilt `flutter build appbundle --release` — the Play Console accepted the package name cleanly.

---

## 5. Phase 4: Google Play App Creation & App Content Declarations

Under **Policy and programs ➔ App content** (accessed via the **Set up your app** dashboard checklist), every required declaration was completed in the exact sequence needed to unlock release submission:

### 5.1 App Access (Sign-in Details)
- **Does your app have restricted access?** ➔ **Yes** (All or some functionality is restricted behind authentication).
- Added reviewer login instructions under **`Demo User Login`** with test credentials backed by a live account in Firebase Authentication so Google Play reviewers can sign in and inspect all business card features.

### 5.2 Ads Declaration
- **Does your app contain ads?** ➔ **No, my app does not contain ads**.

### 5.3 Content Ratings (IARC Questionnaire)
- **Email:** Official contact email provided.
- **Category Selected:** **All other app types** *(intentionally avoided "Social or communication" to prevent unnecessary user-chat moderation requirements since MyCardShare is a professional digital business card & utility tool)*.
- **Terms & Conditions:** Accepted.
- **Questionnaire Answers:** Answered **No** to all categories across both questionnaire pages (Violence, Sexuality/Nudity, Language, Controlled Substances, Downloaded app, User content sharing/UGC, Online content, Age-restricted products, Digital goods purchases, Cash rewards/NFTs, Search engine/browser, News/educational product).
- Submitted rating questionnaire.

### 5.4 Target Audience and Content
> **Important Dependency:** Play Console blocked saving the Data Safety form (`Go to target audience and content`) until the Target Audience age group was saved first.
- **Target Age Group:** Selected **18 and over** (`18+`).
- **Appeal to Children:** Could your store listing appeal to children? ➔ **No**.
- Saved changes, which immediately unlocked saving the Data Safety form.

### 5.5 Privacy Policy
- **Privacy Policy URL:** `https://digitalbusinesscloudcard.com/privacy`

### 5.6 Data Safety Form
- **Does your app collect or share required user data types?** ➔ **Yes**.
- **Is all collected data encrypted in transit?** ➔ **Yes** (HTTPS / TLS via Firebase Auth, Cloud Firestore, and Firebase Storage).
- **Account Creation Methods Supported:**
  - `☑ Username and password` (Email/Password authentication)
  - `☑ OAuth` (Google Sign-In & Apple Sign-In)
- **Account & Data Deletion:**
  - **Delete account URL provided?** ➔ **Yes** (`https://digitalbusinesscloudcard.com/privacy`).
  - **Delete partial data without account deletion (Optional):** Selected **No** to keep the form streamlined and valid.
- **Declared Data Types & Handling (All set to `Collected = Yes`, `Shared = No`, `Processed ephemerally = No`):**

| Category | Data Type | Required or Optional | Purpose(s) Selected |
|---|---|---|---|
| **Personal info** | **Name** | Data collection is required | `App functionality`, `Account management` |
| **Personal info** | **Email address** | Data collection is required | `App functionality`, `Account management` |
| **Personal info** | **Phone number** | Data collection is required | `App functionality`, `Account management` |
| **Photos and videos** | **Photos** *(Profile photos, logos, banners)* | Users can choose whether collected | `App functionality` |
| **Files and docs** | **Files and docs** *(Resumes / CVs, brochures)* | Users can choose whether collected | `App functionality` |
| **Device or other IDs** | **Device or other IDs** *(Firebase Auth & FCM tokens)* | Data collection is required | `App functionality` |

> **UI Note Resolved:** Once completed, Play Console displayed `Change saved. Send for review in Publishing overview.` in the bottom-left corner with the Save button disabled — confirming the form was already saved cleanly.

### 5.7 Government, Financial & Health Declarations
- **Government apps:** **No** (not developed by or on behalf of a government).
- **Financial features:** **My app doesn't provide any financial features**.
- **Health apps:** **My app doesn't provide any health features**.

### 5.8 App-Level Trader Status & Terms of Service
- **Does your trader status apply to this app?** ➔ **Yes, my trader status applies to this app** (inherited from the verified `Pentacloud Consulting` developer account).
- **Terms of Service URL:** Optional field (left empty or linked as applicable) and saved.

### 5.9 Advertising ID Declaration (Resolved During Final Checks)
- **Quick-Check Issue Encountered:** `Incomplete advertising ID declaration — All developers targeting Android 13 or later are required to let us know if their app uses advertising ID`.
- **Code Verification:** Audited `build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml` and `pubspec.yaml` — confirmed `com.google.android.gms.permission.AD_ID` is absent and no Ad SDK or Analytics Advertising ID SDK is used.
- **Declaration Submitted:** **No** (App does not use Advertising ID).

---

## 6. Phase 5: Store Settings, Graphics & Listing Setup

### 6.1 Store Settings
- **App Category:** **Business**
- **Store Listing Contact Email:** `contactus@pentacloudconsulting.com`

### 6.2 Store Listing Visual Assets
- **App Icon:** `512 x 512 px` PNG uploaded.
- **Phone Screenshots:** 8 high-resolution in-app screenshots uploaded.
- **Feature Graphic (`1024 x 500 px`):** Created and saved custom branded PNG at `feature_graphic_1024x500.png` (root workspace directory) featuring a deep navy-to-electric-blue gradient, rounded app icon, *"My Card Share"* headline, NFC/QR/Enterprise/Document badges, and digital card visual preview.
- **Generated / Synthetic Media Content Question:** Selected **"Don't label assets"** (all visuals represent genuine app UI).

### 6.3 Store Listing Copy (Final Clean Version)
- **App Name:** `MyCardShare`
- **Short Description (Max 80 chars):**
  ```text
  Smart Digital Business Card & NFC Networking Platform for Teams & Individuals.
  ```
- **Full Description (Refined Clean Bullet Format):**
  ```text
  My Card Share is a smart digital business card and NFC networking platform designed for individuals, employees, and enterprises.

  Go paperless and share your professional identity in seconds with a single tap or QR scan.

  Key Features:

  • Instant Sharing: Share your contact details via NFC tap or smart QR code — no app required for recipients to view or save.

  • Enterprise & Teams: Centralized management for companies to control branding, verified logos, and team directories.

  • Employee Profiles: Official business cards synced with company designations, direct lines, and social links.

  • Individual Profiles: Customizable digital cards for professionals and freelancers with portfolio links.

  • Document Sharing: Attach and preview your Resume / CV and Company Brochure directly from your card.

  • Real-time Updates: Change your details anytime and your shared card updates everywhere instantly.
  ```

---

## 7. Phase 6: Critical Policy Audit — `READ_MEDIA_IMAGES` Removal

### 7.1 The Policy Blocker
When validating the Production release, Google Play blocked saving with:
- **Error:** `All developers requesting access to the photo and video permissions are required to tell Google Play about the core functionality of their app` (`android.permission.READ_MEDIA_IMAGES`).
- Play Console prompted for a 250-character explanation of why Android System Photo Pickers could not support the app's core functionality.

### 7.2 Why We Did NOT Submit a Justification Form (Audit Findings)
Google Play's **Photo and Video Permissions Policy** strictly prohibits requesting `READ_MEDIA_IMAGES` for infrequent/one-time media selection (such as uploading a profile avatar, banner, or company logo) and mandates using the **Android System Photo Picker** instead. Submitting a justification for profile uploads almost always results in a policy rejection during human review.

A full codebase and manifest-merger audit (`build/app/outputs/logs/manifest-merger-release-report.txt`, all `lib/**/*.dart`, and plugin manifests for `image_picker`, `file_picker`, `image_cropper`, `camera_android_camerax`, and `permission_handler`) proved:
1. **`image_picker` (`^1.1.2`)** automatically uses the native Android System Photo Picker on Android 13+ with **zero media permissions required**.
2. **`file_picker` (`8.3.7`)** uses Storage Access Framework (`ACTION_OPEN_DOCUMENT` / `GET_CONTENT`) with **zero media permissions required**.
3. **`IOSPermissionsService.requestPhotos`** is strictly gated with `if (!_isIOS) return true;` and never requests `Permission.photos` on Android.
4. `READ_MEDIA_IMAGES` came **only** from a manual `<uses-permission>` line in `my_card_share/android/app/src/main/AndroidManifest.xml`, not from any plugin dependency.

### 7.3 Permanent Code Fix Applied
1. **`my_card_share/android/app/src/main/AndroidManifest.xml`:**
   - Removed `<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />`.
   - Retained `<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />` for backward compatibility on Android 12 and below.
2. **`my_card_share/pubspec.yaml`:**
   - Bumped `version: 1.0.0+1` ➔ `version: 1.0.0+2` to guarantee no `versionCode 1` conflict against the previously uploaded draft in Play Console App Bundle Explorer.
3. **Clean Release Rebuild & Verification:**
   - Ran `flutter build appbundle --release` (`1.0.0+2`, `93.7 MB`).
   - Verified `build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml` contains `package="com_pentacloud.mycarshare"`, `android:versionCode="2"`, `android:versionName="1.0.0"`, and **no `READ_MEDIA_IMAGES` permission**.
4. **Play Console Cleanup:**
   - Removed the prior `1 (1.0.0)` bundle via **Remove app bundle** on Production, discarded any accidental **Closed testing** draft release, and uploaded the clean `2 (1.0.0)` `.aab`. The Photo & Video Permissions error vanished completely.

---

## 8. Phase 7: Production Track Configuration, Countries & Final Submission

### 8.1 Avoiding Closed Testing Trap
While navigating Dashboard tasks, **Closed testing - Alpha** was opened briefly (requiring tester email lists). Because Pentacloud Consulting uses an **Organisation Account**, Closed Testing is optional — all release artifacts were moved strictly to **Release ➔ Production**.

### 8.2 Countries / Regions Targeting
Under **Production ➔ Countries/regions**:
- Targeted **177 countries/regions** (Albania, Algeria, and 175 more, including India) plus **Rest of world** so the app will be accessible worldwide upon approval.

### 8.3 Production Release Details & Submission
Under **Production ➔ Create production release**:
- **App Bundle:** Clean `app-release.aab` (`versionCode 2`, `1.0.0`, `Target SDK 36`, `API levels 24+`).
- **Release Name:** `1.0.0 (1)` *(internal Play Console release label; not displayed to users)*.
- **Release Notes (`en-US`):**
  ```xml
  <en-US>
  Initial release of My Card Share:
  - Smart digital business cards with instant NFC tap & QR sharing
  - Full profile support for Individuals, Employees, and Enterprises
  - Seamless Resume / CV and Company Brochure document sharing
  - Instant contact download and real-time cloud updates
  </en-US>
  ```
- Clicked **Next** ➔ **Save** ➔ navigated to **Publishing overview**.
- Resolved the **Advertising ID** declaration (`No`), waited for quick-check validation to clear `1 issue found`, and clicked **`Submit 12 changes for review`**.

### 8.4 Submitted 12 Changes Summary
1. **Production:** `1.0.0 (1)` — Start full rollout
2. **Production:** Countries/regions — Add 177 countries/regions
3. **Production:** Countries/regions — Add rest of world
4. **Store listings:** `English (United States) - en-US` (`MyCardShare` store listing, graphics, descriptions)
5. **App content:** Content Rating
6. **App content:** Target audience and content (`18 and older`)
7. **App content:** Privacy policy (`https://digitalbusinesscloudcard.com/privacy`)
8. **App content:** Ads declaration
9. **App content:** Data safety
10. **App content:** Health apps declaration
11. **App content:** App-level trader status declaration
12. **Store settings:** App category (`Business`) + Support contact

**Final Verified Status in Console:** **`Changes in review`** — *"Your changes are now in review."*

---

## 9. Phase 8: Post-Submission Behavior & Email Routing

- **Auto-Publish Behavior (`Managed publishing off`):** Once Google Play finishes reviewing and approves the submission, the app will **automatically go LIVE on Google Play Store** without requiring any manual publish click.
- **Why the App Switcher Shows `Draft`:** Until the first Production release completes Google's review and goes live, Play Console's *Switch apps / All apps* list continues showing the overall app pill as **`Draft`**. It automatically switches to **`Production` (Live)** once approved.
- **Expected Review Timeline:** Typically **1–3 business days** for verified Organisation accounts (occasionally **5–7 days** for a brand-new first-time app submission).
- **Email Notification Routing:**
  - **`pentacloudmarketingtools@gmail.com`** *(Developer Console login / admin account)* + Account Owner: Receives Google Play review approvals, policy notices, and Console alerts (also visible in Console **Notifications**).
  - **`contactus@pentacloudconsulting.com`** *(Public Store Listing Support Email)*: Displayed publicly under **App support** on the Google Play Store page for end-user inquiries.

---

## 10. Phase 9: Keystore Security Backup & Future Update SOP

### 10.1 Critical Files to Back Up Immediately
Because the signing files are excluded via `.gitignore`, they are **not stored in GitHub**. Back up these two files in an encrypted company vault / private Google Drive immediately:
1. `my_card_share/android/app/upload-keystore.jks`
2. `my_card_share/android/key.properties`

> [!CAUTION]
> **Never commit `upload-keystore.jks` or `key.properties` to a public repository.** Without the upload keystore, future updates cannot be signed for Google Play unless an Upload Key Reset is requested through Google Play Support.

### 10.2 Standard Operating Procedure (SOP) for Future App Updates
For all subsequent releases (bug fixes, UI changes, new features), **you do not need to re-fill Data Safety, Content Ratings, Privacy Policy, or Store Listing**. Follow only these 3 steps:

1. **Increment Version in `my_card_share/pubspec.yaml`:**
   - Always increment the integer after `+` (`versionCode`) strictly higher than the previous upload (`+2` ➔ `+3`, `+4`, ...), and update the public `versionName` as appropriate:
     ```yaml
     version: 1.0.1+3
     ```
2. **Build Signed Release Bundle:**
   ```powershell
   cd my_card_share
   flutter build appbundle --release
   ```
   - Output artifact: `my_card_share/build/app/outputs/bundle/release/app-release.aab` (automatically signed using `key.properties` & `upload-keystore.jks`).
3. **Upload to Google Play Console:**
   - Open **MyCardShare ➔ Release ➔ Production ➔ Create new release**.
   - Upload the newly generated `app-release.aab`.
   - Write concise `<en-US>` release notes describing what changed.
   - Click **Next** ➔ **Save** ➔ **Publishing overview ➔ Submit changes for review**.
