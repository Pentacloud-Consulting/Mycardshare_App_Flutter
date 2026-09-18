import 'package:flutter/material.dart';

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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Scan QR Code",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    size: 160,
                    color: Color(0xFF0052FF),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Scan to save ${widget.name}'s contact card instantly",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
