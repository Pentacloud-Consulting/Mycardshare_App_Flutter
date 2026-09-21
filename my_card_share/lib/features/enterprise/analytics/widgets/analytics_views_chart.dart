import 'package:flutter/material.dart';

class AnalyticsViewsChart extends StatelessWidget {
  const AnalyticsViewsChart({super.key});

  static const List<double> _dailyBarHeights = [
    0.45,
    0.65,
    0.35,
    0.80,
    0.95,
    0.60,
    0.75,
    0.88,
    0.50,
    0.70,
    0.90,
    1.00,
  ];

  static const List<String> _days = [
    "S1",
    "S2",
    "S3",
    "S4",
    "S5",
    "S6",
    "S7",
    "S8",
    "S9",
    "S10",
    "S11",
    "S12",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Company Views — Daily",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Avg 280/day",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0052FF),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Chart Container with Horizontal Gridlines & Bars
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                // Horizontal Light Gray Gridlines
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    return const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF1F5F9),
                    );
                  }),
                ),

                // Bar Chart Columns Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(_dailyBarHeights.length, (index) {
                    final heightFactor = _dailyBarHeights[index];
                    final isPeak = heightFactor >= 0.95;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 14,
                          height: 100 * heightFactor,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPeak
                                  ? [const Color(0xFF0052FF), const Color(0xFF38BDF8)]
                                  : [const Color(0xFF3B82F6), const Color(0xFF93C5FD)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _days[index],
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
