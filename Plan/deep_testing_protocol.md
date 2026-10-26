# 🧪 Complete Deep Verification & End-to-End Testing Protocol

Use this structured prompt and step-by-step checklist to rigorously test all 5 synchronized features across **Next.js Web** and the **Flutter Mobile App**.

---

## 🎯 Test Suite 1: Enterprise Sign-Up & Approval Gate Lifecycle

### Objective:
Verify that a newly registered Enterprise cannot log in until Master Admin approves it, and that status transitions are strictly enforced.

### Step-by-Step Test:
1. **New Enterprise Sign-Up**:
   - Open Web `https://digitalbusinesscloudcard.com/signup` or Mobile App Sign-up screen.
   - Choose tab: **Enterprise**.
   - Fill details:
     - Company Name: `Apex Global Tech`
     - Admin Email: `apex.admin@testmail.com`
     - Password: `Password@123` (Meeting 8 chars, 1 upper, 1 lower, 1 number, 1 special).
   - Click **Create admin account**.
2. **Verify Pending State**:
   - Immediately attempt to log in with `apex.admin@testmail.com` / `Password@123`.
   - **Expected Result**: 
     - 🛑 Access **DENIED**.
     - Error message displays: *"Your organization is pending Master Admin approval. You will be notified once approved."*
     - User is NOT redirected to `/enterprise/dashboard`.

---

## 🎯 Test Suite 2: Master Admin Approvals & Cascade Verification

### Objective:
Verify that Master Admin can see the pending company and that clicking **Approve** cascades the status to both Firestore `companies` and `users`.

### Step-by-Step Test:
1. **Login as Master Admin**:
   - Log into Master Admin portal on Web or Mobile.
   - Navigate to **Approvals** tab (or bottom nav Approvals).
2. **Check Pending Queue**:
   - Verify `Apex Global Tech` is listed under pending approvals with amber badge.
3. **Execute Approval**:
   - Click the **[Approve]** button.
   - **Expected Result**:
     - Status updates instantly to `Approved`.
     - Card disappears from pending list and moves to active Companies list.
4. **Post-Approval Enterprise Login**:
   - Return to login and sign in as `apex.admin@testmail.com` / `Password@123`.
   - **Expected Result**:
     - ✅ Login succeeds immediately.
     - User is safely directed to `/enterprise/dashboard` with full access to roster, brand settings, and campaigns.

---

## 🎯 Test Suite 3: Team Invite Code & Workspace Isolation (Collision Prevention)

### Objective:
Verify that an invite code generated from Company A **only** allows joining Company A, and never accidentally joins Company B (e.g., Islamic web).

### Step-by-Step Test:
1. **Generate Invite Code from Enterprise A**:
   - In `Apex Global Tech` dashboard, open **Team** -> **Invite Employee** / **Invite by Link**.
   - Note the 8-digit deterministic rotating code (e.g. `58392014`) or copy the join link:
     `https://mycardshare.com/join-workspace?enterpriseId={APEX_ID}&code=58392014`
2. **Employee Code Entry**:
   - On a separate device or browser in mobile view, open `/join-workspace`.
   - Enter the 8-digit code.
3. **Inspect Resolved Workspace Preview**:
   - **Expected Result**:
     - The preview screen MUST show **"Apex Global Tech"** with Apex branding.
     - ❌ It must NEVER show any other company name.
4. **Complete Onboarding**:
   - Complete employee onboarding with `employee1@apex.com`.
   - Log in and verify:
     - Employee card has `Apex Global Tech` branding.
     - In Apex Admin dashboard, employee count increases by 1.

---

## 🎯 Test Suite 4: Save Contact (Zero Dialpad, Instant Toast)

### Objective:
Verify that tapping **Save Contact** on a digital card directly triggers the mobile contact card / vCard import without ever launching the phone dialer.

### Step-by-Step Test:
1. **Open Digital Card**:
   - Open any public digital card (e.g. `/card/khyati-duac` or from mobile app profile).
2. **Tap "Save Contact"**:
   - **Expected Result 1 (0ms Latency)**: Toast banner immediately pops up:
     *`Saving Khyati Dua to mobile contacts...`*
   - **Expected Result 2 (No Dialpad)**:
     - ❌ Phone Call Dialpad / Dialer does **NOT** open.
     - ✅ Device displays native Android/iOS **"Import contact / Add to Contacts"** sheet with Name, Phone, Email, Company, and Job Title pre-filled.

---

## 🎯 Test Suite 5: Campaign Creation & Real Label Verification

### Objective:
Verify that creating a custom campaign displays the user's custom campaign name instead of generic numbers ("Campaign 1", "Campaign 2").

### Step-by-Step Test:
1. **Create New Campaign**:
   - Open **Campaigns** screen in mobile app or web portal.
   - Click **+ New Campaign**.
   - Enter Name: `Tech Expo 2026 Flyer` (or `test campaign 2`).
   - Click **Create Campaign**.
2. **Inspect Campaigns List**:
   - **Expected Result**:
     - List item title reads: **"Tech Expo 2026 Flyer"** (or **"test campaign 2"**).
     - ❌ It does **NOT** say "Campaign 1" or "Campaign 2".
     - Trackable link and QR code are active and increment scan count on tap.
