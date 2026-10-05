import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/individual/profile/individual_profile_store.dart';
import '../../../../backend/individual/multiple store/individual_multi_store.dart';
import '../../../../backend/individual/connects/phone.dart';
import '../../../../backend/individual/connects/email.dart';

class CardQuickActions extends StatelessWidget {
  final String? email;
  final String? phone;
  final VoidCallback? onEmailTap;
  final VoidCallback? onCallTap;

  const CardQuickActions({
    super.key,
    this.email,
    this.phone,
    this.onEmailTap,
    this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeProfile = IndividualProfileStore.instance.activeProfile;
    final storedUser = IndividualMultiStore.instance.getAllUsers().firstOrNull;
    final fbUser = FirebaseAuth.instance.currentUser;

    final targetEmail = (email?.trim().isNotEmpty == true ? email!.trim() : null)
        ?? (activeProfile?.email.trim().isNotEmpty == true ? activeProfile!.email.trim() : null)
        ?? (storedUser?.email.trim().isNotEmpty == true ? storedUser!.email.trim() : null)
        ?? (fbUser?.email?.trim().isNotEmpty == true ? fbUser!.email!.trim() : "");

    final targetPhone = (phone?.trim().isNotEmpty == true ? phone!.trim() : null)
        ?? (activeProfile?.phoneNumber.trim().isNotEmpty == true ? activeProfile!.phoneNumber.trim() : "");

    return Row(
      children: [
        Expanded(
          child: _buildActionPillButton(
            icon: Icons.mail_outline_rounded,
            label: "Email",
            onTap: onEmailTap ??
                () async {
                  if (targetEmail.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("No email address available for this user."),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    return;
                  }
                  final launched = await EmailConnectService.instance.sendEmail(
                    emailAddress: targetEmail,
                    subject: "Connection Request from MyCardShare",
                  );
                  if (!launched && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Email address: $targetEmail"),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionPillButton(
            icon: Icons.phone_outlined,
            label: "Call",
            onTap: onCallTap ??
                () async {
                  if (targetPhone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("No phone number available for this user."),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    return;
                  }
                  final launched = await PhoneConnectService.instance.makePhoneCall(targetPhone);
                  if (!launched && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Phone number: $targetPhone"),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
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
