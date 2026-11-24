import 'package:flutter/material.dart';
import '../../../../backend/individual/profile/individual_profile_store.dart';
import '../../../../backend/individual/api_service.dart';

class SettingsIntegrationSection extends StatefulWidget {
  const SettingsIntegrationSection({super.key});

  @override
  State<SettingsIntegrationSection> createState() =>
      _SettingsIntegrationSectionState();
}

class _SettingsIntegrationSectionState
    extends State<SettingsIntegrationSection> {
  bool _isIntegrationEnabled = false;
  bool _isSaving = false;
  late TextEditingController _webhookController;

  @override
  void initState() {
    super.initState();
    final profile = IndividualProfileStore.instance.activeProfile;
    _isIntegrationEnabled = profile?.isIntegrationEnabled ?? false;
    _webhookController =
        TextEditingController(text: profile?.zapierWebhookUrl ?? '');
  }

  @override
  void dispose() {
    _webhookController.dispose();
    super.dispose();
  }

  Future<void> _saveIntegration() async {
    setState(() => _isSaving = true);
    try {
      await IndividualApiService.patch('/api/user/me', {
        'isIntegrationEnabled': _isIntegrationEnabled,
        'zapierWebhookUrl': _webhookController.text.trim(),
      });
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Integration settings saved!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.cable_rounded,
                      color: Color(0xFFF97316), size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Zapier Integration',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Zapier Webhooks',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Auto-send new leads to your Zapier webhook',
                            style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _isIntegrationEnabled,
                      activeTrackColor: const Color(0xFFD4642C),
                      onChanged: (val) =>
                          setState(() => _isIntegrationEnabled = val),
                    ),
                  ],
                ),
                if (_isIntegrationEnabled) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _webhookController,
                    decoration: InputDecoration(
                      labelText: 'Zapier Webhook URL',
                      hintText:
                          'https://hooks.zapier.com/hooks/catch/...',
                      prefixIcon: const Icon(Icons.webhook_rounded,
                          size: 18, color: Color(0xFF64748B)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 13),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveIntegration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4642C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : const Text('Save Integration Settings'),
                    ),
                  ),
                ],
                if (!_isIntegrationEnabled) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _saveIntegration,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
