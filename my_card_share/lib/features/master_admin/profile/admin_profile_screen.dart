import 'package:flutter/material.dart';
import '../../auth/back/smart_back_handler.dart';
import '../../auth/font style/font_style.dart';
import 'widgets/profile_avatar_section.dart';
import 'widgets/profile_form_section.dart';
import 'widgets/profile_security_section.dart';
import 'widgets/profile_activity_section.dart';
import 'widgets/profile_logout_button.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: "System Master Admin");
  final TextEditingController _emailController =
      TextEditingController(text: "admin@mycardshare.com");
  final TextEditingController _phoneController =
      TextEditingController(text: "+1 (555) 019-2834");

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logging out Master Admin..."),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartPopScope(
      onBack: () => SmartBackHandler.handleMasterAdminBack(context: context),
      child: Stack(
        children: [
          // Soft baby-blue gradient blob top-left corner
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDBEAFE).withValues(alpha: 0.7),
                    const Color(0xFFEFF6FF).withValues(alpha: 0.2),
                    const Color(0xFFF8FAFD).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

        // Content
        DefaultTextStyle(
          style: AppFontStyle.bodyMedium,
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Avatar & Super Admin Badge
              ProfileAvatarSection(
                onCameraTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Upload new profile image"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 2. Form Input Fields (Name, Email, Phone)
              ProfileFormSection(
                nameController: _nameController,
                emailController: _emailController,
                phoneController: _phoneController,
              ),
              const SizedBox(height: 24),

              // 3. Security Section
              ProfileSecuritySection(
                onChangePasswordTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Navigate to Change Password"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onTwoFactorChanged: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Two-Factor Authentication ${val ? 'Enabled' : 'Disabled'}"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onActiveSessionsTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Viewing active sessions (3 devices)"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 4. Activity Section
              const ProfileActivitySection(),
              const SizedBox(height: 28),

              // 5. Log Out Button
              ProfileLogoutButton(
                onLogoutTap: _handleLogout,
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
}
