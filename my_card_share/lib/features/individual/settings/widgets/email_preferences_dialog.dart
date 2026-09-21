import 'package:flutter/material.dart';

class EmailPreferencesDialog extends StatefulWidget {
  const EmailPreferencesDialog({super.key});

  @override
  State<EmailPreferencesDialog> createState() => _EmailPreferencesDialogState();
}

class _EmailPreferencesDialogState extends State<EmailPreferencesDialog> {
  bool _leadNotifications = true;
  bool _weeklyDigest = true;
  bool _marketingUpdates = false;
  bool _securityAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x90FFFFFF),
              blurRadius: 12,
              offset: Offset(-4, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Email Preferences",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Color(0xFF475569), size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Clay Item 1: New Lead Alerts
            _buildClaySwitchTile(
              title: "New Lead Alerts",
              subtitle: "Receive email instantly when a new lead scans your card",
              value: _leadNotifications,
              onChanged: (v) => setState(() => _leadNotifications = v),
            ),
            const SizedBox(height: 10),

            // Clay Item 2: Weekly Digest
            _buildClaySwitchTile(
              title: "Weekly Analytics Digest",
              subtitle: "Summary of card views, shares & top leads",
              value: _weeklyDigest,
              onChanged: (v) => setState(() => _weeklyDigest = v),
            ),
            const SizedBox(height: 10),

            // Clay Item 3: Product Updates
            _buildClaySwitchTile(
              title: "Product Updates & News",
              subtitle: "Announcements about new feature releases",
              value: _marketingUpdates,
              onChanged: (v) => setState(() => _marketingUpdates = v),
            ),
            const SizedBox(height: 10),

            // Clay Item 4: Security Alerts
            _buildClaySwitchTile(
              title: "Security & Account Alerts",
              subtitle: "Important security & login notification emails",
              value: _securityAlerts,
              onChanged: (v) => setState(() => _securityAlerts = v),
            ),
            const SizedBox(height: 22),

            // 3D Clay Action Button
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x380052FF),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Email preferences saved!"),
                      backgroundColor: Color(0xFF16A34A),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052FF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "Save Preferences",
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaySwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF0052FF),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
