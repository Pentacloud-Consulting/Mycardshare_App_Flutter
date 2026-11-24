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
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4642C), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4642C).withValues(alpha: 0.12),
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
              color: Color(0xFFD4642C),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "New Change Request",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD4642C),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


