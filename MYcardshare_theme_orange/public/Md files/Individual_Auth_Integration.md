# MyCardShare / DBC Platform — Individual Sign-Up, Login & Mobile/Web Interconnection Specification

> **Target File Location**: `public/Md files/Individual_Auth_Integration.md`  
> **Purpose**: Complete technical specification and step-by-step implementation guide for integrating Individual User Authentication (Sign-Up & Login) and Card Sync between the **Flutter Mobile App** and the **Next.js Web Application / Dashboard**.

---

## 1. Executive Summary & Architecture Overview

The **MyCardShare / DBC Platform** uses a **unified backend architecture**. Both the **Flutter Mobile App** (iOS & Android) and the **Next.js Web Application** interact with the exact same backend infrastructure:

1. **Shared Firebase Authentication** (`projectId: business-card-64459`): Ensures that any user registering or signing in via the mobile app has the exact same identity (`uid`) on the web dashboard.
2. **Firebase Firestore (`users` collection)**: Acts as the primary identity, role management (`individual`), and access control store.
3. **MongoDB (`cards` collection)**: Stores digital business card profile data, QR code slug (`cardSlug`), social links, design themes, leads, and analytics.
4. **Next.js API Gateway (`/api/*`)**: Validates Firebase JWT ID Tokens via Bearer headers and executes business logic for both web and mobile clients.

```mermaid
sequenceDiagram
    autonumber
    actor User as Mobile App / Web User
    participant App as Flutter Mobile App
    participant Auth as Firebase Auth SDK
    participant API as Next.js API Gateway (/api/*)
    participant FS as Firestore (users)
    participant Mongo as MongoDB (cards)
    participant Web as Web Dashboard (/portal)

    Note over User, App: 1. MOBILE APP SIGN-UP / LOGIN
    User->>App: Submits Credentials (Email/Pass or Google)
    App->>Auth: createUserWithEmailAndPassword() / signInWithPopup()
    Auth-->>App: Returns Firebase User & JWT ID Token
    App->>API: GET /api/user/me (Authorization: Bearer <ID_TOKEN>)
    API->>Auth: Verify Token with Firebase Admin SDK
    API->>FS: Fetch/Create User Doc in "users" (role: "individual")
    FS-->>API: Return User Profile Data
    API->>Mongo: Fetch/Create Card Document in "cards"
    Mongo-->>API: Return Digital Card Data
    API-->>App: 200 OK (User + Card Context)

    Note over User, Web: 2. SEAMLESS WEB DASHBOARD SYNC
    User->>Web: Logs in at mycardshare.com/login
    Web->>Auth: Authenticates with SAME Firebase Project
    Auth-->>Web: Same Firebase UID
    Web->>API: GET /api/user/me + GET /api/cards
    API-->>Web: Returns exact card data created/edited on Mobile App!
```

---

## 2. Shared Data Models & Database Schemas

### A. Firestore User Document (`users/{uid}`)
Created immediately upon registration. Identifies the user's role and status across both Mobile App and Web.

```json
{
  "uid": "FIREBASE_USER_UID_12345",
  "email": "user@example.com",
  "fullName": "John Doe",
  "role": "individual",
  "status": "active",
  "cardSlug": "john-doe",
  "avatarUrl": "https://storage.googleapis.com/.../avatar.jpg",
  "bannerUrl": "https://storage.googleapis.com/.../banner.jpg",
  "createdAt": "2026-09-24T10:00:00.000Z",
  "updatedAt": "2026-09-24T10:00:00.000Z"
}
```

### B. MongoDB Card Document (`cards` collection)
Stores the complete digital business card profile accessible by both the app profile screen and web dashboard (`/portal/profile`).

```json
{
  "_id": "65e8a9b1c2f3e4d5a6b7c8d9",
  "userId": "FIREBASE_USER_UID_12345",
  "cardSlug": "john-doe",
  "fullName": "John Doe",
  "jobTitle": "Senior Commercial Broker",
  "companyName": "Apex Real Estate",
  "bio": "Connecting buyers and sellers across commercial properties.",
  "email": "john.doe@example.com",
  "phone": "+15550199",
  "website": "https://apexrealestate.com",
  "address": "100 Tech Plaza, San Francisco, CA",
  "avatarUrl": "https://storage.googleapis.com/.../avatar.jpg",
  "bannerUrl": "https://storage.googleapis.com/.../banner.jpg",
  "themeColor": "#0A84FF",
  "templateStyle": "modern_glass",
  "userStatus": "Actively Networking",
  "cardStatus": "Published",
  "socialLinks": [
    { "id": "1", "platform": "linkedin", "url": "https://linkedin.com/in/johndoe", "label": "LinkedIn" },
    { "id": "2", "platform": "whatsapp", "url": "https://wa.me/15550199", "label": "WhatsApp" }
  ],
  "views": 142,
  "shares": 38,
  "createdAt": "2026-09-24T10:00:00.000Z",
  "lastUpdated": "2026-09-24T10:00:00.000Z"
}
```

