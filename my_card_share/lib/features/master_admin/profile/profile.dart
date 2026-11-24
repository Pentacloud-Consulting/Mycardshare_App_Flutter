import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/back/smart_back_handler.dart';
import '../../auth/font style/font_style.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'widgets/profile_avatar_section.dart';
import 'widgets/profile_form_section.dart';
import 'widgets/profile_security_section.dart';
import 'widgets/profile_activity_section.dart';
import 'widgets/profile_logout_button.dart';
import 'widgets/active_sessions_sheet.dart';
import '../../individual/settings/widgets/change_password_dialog.dart';
import '../../../backend/Cloud Image Upload/cloud_upload_service.dart';
import '../../../backend/app view/app_view_auth_gate.dart';
import '../../../providers/auth_provider.dart';

class MasterAdminProfileScreen extends ConsumerStatefulWidget {
  const MasterAdminProfileScreen({super.key});

  @override
  ConsumerState<MasterAdminProfileScreen> createState() => _MasterAdminProfileScreenState();
}

class _MasterAdminProfileScreenState extends ConsumerState<MasterAdminProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _avatarUrl;
  bool _isUploading = false;
  int _activeSessionCount = 3;

  String _formatLastLogin(DateTime? dt) {
    if (dt == null) return "Last login: Active now";
    final now = DateTime.now();
    final timeStr =
        "${dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour)}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return "Last login: Today, $timeStr";
    }
    final diff = now.difference(dt);
    if (diff.inDays == 1 || (dt.day == now.day - 1 && dt.month == now.month)) {
      return "Last login: Yesterday, $timeStr";
    }
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "Last login: ${months[dt.month - 1]} ${dt.day}, $timeStr";
  }

  String _formatLocationInfo() {
    if (kIsWeb) return "Session: Web Console · Active secure session";
    if (Platform.isAndroid) return "Session: Android Device · Active session";
    if (Platform.isIOS) return "Session: iOS Mobile · Active session";
    if (Platform.isWindows) return "Session: Windows Workstation · Active session";
    return "Session: Secure Admin Workstation";
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authUser = ref.read(authProvider).user;
    final fbUser = FirebaseAuth.instance.currentUser;
    final email = (authUser?.email.isNotEmpty == true)
        ? authUser!.email
        : ((fbUser?.email?.isNotEmpty == true) ? fbUser!.email! : "admin@pentcloud.me");
    final name = (authUser?.name.isNotEmpty == true)
        ? authUser!.name
        : ((fbUser?.displayName?.isNotEmpty == true) ? fbUser!.displayName! : "Platform Master Admin");
    final phone = fbUser?.phoneNumber ?? "+1 (555) 019-2834";
    final avatar = fbUser?.photoURL;

    _emailController.text = email;
    _nameController.text = name;
    _avatarUrl = avatar;
    _phoneController.text = phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 800,
    );

    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(picked.path);
      final uploadedUrl = await CloudUploadService.uploadImageFile(
        imageFile: file,
        category: "avatar",
      );

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        setState(() {
          _avatarUrl = uploadedUrl;
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePhotoURL(uploadedUrl);
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'avatarUrl': uploadedUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🎉 Profile picture updated successfully!"),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to upload image. Please check network."),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upload error: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _handleLogout() async {
    ref.read(authProvider.notifier).logout();
    await AppViewAuthGate.instance.clearPersistentSession();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logged out successfully."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF0F172A),
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text.trim();
    final initials = () {
      if (name.isEmpty) return "MA";
      final parts = name.split(RegExp(r'\s+'));
      if (parts.length == 1) {
        return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
      }
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }();

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
                    const Color(0xFFFED7AA).withValues(alpha: 0.5),
                    const Color(0xFFFFF7ED).withValues(alpha: 0.2),
                    const Color(0xFFF8FAFD).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main Body Content
          DefaultTextStyle(
            style: AppFontStyle.bodyMedium,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Avatar & Super Admin Badge
                  ProfileAvatarSection(
                    initials: initials,
                    avatarUrl: _avatarUrl,
                    onCameraTap: _isUploading ? null : _pickAndUploadImage,
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
                activeSessionsCount:
                    "$_activeSessionCount ${_activeSessionCount == 1 ? 'device' : 'devices'}",
                onChangePasswordTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ChangePasswordDialog(),
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
                  ActiveSessionsSheet.show(
                    context,
                    onSessionsUpdated: () {
                      if (mounted) {
                        setState(() {
                          _activeSessionCount = 1;
                        });
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // 4. Activity Section
              ProfileActivitySection(
                lastLogin: _formatLastLogin(FirebaseAuth.instance.currentUser?.metadata.lastSignInTime),
                locationInfo: _formatLocationInfo(),
              ),
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


