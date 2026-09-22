import 'package:flutter/material.dart';

class AnalyticsGrowthChart extends StatelessWidget {
  final String activeTab;

  const AnalyticsGrowthChart({
    super.key,
    this.activeTab = "Overview",
  });

  @override
  Widget build(BuildContext context) {
    String titleText = "Platform Growth — Daily Signups";
    String subtitleText = "+34 new enterprise workspaces this week";
    String badgeText = "+18.5%";

    if (activeTab == "AI Usage") {
      titleText = "AI Request Volume Trends";
      subtitleText = "+4,210 AI card scans completed today";
      badgeText = "+31.2%";
    } else if (activeTab == "Storage") {
      titleText = "Storage Usage & Quota Growth";
      subtitleText = "+12.4 GB media uploaded this month";
      badgeText = "+14.8%";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitleText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Custom Painted Smooth Upward Line Chart
          SizedBox(
            height: 130,
            width: double.infinity,
            child: CustomPaint(
              painter: _GrowthChartPainter(activeTab: activeTab),
            ),
          ),

          const SizedBox(height: 14),

          // Days Axis Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Mon", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              Text("Tue", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              Text("Wed", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              Text("Thu", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              Text("Fri", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              Text("Sat", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              Text("Sun", style: TextStyle(fontSize: 11, color: Color(0xFF0052FF), fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final String activeTab;

  _GrowthChartPainter({required this.activeTab});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      final double y = (height / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Normalized points showing smooth upward trend based on tab
    final points = activeTab == "AI Usage"
        ? [
            Offset(0, height * 0.90),
            Offset(width * 0.16, height * 0.70),
            Offset(width * 0.33, height * 0.60),
            Offset(width * 0.50, height * 0.40),
            Offset(width * 0.66, height * 0.45),
            Offset(width * 0.83, height * 0.20),
            Offset(width, height * 0.05),
          ]
        : activeTab == "Storage"
            ? [
                Offset(0, height * 0.75),
                Offset(width * 0.16, height * 0.70),
                Offset(width * 0.33, height * 0.65),
                Offset(width * 0.50, height * 0.55),
                Offset(width * 0.66, height * 0.45),
                Offset(width * 0.83, height * 0.35),
                Offset(width, height * 0.20),
              ]
            : [
                Offset(0, height * 0.80),
                Offset(width * 0.16, height * 0.65),
                Offset(width * 0.33, height * 0.55),
                Offset(width * 0.50, height * 0.60),
                Offset(width * 0.66, height * 0.35),
                Offset(width * 0.83, height * 0.25),
                Offset(width, height * 0.10),
              ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    // Fill path under line
    final fillPath = Path.from(path)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    final lineColor = activeTab == "AI Usage"
        ? const Color(0xFF10B981)
        : activeTab == "Storage"
            ? const Color(0xFFF59E0B)
            : const Color(0xFF0052FF);

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withValues(alpha: 0.25),
        lineColor.withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTRB(0, 0, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Highlight endpoint dot
    final lastPoint = points.last;
    final dotOuterPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(lastPoint, 6.5, dotOuterPaint);
    canvas.drawCircle(lastPoint, 3.5, dotInnerPaint);
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) => oldDelegate.activeTab != activeTab;
}
