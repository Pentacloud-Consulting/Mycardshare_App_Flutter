import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onSaveTap;

  const ProfileHeader({
    super.key,
    this.onBackTap,
    this.onSaveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        GestureDetector(
          onTap: onBackTap ?? () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A),
              size: 18,
            ),
          ),
        ),

        // Title Column: Edit Profile + LIVE PREVIEW subtitle
        Column(
          children: const [
            Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 1),
            Text(
              "LIVE PREVIEW",
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),

        // Save Action Button
        GestureDetector(
          onTap: onSaveTap ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile changes saved successfully!"),
                backgroundColor: Color(0xFF16A34A),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF0052FF),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x200052FF),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              "Save",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
