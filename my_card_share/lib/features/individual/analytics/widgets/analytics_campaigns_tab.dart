import 'package:flutter/material.dart';

class AnalyticsCampaignsTab extends StatelessWidget {
  const AnalyticsCampaignsTab({super.key});

  final List<Map<String, String>> _campaigns = const [
    {'name': 'TechSummit 2026 QR', 'scans': '142', 'leads': '28', 'rate': '19.7%'},
    {'name': 'LinkedIn Header QR', 'scans': '88', 'leads': '11', 'rate': '12.5%'},
    {'name': 'Email Signature Link', 'scans': '54', 'leads': '5', 'rate': '9.2%'},
    {'name': 'NFC Smart Card', 'scans': '26', 'leads': '2', 'rate': '7.6%'},
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
                "Active QR & Digital Campaigns",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                "Performance per campaign link and active QR code.",
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ..._campaigns.map((camp) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(camp['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text("${camp['scans']} scans • ${camp['leads']} leads", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            camp['rate']!,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
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
