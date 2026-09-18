import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'language_selector_dialog.dart';

class SettingsPreferencesSection extends StatefulWidget {
  const SettingsPreferencesSection({super.key});

  @override
  State<SettingsPreferencesSection> createState() => _SettingsPreferencesSectionState();
}

class _SettingsPreferencesSectionState extends State<SettingsPreferencesSection> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "PREFERENCES",
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
              // Notifications
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF0284C7),
                    size: 20,
                  ),
                ),
                title: const Text(
                  "Notifications",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                trailing: CupertinoSwitch(
                  value: _notificationsEnabled,
                  activeTrackColor: const Color(0xFF2563EB),
                  onChanged: (val) {
                    setState(() => _notificationsEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? "Notifications enabled" : "Notifications disabled"),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),

              // Dark Mode
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.nightlight_round_outlined,
                    color: Color(0xFF9333EA),
                    size: 20,
                  ),
                ),
                title: const Text(
                  "Dark Mode",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                trailing: CupertinoSwitch(
                  value: _darkModeEnabled,
                  activeTrackColor: const Color(0xFF2563EB),
                  onChanged: (val) {
                    setState(() => _darkModeEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? "Dark Mode enabled" : "Light Mode enabled"),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),

              // Language
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => LanguageSelectorDialog(
                      currentLanguage: _selectedLanguage,
                      onLanguageSelected: (lang) {
                        setState(() => _selectedLanguage = lang);
                      },
                    ),
                  );
                },
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: Color(0xFF16A34A),
                    size: 20,
                  ),
                ),
                title: const Text(
                  "Language",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedLanguage,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
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
