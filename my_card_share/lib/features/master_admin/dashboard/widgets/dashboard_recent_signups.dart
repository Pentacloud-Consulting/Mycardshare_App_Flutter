import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../backend/master_admin/companies/company_management_store.dart';
import '../../../../backend/master_admin/companies/models/master_company_model.dart';

class DashboardRecentSignups extends StatelessWidget {
  const DashboardRecentSignups({super.key});

  @override
  Widget build(BuildContext context) {
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
        StreamBuilder<List<MasterCompanyModel>>(
          stream: CompanyManagementStore.instance.streamCompanies(),
          builder: (context, snapshot) {
            final companies = snapshot.data ?? CompanyManagementStore.instance.companies;

            if (companies.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Center(
                  child: Text(
                    snapshot.connectionState == ConnectionState.waiting
                        ? "Loading recent companies..."
                        : "No companies registered yet",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }

            final recentList = companies.take(4).toList();

            return Column(
              children: recentList.map((company) {
                final isPending = company.status.toLowerCase() == 'pending';
                final isSuspended = company.status.toLowerCase() == 'suspended';

                final statusColor = isSuspended
                    ? const Color(0xFFEF4444)
                    : (isPending ? const Color(0xFFD97706) : const Color(0xFF10B981));
                final statusBg = isSuspended
                    ? const Color(0xFFFEF2F2)
                    : (isPending ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5));
                const logoBg = Color(0xFF0052FF);

                return GestureDetector(
                  onTap: () {
                    context.push('/master-admin/company/${company.id}');
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
                            color: logoBg.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: logoBg.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              company.initials,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: logoBg,
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
                                company.name,
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
                                    company.plan,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text("•", style: TextStyle(color: Color(0xFFCBD5E1))),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${company.employeeCount} seats",
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
                            color: statusBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            company.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}



