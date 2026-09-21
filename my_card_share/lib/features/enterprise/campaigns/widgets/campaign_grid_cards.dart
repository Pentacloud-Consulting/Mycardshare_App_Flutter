import 'dart:ui';
import 'package:flutter/material.dart';

class CampaignGridCards extends StatelessWidget {
  final String selectedFilter;
  final VoidCallback? onNewCampaignTap;
  final Function(Map<String, dynamic> campaign)? onCampaignTap;

  const CampaignGridCards({
    super.key,
    this.selectedFilter = "All",
    this.onNewCampaignTap,
    this.onCampaignTap,
  });

  static const List<Map<String, dynamic>> _campaigns = [
    {
      "id": "1",
      "title": "Web Summit 2026",
      "tag": "CAMPAIGN",
      "color": Color(0xFF0052FF),
      "scans": 432,
      "conv": "12%",
      "endsCaption": "Ends in 5 days",
      "status": "Active",
    },
    {
      "id": "2",
      "title": "Q3 Sales Offsite",
      "tag": "CAMPAIGN",
      "color": Color(0xFF7C3AED),
      "scans": 125,
      "conv": "24%",
      "endsCaption": "Ends in 12 days",
      "status": "Active",
    },
    {
      "id": "3",
      "title": "TechCrunch Disrupt",
      "tag": "CAMPAIGN",
      "color": Color(0xFFEC4899),
      "scans": 890,
      "conv": "8%",
      "endsCaption": "Ends in 2 days",
      "status": "Active",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _campaigns.where((c) {
      if (selectedFilter == "Active" && c["status"] != "Active") return false;
      if (selectedFilter == "Ended" && c["status"] != "Ended") return false;
      return true;
    }).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length + 1, // +1 for New Campaign dashed card
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        // Render New Campaign empty state card for last item
        if (index == filtered.length) {
          return _buildNewCampaignDashedCard(context);
        }

        final camp = filtered[index];
        final Color cardColor = camp["color"] as Color;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              if (onCampaignTap != null) onCampaignTap!(camp);
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Small dot + CAMPAIGN tag & Mini QR Thumbnail
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Small colored dot indicator top-left
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: cardColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        // Small CAMPAIGN label tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cardColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            camp["tag"] as String,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: cardColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Mini QR code thumbnail (top-right corner)
                    Container(
                      width: 28,
                      height: 28,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 20,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Bold Title
                Text(
                  camp["title"] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Stat Row: Scans & Conv Rate side by side
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "👁 ${camp["scans"]}",
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                      Text(
                        "📈 ${camp["conv"]}",
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Small Gray Caption
                Text(
                  camp["endsCaption"] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Card 4: Dashed-border empty state card with a large "+" icon centered
  Widget _buildNewCampaignDashedCard(BuildContext context) {
    return GestureDetector(
      onTap: onNewCampaignTap,
      child: CustomPaint(
        painter: DashedRectPainter(
          color: const Color(0xFF0052FF).withValues(alpha: 0.4),
          strokeWidth: 1.5,
          gap: 5.0,
          radius: 16.0,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF0052FF),
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "New Campaign",
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0052FF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for dashed border card
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 5.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? 6.0 : gap;
        if (draw) {
          dashPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
