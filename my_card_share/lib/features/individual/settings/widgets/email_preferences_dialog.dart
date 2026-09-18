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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Email Preferences",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              title: const Text("New Lead Alerts", style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
              subtitle: const Text("Receive email instantly when a new lead scans your card", style: TextStyle(fontSize: 12)),
              value: _leadNotifications,
              activeTrackColor: const Color(0xFF2563EB),
              onChanged: (v) => setState(() => _leadNotifications = v),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(height: 1),

            SwitchListTile(
              title: const Text("Weekly Analytics Digest", style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
              subtitle: const Text("Summary of card views, shares & top leads", style: TextStyle(fontSize: 12)),
              value: _weeklyDigest,
              activeTrackColor: const Color(0xFF2563EB),
              onChanged: (v) => setState(() => _weeklyDigest = v),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(height: 1),

            SwitchListTile(
              title: const Text("Product Updates & News", style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
              subtitle: const Text("Announcements about new feature releases", style: TextStyle(fontSize: 12)),
              value: _marketingUpdates,
              activeTrackColor: const Color(0xFF2563EB),
              onChanged: (v) => setState(() => _marketingUpdates = v),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(height: 1),

            SwitchListTile(
              title: const Text("Security & Account Alerts", style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
              subtitle: const Text("Important security & login notification emails", style: TextStyle(fontSize: 12)),
              value: _securityAlerts,
              activeTrackColor: const Color(0xFF2563EB),
              onChanged: (v) => setState(() => _securityAlerts = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
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
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "Save Preferences",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
