import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompanyListCard extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;

  const CompanyListCard({
    super.key,
    this.searchQuery = "",
    this.selectedFilter = "All",
  });

  @override
  Widget build(BuildContext context) {
    final allCompanies = [
      {
        'id': 'acme-realty',
        'name': 'Acme Realty Group',
        'plan': 'Enterprise Pro',
        'employees': '34 employees',
        'status': 'Active',
        'statusColor': const Color(0xFF10B981),
        'statusBg': const Color(0xFFECFDF5),
        'logoText': 'AR',
        'logoBg': const Color(0xFF0052FF),
      },
      {
        'id': 'techflow-inc',
        'name': 'TechFlow Solutions',
        'plan': 'Enterprise Standard',
        'employees': '24 employees',
        'status': 'Active',
        'statusColor': const Color(0xFF10B981),
        'statusBg': const Color(0xFFECFDF5),
        'logoText': 'TF',
        'logoBg': const Color(0xFF8B5CF6),
      },
      {
        'id': 'vertex-media',
        'name': 'Vertex Media Group',
        'plan': 'Starter Workspace',
        'employees': '12 employees',
        'status': 'Pending',
        'statusColor': const Color(0xFFD97706),
        'statusBg': const Color(0xFFFFFBEB),
        'logoText': 'VM',
        'logoBg': const Color(0xFFF59E0B),
      },
      {
        'id': 'apex-logistics',
        'name': 'Apex Logistics Ltd',
        'plan': 'Enterprise Pro',
        'employees': '86 employees',
        'status': 'Active',
        'statusColor': const Color(0xFF10B981),
        'statusBg': const Color(0xFFECFDF5),
        'logoText': 'AL',
        'logoBg': const Color(0xFF0D9488),
      },
      {
        'id': 'global-ventures',
        'name': 'Global Corp Ventures',
        'plan': 'Enterprise Standard',
        'employees': '18 employees',
        'status': 'Suspended',
        'statusColor': const Color(0xFFEF4444),
        'statusBg': const Color(0xFFFEF2F2),
        'logoText': 'GC',
        'logoBg': const Color(0xFFEF4444),
      },
      {
        'id': 'horizon-biotech',
        'name': 'Horizon BioTech',
        'plan': 'Enterprise Pro',
        'employees': '52 employees',
        'status': 'Active',
        'statusColor': const Color(0xFF10B981),
        'statusBg': const Color(0xFFECFDF5),
        'logoText': 'HB',
        'logoBg': const Color(0xFF2563EB),
      },
    ];

    final filteredCompanies = allCompanies.where((company) {
      final name = (company['name'] as String).toLowerCase();
      final plan = (company['plan'] as String).toLowerCase();
      final status = company['status'] as String;

      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty || name.contains(query) || plan.contains(query);
      final matchesFilter = selectedFilter == 'All' || status.toLowerCase() == selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();

    if (filteredCompanies.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: const [
            Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF94A3B8)),
            SizedBox(height: 10),
            Text(
              "No companies match criteria",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Try changing search terms or selected status filter.",
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return Container(
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
        children: filteredCompanies.asMap().entries.map((entry) {
          final index = entry.key;
          final company = entry.value;
          final isLast = index == filteredCompanies.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () {
                  context.push('/master-admin/company/${company['id']}');
                },
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? const Radius.circular(16) : Radius.zero,
                  bottom: isLast ? const Radius.circular(16) : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Company Logo Circle
                      Container(
                        width: 44,
                        height: 44,
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
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: company['logoBg'] as Color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Company Name & Subtitle
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
                            const SizedBox(height: 3),
                            Text(
                              "${company['plan']}  ·  ${company['employees']}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status Pill
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
                      const SizedBox(width: 8),

                      // Chevron Arrow
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 16,
                  color: Color(0xFFF1F5F9),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
