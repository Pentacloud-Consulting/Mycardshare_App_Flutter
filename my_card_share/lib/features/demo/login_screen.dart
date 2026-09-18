import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FBFE),
              Color(0xFFE6F3FF),
              Color(0xFF8AC7FF),
              Color(0xFF2988FA),
            ],
            stops: [0.0, 0.4, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF2C3333),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text("🖐️", style: TextStyle(fontSize: 28)),
                  ],
                ),
                const SizedBox(height: 50),
                _buildTextField(
                  hint: "Enter Email",
                  icon: Icons.mail_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  hint: "Enter Password",
                  icon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  isPassword: true,
                  onIconTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xFF2988FA),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2988FA),
                      elevation: 4,
                      shadowColor: const Color(0x802988FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(child: Divider(color: const Color(0xFF999999), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Or with",
                        style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider(color: const Color(0xFF999999), thickness: 1)),
                  ],
                ),
                const SizedBox(height: 30),
                _buildGoogleButton(),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't Have An Account? ",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? onIconTap,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xD9E8ECEF), 
        borderRadius: BorderRadius.circular(27),
      ),
      child: TextField(
        obscureText: isPassword && _obscurePassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          suffixIcon: GestureDetector(
            onTap: onIconTap,
            child: Icon(icon, color: const Color(0xFF888888), size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xE6E8ECEF),
        borderRadius: BorderRadius.circular(27),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(27),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: Text(
                      "G",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Continue with Google",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Color(0xFF555555), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
