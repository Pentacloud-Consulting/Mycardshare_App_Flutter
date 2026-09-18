import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notification/popup_message/logout_popup.dart';

class SettingsLogoutSection extends ConsumerWidget {
  const SettingsLogoutSection({super.key});

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    LogoutPopup.show(context);
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Account", style: TextStyle(color: Color(0xFFEF4444))),
        content: const Text(
          "Warning: Deleting your account will permanently remove all your digital cards, leads, and contacts. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Account deletion request submitted"),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Delete Permanently", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Outlined Red Log Out Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _confirmLogout(context, ref),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFDA4AF), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFE11D48),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Log Out",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE11D48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Delete Account Link
        GestureDetector(
          onTap: () => _confirmDeleteAccount(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              "Delete Account",
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE11D48),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
