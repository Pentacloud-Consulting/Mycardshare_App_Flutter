import 'package:flutter/material.dart';

class AnalyticsLeadsTab extends StatelessWidget {
  const AnalyticsLeadsTab({super.key});

  final List<Map<String, String>> _leadsBreakdown = const [
    {'source': 'QR Scan', 'count': '28', 'conversion': '68%', 'status': 'High Quality'},
    {'source': 'Voice Input', 'count': '12', 'conversion': '42%', 'status': 'Medium'},
    {'source': 'Manual Entry', 'count': '6', 'conversion': '25%', 'status': 'Standard'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Lead Generation Breakdown",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                "Overview of leads acquired per acquisition channel.",
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ..._leadsBreakdown.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['source']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Conversion: ${item['conversion']}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${item['count']} leads",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
