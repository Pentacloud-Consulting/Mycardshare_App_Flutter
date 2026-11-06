import 'package:flutter/material.dart';
import '../../../../backend/individual/previews/individual_metrics_store.dart';
import '../../../../backend/individual/previews/publish_unpublish.dart';
import '../../../../backend/employee_join/home/employee_stats_backend.dart';

class _WaveCurvePainter extends CustomPainter {
  final Color color;

  const _WaveCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.2,
      size.width * 0.65,
      size.height * 0.9,
      size.width,
      size.height * 0.35,
    );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashboardMetricsRow extends StatelessWidget {
  final String? views;
  final String? viewsTrend;
  final String? leads;
  final String? leadsTrend;
  final String? scans;
  final String? scansTrend;

  const DashboardMetricsRow({
    super.key,
    this.views,
    this.viewsTrend,
    this.leads,
    this.leadsTrend,
    this.scans,
    this.scansTrend,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        IndividualMetricsStore.instance,
        EmployeeStatsBackendService.instance,
        PublishUnpublishService.instance,
      ]),
      builder: (context, _) {
        final store = IndividualMetricsStore.instance;
        final empStats = EmployeeStatsBackendService.instance;
        final isPublished = PublishUnpublishService.instance.isPublished;

        // Card Impressions (Card 1)
        final rawViews = views ?? (empStats.views > 0 ? '${empStats.views}' : store.formattedViews);
        final impressionsValue = rawViews.isNotEmpty ? rawViews : '0';
        final impressionsTrend = (viewsTrend != null && viewsTrend!.isNotEmpty)
            ? viewsTrend!
            : (empStats.viewsTrend.isNotEmpty ? empStats.viewsTrend : "+0%");

        // Profile Status (Card 2)
        final statusValue = isPublished ? "Published" : "Draft";
        final statusBadge = isPublished ? "Active" : "Draft";

        // Connections (Card 3)
        final connectionsValue = leads ?? (empStats.leads > 0 ? '${empStats.leads}' : store.formattedLeads);
        final connectionsTrend = (leadsTrend != null && leadsTrend!.isNotEmpty)
            ? leadsTrend!
            : (empStats.leadsTrend.isNotEmpty ? empStats.leadsTrend : "+0%");

        return Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.visibility_outlined,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF0052FF),
                title: "Card Impressions",
                value: impressionsValue,
                badgeText: impressionsTrend,
                badgeBg: const Color(0xFFEFF6FF),
                badgeColor: const Color(0xFF0052FF),
                waveColor: const Color(0xFF0052FF),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.verified_user_outlined,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF10B981),
                title: "Profile Status",
                value: statusValue,
                badgeText: statusBadge,
                badgeBg: const Color(0xFFECFDF5),
                badgeColor: const Color(0xFF10B981),
                waveColor: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.people_outline_rounded,
                iconBg: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF9333EA),
                title: "Connections",
                value: connectionsValue,
                badgeText: connectionsTrend,
                badgeBg: const Color(0xFFF3E8FF),
                badgeColor: const Color(0xFF9333EA),
                waveColor: const Color(0xFF9333EA),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
    required Color waveColor,
  }) {
    final cleanBadge = badgeText
        .replaceAll(RegExp(r'this week', caseSensitive: false), '')
        .replaceAll(RegExp(r'vs last week', caseSensitive: false), '')
        .trim();
    final displayBadge = cleanBadge.isNotEmpty ? cleanBadge : "+0%";

    final isTextValue = int.tryParse(value) == null;

    return Container(
      height: 106,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Wave curve at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 16,
              child: CustomPaint(
                painter: _WaveCurvePainter(color: waveColor),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Icon(icon, color: iconColor, size: 15),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.north_east_rounded, size: 8, color: badgeColor),
                                const SizedBox(width: 2),
                                Text(
                                  displayBadge,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: badgeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.05,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: isTextValue ? 12.5 : 15.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
