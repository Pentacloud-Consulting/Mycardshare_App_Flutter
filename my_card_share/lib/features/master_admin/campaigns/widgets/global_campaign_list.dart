import 'package:flutter/material.dart';

class GlobalCampaignList extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;

  const GlobalCampaignList({
    super.key,
    this.searchQuery = "",
    this.selectedFilter = "All",
  });

  @override
  Widget build(BuildContext context) {
    final allCampaigns = [
      {
        'id': 'camp-1',
        'title': 'Web Summit 2026 Promo',
        'company': 'by Acme Realty Group',
        'scans': '432 scans',
        'conversion': '12% conv',
        'color': const Color(0xFF0052FF),
      },
      {
        'id': 'camp-2',
        'title': 'TechCrunch Disrupt QR Launch',
        'company': 'by TechFlow Solutions',
        'scans': '840 scans',
        'conversion': '18% conv',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'id': 'camp-3',
        'title': 'Q3 Regional Real Estate Expo',
        'company': 'by Skyline Brokers',
        'scans': '312 scans',
        'conversion': '9% conv',
        'color': const Color(0xFFEC4899),
      },
      {
        'id': 'camp-4',
        'title': 'Global Partner Summit Campaign',
        'company': 'by Apex Logistics Ltd',
        'scans': '1,250 scans',
        'conversion': '22% conv',
        'color': const Color(0xFF0D9488),
      },
      {
        'id': 'camp-5',
        'title': 'BioTech Innovation Forum',
        'company': 'by Horizon BioTech',
        'scans': '195 scans',
        'conversion': '15% conv',
        'color': const Color(0xFFD97706),
      },
      {
        'id': 'camp-6',
        'title': 'Autumn Venture Showcase',
        'company': 'by Crestview Capital',
        'scans': '620 scans',
        'conversion': '14% conv',
        'color': const Color(0xFF2563EB),
      },
    ];

    final filteredCampaigns = allCampaigns.where((camp) {
      final title = (camp['title'] as String).toLowerCase();
      final company = (camp['company'] as String).toLowerCase();

      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty || title.contains(query) || company.contains(query);

      bool matchesFilter = true;
      if (selectedFilter != 'All') {
        if (selectedFilter == 'Top Performing') {
          final convText = camp['conversion'] as String;
          final numStr = convText.replaceAll(RegExp(r'[^0-9]'), '');
          final convVal = int.tryParse(numStr) ?? 0;
          matchesFilter = convVal >= 15;
        } else if (selectedFilter == 'By Company') {
          matchesFilter = company.isNotEmpty;
        } else if (selectedFilter == 'Ending Soon') {
          matchesFilter = title.contains('Expo') || title.contains('Forum');
        } else if (selectedFilter == 'Active') {
          matchesFilter = true;
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
              "No campaigns match criteria",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Try changing search terms or filter selection.",
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
          final badgeColor = camp['color'] as Color;

          return Column(
            children: [
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Campaign detail for ${camp['title']}"),
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
                              camp['title'] as String,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              camp['company'] as String,
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
                            camp['scans'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            camp['conversion'] as String,
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
  }
}
