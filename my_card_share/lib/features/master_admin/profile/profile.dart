import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/back/smart_back_handler.dart';
import '../../auth/font style/font_style.dart';
import 'widgets/profile_avatar_section.dart';
import 'widgets/profile_form_section.dart';
import 'widgets/profile_security_section.dart';
import 'widgets/profile_activity_section.dart';
import 'widgets/profile_logout_button.dart';
import '../../individual/settings/widgets/change_password_dialog.dart';
import '../../../backend/Cloud Image Upload/cloud_upload_service.dart';

class MasterAdminProfileScreen extends StatefulWidget {
  const MasterAdminProfileScreen({super.key});

  @override
  State<MasterAdminProfileScreen> createState() => _MasterAdminProfileScreenState();
}

class _MasterAdminProfileScreenState extends State<MasterAdminProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _avatarUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? "admin@mycardshare.com";
      _nameController.text = user.displayName ?? "System Master Admin";
      _avatarUrl = user.photoURL;
      _phoneController.text = user.phoneNumber ?? "+1 (555) 019-2834";
    } else {
      _nameController.text = "System Master Admin";
      _emailController.text = "admin@mycardshare.com";
      _phoneController.text = "+1 (555) 019-2834";
    }
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
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logged out successfully."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF0F172A),
        ),
      );
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/master-admin/login', (route) => false);
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
                    const Color(0xFFDBEAFE).withValues(alpha: 0.7),
                    const Color(0xFFEFF6FF).withValues(alpha: 0.2),
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