---

## 3. Comprehensive API Directory for Mobile App Integration

Base URL: `https://mycardshare.com` (or `http://localhost:3000` during local development).

Every request to a protected endpoint **MUST** include the Firebase JWT ID Token:
`Authorization: Bearer <FIREBASE_ID_TOKEN>`

### Endpoint Reference Table

| HTTP Method | API Path | Headers Required | Request Body | Description |
| :--- | :--- | :--- | :--- | :--- |
| **GET** | `/api/user/me` | `Authorization: Bearer <token>` | None | Returns user profile, role (`individual`), and routing metadata. |
| **PATCH** | `/api/user/me` | `Authorization: Bearer <token>` | `{ fullName, bio, avatarUrl, cardSlug, ... }` | Updates user metadata in Firestore and auto-syncs to MongoDB. |
| **GET** | `/api/cards` | `Authorization: Bearer <token>` | None | Fetches the user's digital business card details & QR slug. |
| **PATCH** | `/api/cards` | `Authorization: Bearer <token>` | `{ fullName, jobTitle, socialLinks, themeColor, ... }` | Creates or updates user's card in MongoDB & syncs to Firestore. |
| **POST** | `/api/user/upload` | `Authorization: Bearer <token>`, `Content-Type: multipart/form-data` | `file` (binary), `type` ("avatar" / "banner") | Uploads avatar/banner image and returns public image URL. |
| **GET** | `/api/cards/public/[slug]` | None (Public) | None | Public lookup for viewing a profile by QR scan / NFC tap. |

---

## 4. Detailed API Specifications & JSON Payloads

### A. Initializing / Syncing Profile After Login (`GET /api/user/me`)

**Request**:
```http
GET /api/user/me HTTP/1.1
Host: mycardshare.com
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...
```

**Success Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "uid": "FIREBASE_USER_UID_12345",
    "email": "user@example.com",
    "fullName": "John Doe",
    "role": "individual",
    "status": "active",
    "cardSlug": "john-doe",
    "avatarUrl": "https://storage.googleapis.com/.../avatar.jpg",
    "createdAt": "2026-09-24T10:00:00.000Z"
  }
}
```

---

### B. Fetching Card Profile (`GET /api/cards`)

**Request**:
```http
GET /api/cards HTTP/1.1
Host: mycardshare.com
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...
```

**Success Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "card": {
      "_id": "65e8a9b1c2f3e4d5a6b7c8d9",
      "userId": "FIREBASE_USER_UID_12345",
      "cardSlug": "john-doe",
      "fullName": "John Doe",
      "jobTitle": "Senior Commercial Broker",
      "companyName": "Apex Real Estate",
      "bio": "Connecting buyers and sellers across commercial properties.",
      "email": "john.doe@example.com",
      "phone": "+15550199",
      "themeColor": "#0A84FF",
      "userStatus": "Actively Networking",
      "cardStatus": "Published",
      "socialLinks": [
        { "id": "1", "platform": "linkedin", "url": "https://linkedin.com/in/johndoe", "label": "LinkedIn" }
      ],
      "views": 142,
      "shares": 38
    }
  }
}
```

---

### C. Updating Digital Card from Mobile App (`PATCH /api/cards`)

**Request**:
```http
PATCH /api/cards HTTP/1.1
Host: mycardshare.com
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...
Content-Type: application/json

{
  "fullName": "John Doe",
  "jobTitle": "Lead Real Estate Specialist",
  "companyName": "Apex Global Realty",
  "bio": "Updated bio from mobile application.",
  "phone": "+15550199",
  "themeColor": "#10B981",
  "userStatus": "Open to Collaborations",
  "cardSlug": "john-doe",
  "socialLinks": [
    { "id": "1", "platform": "linkedin", "url": "https://linkedin.com/in/johndoe", "label": "LinkedIn" },
    { "id": "2", "platform": "twitter", "url": "https://x.com/johndoe", "label": "Twitter/X" }
  ]
}
```

