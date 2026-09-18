import 'package:flutter/material.dart';
import '../../widgets/mobile_top_bar.dart';
import '../../widgets/mobile_bottom_buttons.dart';
import '../../widgets/main_menu_dialog.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedTimeFilter = 0; // 0 = Today, 1 = This Week, 2 = This Month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MainMenuDrawer(),
      extendBody: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9FBFD), Color(0xFFE2F0FD), Color(0xFFCBE2FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const MobileTopBar(title: 'Analytics'),
                        const SizedBox(height: 24),
                        
                        // Time Filters
                        Row(
                          children: [
                            _buildTimeFilter("Today", 0),
                            const SizedBox(width: 8),
                            _buildTimeFilter("This Week", 1),
                            const SizedBox(width: 8),
                            _buildTimeFilter("This Month", 2),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Stats Cards
                        Row(
                          children: [
                            Expanded(child: _buildStatCard("Views", "1268", "12%", const Color(0xFFEAF1FF), const Color(0xFF2988FA))),
                            const SizedBox(width: 12),
                            Expanded(child: _buildStatCard("Shares", "842", "12%", const Color(0xFFFFF9E6), const Color(0xFFF6A723))),
                            const SizedBox(width: 12),
                            Expanded(child: _buildStatCard("Saves", "421", "12%", const Color(0xFFE6F8F0), const Color(0xFF4CA068))),
                          ],
                        ),
                        const SizedBox(height: 32),

                        const Text("Views Over time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3333))),
                        const SizedBox(height: 16),
                        
                        // Chart Area
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: ChartPainter(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        const Text("Top Countries", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3333))),
                        const SizedBox(height: 16),
                        
                        _buildCountryRow("India", "🇮🇳", "1,024", 0.8),
                        _buildCountryRow("USA", "🇺🇸", "564", 0.5),
                        _buildCountryRow("UAE", "🇦🇪", "142", 0.3),
                        _buildCountryRow("UK", "🇬🇧", "92", 0.2),
                      ],
                    ),
                  ),
                ),
              ),

              // Custom Bottom Navigation
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MobileBottomButtons(activeIndex: 2), // Analytics is index 2
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilter(String text, int index) {
    bool isSelected = _selectedTimeFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2988FA) : const Color(0xFFE8ECEF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF2C3333),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String percent, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Color(0xFF2C3333), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.trending_up, color: textColor, size: 14),
              const SizedBox(width: 4),
              Text(percent, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountryRow(String name, String flag, String value, double percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 36,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBE2FA).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3892F7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(flag, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 40,
            child: Text(value, style: const TextStyle(color: Color(0xFF2C3333), fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.right),
          )
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0x33000000)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    List<String> yLabels = ["50", "25", "10", "5", "0"];
    double leftPadding = 30.0;
    double bottomPadding = 20.0;
    double chartWidth = size.width - leftPadding;
    double chartHeight = size.height - bottomPadding;

    // Draw Y axis labels
    for (int i = 0; i < yLabels.length; i++) {
      double y = i * (chartHeight / (yLabels.length - 1));
      textPainter.text = TextSpan(text: yLabels[i], style: const TextStyle(color: Color(0xFF888888), fontSize: 12));
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    // Draw X axis labels and vertical dashed lines
    List<String> xLabels = ["May 01", "May 02", "May 03", "May 04", "May 05"];
    double stepX = chartWidth / (xLabels.length);
    for (int i = 0; i < xLabels.length; i++) {
      double x = leftPadding + (i * stepX) + (stepX / 2);
      textPainter.text = TextSpan(text: xLabels[i], style: const TextStyle(color: Color(0xFF888888), fontSize: 10));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 15));

      // Vertical dashed line
      double dashY = 0;
      while (dashY < chartHeight) {
        canvas.drawLine(Offset(x, dashY), Offset(x, dashY + 4), gridPaint);
        dashY += 8;
      }
    }

    // Draw Line and Gradient Area
    final path = Path();
    List<Offset> points = [
      Offset(leftPadding, chartHeight / 2),
      Offset(leftPadding + stepX, chartHeight - 20),
      Offset(leftPadding + stepX * 2, chartHeight / 2.5),
      Offset(leftPadding + stepX * 3, chartHeight - 40),
      Offset(leftPadding + stepX * 4, 40),
      Offset(leftPadding + stepX * 5, chartHeight / 1.5), 
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      double cp1x = points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 2;
      double cp1y = points[i - 1].dy;
      double cp2x = points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 2;
      double cp2y = points[i].dy;
      path.cubicTo(cp1x, cp1y, cp2x, cp2y, points[i].dx, points[i].dy);
    }

    // Gradient fill
    final areaPath = Path.from(path);
    areaPath.lineTo(points.last.dx, chartHeight);
    areaPath.lineTo(points.first.dx, chartHeight);
    areaPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2988FA).withValues(alpha: 0.3),
          const Color(0xFF2988FA).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTRB(leftPadding, 0, size.width, chartHeight));
    canvas.drawPath(areaPath, fillPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = const Color(0xFF2988FA)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    // Draw tooltip at May 05 (index 4 in points)
    double tipX = points[4].dx;
    double tipY = points[4].dy;
    
    // Draw horizontal dashed line from the tooltip to the right edge
    double horizDashX = tipX;
    while (horizDashX < size.width) {
      canvas.drawLine(Offset(horizDashX, tipY), Offset(horizDashX + 4, tipY), Paint()..color = const Color(0xFF2988FA)..strokeWidth = 2);
      horizDashX += 8;
    }
    
    // Vertical solid blue line down to the axis
    canvas.drawLine(Offset(tipX, tipY), Offset(tipX, chartHeight), Paint()..color = const Color(0xFF2988FA)..strokeWidth = 2);

    // Draw circle on the data point
    final circlePaint = Paint()..color = const Color(0xFF2988FA);
    canvas.drawCircle(Offset(tipX, tipY), 4, circlePaint);
    final circlePaintWhite = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(tipX, tipY), 2, circlePaintWhite);

    // Draw tooltip box
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(tipX, tipY - 20), width: 44, height: 28), 
      const Radius.circular(14)
    );
    canvas.drawRRect(rrect, Paint()..color = Colors.white);
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFE8ECEF)..style = PaintingStyle.stroke..strokeWidth = 1);
    
    textPainter.text = const TextSpan(text: "10", style: TextStyle(color: Color(0xFF2988FA), fontSize: 16, fontWeight: FontWeight.bold));
    textPainter.layout();
    textPainter.paint(canvas, Offset(tipX - textPainter.width / 2, tipY - 20 - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
