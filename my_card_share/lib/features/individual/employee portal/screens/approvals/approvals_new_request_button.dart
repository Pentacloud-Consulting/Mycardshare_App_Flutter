import 'package:flutter/material.dart';

class ApprovalsNewRequestButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ApprovalsNewRequestButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF0052FF), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0052FF).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: Color(0xFF0052FF),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "New Change Request",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0052FF),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
