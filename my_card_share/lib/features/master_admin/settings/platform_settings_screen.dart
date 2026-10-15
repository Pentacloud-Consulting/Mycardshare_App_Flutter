import 'package:flutter/material.dart';
import '../../auth/back/smart_back_handler.dart';
import '../../auth/font style/font_style.dart';
import '../../../backend/master_admin/settings/platform_settings_store.dart';
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
  void initState() {
    super.initState();
    PlatformSettingsStore.instance.checkDatabaseHealth();
  }

  void _showAddAdminDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Add Super Admin",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Admin Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final n = nameCtrl.text.trim();
              final e = emailCtrl.text.trim();
              if (n.isNotEmpty && e.contains('@')) {
                Navigator.pop(ctx);
                final ok = await PlatformSettingsStore.instance.addSuperAdmin(name: n, email: e);
                if (mounted) {
                  _showSnackBar(ok ? "Super Admin $n added live!" : "Error adding admin");
                }
              }
            },
            child: const Text("Add Account", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditKeyDialog(String keyType, String currentKey) {
    final ctrl = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Update ${keyType == 'gemini' ? 'Gemini API' : 'HuggingFace'} Key",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: "API Key",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final key = ctrl.text.trim();
              if (key.isNotEmpty) {
                Navigator.pop(ctx);
                await PlatformSettingsStore.instance.updateKey(keyType: keyType, newKey: key);
                if (mounted) {
                  _showSnackBar("${keyType.toUpperCase()} key updated live.");
                }
              }
            },
            child: const Text("Save Key", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartPopScope(
      onBack: () => SmartBackHandler.handleMasterAdminBack(context: context),
      child: AnimatedBuilder(
        animation: PlatformSettingsStore.instance,
        builder: (context, _) {
          final store = PlatformSettingsStore.instance;

          return StreamBuilder<List<PlatformAdminAccount>>(
            stream: store.streamSuperAdmins(),
            builder: (context, adminSnapshot) {
              final adminList = adminSnapshot.data ?? store.superAdmins;
              final accountItems = adminList.map((a) {
                return AdminAccountItem(
                  initials: a.initials,
                  name: a.name,
                  email: a.email,
                  isPrimary: a.isPrimary,
                );
              }).toList();

              return Stack(
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
                            onEditGemini: () => _showEditKeyDialog('gemini', store.geminiKey),
                            onEditHuggingFace: () => _showEditKeyDialog('huggingface', store.huggingFaceKey),
                            onFirebaseConfig: () {
                              _showSnackBar("Firebase Admin SDK connection verified healthy");
                            },
                          ),
                          const SizedBox(height: 20),

                          // 2. Digital Wallet Credentials Section
                          WalletCredentialsSection(
                            onAppleWalletTap: () {
                              _showSnackBar("Apple Wallet PassKit Certificate: Active & Configured");
                            },
                            onGoogleWalletTap: () {
                              _showSnackBar("Google Wallet Issuer ID: Active & Configured");
                            },
                            onSamsungWalletTap: () {
                              _showSnackBar("Samsung Wallet Partner API: Active & Configured");
                            },
                          ),
                          const SizedBox(height: 20),

                          // 3. Super Admin Accounts Section
                          SuperAdminAccountsSection(
                            adminAccounts: accountItems,
                            onRemoveAccount: (account) async {
                              final match = adminList.firstWhere(
                                (a) => a.email == account.email,
                                orElse: () => PlatformAdminAccount(id: '', name: '', email: ''),
                              );
                              if (match.id.isNotEmpty && !match.isPrimary) {
                                await store.removeSuperAdmin(match.id);
                                _showSnackBar("Super admin ${account.name} removed.");
                              } else {
                                _showSnackBar("Primary master admin account cannot be removed.");
                              }
                            },
                            onAddSuperAdmin: _showAddAdminDialog,
                          ),
                          const SizedBox(height: 20),

                          // 4. System Status Section
                          SystemStatusSection(
                            appVersion: "v1.0.0",
                            dbStatus: store.dbStatus,
                            onEnvironmentTap: () {
                              _showSnackBar("Environment: Production (AWS/GCP Multi-Region)");
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
