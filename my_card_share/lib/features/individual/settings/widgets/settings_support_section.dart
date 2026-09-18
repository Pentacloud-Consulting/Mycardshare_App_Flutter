import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsSupportSection extends StatelessWidget {
  const SettingsSupportSection({super.key});

  void _showHelpModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
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
                  "Help & Support Center",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF2563EB)),
              title: const Text("Email Customer Support", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
              subtitle: const Text("support@mycardshare.com (Response within 2 hours)", style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Opening support email client...")),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.question_answer_rounded, color: Color(0xFF16A34A)),
              title: const Text("FAQ & Knowledgebase", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
              subtitle: const Text("Guides on QR scanning, NFC cards & contact syncing", style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Opening FAQ knowledgebase...")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "My Card Share",
      applicationVersion: "v1.0.0",
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.contact_phone_rounded, color: Colors.white, size: 26),
      ),
      children: const [
        SizedBox(height: 10),
        Text(
          "My Card Share is the modern, smart digital business card and lead management platform built for professionals and teams.",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "SUPPORT",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Help & Support
              ListTile(
                onTap: () => _showHelpModal(context),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: Color(0xFF0284C7),
                    size: 20,
                  ),
                ),
                title: const Text(
                  "Help & Support",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),

              // Terms of Service
              ListTile(
                onTap: () => context.push('/terms'),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF9333EA),
                    size: 20,
                  ),
                ),
                title: const Text(
                  "Terms of Service",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),

              // Privacy Policy
              ListTile(
                onTap: () => context.push('/privacy'),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xFF16A34A),
                    size: 20,
                  ),
                ),
                title: const Text(
                  "Privacy Policy",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),

              // About
              ListTile(
                onTap: () => _showAboutDialog(context),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF0284C7),
                    size: 20,
                  ),
                ),
                title: const Text(
                  "About",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "v1.0.0",
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
