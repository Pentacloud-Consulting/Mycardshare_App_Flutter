import 'package:flutter/material.dart';
import 'widgets/settings_account_section.dart';
import 'widgets/settings_logout_section.dart';
import 'widgets/settings_preferences_section.dart';
import 'widgets/settings_support_section.dart';
import 'widgets/settings_user_profile_card.dart';

class IndividualSettingsScreen extends StatelessWidget {
  const IndividualSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // User Profile Header Card
              SettingsUserProfileCard(),
              SizedBox(height: 20),

              // ACCOUNT Section
              SettingsAccountSection(),
              SizedBox(height: 20),

              // PREFERENCES Section
              SettingsPreferencesSection(),
              SizedBox(height: 20),

              // SUPPORT Section
              SettingsSupportSection(),
              SizedBox(height: 24),

              // Log Out & Delete Account Section
              SettingsLogoutSection(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
