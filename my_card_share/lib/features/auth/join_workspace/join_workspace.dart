import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../backend/employee_join/join_login.dart';
import '../../../backend/employee_join/email_send_request.dart';
import '../../../backend/employee_join/employee_join_request_service.dart';
import '../../../backend/app view/app_view_auth_gate.dart';
import '../../../backend/employee_join/home/employee_home_backend.dart';
import '../../../backend/employee_join/home/employee_stats_backend.dart';
import '../../../services/auth/password_validator.dart';

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
  final TextEditingController _targetEnterpriseEmailController = TextEditingController();

  PasswordValidationResult _passwordValidation = PasswordValidationResult.empty();

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
    _targetEnterpriseEmailController.dispose();
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
        if (info['isExpired'] == true) {
          _showSnackBar("The invite code got expired. Please request a new invite link.", Colors.orange);
        }
        setState(() {
          _previewCompanyName = info['companyName'] ?? 'Enterprise Workspace';
          _previewMemberCount = (info['memberCount'] as num?)?.toInt() ?? 4;
          _previewLogoUrl = info['logoUrl'] as String?;
          _targetEnterpriseUid = info['enterpriseUid'] as String?;
        });
        debugPrint('[JoinWorkspaceScreen] Resolved enterprise: $_previewCompanyName, UID: $_targetEnterpriseUid, members: $_previewMemberCount, logo: $_previewLogoUrl, expired: ${info['isExpired']}');
      }
    } catch (e) {
      debugPrint('[JoinWorkspaceScreen] Lookup code error: $e');
    }
  }

  /// Triggered when user doesn't have an invite code and clicks "Next"
  void _onNextRequest() {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

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

    final validation = PasswordValidationResult.validate(password);
    if (!validation.isValid) {
      _showSnackBar(validation.firstErrorMessage ?? "Password does not meet required criteria", Colors.redAccent);
      return;
    }

    _showEnterpriseEmailModal();
  }

  /// Modal to enter target enterprise email to send join request
  void _showEnterpriseEmailModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool sending = false;
        String? foundCompName;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          color: Color(0xFF0066FF),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Send Join Request",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Enter the official company/admin email of your enterprise.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Enterprise Email Input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    ),
                    child: TextField(
                      controller: _targetEnterpriseEmailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) async {
                        if (val.contains('@')) {
                          final ent = await EmailSendRequestService.instance.lookupEnterpriseByEmailOrName(val);
                          setModalState(() {
                            foundCompName = ent?['companyName'];
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: "Enterprise Email (e.g. admin@islamicweb.com)",
                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: Icon(Icons.business_rounded, color: Color(0xFF0066FF), size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),

                  if (foundCompName != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            "Verified Enterprise: $foundCompName",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Send Request Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: sending
                          ? null
                          : () async {
                              final entEmail = _targetEnterpriseEmailController.text.trim();
                              if (entEmail.isEmpty || !entEmail.contains('@')) {
                                _showSnackBar("Please enter a valid enterprise email address", Colors.redAccent);
                                return;
                              }

                              setModalState(() => sending = true);

                              final ok = await EmailSendRequestService.instance.sendJoinRequest(
                                targetEnterpriseEmail: entEmail,
                                applicantName: _fullNameController.text.trim(),
                                applicantEmail: _emailController.text.trim().toLowerCase(),
                                applicantPassword: _passwordController.text.trim(),
                              );

                              // Sync with Next.js Backend /api/sync/employee-join-request
                              await EmployeeJoinRequestService.submitWorkEmailJoinRequest(
                                workEmail: _emailController.text.trim().toLowerCase(),
                                fullName: _fullNameController.text.trim(),
                                jobTitle: 'Team Member',
                              );

                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                              }
                              if (!mounted) return;

                              if (ok) {
                                _showSnackBar(
                                  "Join request sent successfully to $entEmail! You will be notified once approved.",
                                  const Color(0xFF16A34A),
                                );
                              } else {
                                _showSnackBar("Failed to send request. Please check email address.", Colors.redAccent);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: sending
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "Send Join Request",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onJoinWorkspace() async {
    final code = _inviteCodeController.text.trim();
    if (code.isEmpty) {
      _onNextRequest();
      return;
    }

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

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

    final validation = PasswordValidationResult.validate(password);
    if (!validation.isValid) {
      _showSnackBar(validation.firstErrorMessage ?? "Password does not meet required criteria", Colors.redAccent);
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

      // Log in user via authProvider & persist session
      if (result.userModel != null) {
        ref.read(authProvider.notifier).login(result.userModel!);
        await AppViewAuthGate.instance.savePersistentSession(result.userModel!);
        EmployeeHomeBackendService.instance.loadEmployeeHomeData();
        EmployeeStatsBackendService.instance.loadEmployeeStats();
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
                      onChanged: (val) {
                        setState(() {
                          _passwordValidation = PasswordValidationResult.validate(val);
                        });
                      },
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

                  // Live Password Strength Meter & Checklist (Matching Website Policy)
                  if (_passwordController.text.isNotEmpty)
                    PasswordStrengthIndicatorWidget(validation: _passwordValidation),

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
                                children: [
                                  Text(
                                    _inviteCodeController.text.trim().isEmpty
                                        ? "Next"
                                        : "Join Workspace",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
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



