import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'connectors_sync_service.dart';

class IndividualConnectorsScreen extends StatefulWidget {
  const IndividualConnectorsScreen({super.key});

  @override
  State<IndividualConnectorsScreen> createState() => _IndividualConnectorsScreenState();
}

class _IndividualConnectorsScreenState extends State<IndividualConnectorsScreen> {
  bool _isLoading = false;

  final TextEditingController _zapierWebhookCtrl = TextEditingController();
  final TextEditingController _hubspotKeyCtrl = TextEditingController();
  final TextEditingController _customWebhookCtrl = TextEditingController();

  bool _zapierEnabled = false;
  bool _hubspotEnabled = false;
  bool _customWebhookEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadConnectors();
  }

  @override
  void dispose() {
    _zapierWebhookCtrl.dispose();
    _hubspotKeyCtrl.dispose();
    _customWebhookCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConnectors() async {
    setState(() => _isLoading = true);
    final data = await ConnectorsSyncService.fetchConnectors();

    if (data.isNotEmpty) {
      if (data['zapier'] != null) {
        _zapierWebhookCtrl.text = data['zapier']['url'] ?? '';
        _zapierEnabled = data['zapier']['enabled'] == true;
      }
      if (data['hubspot'] != null) {
        _hubspotKeyCtrl.text = data['hubspot']['apiKey'] ?? '';
        _hubspotEnabled = data['hubspot']['enabled'] == true;
      }
      if (data['custom_webhook'] != null) {
        _customWebhookCtrl.text = data['custom_webhook']['url'] ?? '';
        _customWebhookEnabled = data['custom_webhook']['enabled'] == true;
      }
    } else {
      // Fallback to Firestore user settings
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          final cMap = doc.data()?['connectors'] as Map<String, dynamic>?;
          if (cMap != null) {
            _zapierWebhookCtrl.text = cMap['zapier_url'] ?? '';
            _zapierEnabled = cMap['zapier_enabled'] == true;
            _hubspotKeyCtrl.text = cMap['hubspot_key'] ?? '';
            _hubspotEnabled = cMap['hubspot_enabled'] == true;
            _customWebhookCtrl.text = cMap['webhook_url'] ?? '';
            _customWebhookEnabled = cMap['webhook_enabled'] == true;
          }
        } catch (_) {}
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConnector({
    required String connectorId,
    required String value,
    required bool enabled,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'connectors': {
          if (connectorId == 'zapier') ...{
            'zapier_url': value,
            'zapier_enabled': enabled,
          },
          if (connectorId == 'hubspot') ...{
            'hubspot_key': value,
            'hubspot_enabled': enabled,
          },
          if (connectorId == 'custom_webhook') ...{
            'webhook_url': value,
            'webhook_enabled': enabled,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      await ConnectorsSyncService.saveConnectorConfig(
        connectorId: connectorId,
        config: {"urlOrKey": value, "enabled": enabled},
        autoSyncNewLeads: enabled,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$connectorId integration saved live!"),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFD),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0052FF)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Ambient Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0052FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Automated CRM Lead Delivery",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E3A8A)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "When someone scans your digital card and submits their contact, automatically push it to your CRM in real time.",
                          style: TextStyle(fontSize: 12, color: Color(0xFF3B82F6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "AVAILABLE CONNECTORS",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),

            // 1. Zapier Connector Card
            _buildConnectorCard(
              title: "Zapier Webhook",
              subtitle: "Connect with 5,000+ apps (Gmail, Slack, Notion, Airtable)",
              icon: Icons.flash_on_rounded,
              iconColor: const Color(0xFFFF4F00),
              iconBg: const Color(0xFFFFF0EB),
              controller: _zapierWebhookCtrl,
              hint: "https://hooks.zapier.com/hooks/catch/...",
              isEnabled: _zapierEnabled,
              onToggle: (val) {
                setState(() => _zapierEnabled = val);
                _saveConnector(connectorId: 'zapier', value: _zapierWebhookCtrl.text.trim(), enabled: val);
              },
              onSave: () => _saveConnector(connectorId: 'zapier', value: _zapierWebhookCtrl.text.trim(), enabled: _zapierEnabled),
            ),
            const SizedBox(height: 16),

            // 2. HubSpot CRM Card
            _buildConnectorCard(
              title: "HubSpot CRM",
              subtitle: "Instantly create new Contacts and Deals in HubSpot",
              icon: Icons.hub_rounded,
              iconColor: const Color(0xFFFF7A59),
              iconBg: const Color(0xFFFFF3F0),
              controller: _hubspotKeyCtrl,
              hint: "pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
              isEnabled: _hubspotEnabled,
              onToggle: (val) {
                setState(() => _hubspotEnabled = val);
                _saveConnector(connectorId: 'hubspot', value: _hubspotKeyCtrl.text.trim(), enabled: val);
              },
              onSave: () => _saveConnector(connectorId: 'hubspot', value: _hubspotKeyCtrl.text.trim(), enabled: _hubspotEnabled),
            ),
            const SizedBox(height: 16),

            // 3. Custom Webhook Card
            _buildConnectorCard(
              title: "Custom HTTP Webhook",
              subtitle: "POST raw lead payload to your custom backend or API server",
              icon: Icons.webhook_rounded,
              iconColor: const Color(0xFF0052FF),
              iconBg: const Color(0xFFEFF6FF),
              controller: _customWebhookCtrl,
              hint: "https://api.yourdomain.com/v1/leads/webhook",
              isEnabled: _customWebhookEnabled,
              onToggle: (val) {
                setState(() => _customWebhookEnabled = val);
                _saveConnector(connectorId: 'custom_webhook', value: _customWebhookCtrl.text.trim(), enabled: val);
              },
              onSave: () => _saveConnector(connectorId: 'custom_webhook', value: _customWebhookCtrl.text.trim(), enabled: _customWebhookEnabled),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectorCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required TextEditingController controller,
    required String hint,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required VoidCallback onSave,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isEnabled,
                onChanged: onToggle,
                activeTrackColor: const Color(0xFF0052FF),
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: onSave,
                child: const Text("Save & Verify", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
