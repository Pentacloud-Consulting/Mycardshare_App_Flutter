import 'package:flutter/material.dart';
import '../../../../backend/individual/qr scan/individual_generate_qr.dart';

class FloatingQrButton extends StatefulWidget {
  final String name;

  const FloatingQrButton({
    super.key,
    required this.name,
  });

  @override
  State<FloatingQrButton> createState() => _FloatingQrButtonState();
}

class _FloatingQrButtonState extends State<FloatingQrButton> {
  Offset? _position;

  void _showQrModal(BuildContext context) {
    IndividualGenerateQR.showModal(context, name: widget.name);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Set initial position if not dragged yet (bottom-right default)
    _position ??= Offset(
      screenSize.width - 76,
      screenSize.height - 150,
    );

    return Positioned(
      left: _position!.dx,
      top: _position!.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            double newX = _position!.dx + details.delta.dx;
            double newY = _position!.dy + details.delta.dy;

            // Clamping position to keep button fully visible on screen
            newX = newX.clamp(12.0, screenSize.width - 68.0);
            newY = newY.clamp(60.0, screenSize.height - 120.0);

            _position = Offset(newX, newY);
          });
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF38BDF8), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x250066FF),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Color(0xFF0052FF), size: 26),
            onPressed: () => _showQrModal(context),
          ),
        ),
      ),
    );
  }
}
