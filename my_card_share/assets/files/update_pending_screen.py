with open('my_card_share/lib/features/auth/enterprice sign/registration_pending_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Imports
old_imports = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';"""

new_imports = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../backend/app view/app_view_auth_gate.dart';"""

text = text.replace(old_imports, new_imports, 1)

# 2. ConsumerStatefulWidget
old_class = """class RegistrationPendingScreen extends StatefulWidget {
  const RegistrationPendingScreen({super.key});

  @override
  State<RegistrationPendingScreen> createState() => _RegistrationPendingScreenState();
}

class _RegistrationPendingScreenState extends State<RegistrationPendingScreen>
    with SingleTickerProviderStateMixin {"""

new_class = """class RegistrationPendingScreen extends ConsumerStatefulWidget {
  const RegistrationPendingScreen({super.key});

  @override
  ConsumerState<RegistrationPendingScreen> createState() => _RegistrationPendingScreenState();
}

class _RegistrationPendingScreenState extends ConsumerState<RegistrationPendingScreen>
    with SingleTickerProviderStateMixin {"""

text = text.replace(old_class, new_class, 1)

# 3. Add _handleBackToLogin method
old_methods = """  void _handleResendEmail() async {"""

new_methods = """  Future<void> _handleBackToLogin() async {
    try {
      // ⚡ STEP 1: Sign out of Firebase Auth
      await FirebaseAuth.instance.signOut();

      // ⚡ STEP 2: Clear Google Sign-In SDK session (Crucial!)
      // This prevents Android from automatically reusing the same account!
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        await googleSignIn.disconnect();
      } catch (e) {
        debugPrint("[RegistrationPendingScreen] Google signOut notice: $e");
      }

      // ⚡ STEP 3: Clear Riverpod Auth Provider State
      ref.read(authProvider.notifier).logout();

      // ⚡ STEP 4: Clear Persistent Session & Local Storage
      await AppViewAuthGate.instance.clearPersistentSession();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('is_logged_in');
        await prefs.remove('user_id');
        await prefs.remove('user_email');
        await prefs.remove('user_name');
        await prefs.remove('user_role');
      } catch (_) {}

      // ⚡ STEP 5: Navigate to Login cleanly
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      debugPrint("[RegistrationPendingScreen] Back to login error: $e");
      if (mounted) {
        context.go('/login');
      }
    }
  }

  void _handleResendEmail() async {"""

text = text.replace(old_methods, new_methods, 1)

# 4. Wrap with PopScope
old_scaffold = """  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),"""

new_scaffold = """  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBackToLogin();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),"""

text = text.replace(old_scaffold, new_scaffold, 1)

# And close PopScope at the end of build
old_end = """        ],
      ),
    );
  }"""

new_end = """        ],
      ),
    ),
    );
  }"""

text = text.replace(old_end, new_end, 1)

# 5. Update Back to Login button
old_button = """                  // Bottom Link: Back to Login
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Padding("""

new_button = """                  // Bottom Link: Back to Login
                  GestureDetector(
                    onTap: _handleBackToLogin,
                    child: const Padding("""

text = text.replace(old_button, new_button, 1)

with open('my_card_share/lib/features/auth/enterprice sign/registration_pending_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("REGISTRATION PENDING UPDATED")
