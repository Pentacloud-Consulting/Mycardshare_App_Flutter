import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../back/smart_back_handler.dart';
import '../font style/font_style.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';

class EmployeeLoginScreen extends ConsumerStatefulWidget {
  const EmployeeLoginScreen({super.key});

  @override
  ConsumerState<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends ConsumerState<EmployeeLoginScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: "you@acmerealty.com");
  final TextEditingController _passwordController = TextEditingController();
  int _selectedTab = 2; // Default 2: Employee tab
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Recognized company state based on email
  String _recognizedCompanyName = "Acme Realty Group";
  String _recognizedCompanyMembers = "34 members · Enterprise";
  bool _isCompanyRecognized = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final email = _emailController.text.trim().toLowerCase();
    setState(() {
      if (email.contains("vertex")) {
        _recognizedCompanyName = "Vertex Media Group";
        _recognizedCompanyMembers = "25 members · Enterprise Pro";
        _isCompanyRecognized = true;
      } else if (email.contains("crestview")) {
        _recognizedCompanyName = "Crestview Capital";
        _recognizedCompanyMembers = "18 members · Enterprise";
        _isCompanyRecognized = true;
      } else if (email.contains("@") && email.split("@").last.isNotEmpty) {
        final domain = email.split("@").last;
        final name = domain.split(".").first;
        _recognizedCompanyName =
            "${name[0].toUpperCase()}${name.substring(1)} Workspace";
        _recognizedCompanyMembers = "Verified Organization Domain";
        _isCompanyRecognized = true;
      } else if (email.isNotEmpty) {
        _recognizedCompanyName = "Acme Realty Group";
        _recognizedCompanyMembers = "34 members · Enterprise";
        _isCompanyRecognized = true;
      } else {
        _isCompanyRecognized = false;
      }
    });
  }

  void _onLogin() {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final roleStr = _selectedTab == 1
        ? 'enterprise'
        : _selectedTab == 2
            ? 'employee'
            : 'individual';

    final user = UserModel(
      id: 'emp_user_1',
      name: 'Alex Johnson',
      email: email.isNotEmpty ? email : 'alex@acmerealty.com',
      role: roleStr,
    );

    ref.read(authProvider.notifier).login(user);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (roleStr == 'enterprise') {
          context.go('/enterprise-onboarding');
        } else {
          context.go('/portal');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartPopScope(
      onBack: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go('/onboarding');
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
        children: [
          // Soft baby-blue gradient blob in top-left corner
          Positioned(
            top: -90,
            left: -90,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDBEAFE).withValues(alpha: 0.75),
                    const Color(0xFFEFF6FF).withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 36),

                  // Top: Small circular app logo (blue gradient card icon) centered
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0052FF).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bold headline "Welcome Back" in dark navy
                  Text(
                    "Welcome Back",
                    textAlign: TextAlign.center,
                    style: AppFontStyle.headlineLarge.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Login to manage your digital card",
                    textAlign: TextAlign.center,
                    style: AppFontStyle.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // Segmented Tab Bar (3 pill-shaped tabs) inside rounded light-gray pill container
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        _buildTabPill(
                          index: 0,
                          icon: Icons.person_outline_rounded,
                          label: "Individual",
                        ),
                        _buildTabPill(
                          index: 1,
                          icon: Icons.business_rounded,
                          label: "Enterprise",
                        ),
                        _buildTabPill(
                          index: 2,
                          icon: Icons.people_alt_rounded,
                          label: "Employee",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Company Branding Preview Card (Employee Tab Only)
                  if (_selectedTab == 2 && _isCompanyRecognized) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0052FF).withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Small company logo circle (left)
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0052FF), Color(0xFF1D4ED8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0052FF).withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _recognizedCompanyName.isNotEmpty
                                    ? _recognizedCompanyName.substring(0, 2).toUpperCase()
                                    : "AR",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Company Info Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _recognizedCompanyName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _recognizedCompanyMembers,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Small Green Checkmark Badge "Recognized"
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF10B981),
                                  size: 13,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Recognized",
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Work Email Address Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: "you@acmerealty.com",
                        labelText: "Work Email Address",
                        labelStyle: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Password Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: "••••••••",
                        labelText: "Password",
                        labelStyle: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF64748B),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.push('/reset-password'),
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0052FF),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Full-width rounded gradient button (blue #0052FF to light blue #38bdf8)
                  _isLoading
                      ? Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                            ),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: _onLogin,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0052FF).withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ],
                            ),
                          ),
                        ),

                  const SizedBox(height: 32),

                  // Bottom: Centered text "New Employee? Join Workspace"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "New Employee? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/join-workspace'),
                        child: const Text(
                          "Join Workspace",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF10B981), // Distinct Green
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0052FF).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
