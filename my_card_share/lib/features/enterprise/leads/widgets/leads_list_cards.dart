import 'package:flutter/material.dart';

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

  static const List<Map<String, dynamic>> _allLeads = [
    {
      "id": "1",
      "name": "Robert Fox",
      "company": "Nexus Global Dynamics",
      "capturedBy": "James Mitchell",
      "date": "Sept 15",
      "status": "Synced",
      "initials": "RF",
      "avatarColor": Color(0xFF0D9488),
      "avatarBg": Color(0xFFCCFBF1),
    },
    {
      "id": "2",
      "name": "Sophia Martinez",
      "company": "Pinnacle Real Estate Partners",
      "capturedBy": "Sarah Jenkins",
      "date": "Sept 14",
      "status": "Synced",
      "initials": "SM",
      "avatarColor": Color(0xFF7C3AED),
      "avatarBg": Color(0xFFF3E8FF),
    },
    {
      "id": "3",
      "name": "Marcus Vance",
      "company": "Horizon Tech Ventures",
      "capturedBy": "David Miller",
      "date": "Sept 14",
      "status": "Failed",
      "initials": "MV",
      "avatarColor": Color(0xFFD97706),
      "avatarBg": Color(0xFFFEF3C7),
    },
    {
      "id": "4",
      "name": "Elena Rostova",
      "company": "Apex Wealth Management",
      "capturedBy": "Emily Turner",
      "date": "Sept 12",
      "status": "Synced",
      "initials": "ER",
      "avatarColor": Color(0xFF0052FF),
      "avatarBg": Color(0xFFEFF4FF),
    },
    {
      "id": "5",
      "name": "Brandon Vance",
      "company": "Capital Growth Holdings",
      "capturedBy": "Michael Ross",
      "date": "Sept 10",
      "status": "Failed",
      "initials": "BV",
      "avatarColor": Color(0xFFEF4444),
      "avatarBg": Color(0xFFFEE2E2),
    },
  ];

  List<Map<String, dynamic>> get _filteredLeads {
    return _allLeads.where((lead) {
      final status = lead["status"] as String;

      if (selectedFilter == "CRM Synced" && status != "Synced") return false;
      if (selectedFilter == "Failed" && status != "Failed") return false;

      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final name = (lead["name"] as String).toLowerCase();
        final company = (lead["company"] as String).toLowerCase();
        final capturedBy = (lead["capturedBy"] as String).toLowerCase();
        return name.contains(query) || company.contains(query) || capturedBy.contains(query);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final leads = _filteredLeads;

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
              "No leads found",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Try changing your search query or filter selection",
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: leads.map((lead) {
        final isSynced = lead["status"] == "Synced";

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
              if (onLeadTap != null) onLeadTap!(lead);
            },
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                // Circular Initials Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: lead["avatarBg"] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      lead["initials"] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: lead["avatarColor"] as Color,
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
                        lead["name"] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lead["company"] as String,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Key Differentiator: Captured By Employee Attribution
                      Text(
                        "via ${lead["capturedBy"]} · ${lead["date"]}",
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
                      onTap: () {
                        if (!isSynced && onRetrySync != null) {
                          onRetrySync!(lead);
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
  }
}
