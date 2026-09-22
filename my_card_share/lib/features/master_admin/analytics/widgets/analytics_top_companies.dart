import 'package:flutter/material.dart';

class AnalyticsTopCompanies extends StatelessWidget {
  const AnalyticsTopCompanies({super.key});

  @override
  Widget build(BuildContext context) {
    final topCompanies = [
      {
        'rank': '#1',
        'name': 'Acme Realty Group',
        'scans': '4,204 scans this month',
        'logoText': 'AR',
        'logoBg': const Color(0xFF0052FF),
        'rankBg': const Color(0xFFFEF3C7),
        'rankColor': const Color(0xFFD97706),
      },
      {
        'rank': '#2',
        'name': 'TechFlow Solutions',
        'scans': '3,180 scans this month',
        'logoText': 'TF',
        'logoBg': const Color(0xFF8B5CF6),
        'rankBg': const Color(0xFFF1F5F9),
        'rankColor': const Color(0xFF475569),
      },
      {
        'rank': '#3',
        'name': 'Apex Logistics Ltd',
        'scans': '2,840 scans this month',
        'logoText': 'AL',
        'logoBg': const Color(0xFF0D9488),
        'rankBg': const Color(0xFFFEF2F2),
        'rankColor': const Color(0xFFDC2626),
      },
    ];

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
            children: const [
              Text(
                "Top Companies by Activity",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B), size: 20),
            ],
          ),

          const SizedBox(height: 16),

          Column(
            children: topCompanies.asMap().entries.map((entry) {
              final index = entry.key;
              final company = entry.value;
              final isLast = index == topCompanies.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        // Rank Badge (#1, #2, #3)
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: company['rankBg'] as Color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              company['rank'] as String,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: company['rankColor'] as Color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Logo Circle
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: (company['logoBg'] as Color).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (company['logoBg'] as Color).withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              company['logoText'] as String,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: company['logoBg'] as Color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Company Name & Scans Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                company['name'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                company['scans'] as String,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF94A3B8),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                      height: 12,
                      indent: 40,
                      color: Color(0xFFF1F5F9),
                    ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
