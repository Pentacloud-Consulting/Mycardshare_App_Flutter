# 📱 My Card Share — iOS App Release Plan
> **Version:** 1.0.0 | **Target:** App Store (iOS 14+) | **Framework:** Flutter 3.x
> **Last Updated:** October 2026

---

## 🗂️ Table of Contents

1. [Prerequisites & Requirements](#1-prerequisites--requirements)
2. [Apple Developer Account Setup](#2-apple-developer-account-setup)
3. [Xcode & macOS Setup](#3-xcode--macos-setup)
4. [Firebase iOS Configuration](#4-firebase-ios-configuration)
5. [Info.plist — All Permissions Needed](#5-infoplist--all-permissions-needed)
6. [Plugin iOS Compatibility Fixes](#6-plugin-ios-compatibility-fixes)
7. [Apple Wallet (Passkit) Integration](#7-apple-wallet-passkit-integration)
8. [NFC on iOS — Special Requirements](#8-nfc-on-ios--special-requirements)
9. [Push Notifications — APNs Setup](#9-push-notifications--apns-setup)
10. [Deep Linking (Universal Links)](#10-deep-linking-universal-links)
11. [Google Sign-In iOS Fix](#11-google-sign-in-ios-fix)
12. [Build & Archive for App Store](#12-build--archive-for-app-store)
13. [App Store Connect Setup](#13-app-store-connect-setup)
14. [TestFlight Beta Distribution](#14-testflight-beta-distribution)
15. [App Store Review Checklist](#15-app-store-review-checklist)
16. [Known iOS-Specific Issues to Fix](#16-known-ios-specific-issues-to-fix)
17. [Priority Task Order](#17-priority-task-order)

---

## 1. Prerequisites & Requirements

### 💻 macOS Machine REQUIRED
> [!CAUTION]
> iOS builds **CANNOT** be done on Windows. You MUST have a Mac to build and submit to the App Store.

| Requirement | Minimum Version | Recommended |
|---|---|---|
| **macOS** | macOS 12 Ventura | macOS 14 Sonoma |
| **Xcode** | 15.0 | 15.4+ |
| **Flutter** | 3.19+ | Latest stable |
| **CocoaPods** | 1.14+ | Latest |
| **iOS Deployment Target** | iOS 14.0 | iOS 15.0 |

### 📦 Install CocoaPods on Mac
```bash
sudo gem install cocoapods
# OR use Homebrew (recommended)
brew install cocoapods
```

---

## 2. Apple Developer Account Setup

> [!IMPORTANT]
> Apple Developer Program costs **$99/year USD**. Without it, you cannot submit to App Store.

### Step-by-Step:

1. **Enroll at:** https://developer.apple.com/programs/enroll/
2. **Account Type:** Individual ($99/yr) OR Organization ($99/yr, requires DUNS number)
3. **Wait:** Apple takes 24–48 hours to verify enrollment

### Create These in Apple Developer Portal:

#### A. App ID (Bundle ID)
- Go to: https://developer.apple.com/account/resources/identifiers
- Click **+** → Select **App IDs** → App
- **Bundle ID:** `com.mycardshare.app` (exact, no changes after submission!)
- **Capabilities to Enable:**
  - ✅ Push Notifications
  - ✅ NFC Tag Reading
  - ✅ Associated Domains (for Universal Links)
  - ✅ Sign In with Apple (optional but recommended)
  - ✅ Apple Wallet / PassKit (for Add to Wallet)

#### B. Certificates
You need **2 certificates:**

| Certificate | Purpose |
|---|---|
| **Apple Development** | For testing on real devices |
| **Apple Distribution** | For App Store submission |

- Go to: https://developer.apple.com/account/resources/certificates
- Create both using Xcode → Preferences → Accounts → Manage Certificates

#### C. Provisioning Profiles
| Profile Type | When Used |
|---|---|
| **Development** | Running on device during development |
| **App Store Distribution** | Submitting to App Store |

---

## 3. Xcode & macOS Setup

### On your Mac, run these commands:

```bash
# 1. Clone/copy project to Mac
git clone <your-repo-url>
cd my_card_share

# 2. Get Flutter packages
flutter pub get

# 3. Install CocoaPods dependencies
cd ios
pod install
cd ..

# 4. Open in Xcode (ALWAYS open .xcworkspace, NOT .xcodeproj)
open ios/Runner.xcworkspace
```

### Xcode Settings to Configure:

#### In Xcode → Runner → Signing & Capabilities:
- **Team:** Select your Apple Developer Team
- **Bundle Identifier:** `com.mycardshare.app`
- **Automatically manage signing:** ✅ ON (recommended for beginners)

#### In Xcode → Runner → General:
- **Display Name:** `My Card Share`
- **Version:** `1.0.0`
- **Build:** `1`
- **Minimum Deployments:** iOS 14.0
- **iPhone Orientation:** Portrait only (uncheck Landscape)

---

## 4. Firebase iOS Configuration

> [!IMPORTANT]
> The current project only has `google-services.json` (Android). You MUST add `GoogleService-Info.plist` for iOS separately.

### Steps:

1. Go to **Firebase Console** → Your Project → Project Settings
2. Click **"Add App"** → Select **iOS** icon
3. **iOS Bundle ID:** `com.mycardshare.app` (same as Apple Developer Portal)
4. **App Nickname:** `My Card Share iOS`
5. **App Store ID:** Leave blank for now (add after App Store listing created)
6. Download **`GoogleService-Info.plist`**

### Add to Xcode:
```
Drag GoogleService-Info.plist INTO Xcode → Runner folder
✅ Make sure "Add to targets: Runner" is checked
✅ DO NOT just copy to filesystem — must be added via Xcode drag-drop
```

### Enable Firebase Services for iOS in Console:
- ✅ Firebase Auth (Email/Password + Google Sign-In)
- ✅ Cloud Firestore
- ✅ Firebase Storage
- ✅ Firebase Messaging (Push Notifications)
- ✅ Firebase Crashlytics (add `firebase_crashlytics: ^4.x.x` to pubspec)

---

## 5. Info.plist — All Permissions Needed

> [!WARNING]
> Apple REJECTS apps that request permissions without clear usage descriptions. Every permission must have a string.

Open `ios/Runner/Info.plist` and add these keys. **Current state:** only `NSCameraUsageDescription` is present. Missing:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>

  <!-- ═══ ALREADY PRESENT ═══ -->
  <key>NSCameraUsageDescription</key>
  <string>My Card Share uses your camera to scan business cards and QR codes.</string>

  <!-- ═══ ADD THESE — MISSING ═══ -->

  <!-- Photos / Gallery -->
  <key>NSPhotoLibraryUsageDescription</key>
  <string>My Card Share accesses your photo library to set your profile photo and banner image.</string>

  <key>NSPhotoLibraryAddUsageDescription</key>
  <string>My Card Share saves QR code images to your photo library.</string>

  <!-- Contacts -->
  <key>NSContactsUsageDescription</key>
  <string>My Card Share accesses your contacts to save digital business cards directly to your address book.</string>

  <!-- NFC -->
  <key>NFCReaderUsageDescription</key>
  <string>My Card Share uses NFC to share your digital business card by tapping phones together.</string>

  <!-- Microphone (for camera/video, may be needed) -->
  <key>NSMicrophoneUsageDescription</key>
  <string>My Card Share uses the microphone during card scanning with the camera.</string>

  <!-- ═══ App Transport Security (allow our backend) ═══ -->
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
      <key>digitalbusinesscloudcard.com</key>
      <dict>
        <key>NSExceptionAllowsInsecureHTTPLoads</key>
        <false/>
        <key>NSIncludesSubdomains</key>
        <true/>
      </dict>
      <key>mycardshare.com</key>
      <dict>
        <key>NSExceptionAllowsInsecureHTTPLoads</key>
        <false/>
        <key>NSIncludesSubdomains</key>
        <true/>
      </dict>
    </dict>
  </dict>

  <!-- ═══ URL Schemes (for Google Sign-In redirect) ═══ -->
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <!-- Get this value from GoogleService-Info.plist → REVERSED_CLIENT_ID -->
        <string>com.googleusercontent.apps.943022881240-XXXXXX</string>
      </array>
    </dict>
    <!-- Deep Link custom scheme -->
    <dict>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>mycardshare</string>
      </array>
    </dict>
  </array>

  <!-- ═══ Queried URL Schemes (for url_launcher) ═══ -->
  <key>LSApplicationQueriesSchemes</key>
  <array>
    <string>tel</string>
    <string>mailto</string>
    <string>https</string>
    <string>http</string>
    <string>whatsapp</string>
    <string>instagram</string>
    <string>linkedin</string>
    <string>twitter</string>
    <string>facebook</string>
    <string>maps</string>
    <string>comgooglemaps</string>
  </array>

</dict>
</plist>
```

---

## 6. Plugin iOS Compatibility Fixes

> [!WARNING]
> Several plugins in `pubspec.yaml` need iOS-specific configuration:

### 6.1 `nfc_manager` — iOS NFC Setup

**Add NFC Entitlement in Xcode:**
1. Xcode → Runner → Signing & Capabilities → **+** → NFC Tag Reading
2. This creates `Runner.entitlements` with:
```xml
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
  <string>NDEF</string>
  <string>TAG</string>
</array>
```

**Add to Info.plist:**
```xml
<key>NFCReaderUsageDescription</key>
<string>My Card Share uses NFC to share your digital business card.</string>
```

> [!NOTE]
> iOS NFC can only READ NFC tags (no WRITE/emulation unlike Android). The "share by tap" feature needs to be redesigned for iOS — use AirDrop or QR code as fallback.

### 6.2 `google_mlkit_text_recognition` — iOS Minimum Version

This plugin requires **iOS 15.5+** minimum. Update `ios/Podfile`:
```ruby
platform :ios, '15.5'
```

### 6.3 `image_cropper` — iOS UCrop Config

Add to `ios/Podfile` (inside `target 'Runner'`):
```ruby
pod 'TOCropViewController'
```

### 6.4 `permission_handler` — iOS Podfile

In `ios/Podfile`, add this to resolve permission_handler:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
        'PERMISSION_PHOTOS=1',
        'PERMISSION_CONTACTS=1',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

### 6.5 `firebase_messaging` — APNs Key Required

See Section 9 (Push Notifications).

### 6.6 `flutter_contacts` — iOS 9+ Only

Works on iOS 9+. Already covered by our iOS 14 minimum.

### 6.7 `share_plus` — No extra setup needed on iOS ✅

### 6.8 `camera` — Podfile minimum iOS 14

```ruby
platform :ios, '14.0'
```

---

## 7. Apple Wallet (PassKit) Integration

> [!IMPORTANT]
> Samsung Wallet is **NOT available on iOS**. For iOS, you need **Apple Wallet (Passkit)**.

### Current State:
- Android: Google Wallet + Samsung Wallet ✅
- iOS: **Apple Wallet — NOT IMPLEMENTED YET** ❌

### What You Need to Add:

#### Step 1: Add PassKit Capability in Xcode
- Xcode → Runner → Signing & Capabilities → **+** → **Wallet**

#### Step 2: Create Apple Pass Certificate
1. Go to https://developer.apple.com/account/resources/certificates
2. Create **Pass Type ID Certificate**
3. **Pass Type ID:** `pass.com.mycardshare.businesscard`
4. Download `.cer` → Export as `.p12` from Keychain Access
5. Upload to your backend server

#### Step 3: Backend Must Generate `.pkpass` File
The backend (`digitalbusinesscloudcard.com`) must:
- Accept card data from app
- Use the Pass certificate to sign a `.pkpass` file
- Return a URL to the `.pkpass` file (e.g., `https://digitalbusinesscloudcard.com/api/wallet/apple?slug=xyz`)

#### Step 4: Flutter Code — Add Apple Wallet Button
In `wallet_service.dart`, add:
```dart
static Future<String> addToAppleWallet({
  BuildContext? context,
  Map<String, dynamic>? cardData,
  IndividualProfileData? profile,
  PublicProfileData? publicProfile,
}) async {
  final headers = await _getHeaders();
  final data = resolveCardData(cardData: cardData, profile: profile, publicProfile: publicProfile);
  final slug = data['cardSlug'] as String;

  try {
    // 1. Request .pkpass URL from backend
    final response = await http.post(
      Uri.parse('https://digitalbusinesscloudcard.com/api/wallet/apple'),
      headers: headers,
      body: jsonEncode({'cardSlug': slug, 'cardData': data}),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final resJson = jsonDecode(response.body) as Map<String, dynamic>;
      final passUrl = resJson['passUrl'] ?? resJson['url'] ?? '';
      if (passUrl.isNotEmpty) {
        // 2. Launch .pkpass URL — iOS will auto-open Apple Wallet
        await _launchExternalUrl(passUrl);
        return passUrl;
      }
    }
  } catch (e) {
    debugPrint('[WalletService] Apple Wallet error: $e');
  }

  // Fallback: Open card in Safari
  final fallbackUrl = 'https://digitalbusinesscloudcard.com/card/$slug';
  await _launchExternalUrl(fallbackUrl);
  return fallbackUrl;
}
```

#### Step 5: Show Apple Wallet Button on iOS Only
```dart
import 'dart:io' show Platform;

// In wallet buttons section:
if (Platform.isIOS)
  ElevatedButton(
    onPressed: () => WalletService.addToAppleWallet(context: context, profile: profile),
    child: Row(children: [
      Image.asset('assets/icons/apple_wallet.png', height: 24),
      Text('Add to Apple Wallet'),
    ]),
  ),
if (Platform.isAndroid) ...[
  // Google Wallet button
  // Samsung Wallet button
],
```

---

## 8. NFC on iOS — Special Requirements

> [!WARNING]
> iOS NFC is very limited compared to Android. **Card emulation (HCE) is NOT possible on iOS.**

### What Works on iOS:
| Feature | iOS Support |
|---|---|
| Read NFC tags (NDEF) | ✅ iOS 13+ |
| Read NFC tags (ISO 7816) | ✅ iOS 13+ |
| Write to NFC tags | ✅ iOS 13+ |
| Card emulation (share by tap phone-to-phone) | ❌ NOT POSSIBLE |

### Solution for "Share by NFC tap":
Since card emulation isn't possible on iOS, redesign the share-by-tap flow:

```dart
// In NFC share button handler:
if (Platform.isIOS) {
  // Show alternative options
  showModalBottomSheet(
    context: context,
    builder: (_) => Column(children: [
      ListTile(
        leading: Icon(Icons.qr_code),
        title: Text('Show QR Code'),
        onTap: () => _showQRCode(),
      ),
      ListTile(
        leading: Icon(Icons.share),
        title: Text('Share via AirDrop / Messages'),
        onTap: () => _shareCardLink(),
      ),
    ]),
  );
} else {
  // Android NFC share flow
  _startNFCShare();
}
```

---

## 9. Push Notifications — APNs Setup

> [!IMPORTANT]
> Firebase Cloud Messaging on iOS requires an **APNs Key** from Apple. Without this, push notifications will NOT work on iOS.

### Step 1: Create APNs Key
1. Go to: https://developer.apple.com/account/resources/authkeys
2. Click **+** → Enable **Apple Push Notifications service (APNs)**
3. Download the `.p8` key file — **save it safely, can only download once!**
4. Note down:
   - **Key ID** (10-character string, e.g., `ABCD1234EF`)
   - **Team ID** (from top-right of developer portal)

### Step 2: Upload to Firebase
1. Firebase Console → Project Settings → Cloud Messaging
2. **Apple app configuration** section
3. Upload `.p8` file → Enter Key ID + Team ID

### Step 3: Xcode — Add Push Notifications Capability
- Xcode → Runner → Signing & Capabilities → **+** → Push Notifications
- Xcode → Runner → Signing & Capabilities → **+** → Background Modes → check **Remote notifications**

### Step 4: AppDelegate.swift Update
The Flutter `firebase_messaging` plugin handles this automatically if you've added the capability. Verify `ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## 10. Deep Linking (Universal Links)

Android has App Links configured. iOS needs **Universal Links** (HTTPS) or **Custom URL Schemes**.

### Step 1: Add Associated Domains in Xcode
- Xcode → Runner → Signing & Capabilities → **+** → Associated Domains
- Add entries:
  ```
  applinks:digitalbusinesscloudcard.com
  applinks:mycardshare.com
  ```

### Step 2: Host `apple-app-site-association` File
On your web server, host this file at:
- `https://digitalbusinesscloudcard.com/.well-known/apple-app-site-association`
- `https://mycardshare.com/.well-known/apple-app-site-association`

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["TEAMID.com.mycardshare.app"],
        "components": [
          { "/": "/card/*" },
          { "/": "/profile/*" }
        ]
      }
    ]
  }
}
```
> Replace `TEAMID` with your 10-character Apple Team ID.

### Step 3: Flutter go_router — Handle Deep Links

In your `router.dart`, the existing routes should work since go_router handles Universal Links automatically.

---

## 11. Google Sign-In iOS Fix

> [!IMPORTANT]
> Google Sign-In on iOS requires the `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` added to `Info.plist`.

### Steps:

1. Open `ios/Runner/GoogleService-Info.plist`
2. Find `REVERSED_CLIENT_ID` value (looks like: `com.googleusercontent.apps.943022881240-xxxxxxxx`)
3. Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.943022881240-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</string>
    </array>
  </dict>
</array>
```

### Also Update `google_sign_in` in `individual_auth_service.dart`:
```dart
// The clientId is needed for iOS:
final GoogleSignIn _googleSignIn = GoogleSignIn(
  serverClientId: _webClientId,
  clientId: kIsWeb ? _webClientId : null, // null on mobile is correct — uses GoogleService-Info.plist
  scopes: <String>['email', 'profile'],
);
```
This is already correct ✅ — just need the plist entry.

---

## 12. Build & Archive for App Store

### On your Mac terminal:

```bash
# Clean previous build artifacts
flutter clean
flutter pub get

# Install pods
cd ios && pod install && cd ..

# Build iOS release (no codesign for CI, Xcode handles it)
flutter build ios --release

# OR: Build IPA directly
flutter build ipa --release
# This creates: build/ios/ipa/my_card_share.ipa
```

### Via Xcode (Manual):
1. Open `ios/Runner.xcworkspace` in Xcode
2. Set scheme to **Runner** and destination to **Any iOS Device (arm64)**
3. **Product → Archive**
4. In Organizer window → **Distribute App** → **App Store Connect**
5. Follow prompts → Upload

---

## 13. App Store Connect Setup

1. Go to: https://appstoreconnect.apple.com
2. **My Apps → +** → New App

### Fill In:
| Field | Value |
|---|---|
| **Platform** | iOS |
| **Name** | My Card Share |
| **Primary Language** | English (U.S.) |
| **Bundle ID** | com.mycardshare.app |
| **SKU** | mycardshare-ios-001 |
| **User Access** | Full Access |

### App Information:
- **Category:** Business (Primary), Productivity (Secondary)
- **Age Rating:** 4+ (no objectionable content)
- **Content Rights:** Does not contain third-party content

### App Privacy (Required since iOS 14):
Declare what data you collect:
| Data Type | Collected? | Purpose | Linked to User? |
|---|---|---|---|
| Name | ✅ | App Functionality | ✅ Yes |
| Email Address | ✅ | App Functionality, Account | ✅ Yes |
| Phone Number | ✅ | App Functionality | ✅ Yes |
| Photos/Videos | ✅ | App Functionality | ❌ No |
| Contacts | ✅ | App Functionality | ❌ No |
| Device ID | ✅ | Analytics | ❌ No |
| Crash Data | ✅ | App Functionality | ❌ No |

### Screenshots Required:
| Device | Size | Count |
|---|---|---|
| iPhone 6.9" (Pro Max) | 1320×2868 px | 3-10 |
| iPhone 6.7" (Plus) | 1290×2796 px | 3-10 |
| iPad Pro 13" (optional) | 2048×2732 px | 3-10 |

> [!TIP]
> Use iPhone 15 Pro Max simulator in Xcode to take screenshots. Tools like **Screenshot Maker Pro** or **Figma** can help create beautiful store frames.

---

## 14. TestFlight Beta Distribution

Before public release, test with TestFlight:

1. After uploading build in Xcode → App Store Connect → **TestFlight** tab
2. **Add Internal Testers:** Up to 100 Apple IDs in your dev team
3. **Add External Testers:** Up to 10,000 testers (requires Beta App Review — 1-2 days)
4. Share the TestFlight link

---

## 15. App Store Review Checklist

> [!WARNING]
> These are common rejection reasons — fix them before submitting:

- [ ] **Account Deletion Flow:** App must allow users to delete their account FROM within the app (not just request). Our app has "Request Deletion" but master admin confirms — **Apple may reject this**. Add instant self-delete option in settings.
- [ ] **Login with Apple (Sign in with Apple):** If you offer Google Sign-In, Apple REQUIRES you to also offer "Sign in with Apple" (per App Store Review Guideline 4.8)
- [ ] **No placeholder/demo content:** Remove all `debugPrint` test data, no "lorem ipsum" text
- [ ] **All features must work:** NFC share alternative for iOS, Apple Wallet
- [ ] **Privacy Policy URL:** Must be hosted publicly. Add to: `https://mycardshare.com/privacy`
- [ ] **Terms of Service URL:** Must be hosted publicly. Add to: `https://mycardshare.com/terms`
- [ ] **Support URL:** Must be accessible. Add to: `https://mycardshare.com/support`
- [ ] **No crash on launch** — test on real device (not just simulator)
- [ ] **Metadata:** No mention of "Android", "Samsung", "Google Wallet" in iOS screenshots/description
- [ ] **Push Notifications:** Must ask permission using system prompt (which Flutter plugin handles)

---

## 16. Known iOS-Specific Issues to Fix

### A. `nfc_manager` — NFC Write on iOS
Current code may call NFC methods that work on Android but crash on iOS. Wrap all NFC code:
```dart
import 'dart:io' show Platform;

if (Platform.isAndroid) {
  // Android-specific NFC code (card emulation, HCE)
} else if (Platform.isIOS) {
  // iOS-only NFC code (read/write tags only)
}
```

### B. Samsung Wallet — Hide on iOS
```dart
// In wallet_service.dart or UI:
if (Platform.isAndroid)
  _buildSamsungWalletButton(),
```

### C. `google_mlkit_text_recognition` — Min iOS 15.5
Update `ios/Podfile` line 1:
```ruby
platform :ios, '15.5'
```

### D. `permission_handler` — iOS Needs `PERMISSION_*` Macros
Already covered in Section 6.4 above.

### E. `image_cropper` — iOS Needs Specific Config
In `ios/Podfile`:
```ruby
pod 'TOCropViewController', '~> 2.0'
```

### F. Keyboard Overlap on iOS (Safe Area)
Flutter handles this via `MediaQuery.of(context).viewInsets.bottom` — verify all forms/sheets use this correctly. Already done in `active_lead.dart` ✅

### G. Status Bar Style on iOS
Add to `Info.plist` for proper status bar:
```xml
<key>UIStatusBarStyle</key>
<string>UIStatusBarStyleDarkContent</string>
<key>UIViewControllerBasedStatusBarAppearance</key>
<false/>
```

### H. Sign in with Apple (REQUIRED by Apple)
Add package to `pubspec.yaml`:
```yaml
sign_in_with_apple: ^6.1.2
```

And add in auth flow alongside Google Sign-In button.

---

## 17. Priority Task Order

### 🔴 Phase 1 — Blockers (Must do FIRST)

| # | Task | File/Location | Effort |
|---|---|---|---|
| 1 | Get macOS machine + Xcode | — | High |
| 2 | Create Apple Developer Account ($99) | developer.apple.com | Low |
| 3 | Create App ID with all capabilities | Apple Developer Portal | Medium |
| 4 | Add Firebase iOS app → download `GoogleService-Info.plist` | Firebase Console | Low |
| 5 | Add `GoogleService-Info.plist` to Xcode | `ios/Runner/` | Low |
| 6 | Fix `Info.plist` — add ALL missing permissions | `ios/Runner/Info.plist` | Medium |
| 7 | Add Google Sign-In `REVERSED_CLIENT_ID` to `Info.plist` | `ios/Runner/Info.plist` | Low |
| 8 | Fix `Podfile` — set `platform :ios, '15.5'` | `ios/Podfile` | Low |
| 9 | Add `permission_handler` macros to `Podfile` | `ios/Podfile` | Low |
| 10 | Run `pod install` on Mac | Terminal | Low |

### 🟡 Phase 2 — Core Features

| # | Task | File/Location | Effort |
|---|---|---|---|
| 11 | Wrap NFC code in `Platform.isAndroid/isIOS` guards | `nfc_*` files | Medium |
| 12 | Hide Samsung Wallet on iOS | `wallet_service.dart` + UI | Low |
| 13 | Implement Apple Wallet (PassKit) | `wallet_service.dart` | High |
| 14 | Setup APNs Key in Firebase | Firebase Console | Low |
| 15 | Add Push Notification + Background Mode capability in Xcode | Xcode | Low |
| 16 | Setup Universal Links + `apple-app-site-association` | Server + Xcode | Medium |

### 🟢 Phase 3 — App Store Requirements

| # | Task | File/Location | Effort |
|---|---|---|---|
| 17 | Add **Sign in with Apple** | Auth screens | High |
| 18 | Add instant account self-delete (no admin approval needed for user-initiated) | Settings screen | Medium |
| 19 | Host Privacy Policy + Terms at public URL | Website | Medium |
| 20 | Take App Store screenshots (iPhone 6.9" + 6.7") | Simulator | Medium |
| 21 | Create App Store Connect listing | appstoreconnect.apple.com | Medium |
| 22 | TestFlight internal testing | — | Low |
| 23 | Fix any TestFlight crash reports | Various | High |
| 24 | Submit for App Store Review | App Store Connect | Low |

---

## 📊 Estimated Timeline

```
Week 1: Phase 1 (Mac setup, Apple accounts, Firebase iOS, Info.plist)
Week 2: Phase 2 (NFC guards, Apple Wallet backend + Flutter code)
Week 3: Phase 3 (Sign in with Apple, screenshots, App Store Connect)
Week 4: TestFlight testing + bug fixes
Week 5: App Store submission + review (Apple takes 1-7 days)
```

---

## 📁 Files That Need Changes Summary

| File | Change Needed |
|---|---|
| `ios/Runner/Info.plist` | Add 8+ permission strings, URL schemes, LSApplicationQueriesSchemes |
| `ios/Podfile` | platform iOS 15.5, permission_handler macros |
| `ios/Runner/AppDelegate.swift` | Verify FirebaseApp.configure() present |
| `ios/Runner/Runner.entitlements` | NFC, Push Notifications, Associated Domains, Wallet |
| `lib/backend/individual/wallet/wallet_service.dart` | Add `addToAppleWallet()`, Platform checks |
| `lib/features/*/wallet_button_widget.dart` | Platform-specific wallet buttons |
| `pubspec.yaml` | Add `sign_in_with_apple: ^6.1.2` |
| Any NFC share file | Wrap with `Platform.isAndroid` guards |
| `lib/backend/individual/sign/individual_auth_service.dart` | Add Sign in with Apple |

---

*Generated: October 2026 | My Card Share v1.0.0 iOS Release Plan*
