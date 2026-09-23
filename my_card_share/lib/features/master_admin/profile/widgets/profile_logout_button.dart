import 'package:flutter/material.dart';

class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback? onLogoutTap;

  const ProfileLogoutButton({
    super.key,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onLogoutTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2), // Light red border
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: Color(0xFFEF4444), // Red text & icon
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              "Log Out",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEF4444),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
