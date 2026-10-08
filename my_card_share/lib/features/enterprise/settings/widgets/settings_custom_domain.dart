import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/settings/custom_domain.dart';

/// Opens the full Custom Domain Configuration & DNS Requirements Screen.
Future<void> showCustomDomainPage(BuildContext context, {String? uid}) async {
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (ctx) => EnterpriseCustomDomainScreen(uid: uid),
    ),
  );
}

/// Frontend Row Widget for Image 1 in Settings Workspace List.
/// Streamed in real-time with domain status ("Not set", "Pending DNS", "Active").
class SettingsCustomDomainRow extends StatelessWidget {
  final VoidCallback? onTap;
  final String? uid;

  const SettingsCustomDomainRow({
    super.key,
    this.onTap,
    this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<CustomDomainData>(
      stream: EnterpriseCustomDomainService.instance.streamCustomDomain(targetUid),
      builder: (context, snapshot) {
        final domainData = snapshot.data ?? const CustomDomainData(domain: '', status: CustomDomainStatus.notSet);
        final trailingText = domainData.isConfigured ? domainData.statusText : 'Not set';

        return InkWell(
          onTap: onTap ?? () => showCustomDomainPage(context, uid: targetUid),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // Soft Purple Rounded Square with Globe Icon (Image 1 style)
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: Color(0xFF7C3AED),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Custom Domain",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Text(
                  trailingText,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: domainData.isVerified
                        ? const Color(0xFF16A34A)
                        : domainData.isConfigured
                            ? const Color(0xFFD97706)
                            : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Dedicated Screen Page for Custom Domain Requirements & DNS Setup.
class EnterpriseCustomDomainScreen extends StatefulWidget {
  final String? uid;

  const EnterpriseCustomDomainScreen({
    super.key,
    this.uid,
  });

  @override
  State<EnterpriseCustomDomainScreen> createState() => _EnterpriseCustomDomainScreenState();
}

class _EnterpriseCustomDomainScreenState extends State<EnterpriseCustomDomainScreen> {
  final TextEditingController _domainController = TextEditingController();
  bool _isSaving = false;
  bool _isVerifying = false;
  bool _initialized = false;

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveDomain() async {
    final input = _domainController.text.trim();
    if (!EnterpriseCustomDomainService.isValidDomain(input)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a valid domain format (e.g. cards.yourcompany.com)"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final success = await EnterpriseCustomDomainService.instance.saveCustomDomain(
      domainName: input,
      uid: widget.uid,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text("Custom domain '$input' saved! Add the CNAME record to complete setup.")),
              ],
            ),
            backgroundColor: const Color(0xFF7C3AED),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _handleVerifyDNS() async {
    setState(() => _isVerifying = true);
    final success = await EnterpriseCustomDomainService.instance.verifyDomainDNS(uid: widget.uid);

    if (mounted) {
      setState(() => _isVerifying = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text("DNS Verified! Custom Domain is active with SSL security."),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _handleRemoveDomain() async {
    await EnterpriseCustomDomainService.instance.removeCustomDomain(uid: widget.uid);
    if (mounted) {
      _domainController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Custom domain removed."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$label copied to clipboard!"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetUid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Custom Domain Setup",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<CustomDomainData>(
        stream: EnterpriseCustomDomainService.instance.streamCustomDomain(targetUid),
        builder: (context, snapshot) {
          final domainData = snapshot.data ?? const CustomDomainData(domain: '', status: CustomDomainStatus.notSet);

          if (!_initialized && domainData.domain.isNotEmpty) {
            _domainController.text = domainData.domain;
            _initialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status Banner Box ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: domainData.isVerified
                              ? const Color(0xFFDCFCE7)
                              : domainData.isConfigured
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          domainData.isVerified
                              ? Icons.verified_user_rounded
                              : domainData.isConfigured
                                  ? Icons.pending_actions_rounded
                                  : Icons.language_rounded,
                          color: domainData.isVerified
                              ? const Color(0xFF16A34A)
                              : domainData.isConfigured
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF64748B),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              domainData.isConfigured ? domainData.domain : "No Custom Domain Mapped",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Status: ${domainData.statusText}${domainData.sslActive ? ' · SSL Secured' : ''}",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: domainData.isVerified
                                    ? const Color(0xFF16A34A)
                                    : domainData.isConfigured
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ── Step 1: Input Domain Name ─────────────────────────────────
                const Text(
                  "1. Enter Your Domain / Subdomain",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Map a custom domain (e.g. cards.yourcompany.com) so all your employee cards use your brand URL.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.35),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _domainController,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                          decoration: const InputDecoration(
                            hintText: "e.g. cards.acmerealty.com",
                            prefixIcon: Icon(Icons.language_rounded, color: Color(0xFF7C3AED), size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: _isSaving ? null : _handleSaveDomain,
                          child: _isSaving
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Save Domain", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // ── Step 2: DNS Requirements & CNAME Table ───────────────────
                const Text(
                  "2. DNS Configuration Requirements",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Log in to your domain registrar (GoDaddy, Cloudflare, Namecheap, etc.) and add the following CNAME record:",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.35),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: Column(
                    children: [
                      _buildDnsRow("Record Type", "CNAME", copyable: false),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildDnsRow("Host / Subdomain", _domainController.text.contains('.') ? _domainController.text.split('.').first : "cards"),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildDnsRow("Target / Points To", domainData.targetCname),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildDnsRow("TTL", "3600 (Automatic)", copyable: false),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // ── Step 3: Verification & SSL ────────────────────────────────
                const Text(
                  "3. Verify DNS & SSL Activation",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "DNS propagation typically takes 5–15 minutes. Once added, click below to verify and issue SSL.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.35),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isVerifying ? null : _handleVerifyDNS,
                    icon: _isVerifying
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                    label: Text(
                      _isVerifying ? "Verifying DNS..." : "Verify Domain DNS Now",
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),

                if (domainData.isConfigured) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: _handleRemoveDomain,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                      label: const Text(
                        "Remove Custom Domain Mapping",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.redAccent),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDnsRow(String label, String value, {bool copyable = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            if (copyable) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _copyToClipboard(value, label),
                child: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF7C3AED)),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
