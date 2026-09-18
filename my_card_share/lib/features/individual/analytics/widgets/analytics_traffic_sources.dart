import 'package:flutter/material.dart';

class AnalyticsTrafficSources extends StatelessWidget {
  const AnalyticsTrafficSources({super.key});

  final List<Map<String, dynamic>> _sources = const [
    {
      'name': 'QR Scan',
      'percentage': 72,
      'color': Color(0xFF0066FF),
    },
    {
      'name': 'Direct Link',
      'percentage': 48,
      'color': Color(0xFF0D9488),
    },
    {
      'name': 'Email Share',
      'percentage': 35,
      'color': Color(0xFF16A34A),
    },
    {
      'name': 'WhatsApp',
      'percentage': 22,
      'color': Color(0xFFF59E0B),
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          const Text(
            "Traffic Sources",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: _sources.map((item) {
              final String name = item['name'];
              final int percentage = item['percentage'];
              final Color color = item['color'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "$percentage%",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress Bar track
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage / 100.0,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
