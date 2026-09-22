import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardRecentSignups extends StatelessWidget {
  const DashboardRecentSignups({super.key});

  @override
  Widget build(BuildContext context) {
    final recentSignups = [
      {
        'id': 'sign-1',
        'name': 'Vertex Media Group',
        'tier': 'Starter Workspace',
        'time': '2h ago',
        'status': 'Pending',
        'statusColor': const Color(0xFFD97706),
        'statusBg': const Color(0xFFFFFBEB),
        'logoText': 'VM',
        'logoBg': const Color(0xFF8B5CF6),
      },
      {
        'id': 'sign-2',
        'name': 'Nexus Digital Labs',
        'tier': 'Enterprise Pro',
        'time': '5h ago',
        'status': 'Active',
        'statusColor': const Color(0xFF10B981),
        'statusBg': const Color(0xFFECFDF5),
        'logoText': 'ND',
        'logoBg': const Color(0xFF0052FF),
      },
      {
        'id': 'sign-3',
        'name': 'Horizon BioTech',
        'tier': 'Enterprise Standard',
        'time': '1d ago',
        'status': 'Active',
        'statusColor': const Color(0xFF10B981),
        'statusBg': const Color(0xFFECFDF5),
        'logoText': 'HB',
        'logoBg': const Color(0xFF0D9488),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Company Signups",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push('/master-admin/company');
              },
              child: const Text(
                "See All",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0052FF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: recentSignups.map((company) {
            return GestureDetector(
              onTap: () {
                context.push('/master-admin/company');
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Company Logo Circle
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: (company['logoBg'] as Color).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (company['logoBg'] as Color).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          company['logoText'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: company['logoBg'] as Color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company['name'] as String,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                company['tier'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text("•", style: TextStyle(color: Color(0xFFCBD5E1))),
                              const SizedBox(width: 6),
                              Text(
                                company['time'] as String,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status Pill Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: company['statusBg'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        company['status'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: company['statusColor'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
