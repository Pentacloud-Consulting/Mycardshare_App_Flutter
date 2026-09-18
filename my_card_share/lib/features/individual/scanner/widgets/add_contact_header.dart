import 'package:flutter/material.dart';

class AddContactHeader extends StatelessWidget {
  final VoidCallback? onCloseTap;

  const AddContactHeader({
    super.key,
    this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ambient soft blue curve on top right (matches design)
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE0F2FE),
            ),
          ),
        ),
        // Header Row Content
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          child: Row(
            children: [
              // Close X icon
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF1E293B),
                  size: 24,
                ),
                onPressed: onCloseTap ??
                    () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                tooltip: 'Close',
              ),
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 48.0),
                    child: Text(
                      'Add a Contact',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
