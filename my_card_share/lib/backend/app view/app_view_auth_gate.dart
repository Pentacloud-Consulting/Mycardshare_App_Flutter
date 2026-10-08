import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../individual/profile/individual_profile_store.dart';
import '../individual/multiple_store/individual_multi_store.dart';
import '../enterprise/profile/enterprise_profile_store.dart';
import '../enterprise/multiple_store/enterprise_multi_store.dart';
import '../enterprise/home_backend/employees_page.dart';
import '../employee_join/home/employee_home_backend.dart';
import '../employee_join/home/employee_stats_backend.dart';
import '../../models/user_model.dart';

/// App View Auth Gate Service
/// Handles app startup auth state inspection, login/signup session persistence,
/// and profile data restoration across app restarts.
class AppViewAuthGate {
  AppViewAuthGate._internal();
  static final AppViewAuthGate instance = AppViewAuthGate._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns true if a user is currently signed in via Firebase Auth or SharedPreferences
  bool get hasActiveSession => _auth.currentUser != null;

  /// Get the current authenticated Firebase User instance
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Saves session data to persistent SharedPreferences storage
  Future<void> savePersistentSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_role', user.role.toLowerCase());
      debugPrint('[AppViewAuthGate] Persistent session saved for ${user.email} (role: ${user.role}).');
    } catch (e) {
      debugPrint('[AppViewAuthGate] Error saving persistent session: $e');
    }
  }

  /// Clears persistent SharedPreferences session on logout
  Future<void> clearPersistentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_role');
      debugPrint('[AppViewAuthGate] Persistent session cleared from SharedPreferences.');
    } catch (e) {
      debugPrint('[AppViewAuthGate] Error clearing persistent session: $e');
    }
  }

  /// Inspect current session on app launch and load profile data automatically
  Future<UserModel?> restoreSessionOnAppLaunch() async {
    final user = _auth.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final isPersistedLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (user == null && !isPersistedLoggedIn) {
      debugPrint('[AppViewAuthGate] No active Firebase or persistent session found. Showing Onboarding.');
      return null;
    }

    String email = user?.email?.trim().toLowerCase() ?? prefs.getString('user_email')?.trim().toLowerCase() ?? '';
    String role = prefs.getString('user_role')?.toLowerCase() ?? 'individual';
    String uid = user?.uid ?? prefs.getString('user_id') ?? 'user_restored';
    String name = user?.displayName ?? prefs.getString('user_name') ?? (email.contains('@') ? email.split('@').first : 'User');
    String companyName = 'Islamic Web';

    debugPrint('[AppViewAuthGate] Active session detected for $email ($uid, role: $role). Restoring session...');

    try {
      // Check EnterpriseMultiStore
      final storeUser = EnterpriseMultiStore.instance.getUser(email);
      if (storeUser != null) {
        if (storeUser.role.isNotEmpty) role = storeUser.role.toLowerCase();
        if (storeUser.companyName.isNotEmpty) companyName = storeUser.companyName;
      }

      // Query Firestore users collection by UID & Email DocId
      if (user != null || email.isNotEmpty) {
        try {
          DocumentSnapshot? doc;
          if (user != null) {
            final snap = await _firestore.collection('users').doc(user.uid).get();
            if (snap.exists) doc = snap;
          }
          if (doc == null && email.isNotEmpty) {
            final docId = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
            final snap = await _firestore.collection('users').doc(docId).get();
            if (snap.exists) doc = snap;
          }

          if (doc != null && doc.data() != null) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['role'] != null && (data['role'] as String).isNotEmpty) {
              role = (data['role'] as String).toLowerCase();
            }
            if (data['companyName'] != null) companyName = data['companyName'];
            if (data['fullName'] != null) name = data['fullName'];
          }
        } catch (e) {
          debugPrint('[AppViewAuthGate] Firestore role lookup note: $e');
        }
      }

      if (role == 'enterprise') {
        await EnterpriseProfileStore.instance.loadProfile(uid, email, companyName);
        final userModel = UserModel(
          id: uid,
          name: EnterpriseProfileStore.instance.currentProfile?.companyName ?? companyName,
          email: email,
          role: 'enterprise',
        );
        await savePersistentSession(userModel);
        return userModel;
      } else if (role == 'employee') {
        EmployeeHomeBackendService.instance.loadEmployeeHomeData();
        EmployeeStatsBackendService.instance.loadEmployeeStats();
        final userModel = UserModel(
          id: uid,
          name: name,
          email: email,
          role: 'employee',
        );
        await savePersistentSession(userModel);
        return userModel;
      } else {
        await IndividualProfileStore.instance.loadProfile(uid, email, name);
        IndividualMultiStore.instance.saveUser(
          fullName: name,
          email: email,
          password: '',
          role: 'individual',
        );
        final userModel = UserModel(
          id: uid,
          name: name,
          email: email,
          role: 'individual',
        );
        await savePersistentSession(userModel);
        return userModel;
      }
    } catch (e) {
      debugPrint('[AppViewAuthGate] Session restoration error: $e');
      final fallbackModel = UserModel(
        id: uid,
        name: name,
        email: email,
        role: role,
      );
      await savePersistentSession(fallbackModel);
      return fallbackModel;
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

      await savePersistentSession(UserModel(
        id: user.uid,
        name: user.displayName ?? user.email?.split('@').first ?? 'User',
        email: user.email ?? '',
        role: role,
      ));
    } catch (e) {
      debugPrint('[AppViewAuthGate] OnUserAuthenticated sync error: $e');
    }
  }

  /// Cleanly sign out current user session
  Future<void> signOut() async {
    try {
      await EnterpriseEmployeesService.instance.markEmployeeInactive();
      await clearPersistentSession();
      await _auth.signOut();
      debugPrint('[AppViewAuthGate] User session signed out cleanly.');
    } catch (e) {
      debugPrint('[AppViewAuthGate] SignOut error: $e');
    }
  }
}




