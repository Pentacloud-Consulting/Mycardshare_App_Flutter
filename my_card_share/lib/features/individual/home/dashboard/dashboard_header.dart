import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/individual/profile/individual_profile_store.dart';
import '../../../../backend/individual/multiple_store/individual_multi_store.dart';

/// Top Header component for Individual Users
class DashboardHeader extends StatelessWidget {
  final String? userName;
  final String? companyName;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  const DashboardHeader({
    super.key,
    this.userName,
    this.companyName,
    this.onMenuTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: IndividualProfileStore.instance,
      builder: (context, _) {
        final fbUser = FirebaseAuth.instance.currentUser;
        final currentEmail = (fbUser?.email ?? '').toLowerCase();
        final activeProfile = IndividualProfileStore.instance.activeProfile;
        final isSameUser = activeProfile != null &&
            ((fbUser != null && activeProfile.uid == fbUser.uid) ||
             (currentEmail.isNotEmpty && activeProfile.email.toLowerCase() == currentEmail));
        final validActive = isSameUser ? activeProfile : null;

        final storedUser = currentEmail.isNotEmpty
            ? (IndividualMultiStore.instance.getUser(currentEmail) ??
               IndividualMultiStore.instance.getAllUsers().cast<IndividualUserRecord?>().firstWhere(
                 (u) => u?.email.toLowerCase() == currentEmail,
                 orElse: () => null,
               ))
            : null;

        final resolvedName = (userName != null && userName!.trim().isNotEmpty && userName != "User")
            ? userName!.trim()
            : (validActive?.fullName.isNotEmpty == true
                ? validActive!.fullName.split(' ').first
                : (storedUser?.fullName.isNotEmpty == true
                    ? storedUser!.fullName.split(' ').first
                    : (fbUser?.displayName?.isNotEmpty == true
                        ? fbUser!.displayName!.split(' ').first
                        : (currentEmail.isNotEmpty ? currentEmail.split('@').first : "User"))));

        // Filter out numeric UID-based workspace names (e.g. "49126615 Workspace")
        // that get set when joining via enterprise invite links.
        bool _isJunkCompany(String? name) {
          if (name == null || name.trim().isEmpty) return true;
          final trimmed = name.trim();
          if (trimmed == "MyCardShare Member" || trimmed == "Enterprise Workspace" ||
              trimmed == "Acme Realty" || trimmed == "Pro Member") return true;
          // e.g. "49126615 Workspace" — numeric prefix followed by " Workspace"
          if (RegExp(r'\d+\s+Workspace', caseSensitive: false).hasMatch(trimmed)) return true;
          return false;
        }
        final resolvedCompany = (!_isJunkCompany(companyName))
            ? companyName!.trim()
            : ((!_isJunkCompany(activeProfile?.companyName)) ? activeProfile!.companyName : "Pro Member");

        return Row(
          children: [
            // Left: Circular Drawer / Menu Icon Button
            GestureDetector(
              onTap: onMenuTap ??
                  () {
                    Scaffold.maybeOf(context)?.openDrawer();
                  },
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF0F172A),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Center: Hi, User + Company / Pro Badge
            Expanded(
              child: Row(
                children: [
                  const Text(
                    "Hi, ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      resolvedName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFD4642C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Pill Badge - constrained to prevent overlap with bell
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFED7AA), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFD4642C),
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                resolvedCompany,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFD4642C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right: Notification Bell Button
            GestureDetector(
              onTap: onNotificationTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No new notifications")),
                    );
                  },
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF0F172A),
                      size: 22,
                    ),
                    Positioned(
                      top: 11,
                      right: 11,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

