import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../backend/master_admin/companies/company_management_store.dart';
import '../../../../backend/master_admin/companies/models/master_company_model.dart';

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
    return StreamBuilder<List<MasterCompanyModel>>(
      stream: CompanyManagementStore.instance.streamCompanies(),
      builder: (context, snapshot) {
        final allCompanies = snapshot.data ?? CompanyManagementStore.instance.companies;

        if (snapshot.connectionState == ConnectionState.waiting && allCompanies.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          );
        }

        final filteredCompanies = allCompanies.where((company) {
          final name = company.name.toLowerCase();
          final plan = company.plan.toLowerCase();
          final status = company.status;

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
            child: const Column(
              children: [
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

              final isSuspended = company.status.toLowerCase() == 'suspended';
              final isPending = company.status.toLowerCase() == 'pending';
              final statusColor = isSuspended
                  ? const Color(0xFFEF4444)
                  : (isPending ? const Color(0xFFD97706) : const Color(0xFF10B981));
              final statusBg = isSuspended
                  ? const Color(0xFFFEF2F2)
                  : (isPending ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5));
              const logoBg = Color(0xFF0052FF);

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      context.push('/master-admin/company/${company.id}');
                    },
                    borderRadius: BorderRadius.vertical(
                      top: index == 0 ? const Radius.circular(16) : Radius.zero,
                      bottom: isLast ? const Radius.circular(16) : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          // Company Logo Circle (Image logo if available, else Initials)
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: logoBg.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: logoBg.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: company.logoUrl != null && company.logoUrl!.trim().isNotEmpty
                                ? Image.network(
                                    company.logoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        company.initials,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: logoBg,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      company.initials,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: logoBg,
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
                                  company.name,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "${company.plan}  ·  ${company.employeeCount} seats",
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
      },
    );
  }
}



