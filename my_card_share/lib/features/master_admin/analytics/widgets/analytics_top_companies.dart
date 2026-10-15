import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../backend/master_admin/companies/company_management_store.dart';
import '../../../../backend/master_admin/companies/models/master_company_model.dart';

class AnalyticsTopCompanies extends StatelessWidget {
  const AnalyticsTopCompanies({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MasterCompanyModel>>(
      stream: CompanyManagementStore.instance.streamCompanies(),
      builder: (context, snapshot) {
        final companies = snapshot.data ?? CompanyManagementStore.instance.companies;
        final list = companies.take(3).toList();

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

          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "No active companies registered yet",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Column(
              children: list.asMap().entries.map((entry) {
                final index = entry.key;
                final company = entry.value;
                final isLast = index == list.length - 1;

                final rank = "#${index + 1}";
                final rankBg = index == 0
                    ? const Color(0xFFFEF3C7)
                    : (index == 1 ? const Color(0xFFF1F5F9) : const Color(0xFFFEF2F2));
                final rankColor = index == 0
                    ? const Color(0xFFD97706)
                    : (index == 1 ? const Color(0xFF475569) : const Color(0xFFDC2626));
                const logoBg = Color(0xFF0052FF);

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        context.push('/master-admin/company/${company.id}');
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            // Rank Badge
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: rankBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  rank,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: rankColor,
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
                                color: logoBg.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: logoBg.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  company.initials,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: logoBg,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Company Name & Plan / Seat Count
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    company.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${company.plan} · ${company.employeeCount} seats",
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
      },
    );
  }
}


