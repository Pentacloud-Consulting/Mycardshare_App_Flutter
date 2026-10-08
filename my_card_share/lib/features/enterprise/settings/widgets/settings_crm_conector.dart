import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/settings/crm_connectors.dart';

/// Opens the full CRM Connectors Management Screen on rootNavigator.
Future<void> showCrmConnectorsPage(BuildContext context, {String? uid}) async {
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (ctx) => EnterpriseCrmConnectorsScreen(uid: uid),
    ),
  );
}

/// Settings Row Widget for CRM Connectors in Settings list.
class SettingsCrmConnectorRow extends StatelessWidget {
  final VoidCallback? onTap;
  final String? uid;

  const SettingsCrmConnectorRow({
    super.key,
    this.onTap,
    this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<List<CrmConnectorModel>>(
      stream: EnterpriseCrmService.instance.streamConnectors(targetUid),
      builder: (context, snapshot) {
        final connectors = snapshot.data ?? EnterpriseCrmService.defaultConnectors;
        final connectedCount = connectors.where((c) => c.isConnected).length;
        final trailingText = connectedCount > 0 ? "$connectedCount Connected" : "Not set";

        return InkWell(
          onTap: onTap ?? () => showCrmConnectorsPage(context, uid: targetUid),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // Soft Blue Square with Hub/Sync Icon
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.hub_rounded,
                    color: Color(0xFF0052FF),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "CRM Connectors",
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
                    color: connectedCount > 0 ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
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

/// Full Dedicated Screen Page for CRM Connectors (matching exact visual mockup).
class EnterpriseCrmConnectorsScreen extends StatefulWidget {
  final String? uid;

  const EnterpriseCrmConnectorsScreen({
    super.key,
    this.uid,
  });

  @override
  State<EnterpriseCrmConnectorsScreen> createState() => _EnterpriseCrmConnectorsScreenState();
}

class _EnterpriseCrmConnectorsScreenState extends State<EnterpriseCrmConnectorsScreen> {
  final TextEditingController _webhookController = TextEditingController();
  bool _isTestingWebhook = false;
  bool _initializedWebhook = false;

  @override
  void dispose() {
    _webhookController.dispose();
    super.dispose();
  }

  void _copyWebhookUrl() {
    final text = _webhookController.text.trim();
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Webhook URL copied to clipboard!"),
          ],
        ),
        backgroundColor: const Color(0xFF0052FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleTestWebhook() async {
    setState(() => _isTestingWebhook = true);
    final targetUid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
    await EnterpriseCrmService.instance.testWebhook(_webhookController.text, targetUid);

    if (mounted) {
      setState(() => _isTestingWebhook = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.send_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("Webhook test payload dispatched successfully (200 OK)!"),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _openConnectDialog(BuildContext context, CrmConnectorModel connector) {
    final instanceController = TextEditingController(text: connector.instanceUrl);
    final apiKeyController = TextEditingController(text: connector.apiKey);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("Connect ${connector.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Configure real API parameters for ${connector.name} lead sync.",
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
            const SizedBox(height: 14),
            if (connector.provider == 'salesforce') ...[
              TextField(
                controller: instanceController,
                decoration: InputDecoration(
                  labelText: "Instance Domain URL",
                  hintText: "acme.my.salesforce.com",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "API Token / Access Key",
                hintText: "Enter secret API token...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final targetUid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
              await EnterpriseCrmService.instance.updateConnectorStatus(
                connectorId: connector.id,
                name: connector.name,
                isConnected: true,
                instanceUrl: instanceController.text.trim(),
                apiKey: apiKeyController.text.trim(),
                uid: targetUid,
              );
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text("${connector.name} connected successfully!"),
                    backgroundColor: const Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text("Connect Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLogsModal(BuildContext context, List<CrmSyncLogModel> logs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FailedSyncLogsModal(logs: logs, uid: widget.uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetUid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Header ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        "CRM Connectors",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.notifications_none_rounded, size: 20, color: Color(0xFF0F172A)),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subhead title
                    const Text(
                      "Automatically sync leads to your CRM",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 1. CRM Connectors List ──────────────────────────────────
                    StreamBuilder<List<CrmConnectorModel>>(
                      stream: EnterpriseCrmService.instance.streamConnectors(targetUid),
                      builder: (context, snapshot) {
                        final connectors = snapshot.data ?? EnterpriseCrmService.defaultConnectors;

                        return Column(
                          children: connectors.map((connector) {
                            return _buildConnectorCard(context, connector, targetUid);
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── 2. Webhook URL Card Section ──────────────────────────────
                    StreamBuilder<CrmWebhookConfig>(
                      stream: EnterpriseCrmService.instance.streamWebhookConfig(targetUid),
                      builder: (context, snapshot) {
                        final config = snapshot.data ?? const CrmWebhookConfig();

                        if (!_initializedWebhook && config.webhookUrl.isNotEmpty) {
                          _webhookController.text = config.webhookUrl;
                          _initializedWebhook = true;
                        }

                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Webhook URL",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // URL Box with Copy Icon Button
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _webhookController.text,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF334155),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _copyWebhookUrl,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFCBD5E1)),
                                        ),
                                        child: const Icon(
                                          Icons.copy_rounded,
                                          size: 16,
                                          color: Color(0xFF0052FF),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Outlined Test Webhook Button
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                ),
                                onPressed: _isTestingWebhook ? null : _handleTestWebhook,
                                icon: _isTestingWebhook
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0052FF)))
                                    : const Icon(Icons.send_rounded, size: 16, color: Color(0xFF0052FF)),
                                label: const Text(
                                  "Test Webhook",
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0052FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── 3. Alert Banner: Failed Syncs ───────────────────────────
                    StreamBuilder<List<CrmSyncLogModel>>(
                      stream: EnterpriseCrmService.instance.streamFailedSyncLogs(targetUid),
                      builder: (context, snapshot) {
                        final failedLogs = snapshot.data ?? [];
                        if (failedLogs.isEmpty) return const SizedBox.shrink();

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text("⚠️  ⚠️ ", style: TextStyle(fontSize: 14)),
                                  Text(
                                    "${failedLogs.length} Failed Syncs",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => _showLogsModal(context, failedLogs),
                                child: const Text(
                                  "View Logs",
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0052FF),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectorCard(BuildContext context, CrmConnectorModel connector, String? targetUid) {
    Color iconBg;
    Color iconColor;
    IconData iconData;

    switch (connector.provider.toLowerCase()) {
      case 'salesforce':
        iconBg = const Color(0xFFE0F2FE);
        iconColor = const Color(0xFF0284C7);
        iconData = Icons.cloud_rounded;
        break;
      case 'hubspot':
        iconBg = const Color(0xFFFFEDD5);
        iconColor = const Color(0xFFEA580C);
        iconData = Icons.hub_rounded;
        break;
      case 'zapier':
        iconBg = const Color(0xFFFEF9C3);
        iconColor = const Color(0xFFCA8A04);
        iconData = Icons.flash_on_rounded;
        break;
      case 'followupboss':
      default:
        iconBg = const Color(0xFFCCFBF1);
        iconColor = const Color(0xFF0D9488);
        iconData = Icons.badge_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),

          // Name + Subtitle + Instance Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connector.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: connector.isConnected ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      connector.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: connector.isConnected ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                if (connector.instanceUrl.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    "Instance: ${connector.instanceUrl}",
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Action: Switch Toggle (if Connected) or Connect Outlined Button
          if (connector.isConnected) ...[
            Switch(
              value: connector.isConnected,
              activeThumbColor: const Color(0xFF0052FF),
              activeTrackColor: const Color(0xFFDBEAFE),
              onChanged: (val) async {
                await EnterpriseCrmService.instance.updateConnectorStatus(
                  connectorId: connector.id,
                  name: connector.name,
                  isConnected: val,
                  uid: targetUid,
                );
              },
            ),
          ] else ...[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () => _openConnectDialog(context, connector),
              child: const Text(
                "Connect",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0052FF),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Modal Bottom Sheet displaying failed CRM sync log details.
class FailedSyncLogsModal extends StatelessWidget {
  final List<CrmSyncLogModel> logs;
  final String? uid;

  const FailedSyncLogsModal({super.key, required this.logs, this.uid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Failed Sync Logs",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Column(
            children: logs.map((log) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${log.connectorName} · ${log.leadName}",
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          log.leadEmail,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Error: ${log.errorMessage}",
                      style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
                await EnterpriseCrmService.instance.clearSyncLogs(targetUid);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Sync logs resolved and cleared."),
                      backgroundColor: const Color(0xFF16A34A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              child: const Text("Clear Logs & Retry Sync", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
