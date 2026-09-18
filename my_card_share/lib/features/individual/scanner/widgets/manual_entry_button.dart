import 'package:flutter/material.dart';

class ManualEntryButton extends StatelessWidget {
  final VoidCallback onTap;

  const ManualEntryButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // "or" Divider Row
        Row(
          children: const [
            Expanded(
              child: Divider(
                color: Color(0xFFE2E8F0),
                thickness: 1.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'or',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Color(0xFFE2E8F0),
                thickness: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Enter Manually Button
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              splashColor: const Color(0xFFF1F5F9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF0F172A),
                    size: 19,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Enter Manually',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
