import 'package:flutter/material.dart';

import 'widgets/more_profile_card.dart';
import 'widgets/more_platform_management_card.dart';
import 'widgets/more_system_card.dart';
import 'widgets/more_support_card.dart';
import 'widgets/more_logout_button.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Top-Left Ambient Soft Baby-Blue Gradient Blob
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF38BDF8).withValues(alpha: 0.22),
                  const Color(0xFF0052FF).withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Main More Settings Content Area
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // 1. Profile Summary Card (Avatar, Platform Admin, Super Admin tag, email, Edit link)
              MoreProfileCard(
                adminName: "Platform Admin",
                adminEmail: "admin@mycardshare.com",
                initials: "MA",
              ),

              SizedBox(height: 20),

              // 2. PLATFORM MANAGEMENT Grouped Card (Lead Audit Logs, Global Campaigns, Platform Analytics, Workspaces)
              MorePlatformManagementCard(),

              SizedBox(height: 20),

              // 3. SYSTEM Grouped Card (Platform Settings, Super Admin Accounts, API Keys)
              MoreSystemCard(),

              SizedBox(height: 20),

              // 4. SUPPORT Grouped Card (Help & Documentation, About v1.0.0)
              MoreSupportCard(),

              SizedBox(height: 24),

              // 5. Full-Width Red Outlined Log Out Button
              MoreLogoutButton(),

              SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }
}
