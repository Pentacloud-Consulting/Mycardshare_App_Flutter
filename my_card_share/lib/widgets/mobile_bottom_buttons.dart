import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileBottomButtons extends StatelessWidget {
  final int activeIndex;
  const MobileBottomButtons({super.key, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Reduced slightly since we have custom path
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Glassy background layer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _GlassyBarClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 100, // Height encompasses the bump now (0 to 100)
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15), // Light frosted glass fill
                  ),
                ),
              ),
            ),
          ),
          
          // The border overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _GlassyBarBorderPainter(),
            ),
          ),
          
          // Navigation Items
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(context, Icons.home_filled, "Home", activeIndex == 0),
                _buildNavItem(context, Icons.document_scanner_outlined, "Scan", activeIndex == 1),
                const SizedBox(width: 50), // Space for center FAB
                _buildNavItem(context, Icons.bar_chart, "Analytics", activeIndex == 2),
                _buildNavItem(context, Icons.person_outline, "Contact", activeIndex == 3),
              ],
            ),
          ),
          
          // Center floating button
          Positioned(
            bottom: 30, // Positioned carefully in the bump (top is Y=14)
            child: Container(
              height: 56,
              width: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))
                ]
              ),
              child: const Icon(Icons.add, color: Color(0xFF2C3333), size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        
        if (label == 'Scan') {
          context.push('/scan');
        } else if (label == 'Home') {
          context.go('/home');
        } else if (label == 'Analytics') {
          context.go('/analytics');
        } else if (label == 'Contact') {
          context.go('/contact');
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF2988FA) : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}

class _GlassyBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return _getGlassyPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _GlassyBarBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _getGlassyPath(size);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.8),
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.4),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Path _getGlassyPath(Size size) {
  Path path = Path();
  double cornerRadius = 35.0; // Fully circular ends
  double bumpRadius = 38.0; // The radius of the upward bump
  double topOffset = 30.0; // The Y coordinate where the flat top of the bar lies
  
  // Start from top-left, after the corner
  path.moveTo(cornerRadius, topOffset);
  
  // Left flat section to the bump
  path.lineTo(size.width / 2 - bumpRadius - 12, topOffset);
  
  // Smooth bump upwards (curves up to y = 0)
  path.cubicTo(
    size.width / 2 - bumpRadius / 2, topOffset,
    size.width / 2 - bumpRadius + 5, 0,
    size.width / 2, 0,
  );
  path.cubicTo(
    size.width / 2 + bumpRadius - 5, 0,
    size.width / 2 + bumpRadius / 2, topOffset,
    size.width / 2 + bumpRadius + 12, topOffset,
  );
  
  // Right flat section
  path.lineTo(size.width - cornerRadius, topOffset);
  
  // Top right corner
  path.quadraticBezierTo(size.width, topOffset, size.width, topOffset + cornerRadius);
  
  // Right side
  path.lineTo(size.width, size.height - cornerRadius);
  
  // Bottom right corner
  path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);
  
  // Bottom flat section
  path.lineTo(cornerRadius, size.height);
  
  // Bottom left corner
  path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
  
  // Left side
  path.lineTo(0, topOffset + cornerRadius);
  
  // Top left corner
  path.quadraticBezierTo(0, topOffset, cornerRadius, topOffset);
  
  path.close();
  return path;
}
