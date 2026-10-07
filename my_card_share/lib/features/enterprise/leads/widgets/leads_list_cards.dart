import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/home_backend/leads_service.dart';

class LeadsListCards extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;
  final Function(Map<String, dynamic> lead)? onLeadTap;
  final Function(Map<String, dynamic> lead)? onRetrySync;

  const LeadsListCards({
    super.key,
    this.searchQuery = "",
    this.selectedFilter = "All",
    this.onLeadTap,
    this.onRetrySync,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<List<EnterpriseLeadModel>>(
      stream: EnterpriseLeadsService.instance.streamLeads(
        uid,
        selectedFilter,
        searchQuery,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: Color(0xFF0052FF)),
            ),
          );
        }

        final leads = snapshot.data ?? [];

        if (leads.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: const Column(
              children: [
                Icon(Icons.assignment_late_outlined, size: 40, color: Color(0xFF94A3B8)),
                SizedBox(height: 10),
                Text(
                  "No leads captured yet",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Team members will capture leads when sharing digital cards",
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: leads.map((lead) {
            final isSynced = lead.status == "Synced";
            final map = {
              "id": lead.id,
              "name": lead.name,
              "company": lead.company,
              "capturedBy": lead.capturedBy,
              "email": lead.email,
              "date": lead.date.toString().split(' ').first,
              "status": lead.status,
              "initials": lead.initials,
            };

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
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
              child: InkWell(
                onTap: () {
                  if (onLeadTap != null) onLeadTap!(map);
                },
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    // Circular Initials Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF4FF),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          lead.initials,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0052FF),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Center Column: Name, Company, Attribution
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lead.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lead.company.isNotEmpty ? lead.company : lead.email,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Captured By Attribution
                          Text(
                            "via ${lead.capturedBy} · ${lead.date.year}-${lead.date.month.toString().padLeft(2, '0')}-${lead.date.day.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Right Side: Sync Status Tag & Chevron Arrow
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (!isSynced && uid != null) {
                              await EnterpriseLeadsService.instance.retrySyncLead(uid, lead.id);
                              if (onRetrySync != null) onRetrySync!(map);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSynced
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSynced
                                    ? const Color(0xFFA7F3D0)
                                    : const Color(0xFFFECACA),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSynced ? Icons.check_circle_rounded : Icons.sync_problem_rounded,
                                  size: 13,
                                  color: isSynced
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isSynced ? "Synced" : "Failed",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isSynced
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}