**Success Response (200 OK)**:
```json
{
  "success": true,
  "message": "Card updated successfully",
  "data": {
    "card": {
      "userId": "FIREBASE_USER_UID_12345",
      "cardSlug": "john-doe",
      "jobTitle": "Lead Real Estate Specialist",
      "themeColor": "#10B981",
      "userStatus": "Open to Collaborations"
    }
  }
}
```

---

## 5. Step-by-Step Flutter Mobile App Implementation (Dart Code)

Below is the complete, copy-paste-ready Flutter code architecture to connect individual Signup & Login to the MyCardShare backend.

### A. HTTP & Auth Helper (`api_service.dart`)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String baseUrl = "https://mycardshare.com"; // Change to your backend URL

  /// Helper to get fresh Firebase Bearer Token
  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged into Firebase");
    }

    // Force refresh token if needed
    final idToken = await user.getIdToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $idToken",
    };
  }

  /// GET Request Helper
  static Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("API Error [${response.statusCode}]: ${response.body}");
    }
  }

  /// PATCH Request Helper
  static Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse("$baseUrl$endpoint"),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("API Error [${response.statusCode}]: ${response.body}");
    }
  }
}
```

---

### B. Individual Sign-Up Service (`individual_auth_service.dart`)

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'api_service.dart';

class IndividualAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign Up Individual User & Initialize Web/Backend Context
  Future<UserCredential> signUpIndividual({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // 1. Register User in Firebase Authentication
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final String uid = credential.user!.uid;

    // 2. Create User Document in Firestore with role "individual"
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': 'individual',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 3. Initialize Card Profile on Backend (Syncs to MongoDB for Web Dashboard)
    String defaultSlug = fullName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');
    await ApiService.patch('/api/cards', {
      'fullName': fullName,
      'email': email,
      'cardSlug': defaultSlug,
      'userStatus': 'Actively Networking',
      'cardStatus': 'Published',
      'themeColor': '#0A84FF',
    });

    return credential;
  }

  /// Login Individual User & Fetch Synced Profile Data
  Future<Map<String, dynamic>> loginIndividual({
    required String email,
    required String password,
  }) async {
    // 1. Authenticate with Firebase Auth
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Fetch User Profile from Backend (Validates role & company context)
    final userResponse = await ApiService.get('/api/user/me');

    // 3. Fetch User Card from Backend (Retrieves QR Slug & Dashboard Sync State)
    final cardResponse = await ApiService.get('/api/cards');

    return {
      'user': userResponse['data'],
      'card': cardResponse['data']?['card'],
    };
  }
}
```

---

## 6. How Mobile App Data Auto-Reflects on Web Dashboard

When an individual user logs in or edits their card on the **Flutter App**:

1. **Simultaneous Dual-Write**:
   - The Flutter app calls `PATCH /api/cards`.
   - The backend service (`userService.updateProfile` and `cardService.updateCard`) updates **both** Firestore (`users/{uid}`) and MongoDB (`cards` collection).

2. **Web Dashboard Instant Load**:
   - When the user opens `https://mycardshare.com/login` and signs in with their same email/password:
   - Next.js fetches profile from `/api/user/me` and `/api/cards`.
   - All edits made in the mobile app (avatar photo, job title, theme color, social links, status badge) immediately display on the Web Dashboard (`/portal/profile`).

3. **QR Code Slug Synchronization**:
   - Both Flutter App and Web App generate QR codes using the exact same target URL:
     $$\text{QR URL} = \text{https://mycardshare.com/card/} + \text{cardSlug}$$
   - Any visitor scanning the physical phone screen QR code or website QR code lands on the same public card page.

---

## 7. Key Best Practices & Security Checklist

1. **Automatic Token Refresh**: Always use `FirebaseAuth.instance.currentUser!.getIdToken()` before making an HTTP request to ensure the JWT token has not expired.
2. **Slug Uniqueness Validation**: When a user changes their custom URL slug in the mobile app, the backend `/api/cards` endpoint automatically validates uniqueness against all existing MongoDB cards and returns an error if taken.
3. **Multipart Image Uploads**: For avatars and banners, mobile apps must use `POST /api/user/upload` with `multipart/form-data` instead of sending base64 strings in `PATCH /api/user/me`.
4. **Offline Support**: Cache the card data locally on the mobile device (using `shared_preferences` or `hive`) so the QR code can be displayed even when the user is offline.

---

> **Documentation Summary**: This document details the exact technical implementation, database schemas, API specs, and Flutter Dart code necessary to seamlessly interconnect Individual Sign-Up/Login between the Mobile Application and Web Dashboard.
