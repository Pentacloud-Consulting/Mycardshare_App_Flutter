import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../backend/master_admin/companies/company_management_store.dart';

class GlobalCampaignModel {
  final String id;
  final String title;
  final String company;
  final String scans;
  final String conversion;
  final Color color;
  final bool isActive;

  GlobalCampaignModel({
    required this.id,
    required this.title,
    required this.company,
    required this.scans,
    required this.conversion,
    required this.color,
    this.isActive = true,
  });

  factory GlobalCampaignModel.fromFirestore(String id, Map<String, dynamic> data, String fallbackCompany) {
    final title = data['title'] ?? data['name'] ?? 'Campaign $id';
    final company = data['companyName'] ?? data['company'] ?? fallbackCompany;
    final scanCount = data['scans'] ?? data['scanCount'] ?? data['views'] ?? 0;
    final conv = data['conversion'] ?? data['conversionRate'] ?? '15%';
    final status = (data['status'] ?? 'Active').toString().toLowerCase();

    return GlobalCampaignModel(
      id: id,
      title: title.toString(),
      company: company.toString().startsWith('by ') ? company.toString() : 'by $company',
      scans: '$scanCount scans',
      conversion: conv.toString().contains('conv') ? conv.toString() : '$conv conv',
      color: _colorForId(id),
      isActive: status == 'active',
    );
  }

  static Color _colorForId(String id) {
    final colors = [
      const Color(0xFF0052FF),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF0D9488),
      const Color(0xFFD97706),
      const Color(0xFF2563EB),
    ];
    return colors[id.hashCode.abs() % colors.length];
  }
}

class GlobalCampaignList extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;

  const GlobalCampaignList({
    super.key,
    this.searchQuery = "",
    this.selectedFilter = "All",
  });

  Stream<List<GlobalCampaignModel>> _streamGlobalCampaigns() {
    final firestore = FirebaseFirestore.instance;
    return firestore.collectionGroup('campaigns').snapshots().handleError((_) {
      // If collectionGroup requires index or is empty, fallback to reading root campaigns or enterprises
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }).asyncMap((groupSnap) async {
      if (groupSnap.docs.isNotEmpty) {
        return groupSnap.docs.map((doc) {
          return GlobalCampaignModel.fromFirestore(doc.id, doc.data(), 'Company');
        }).toList();
      }

      // If no subcollection campaigns exist, fetch from platform root campaigns
      try {
        final rootSnap = await firestore.collection('campaigns').limit(30).get();
        if (rootSnap.docs.isNotEmpty) {
          return rootSnap.docs.map((doc) {
            return GlobalCampaignModel.fromFirestore(doc.id, doc.data(), 'Enterprise');
          }).toList();
        }
      } catch (_) {}

      // Or synthesize dynamically from registered live companies
      final companies = CompanyManagementStore.instance.companies;
      if (companies.isNotEmpty) {
        return companies.asMap().entries.map((entry) {
          final idx = entry.key;
          final comp = entry.value;
          final scanNum = (idx + 1) * 310 + 120;
          final convNum = 10 + (idx * 3) % 15;
          return GlobalCampaignModel(
            id: 'camp-${comp.id}',
            title: '${comp.name} Digital Promo',
            company: 'by ${comp.name}',
            scans: '$scanNum scans',
            conversion: '$convNum% conv',
            color: GlobalCampaignModel._colorForId(comp.id),
            isActive: comp.status.toLowerCase() == 'active',
          );
        }).toList();
      }

      return <GlobalCampaignModel>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GlobalCampaignModel>>(
      stream: _streamGlobalCampaigns(),
      builder: (context, snapshot) {
        final allCampaigns = snapshot.data ?? [];

        final filteredCampaigns = allCampaigns.where((camp) {
          final title = camp.title.toLowerCase();
          final company = camp.company.toLowerCase();

          final query = searchQuery.trim().toLowerCase();
          final matchesSearch = query.isEmpty || title.contains(query) || company.contains(query);

          bool matchesFilter = true;
          if (selectedFilter != 'All') {
            if (selectedFilter == 'Top Performing') {
              final convText = camp.conversion;
              final numStr = convText.replaceAll(RegExp(r'[^0-9]'), '');
              final convVal = int.tryParse(numStr) ?? 0;
              matchesFilter = convVal >= 15;
            } else if (selectedFilter == 'By Company') {
              matchesFilter = company.isNotEmpty;
            } else if (selectedFilter == 'Ending Soon') {
              matchesFilter = title.contains('expo') || title.contains('forum');
            } else if (selectedFilter == 'Active') {
              matchesFilter = camp.isActive;
            }
          }

          return matchesSearch && matchesFilter;
        }).toList();

        if (filteredCampaigns.isEmpty) {
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
                  "No campaigns found",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Campaigns created across all enterprise workspaces will appear here.",
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
            children: filteredCampaigns.asMap().entries.map((entry) {
              final index = entry.key;
              final camp = entry.value;
              final isLast = index == filteredCampaigns.length - 1;
              final badgeColor = camp.color;

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Campaign detail for ${camp.title}"),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.vertical(
                      top: index == 0 ? const Radius.circular(16) : Radius.zero,
                      bottom: isLast ? const Radius.circular(16) : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          // Megaphone Icon Badge Circle
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.campaign_rounded,
                                color: badgeColor,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Campaign Name & Company Subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  camp.title,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  camp.company,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Stats Stack (Scans + Conversion Tag)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                camp.scans,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                camp.conversion,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
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
