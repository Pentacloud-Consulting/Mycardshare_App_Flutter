import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../backend/employee_join/join_login.dart';

class JoinWorkspaceScreen extends ConsumerStatefulWidget {
  const JoinWorkspaceScreen({super.key});

  @override
  ConsumerState<JoinWorkspaceScreen> createState() => _JoinWorkspaceScreenState();
}

class _JoinWorkspaceScreenState extends ConsumerState<JoinWorkspaceScreen> {
  final TextEditingController _inviteCodeController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String _previewCompanyName = "";
  int _previewMemberCount = 0;
  String? _previewLogoUrl;
  String? _targetEnterpriseUid;

  @override
  void initState() {
    super.initState();
    _inviteCodeController.addListener(_onCodeChanged);
    _onCodeChanged();
  }

  @override
  void dispose() {
    _inviteCodeController.removeListener(_onCodeChanged);
    _inviteCodeController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    final code = _inviteCodeController.text.trim();
    if (code.isEmpty) {
      if (mounted) {
        setState(() {
          _previewCompanyName = "";
          _previewMemberCount = 0;
          _previewLogoUrl = null;
          _targetEnterpriseUid = null;
        });
      }
    } else {
      _lookupEnterpriseByCode(code);
    }
  }

  /// Live lookup using JoinLoginBackendService
  Future<void> _lookupEnterpriseByCode(String code) async {
    try {
      final info = await JoinLoginBackendService.instance.lookupEnterpriseByInviteCode(code);
      if (info != null && mounted) {
        setState(() {
          _previewCompanyName = info['companyName'] ?? 'Enterprise Workspace';
          _previewMemberCount = (info['memberCount'] as num?)?.toInt() ?? 4;
          _previewLogoUrl = info['logoUrl'] as String?;
          _targetEnterpriseUid = info['enterpriseUid'] as String?;
        });
        debugPrint('[JoinWorkspaceScreen] Resolved enterprise: $_previewCompanyName, UID: $_targetEnterpriseUid, members: $_previewMemberCount, logo: $_previewLogoUrl');
      }
    } catch (e) {
      debugPrint('[JoinWorkspaceScreen] Lookup code error: $e');
    }
  }

  Future<void> _onJoinWorkspace() async {
    final code = _inviteCodeController.text.trim();
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (code.isEmpty) {
      _showSnackBar("Please enter your invitation code", Colors.redAccent);
      return;
    }
    if (fullName.isEmpty) {
      _showSnackBar("Please enter your full name", Colors.redAccent);
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar("Please enter a valid work email address", Colors.redAccent);
      return;
    }
    if (password.isEmpty) {
      _showSnackBar("Please enter your password", Colors.redAccent);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await JoinLoginBackendService.instance.joinWorkspaceWithCode(
        inviteCode: code,
        fullName: fullName,
        email: email,
        password: password,
      );

      if (!result.success) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar(result.message, Colors.redAccent);
        }
        return;
      }

      // Log in user via authProvider
      if (result.userModel != null) {
        ref.read(authProvider.notifier).login(result.userModel!);
      }

      if (mounted) {
        _showSnackBar(
          result.message,
          const Color(0xFF16A34A),
        );
        setState(() {
          _isLoading = false;
        });
        context.go('/portal');
      }
    } catch (e) {
      debugPrint('[JoinWorkspaceScreen] Join error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar("Error joining workspace: $e", Colors.redAccent);
      }
    }
  }


  void _showSnackBar(String text, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Stack(
        children: [
          // Background Top-Left Ambient Blue Circle Glow
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38B6FF).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Small subtle float circle top
          Positioned(
            top: 45,
            left: 110,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38B6FF).withValues(alpha: 0.15),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // Centered Real Logo Badge
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0066FF).withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/logo/MYSHAREFAVO.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title & Subtitle
                  const Text(
                    "Join Your Team",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Enter your invite code to get started",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Workspace Card Preview Banner (Live Enterprise / Empty State)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _previewCompanyName.isEmpty
                        ? Container(
                            key: const ValueKey("empty_banner"),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.business_rounded,
                                    color: Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Enter invitation code below",
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        "Organization details will load automatically",
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            key: const ValueKey("loaded_banner"),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                // Real Logo Badge (or Clean Empty Fallback if no logo uploaded)
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: (_previewLogoUrl != null && _previewLogoUrl!.trim().isNotEmpty)
                                      ? ClipOval(
                                          child: _previewLogoUrl!.startsWith('http')
                                              ? Image.network(
                                                  _previewLogoUrl!,
                                                  width: 48,
                                                  height: 48,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (ctx, err, stack) =>
                                                      _buildEmptyLogoFallback(_previewCompanyName),
                                                )
                                              : Image.asset(
                                                  _previewLogoUrl!,
                                                  width: 48,
                                                  height: 48,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (ctx, err, stack) =>
                                                      _buildEmptyLogoFallback(_previewCompanyName),
                                                ),
                                        )
                                      : _buildEmptyLogoFallback(_previewCompanyName),
                                ),
                                const SizedBox(width: 12),

                                // Title + Member Count
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              _previewCompanyName,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons.verified_rounded,
                                            color: Color(0xFF0066FF),
                                            size: 15,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        "$_previewMemberCount members",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Verified Workspace Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF16A34A),
                                        size: 11,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        "Verified Workspace",
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF15803D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 18),

                  // Input 1: Invitation Code Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _inviteCodeController,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: "e.g. ZUHAIB-7687-Z9B4I9ZO",
                        labelText: "Invitation Code",
                        labelStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        prefixIcon: Icon(
                          Icons.confirmation_number_outlined,
                          color: Color(0xFF94A3B8),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Input 2: Full Name Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _fullNameController,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Full Name",
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF94A3B8),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Input 3: Work Email Field (Added as requested)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Work Email (e.g. employee@company.com)",
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Color(0xFF94A3B8),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Input 4: Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF94A3B8),
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: const Color(0xFF94A3B8),
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Join Workspace Gradient Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0066FF), Color(0xFF0099FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0066FF).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onJoinWorkspace,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Join Workspace",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer: Don't have a code? Contact your admin
                  const Text(
                    "Don't have a code? Contact your admin",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLogoFallback(String companyName) {
    final cleanName = companyName.trim();
    final initial = cleanName.isNotEmpty ? cleanName[0].toUpperCase() : '';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
      ),
      child: Center(
        child: initial.isNotEmpty
            ? Text(
                initial,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              )
            : const Icon(
                Icons.business_rounded,
                color: Color(0xFF2563EB),
                size: 24,
              ),
      ),
    );
  }
}



