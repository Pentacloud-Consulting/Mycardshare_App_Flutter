import 'package:flutter/material.dart';

class AnalyticsDailyChart extends StatefulWidget {
  const AnalyticsDailyChart({super.key});

  @override
  State<AnalyticsDailyChart> createState() => _AnalyticsDailyChartState();
}

class _AnalyticsDailyChartState extends State<AnalyticsDailyChart> {
  int? _hoveredIndex;

  final List<Map<String, dynamic>> _chartData = [
    {'date': 'Sep 7', 'views': 140, 'leads': 65},
    {'date': 'Sep 8', 'views': 142, 'leads': 80},
    {'date': 'Sep 9', 'views': 155, 'leads': 82},
    {'date': 'Sep 10', 'views': 190, 'leads': 110},
    {'date': 'Sep 11', 'views': 175, 'leads': 88},
    {'date': 'Sep 12', 'views': 240, 'leads': 128},
    {'date': 'Sep 13', 'views': 180, 'leads': 98},
    {'date': 'Sep 14', 'views': 235, 'leads': 138},
    {'date': 'Sep 15', 'views': 330, 'leads': 170},
    {'date': 'Sep 16', 'views': 290, 'leads': 170},
  ];

  @override
  Widget build(BuildContext context) {
    const maxVal = 400.0;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                // Y-Axis Labels
                SizedBox(
                  width: 28,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("400", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      Text("300", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      Text("200", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      Text("100", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      Text("0", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Chart Grid & Dual Bars
                Expanded(
                  child: Stack(
                    children: [
                      // Dashed horizontal grid lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          5,
                          (_) => Container(
                            height: 1,
                            color: const Color(0xFFF1F5F9),
                          ),
                        ),
                      ),

                      // Bars Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(_chartData.length, (index) {
                          final item = _chartData[index];
                          final viewsH = (item['views'] as int) / maxVal * 150;
                          final leadsH = (item['leads'] as int) / maxVal * 150;
                          final isHovered = _hoveredIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _hoveredIndex = isHovered ? null : index;
                              });
                            },
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
                                    child: Text(
                                      "${item['views']}v / ${item['leads']}l",
                                      style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Views Bar (Darker Blue)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 8,
                                      height: viewsH,
                                      decoration: BoxDecoration(
                                        color: isHovered ? const Color(0xFF1D4ED8) : const Color(0xFF0066FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    // Leads Bar (Lighter Blue)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 8,
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
                                  item['date'] as String,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: isHovered ? FontWeight.bold : FontWeight.w500,
                                    color: isHovered ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
