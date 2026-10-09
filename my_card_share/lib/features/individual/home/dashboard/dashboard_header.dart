import 'package:flutter/material.dart';
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
        final activeProfile = IndividualProfileStore.instance.activeProfile;
        final storedUser = IndividualMultiStore.instance.getAllUsers().firstOrNull;

        final resolvedName = (userName != null && userName!.trim().isNotEmpty && userName != "User")
            ? userName!.trim()
            : (activeProfile?.fullName.isNotEmpty == true
                ? activeProfile!.fullName.split(' ').first
                : (storedUser?.fullName.isNotEmpty == true ? storedUser!.fullName.split(' ').first : "User"));

        final resolvedCompany = (companyName != null && companyName!.trim().isNotEmpty && companyName != "MyCardShare Member")
            ? companyName!.trim()
            : (activeProfile?.companyName.isNotEmpty == true ? activeProfile!.companyName : "Pro Member");

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
                        color: Color(0xFF0066FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Pill Badge
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: Color(0xFF0066FF),
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              resolvedCompany,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0066FF),
                              ),
                            ),
                          ),
                        ],
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

