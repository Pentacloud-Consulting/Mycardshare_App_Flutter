import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'invite.dart';

/// Opens the Enterprise Invite Link Popup Modal Sheet.
Future<void> showEnterpriseInvitePopup(
  BuildContext context, {
  String? uid,
  String? inviteeEmail,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => EnterpriseInvitePopupModal(
      uid: uid,
      inviteeEmail: inviteeEmail,
    ),
  );
}

/// Standalone Tile Card matching the design in user screenshot:
/// Icon: Yellow/Gold rounded container with Link Icon 🔗
/// Title: "Copy Workspace Invite Link"
/// Subtitle: "Share join link with new employees to onboard instantly"
/// Trailing: Chevron right >
class CopyWorkspaceInviteTile extends StatelessWidget {
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final String? uid;

  const CopyWorkspaceInviteTile({
    super.key,
    this.onTap,
    this.margin,
    this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => showEnterpriseInvitePopup(context, uid: uid),
      child: Container(
        margin: margin,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gold Rounded Square Icon Container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.link_rounded,
                color: Color(0xFFD97706),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Title & Subtitle
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Copy Workspace Invite Link",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Share join link with new employees to onboard instantly",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Trailing Chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

/// The actual Popup Modal Sheet layout for copying the enterprise invite link.
class EnterpriseInvitePopupModal extends StatelessWidget {
  final String? uid;
  final String? inviteeEmail;

  const EnterpriseInvitePopupModal({
    super.key,
    this.uid,
    this.inviteeEmail,
  });

  @override
  Widget build(BuildContext context) {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;

    return Container(
      padding: const EdgeInsets.all(22.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Drag Handle Bar
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Title + Close Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    inviteeEmail != null && inviteeEmail!.isNotEmpty
                        ? "Employee Invite Link"
                        : "Workspace Invite Link",
                    style: const TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description Subtitle
          const Text(
            "Share this link with team members to let them join your organization workspace directly.",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
          ),

          const SizedBox(height: 18),

          // Real-Time Streamed Link Box
          StreamBuilder<String>(
            stream: EnterpriseInviteLinkService.instance.streamInviteLink(
              uid: targetUid,
              inviteeEmail: inviteeEmail,
            ),
            builder: (context, snapshot) {
              final inviteLink = snapshot.data ?? "mycardshare.com/join-workspace";

              return Column(
                children: [
                  // Link Text Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.link_rounded,
                          color: Color(0xFF0052FF),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            inviteLink,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Action Buttons Row (Copy Link & Share)
                  Row(
                    children: [
                      // Primary Copy Button
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0052FF),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              EnterpriseInviteLinkService.instance.copyInviteLink(
                                context,
                                inviteLink,
                                inviteeEmail: inviteeEmail,
                              );
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Copy Link",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Share Button
                      SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: () {
                            EnterpriseInviteLinkService.instance.shareInviteLink(
                              context,
                              inviteLink,
                            );
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.share_outlined,
                            size: 18,
                            color: Color(0xFF0052FF),
                          ),
                          label: const Text(
                            "Share",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0052FF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // Secondary Option: Direct Add / Batch Invite Button
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showEnterpriseInviteModal(context);
              },
              icon: const Icon(
                Icons.person_add_alt_1_rounded,
                size: 18,
                color: Color(0xFF64748B),
              ),
              label: const Text(
                "Add Team Member by Email or Form",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
