import 'package:flutter/material.dart';

class LanguageSelectorDialog extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageSelected;

  const LanguageSelectorDialog({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  static const List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'Spanish (Español)', 'code': 'es', 'flag': '🇪🇸'},
    {'name': 'French (Français)', 'code': 'fr', 'flag': '🇫🇷'},
    {'name': 'German (Deutsch)', 'code': 'de', 'flag': '🇩🇪'},
    {'name': 'Hindi (हिन्दी)', 'code': 'hi', 'flag': '🇮🇳'},
    {'name': 'Arabic (العربية)', 'code': 'ar', 'flag': '🇦🇪'},
  ];

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
                  "Select Language",
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
            const SizedBox(height: 10),
            Column(
              children: languages.map((lang) {
                final isSelected = lang['name']!.startsWith(currentLanguage);
                return ListTile(
                  leading: Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                  title: Text(
                    lang['name']!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 20)
                      : null,
                  onTap: () {
                    onLanguageSelected(lang['name']!.split(' ')[0]);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Language set to ${lang['name']}"),
                        backgroundColor: const Color(0xFF16A34A),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
