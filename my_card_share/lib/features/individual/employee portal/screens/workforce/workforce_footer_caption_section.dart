import 'package:flutter/material.dart';

class WorkforceFooterCaptionSection extends StatelessWidget {
  final String captionText;

  const WorkforceFooterCaptionSection({
    super.key,
    this.captionText = "Contact your admin to update team member details",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              captionText,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
