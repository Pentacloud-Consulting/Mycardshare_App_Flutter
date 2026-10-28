with open('my_card_share/lib/features/auth/login/login_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Add import
if 'google_sign_in.dart' not in text:
    text = "import 'package:google_sign_in/google_sign_in.dart';\n" + text

# 2. Add signOut in _onGoogleLogin
old_on_google = """  void _onGoogleLogin() async {
    final roleStr = _selectedTab == 1
        ? 'enterprise'
        : _selectedTab == 2
            ? 'employee'
            : 'individual';"""

new_on_google = """  void _onGoogleLogin() async {
    final roleStr = _selectedTab == 1
        ? 'enterprise'
        : _selectedTab == 2
            ? 'employee'
            : 'individual';

    // ⚡ ALWAYS call signOut first so Android shows 'Choose an account' dialog!
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('[LoginScreen] Pre-Google login signout notice: $e');
    }"""

text = text.replace(old_on_google, new_on_google, 1)

with open('my_card_share/lib/features/auth/login/login_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print('LOGIN SCREEN UPDATED')
