import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../individual/profile/individual_profile_store.dart';
import '../individual/multiple_store/individual_multi_store.dart';
import '../enterprise/profile/enterprise_profile_store.dart';
import '../../models/user_model.dart';

/// App View Auth Gate Service
/// Handles app startup auth state inspection, login/signup session persistence,
/// and profile data restoration across app restarts.
class AppViewAuthGate {
  AppViewAuthGate._internal();
  static final AppViewAuthGate instance = AppViewAuthGate._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns true if a user is currently signed in via Firebase Auth
  bool get hasActiveSession => _auth.currentUser != null;

  /// Get the current authenticated Firebase User instance
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Inspect current session on app launch and load profile data automatically
  Future<UserModel?> restoreSessionOnAppLaunch() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[AppViewAuthGate] No active session found. Showing Onboarding.');
      return null;
    }

    debugPrint('[AppViewAuthGate] Active session detected for ${user.email} (${user.uid}). Loading user profile...');

    try {
      // 1. Fetch user role from Firestore if available
      String role = 'individual';
      String companyName = user.displayName ?? 'My Company';

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        role = data['role'] ?? 'individual';
        companyName = data['companyName'] ?? data['fullName'] ?? companyName;
      }

      if (role == 'enterprise') {
        // 2a. Hydrate EnterpriseProfileStore for enterprise users
        await EnterpriseProfileStore.instance.loadProfile(
          user.uid,
          user.email ?? '',
          companyName,
        );

        return UserModel(
          id: user.uid,
          name: EnterpriseProfileStore.instance.currentProfile?.companyName ?? companyName,
          email: user.email ?? '',
          role: role,
        );
      } else {
        // 2b. Hydrate IndividualProfileStore for individual users
        await IndividualProfileStore.instance.loadProfile(
          user.uid,
          user.email ?? '',
          user.displayName ?? '',
        );

        // 3. Sync to IndividualMultiStore for local lookup
        IndividualMultiStore.instance.saveUser(
          fullName: user.displayName ?? user.email?.split('@').first ?? 'User',
          email: user.email ?? '',
          password: '',
          role: role,
        );
      }

      return UserModel(
        id: user.uid,
        name: user.displayName ?? user.email?.split('@').first ?? 'User',
        email: user.email ?? '',
        role: role,
      );
    } catch (e) {
      debugPrint('[AppViewAuthGate] Session restoration error: $e');
      return UserModel(
        id: user.uid,
        name: user.displayName ?? user.email ?? 'User',
        email: user.email ?? '',
        role: 'individual',
      );
    }
  }


  /// Called after successful login/signup to ensure profile store & local state are synced
  Future<void> onUserAuthenticated(User user, {String role = 'individual'}) async {
    try {
      if (role == 'enterprise') {
        // Enterprise: load into EnterpriseProfileStore
        await EnterpriseProfileStore.instance.loadProfile(
          user.uid,
          user.email ?? '',
          user.displayName ?? 'My Company',
        );
      } else {
        // Individual / Employee: load into IndividualProfileStore
        await IndividualProfileStore.instance.loadProfile(
          user.uid,
          user.email ?? '',
          user.displayName ?? '',
        );

        IndividualMultiStore.instance.saveUser(
          fullName: user.displayName ?? user.email?.split('@').first ?? 'User',
          email: user.email ?? '',
          password: '',
          role: role,
        );
      }
    } catch (e) {
      debugPrint('[AppViewAuthGate] OnUserAuthenticated sync error: $e');
    }
  }

  /// Cleanly sign out current user session
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('[AppViewAuthGate] User session signed out cleanly.');
    } catch (e) {
      debugPrint('[AppViewAuthGate] SignOut error: $e');
    }
  }
}


