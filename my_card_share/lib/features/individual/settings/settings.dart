import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../backend/individual/profile/individual_profile_store.dart';
import '../../../backend/individual/multiple store/individual_multi_store.dart';
import 'widgets/settings_account_section.dart';
import 'widgets/settings_logout_section.dart';
import 'widgets/settings_preferences_section.dart';
import 'widgets/settings_support_section.dart';
import 'widgets/settings_user_profile_card.dart';

class IndividualSettingsScreen extends StatefulWidget {
  const IndividualSettingsScreen({super.key});

  @override
  State<IndividualSettingsScreen> createState() => _IndividualSettingsScreenState();
}

class _IndividualSettingsScreenState extends State<IndividualSettingsScreen> {
  @override
  void initState() {
    super.initState();
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      IndividualProfileStore.instance.loadProfile(
        fbUser.uid,
        fbUser.email ?? '',
        fbUser.displayName ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: IndividualProfileStore.instance,
          builder: (context, _) {
            final firebaseUser = FirebaseAuth.instance.currentUser;
            final activeProfile = IndividualProfileStore.instance.activeProfile;
            final storedUser = IndividualMultiStore.instance.getAllUsers().firstOrNull;

            final displayName = (activeProfile?.fullName.isNotEmpty == true ? activeProfile!.fullName : null)
                ?? (storedUser?.fullName.isNotEmpty == true ? storedUser!.fullName : null)
                ?? (firebaseUser?.displayName?.isNotEmpty == true ? firebaseUser!.displayName : null)
                ?? (firebaseUser?.email?.isNotEmpty == true ? firebaseUser!.email!.split('@').first : null)
                ?? "User";

            final displayEmail = (activeProfile?.email.isNotEmpty == true ? activeProfile!.email : null)
                ?? (storedUser?.email.isNotEmpty == true ? storedUser!.email : null)
                ?? (firebaseUser?.email?.isNotEmpty == true ? firebaseUser!.email : null)
                ?? "";

            final displayPhoto = (activeProfile?.profilePhoto?.isNotEmpty == true ? activeProfile!.profilePhoto : null)
                ?? (firebaseUser?.photoURL?.isNotEmpty == true ? firebaseUser!.photoURL : null);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Header Card
                  SettingsUserProfileCard(
                    name: displayName,
                    email: displayEmail,
                    avatarUrl: displayPhoto,
                  ),
                  const SizedBox(height: 20),

                  // ACCOUNT Section
                  const SettingsAccountSection(),
                  const SizedBox(height: 20),

                  // PREFERENCES Section
                  const SettingsPreferencesSection(),
                  const SizedBox(height: 20),

                  // SUPPORT Section
                  const SettingsSupportSection(),
                  const SizedBox(height: 24),

                  // Log Out & Delete Account Section
                  const SettingsLogoutSection(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
