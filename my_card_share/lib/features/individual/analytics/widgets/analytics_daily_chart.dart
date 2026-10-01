import 'package:flutter/material.dart';
import '../../../../backend/individual/analytics/chart.dart';
import '../../../../backend/individual/previews/individual_metrics_store.dart';
import '../../../../backend/individual/previews/user_leads.dart';

class AnalyticsDailyChart extends StatefulWidget {
  const AnalyticsDailyChart({super.key});

  @override
  State<AnalyticsDailyChart> createState() => _AnalyticsDailyChartState();
}

class _AnalyticsDailyChartState extends State<AnalyticsDailyChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([IndividualMetricsStore.instance, UserLeadsService.instance]),
      builder: (context, _) {
        final totalViews = IndividualMetricsStore.instance.metrics.views;
        final totalLeads = UserLeadsService.instance.totalLeadsCount > 0
            ? UserLeadsService.instance.totalLeadsCount
            : IndividualMetricsStore.instance.metrics.leads;

        final chartPoints = AnalyticsChartService.instance.getDailyChartData(
          totalViews: totalViews,
          totalLeads: totalLeads,
        );
        final maxVal = AnalyticsChartService.instance.calculateMaxYValue(chartPoints);
        final step = (maxVal / 4).round();

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Legend
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  const Text(
                    "Views & Leads — Daily",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLegendItem(color: const Color(0xFF0066FF), label: "Views"),
                      const SizedBox(width: 12),
                      _buildLegendItem(color: const Color(0xFF60A5FA), label: "Leads"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Interactive Chart Area
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Dynamic Y-Axis Labels
                    SizedBox(
                      width: 28,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${maxVal.toInt()}", style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                          Text("${step * 3}", style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                          Text("${step * 2}", style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                          Text("$step", style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                          const Text("0", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Chart Grid & Dual Bars
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const itemWidth = 44.0;
                          final minWidth = itemWidth * chartPoints.length;
                          final contentWidth = constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: SizedBox(
                              width: contentWidth,
                              height: 180,
                              child: Stack(
                                children: [
                                  // Dashed horizontal grid lines
                                  Positioned.fill(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: List.generate(
                                        5,
                                        (_) => Container(
                                          height: 1,
                                          color: const Color(0xFFF1F5F9),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Bars Row
                                  Positioned.fill(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: List.generate(chartPoints.length, (index) {
                                        final item = chartPoints[index];
                                        final viewsH = (item.views / maxVal) * 135;
                                        final leadsH = (item.leads / maxVal) * 135;
                                        final isHovered = _hoveredIndex == index;

                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _hoveredIndex = isHovered ? null : index;
                                            });
                                          },
                                          child: SizedBox(
                                            width: itemWidth,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                if (isHovered)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    margin: const EdgeInsets.only(bottom: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF0F172A),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        "${item.views}v / ${item.leads}l",
                                                        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    // Views Bar (Darker Blue)
                                                    AnimatedContainer(
                                                      duration: const Duration(milliseconds: 300),
                                                      width: 7,
                                                      height: viewsH,
                                                      decoration: BoxDecoration(
                                                        color: isHovered ? const Color(0xFF1D4ED8) : const Color(0xFF0066FF),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    // Leads Bar (Lighter Blue)
                                                    AnimatedContainer(
                                                      duration: const Duration(milliseconds: 300),
                                                      width: 7,
                                                      height: leadsH,
                                                      decoration: BoxDecoration(
                                                        color: isHovered ? const Color(0xFF3B82F6) : const Color(0xFF60A5FA),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  item.date,
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: isHovered ? FontWeight.bold : FontWeight.w500,
                                                    color: isHovered ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
