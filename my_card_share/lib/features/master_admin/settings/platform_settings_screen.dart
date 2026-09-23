import 'package:flutter/material.dart';
import '../../auth/back/smart_back_handler.dart';
import '../../auth/font style/font_style.dart';
import 'widgets/ai_engine_keys_section.dart';
import 'widgets/wallet_credentials_section.dart';
import 'widgets/super_admin_accounts_section.dart';
import 'widgets/system_status_section.dart';

class PlatformSettingsScreen extends StatefulWidget {
  const PlatformSettingsScreen({super.key});

  @override
  State<PlatformSettingsScreen> createState() => _PlatformSettingsScreenState();
}

class _PlatformSettingsScreenState extends State<PlatformSettingsScreen> {
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

        // Main scrollable content
        DefaultTextStyle(
          style: AppFontStyle.bodyMedium,
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. AI Engine Keys Section
              AiEngineKeysSection(
                onEditGemini: () {
                  _showSnackBar("Edit Gemini API Key");
                },
                onEditHuggingFace: () {
                  _showSnackBar("Edit HuggingFace API Key");
                },
                onFirebaseConfig: () {
                  _showSnackBar("Configure Firebase Admin Key");
                },
              ),
              const SizedBox(height: 20),

              // 2. Digital Wallet Credentials Section
              WalletCredentialsSection(
                onAppleWalletTap: () {
                  _showSnackBar("Apple Wallet PassKit settings");
                },
                onGoogleWalletTap: () {
                  _showSnackBar("Google Wallet credentials settings");
                },
                onSamsungWalletTap: () {
                  _showSnackBar("Samsung Wallet configuration");
                },
              ),
              const SizedBox(height: 20),

              // 3. Super Admin Accounts Section
              SuperAdminAccountsSection(
                onRemoveAccount: (account) {
                  _showSnackBar("Removed super admin: ${account.name}");
                },
                onAddSuperAdmin: () {
                  _showSnackBar("Add New Super Admin dialog");
                },
              ),
              const SizedBox(height: 20),

              // 4. System Status Section
              SystemStatusSection(
                onEnvironmentTap: () {
                  _showSnackBar("Environment: Production");
                },
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
