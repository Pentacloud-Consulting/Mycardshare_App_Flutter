import 'package:flutter/material.dart';
import '../../../../backend/enterprise/security/enterprise_security_service.dart';

/// Dedicated Enterprise Security & Access Control Management Screen.
class EnterpriseSecurityScreen extends StatefulWidget {
  const EnterpriseSecurityScreen({super.key});

  @override
  State<EnterpriseSecurityScreen> createState() =>
      _EnterpriseSecurityScreenState();
}

class _EnterpriseSecurityScreenState extends State<EnterpriseSecurityScreen> {
  final TextEditingController _domainController = TextEditingController();
  bool _isSaving = false;
  bool _isEditingDomain = false;

  final List<Map<String, dynamic>> _ssoProviders = [
    {
      'name': 'Google Workspace',
      'icon': Icons.g_mobiledata_rounded,
      'color': Color(0xFF4285F4),
      'desc': 'OAuth 2.0 & Google Sign-In',
    },
    {
      'name': 'Microsoft Entra ID',
      'icon': Icons.window_rounded,
      'color': Color(0xFF0078D4),
      'desc': 'Azure AD & Office 365 SSO',
    },
    {
      'name': 'Okta Identity',
      'icon': Icons.security_rounded,
      'color': Color(0xFF00297A),
      'desc': 'Okta SAML 2.0 & OIDC',
    },
    {
      'name': 'SAML 2.0 / Custom',
      'icon': Icons.link_rounded,
      'color': Color(0xFF059669),
      'desc': 'Custom Corporate IDP',
    },
  ];

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  void _showToast(String msg, {bool isSuccess = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.info_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isSuccess ? const Color(0xFF059669) : const Color(0xFFD4642C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: StreamBuilder<EnterpriseSecurityPolicies>(
        stream: EnterpriseSecurityService.instance.streamPolicies(),
        builder: (context, snapshot) {
          final policies = snapshot.data ?? EnterpriseSecurityPolicies();

          if (!_isEditingDomain && _domainController.text.isEmpty) {
            _domainController.text = policies.allowedDomain;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Summary Header Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFA7F3D0),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Color(0xFF059669),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Security & Access",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: policies.ssoEnforced &&
                                            policies.domainLockEnabled
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFFF7ED),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: policies.ssoEnforced &&
                                              policies.domainLockEnabled
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFD4642C),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 3,
                                        backgroundColor: policies.ssoEnforced &&
                                                policies.domainLockEnabled
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFD4642C),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        policies.ssoEnforced &&
                                                policies.domainLockEnabled
                                            ? "ACTIVE & PROTECTED"
                                            : "STANDARD",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: policies.ssoEnforced &&
                                                  policies.domainLockEnabled
                                              ? const Color(0xFF047857)
                                              : const Color(0xFFD4642C),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Enforce Single Sign-On (SSO) and corporate domain verification for all enterprise employees.",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF64748B),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── 1. Single Sign-On (SSO) Authentication Section ──
                _buildSectionTitle(
                  "SINGLE SIGN-ON (SSO)",
                  "Manage identity provider integration and employee login rules",
                ),
                const SizedBox(height: 10),
                _buildCard(
                  children: [
                    // Enforce SSO Only Switch
                    _buildSwitchRow(
                      icon: Icons.key_rounded,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: "Enforce SSO Authentication",
                      subtitle:
                          "Require all members to authenticate exclusively via your corporate identity provider.",
                      value: policies.ssoEnforced,
                      onChanged: (val) async {
                        await EnterpriseSecurityService.instance
                            .updatePolicy('ssoEnforced', val);
                        _showToast(val
                            ? "SSO Authentication enforced successfully!"
                            : "SSO Authentication set to optional.");
                      },
                    ),

                    const Divider(height: 24, color: Color(0xFFF1F5F9)),

                    // Identity Provider Selector
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "Primary Identity Provider (IdP)",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._ssoProviders.map((prov) {
                      final name = prov['name'] as String;
                      final icon = prov['icon'] as IconData;
                      final iconColor = prov['color'] as Color;
                      final desc = prov['desc'] as String;
                      final isSelected = policies.ssoProvider == name;

                      return GestureDetector(
                        onTap: () async {
                          await EnterpriseSecurityService.instance
                              .updatePolicy('ssoProvider', name);
                          _showToast("Identity Provider updated to $name!");
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFF7ED)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFD4642C)
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: iconColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? const Color(0xFFD4642C)
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      desc,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFFD4642C),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // ── 2. Company Domain Lock Policy ──
                _buildSectionTitle(
                  "COMPANY DOMAIN LOCK",
                  "Restricted workspace enrollment to authorized company emails",
                ),
                const SizedBox(height: 10),
                _buildCard(
                  children: [
                    _buildSwitchRow(
                      icon: Icons.domain_verification_rounded,
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF059669),
                      title: "Strict Corporate Domain Lock",
                      subtitle:
                          "Only users with an official company email domain can create or claim cards.",
                      value: policies.domainLockEnabled,
                      onChanged: (val) async {
                        await EnterpriseSecurityService.instance
                            .updatePolicy('domainLockEnabled', val);
                        _showToast(val
                            ? "Corporate Domain Lock activated!"
                            : "Domain Lock disabled.");
                      },
                    ),

                    const Divider(height: 24, color: Color(0xFFF1F5F9)),

                    // Authorized Domain Field
                    const Text(
                      "Authorized Company Domain",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.alternate_email_rounded,
                            color: Color(0xFFD4642C),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _domainController,
                              onChanged: (_) => _isEditingDomain = true,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: "company.com",
                                hintStyle: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final text = _domainController.text
                                  .trim()
                                  .replaceAll('@', '');
                              if (text.isNotEmpty) {
                                await EnterpriseSecurityService.instance
                                    .updatePolicy('allowedDomain', text);
                                _showToast("Authorized domain saved: @$text");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4642C),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF059669),
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Enforced for all cards & invitation codes",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── 3. Team & Brand Governance ──
                _buildSectionTitle(
                  "TEAM & BRAND GOVERNANCE",
                  "Workspace enforcement on brand templates and member approval",
                ),
                const SizedBox(height: 10),
                _buildCard(
                  children: [
                    _buildSwitchRow(
                      icon: Icons.lock_outline_rounded,
                      iconBg: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFD4642C),
                      title: "Brand & Template Lock",
                      subtitle:
                          "Standard employees cannot alter official company logo, banner, and template design.",
                      value: policies.brandLockEnabled,
                      onChanged: (val) async {
                        await EnterpriseSecurityService.instance
                            .updatePolicy('brandLockEnabled', val);
                        _showToast(val
                            ? "Brand Design locked for standard members."
                            : "Brand design lock disabled.");
                      },
                    ),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _buildSwitchRow(
                      icon: Icons.how_to_reg_outlined,
                      iconBg: const Color(0xFFFAF5FF),
                      iconColor: const Color(0xFF7C3AED),
                      title: "Require Admin Approval For Joins",
                      subtitle:
                          "Employees requesting to join must be manually approved by an enterprise administrator.",
                      value: policies.requireApprovalForJoins,
                      onChanged: (val) async {
                        await EnterpriseSecurityService.instance
                            .updatePolicy('requireApprovalForJoins', val);
                        _showToast(val
                            ? "Mandatory join approval enforced."
                            : "Join approval set to automatic.");
                      },
                    ),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _buildSwitchRow(
                      icon: Icons.phonelink_lock_rounded,
                      iconBg: const Color(0xFFFEF2F2),
                      iconColor: const Color(0xFFDC2626),
                      title: "Two-Factor Authentication (2FA)",
                      subtitle:
                          "Mandate two-factor authentication challenge on administrator logins.",
                      value: policies.twoFactorRequired,
                      onChanged: (val) async {
                        await EnterpriseSecurityService.instance
                            .updatePolicy('twoFactorRequired', val);
                        _showToast(val
                            ? "2FA required for administrator sessions."
                            : "2FA set to optional.");
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── 4. Security & Compliance Status Card ──
                _buildSectionTitle(
                  "SECURITY & ENCRYPTION PROTOCOLS",
                  "Verified standards protecting enterprise digital card data",
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildComplianceTile(
                        icon: Icons.enhanced_encryption_rounded,
                        title: "TLS 1.3 / AES-256 Bit Encryption",
                        subtitle:
                            "All card transactions, contact downloads, and lead exchanges are encrypted in transit and at rest.",
                        status: "ACTIVE",
                        statusColor: const Color(0xFF059669),
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildComplianceTile(
                        icon: Icons.shield_rounded,
                        title: "SOC 2 Type II & ISO 27001",
                        subtitle:
                            "Adheres to cloud compliance standards for enterprise digital credential sharing.",
                        status: "VERIFIED",
                        statusColor: const Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── 5. Save All Changes Button ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4642C), Color(0xFFE8824E)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4642C).withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              setState(() => _isSaving = true);
                              final updated = policies.copyWith(
                                allowedDomain: _domainController.text
                                    .trim()
                                    .replaceAll('@', ''),
                              );
                              final ok = await EnterpriseSecurityService
                                  .instance
                                  .saveAllPolicies(updated);
                              setState(() => _isSaving = false);
                              if (ok) {
                                _showToast(
                                    "All Enterprise Security policies saved successfully!");
                              }
                            },
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline_rounded,
                              color: Colors.white, size: 20),
                      label: Text(
                        _isSaving
                            ? "Saving Policies..."
                            : "Save Security Policies",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Switch(
          value: value,
          activeThumbColor: const Color(0xFFD4642C),
          activeTrackColor: const Color(0xFFFED7AA),
          inactiveThumbColor: const Color(0xFF94A3B8),
          inactiveTrackColor: const Color(0xFFE2E8F0),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildComplianceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: statusColor, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
