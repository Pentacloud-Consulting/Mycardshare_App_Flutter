import 'package:flutter/material.dart';
import '../../../../backend/employee_join/home/employee_home_backend.dart';
import '../../../../backend/enterprise/profile/enterprise_profile_store.dart';

/// Top Header component matching Image 1: Drawer Icon + Hi, User + Company Pill Badge + Bell Notification
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
      listenable: EmployeeHomeBackendService.instance,
      builder: (context, _) {
        final homeBackend = EmployeeHomeBackendService.instance;
        final entProfile = EnterpriseProfileStore.instance.currentProfile;

        final resolvedName = (userName != null && userName!.trim().isNotEmpty && userName != "User")
            ? userName!.trim()
            : (homeBackend.userName.isNotEmpty && homeBackend.userName != "User"
                ? homeBackend.userName
                : "Zuhaib");

        final resolvedCompany = (companyName != null && companyName!.trim().isNotEmpty && companyName != "MyCardShare Member" && companyName != "Enterprise Workspace")
            ? companyName!.trim()
            : (homeBackend.companyName.isNotEmpty && homeBackend.companyName != "Enterprise Workspace"
                ? homeBackend.companyName
                : (entProfile?.companyName.isNotEmpty == true ? entProfile!.companyName : "Islamic Web"));

        return Row(
          children: [
            // Left: Circular Drawer / Menu Icon Button (Image 1 top-left)
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

            // Center: Hi, User + Company Pill Badge (Image 1 center)
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

                  // Enterprise Company Pill Badge (Image 1: [🏢 Acme Realty] / [🏢 Islamic Web])
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
                            Icons.domain_rounded,
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

            // Right: Notification Bell Button (Image 1 top-right)
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
