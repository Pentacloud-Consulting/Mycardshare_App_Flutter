import 'package:flutter/material.dart';
import '../../public/landing/onboarding_screen.dart' as public_onboarding;
import 'onboarding_wizard_screen.dart' as wizard;

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const public_onboarding.OnboardingScreen();
  }
}

class OnboardingWizardScreen extends StatelessWidget {
  const OnboardingWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const wizard.OnboardingWizardScreen();
  }
}
