import 'package:flutter/material.dart';

class VaultCamera extends StatelessWidget {
  final VoidCallback? onTap;

  const VaultCamera({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Camera Scan launched...")),
            );
          },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF0052FF),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x350052FF),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
