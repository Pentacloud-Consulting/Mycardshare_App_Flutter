import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9FBFD), Color(0xFFE2F0FD), Color(0xFF3892F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 20,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8ECEF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Color(0xFF2C3333), size: 20),
                  ),
                ),
              ),
              const Positioned(
                top: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Place the business Card\nwithin the frame",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF2C3333),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          color: const Color(0xFFDCDFE3),
                          width: double.infinity,
                          height: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                left: -50,
                                top: -50,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.brown.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.withValues(alpha: 0.3),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: -0.05,
                                child: Container(
                                  width: 240,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 10))
                                    ]
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF4CA068),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.location_on, color: Colors.white, size: 14),
                                            SizedBox(width: 4),
                                            Text("THE HOME FINDERS", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                          ],
                                        )
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.blue, width: 2),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: const Icon(Icons.qr_code_2, size: 36, color: Colors.blue),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  const Text("Get to know us", style: TextStyle(color: Colors.blue, fontSize: 6)),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: const [
                                                  Text("Carol Bryans", style: TextStyle(color: Color(0xFF2988FA), fontWeight: FontWeight.bold, fontSize: 16)),
                                                  Text("Real Estate Agent", style: TextStyle(color: Color(0xFF888888), fontSize: 10)),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Text("M  ", style: TextStyle(color: Color(0xFF2988FA), fontSize: 7, fontWeight: FontWeight.bold)),
                                                      Text("+1 (234) 567 8900", style: TextStyle(color: Colors.grey, fontSize: 7)),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text("E   ", style: TextStyle(color: Color(0xFF2988FA), fontSize: 7, fontWeight: FontWeight.bold)),
                                                      Text("carol@homefinders.com", style: TextStyle(color: Colors.grey, fontSize: 7)),
                                                    ],
                                                  ),
                                                ]
                                              )
                                            )
                                          ]
                                        )
                                      )
                                    ]
                                  )
                                ),
                              )
                            ]
                          )
                        ),
                      ),
                      CustomPaint(
                        size: Size.infinite,
                        painter: ScannerBorderPainter(),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
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
}

class ScannerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2988FA)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 40;
    const double radius = 24;

    // Top Left
    var path = Path();
    path.moveTo(0, cornerLength);
    path.lineTo(0, radius);
    path.arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius));
    path.lineTo(cornerLength, 0);
    canvas.drawPath(path, paint);

    // Top Right
    path = Path();
    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius));
    path.lineTo(size.width, cornerLength);
    canvas.drawPath(path, paint);

    // Bottom Left
    path = Path();
    path.moveTo(0, size.height - cornerLength);
    path.lineTo(0, size.height - radius);
    path.arcToPoint(Offset(radius, size.height), radius: const Radius.circular(radius), clockwise: false);
    path.lineTo(cornerLength, size.height);
    canvas.drawPath(path, paint);

    // Bottom Right
    path = Path();
    path.moveTo(size.width - cornerLength, size.height);
    path.lineTo(size.width - radius, size.height);
    path.arcToPoint(Offset(size.width, size.height - radius), radius: const Radius.circular(radius), clockwise: false);
    path.lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
