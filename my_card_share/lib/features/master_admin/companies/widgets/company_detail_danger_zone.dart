import 'package:flutter/material.dart';

class CompanyDetailDangerZone extends StatelessWidget {
  final bool isSuspended;
  final VoidCallback? onSuspend;
  final VoidCallback? onDelete;

  const CompanyDetailDangerZone({
    super.key,
    this.isSuspended = false,
    this.onSuspend,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 18),
            SizedBox(width: 6),
            Text(
              "Danger Zone",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFFDC2626),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Suspend / Reactivate Company Button
        GestureDetector(
          onTap: onSuspend,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSuspended ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSuspended ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSuspended
                      ? Icons.play_circle_outline_rounded
                      : Icons.pause_circle_outline_rounded,
                  color: isSuspended ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isSuspended ? "Reactivate Company" : "Suspend Company",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isSuspended ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Delete Company Button
        GestureDetector(
          onTap: onDelete,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 18),
                SizedBox(width: 8),
                Text(
                  "Delete Company",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


