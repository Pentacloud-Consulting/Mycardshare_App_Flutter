import 'package:flutter/material.dart';
import '../../../../backend/individual/profile/individual_profile_store.dart';

class CardQuickActions extends StatelessWidget {
  final VoidCallback? onEmailTap;
  final VoidCallback? onCallTap;

  const CardQuickActions({
    super.key,
    this.onEmailTap,
    this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeProfile = IndividualProfileStore.instance.activeProfile;
    final email = activeProfile?.email ?? "";
    final phone = activeProfile?.phoneNumber ?? "";

    return Row(
      children: [
        Expanded(
          child: _buildActionPillButton(
            icon: Icons.mail_outline_rounded,
            label: "Email",
            onTap: onEmailTap ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(email.isNotEmpty ? "Email: $email" : "No email provided"),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionPillButton(
            icon: Icons.phone_outlined,
            label: "Call",
            onTap: onCallTap ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(phone.isNotEmpty ? "Calling: $phone" : "No phone provided"),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
          ),
        ),
      ],
    );
  }

  Widget _buildActionPillButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF0F172A), size: 19),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
