import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../profile/enterprise_profile_store.dart';
import 'enterprise_auth_service.dart';

/// Enterprise Google Authentication & Real-Time Dual-Sync Service
/// Connects Firebase Auth, Firestore companies/users collections,
/// and Next.js /api/sync/enterprise-google-signup endpoint.
class EnterpriseGoogleAuthSyncService {
  EnterpriseGoogleAuthSyncService._internal();
  static final EnterpriseGoogleAuthSyncService instance =
      EnterpriseGoogleAuthSyncService._internal();

  static const String baseUrl = "https://mycardshare.com";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Performs Google Sign-In for Enterprise users and ensures
  /// proper Organization provisioning across Firestore and Web Backend.
  Future<EnterpriseAuthResult> signUpEnterpriseWithGoogle({
    String? companyName,
    String? adminTitle,
    String? phone,
  }) async {
    try {
      debugPrint('[EnterpriseGoogleAuthSyncService] Starting Enterprise Google Sign-In...');

      // 1. Google Sign-In Trigger
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return EnterpriseAuthResult.error('Google sign-in was cancelled.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("Firebase user is null after Google authentication.");
      }

      final String uid = user.uid;
      final String email = user.email ?? googleUser.email;
      final String displayName = user.displayName ?? googleUser.displayName ?? email.split('@').first;
      final String? photoUrl = user.photoURL ?? googleUser.photoUrl;

      final resolvedCompany = companyName?.trim().isNotEmpty == true
          ? companyName!.trim()
          : "$displayName's Organization";

      final resolvedTitle = adminTitle?.trim().isNotEmpty == true
          ? adminTitle!.trim()
          : "Enterprise Administrator";

      final slug = EnterpriseProfileData.generateCardSlug(resolvedCompany);

      // 2. Ensure Firestore users/{uid} is explicitly set as 'enterprise'
      // This prevents the Google default to "standard" / "individual" role!
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'fullName': displayName,
        'companyName': resolvedCompany,
        'role': 'enterprise',
        'status': 'active',
        'approvalStatus': 'approved',
        'cardSlug': slug,
        'plan': 'enterprise_free',
        'avatarUrl': photoUrl,
        'photoURL': photoUrl,
        'picture': photoUrl,
        'profilePhoto': photoUrl,
        'provider': 'google',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Also ensure email doc id if used
      final emailDocId = email.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      if (emailDocId != uid) {
        await _firestore.collection('users').doc(emailDocId).set({
          'uid': uid,
          'email': email,
          'role': 'enterprise',
          'companyName': resolvedCompany,
          'status': 'active',
          'approvalStatus': 'approved',
        }, SetOptions(merge: true));
      }

      // 3. Ensure Firestore enterprises/{uid} document exists
      final profileData = EnterpriseProfileData(
        uid: uid,
        companyName: resolvedCompany,
        email: email,
        logoUrl: photoUrl,
        cardSlug: slug,
        plan: 'enterprise_free',
      );

      await _firestore
          .collection('enterprises')
          .doc(uid)
          .set(profileData.toFirestore(), SetOptions(merge: true));

      // 4. Ensure companies collection entry exists
      final companyDoc = await _firestore.collection('companies').doc(uid).get();
      if (!companyDoc.exists) {
        final voucherPrefix = (resolvedCompany.replaceAll(RegExp(r'[^a-zA-Z]'), '').substring(0, 3)).toUpperCase();
        final voucherCode = '${voucherPrefix.isNotEmpty ? voucherPrefix : "MCS"}${100 + (DateTime.now().millisecondsSinceEpoch % 900)}';

        await _firestore.collection('companies').doc(uid).set({
          'companyId': uid,
          'companyName': resolvedCompany,
          'adminUid': uid,
          'adminEmail': email,
          'adminName': displayName,
          'voucherCode': voucherCode,
          'memberCount': 1,
          'status': 'active',
          'approvalStatus': 'approved',
          'logoUrl': photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // 5. Dual-Sync with Next.js Backend Endpoint (Non-blocking)
      _syncEnterpriseToBackend(
        user: user,
        companyName: resolvedCompany,
        adminTitle: resolvedTitle,
        phone: phone ?? user.phoneNumber ?? "",
      );

      // 6. Return successful auth result
      return EnterpriseAuthResult(
        isSuccess: true,
        message: 'Enterprise Google Sign-In successful.',
        firebaseUser: user,
        profileData: profileData,
        onboardingCompleted: true,
        isApproved: true,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[EnterpriseGoogleAuthSyncService] FirebaseAuthException: ${e.code}');
      return EnterpriseAuthResult.error(e.message ?? 'Authentication failed');
    } catch (e) {
      debugPrint('[EnterpriseGoogleAuthSyncService] Error: $e');
      return EnterpriseAuthResult.error('Enterprise Google Sign-In failed: $e');
    }
  }

  /// Fire-and-forget background sync to /api/sync/enterprise-google-signup
  void _syncEnterpriseToBackend({
    required User user,
    required String companyName,
    required String adminTitle,
    required String phone,
  }) async {
    try {
      final idToken = await user.getIdToken();
      final response = await http.post(
        Uri.parse("$baseUrl/api/sync/enterprise-google-signup"),
        headers: {
          "Content-Type": "application/json",
          if (idToken != null) "Authorization": "Bearer $idToken",
        },
        body: jsonEncode({
          "companyName": companyName,
          "adminTitle": adminTitle,
          "phone": phone,
          "email": user.email,
          "fullName": user.displayName,
          "avatarUrl": user.photoURL,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[EnterpriseGoogleAuthSyncService] Backend sync success: ${response.body}');
      } else {
        debugPrint('[EnterpriseGoogleAuthSyncService] Backend sync notice: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('[EnterpriseGoogleAuthSyncService] Backend sync background notice: $e');
    }
  }
}
