import 'package:flutter/material.dart';

class SettingsDeactivateButton extends StatelessWidget {
  final VoidCallback onTap;

  const SettingsDeactivateButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: const Text(
          "Deactivate Workspace",
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFFEF4444),
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}


