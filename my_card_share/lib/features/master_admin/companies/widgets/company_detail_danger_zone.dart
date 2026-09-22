import 'package:flutter/material.dart';

class CompanyDetailDangerZone extends StatelessWidget {
  final VoidCallback? onSuspend;
  final VoidCallback? onDelete;

  const CompanyDetailDangerZone({
    super.key,
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

        // Suspend Company Button
        GestureDetector(
          onTap: () {
            if (onSuspend != null) {
              onSuspend!();
            } else {
              _showConfirmDialog(
                context,
                title: "Suspend Company?",
                message: "Are you sure you want to temporarily suspend this company workspace?",
                confirmLabel: "Suspend",
                confirmColor: const Color(0xFFD97706),
              );
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pause_circle_outline_rounded, color: Color(0xFFD97706), size: 18),
                SizedBox(width: 8),
                Text(
                  "Suspend Company",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Delete Company Button
        GestureDetector(
          onTap: () {
            if (onDelete != null) {
              onDelete!();
            } else {
              _showConfirmDialog(
                context,
                title: "Delete Company Permanently?",
                message: "This action cannot be undone. All company cards and workforce data will be deleted.",
                confirmLabel: "Delete Permanently",
                confirmColor: const Color(0xFFDC2626),
              );
            }
          },
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

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(message, style: const TextStyle(color: Color(0xFF475569))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Action executed: $confirmLabel"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: confirmColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text(confirmLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
