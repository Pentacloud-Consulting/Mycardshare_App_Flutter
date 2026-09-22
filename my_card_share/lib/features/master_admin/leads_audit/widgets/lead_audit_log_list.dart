import 'package:flutter/material.dart';

class LeadAuditLogList extends StatefulWidget {
  final String searchQuery;
  final String selectedFilter;

  const LeadAuditLogList({
    super.key,
    this.searchQuery = "",
    this.selectedFilter = "All",
  });

  @override
  State<LeadAuditLogList> createState() => _LeadAuditLogListState();
}

class _LeadAuditLogListState extends State<LeadAuditLogList> {
  final List<Map<String, dynamic>> _logItems = [
    {
      'id': 'log-1',
      'company': 'Acme Realty Group',
      'leadName': 'Sarah Jenkins',
      'via': 'public_card_form',
      'time': 'Sept 15, 2:30 PM',
      'status': 'Delivered',
      'isDelivered': true,
    },
    {
      'id': 'log-2',
      'company': 'TechFlow Solutions',
      'leadName': 'David Miller',
      'via': 'qr_scanner_web',
      'time': 'Sept 15, 1:45 PM',
      'status': 'Delivered',
      'isDelivered': true,
    },
    {
      'id': 'log-3',
      'company': 'Vertex Media Group',
      'leadName': 'Alex Rivera',
      'via': 'hubspot_webhook',
      'time': 'Sept 15, 12:10 PM',
      'status': 'Failed',
      'isDelivered': false,
    },
    {
      'id': 'log-4',
      'company': 'Apex Logistics Ltd',
      'leadName': 'Emily Watson',
      'via': 'public_card_form',
      'time': 'Sept 15, 11:20 AM',
      'status': 'Delivered',
      'isDelivered': true,
    },
    {
      'id': 'log-5',
      'company': 'Crestview Capital',
      'leadName': 'Michael Chang',
      'via': 'salesforce_sync',
      'time': 'Sept 15, 10:05 AM',
      'status': 'Failed',
      'isDelivered': false,
    },
    {
      'id': 'log-6',
      'company': 'Horizon BioTech',
      'leadName': 'Sophia Martinez',
      'via': 'public_card_form',
      'time': 'Sept 15, 09:15 AM',
      'status': 'Delivered',
      'isDelivered': true,
    },
  ];

  void _handleRetry(String leadName, String logId) {
    setState(() {
      final index = _logItems.indexWhere((item) => item['id'] == logId);
      if (index != -1) {
        _logItems[index]['status'] = 'Delivered';
        _logItems[index]['isDelivered'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text("Re-sending lead log for $leadName... Success!")),
          ],
        ),
        backgroundColor: const Color(0xFF0052FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _logItems.where((log) {
      final company = (log['company'] as String).toLowerCase();
      final leadName = (log['leadName'] as String).toLowerCase();
      final status = log['status'] as String;

      final query = widget.searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty || company.contains(query) || leadName.contains(query);
      
      bool matchesFilter = true;
      if (widget.selectedFilter != 'All') {
        if (widget.selectedFilter == 'Retrying') {
          matchesFilter = status == 'Retrying' || status == 'Failed';
        } else {
          matchesFilter = status.toLowerCase() == widget.selectedFilter.toLowerCase();
        }
      }

      return matchesSearch && matchesFilter;
    }).toList();

    if (filteredLogs.isEmpty) {
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
              "No lead logs match criteria",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Try changing search terms or status filter.",
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
        children: filteredLogs.asMap().entries.map((entry) {
          final index = entry.key;
          final log = entry.value;
          final isLast = index == filteredLogs.length - 1;
          final isDelivered = log['isDelivered'] as bool;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Icon (Green Check or Red Cancel)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDelivered
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF2F2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDelivered
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: isDelivered
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Log Info (Company → Lead Name, via + time)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF0F172A),
                                fontFamily: 'sans-serif',
                              ),
                              children: [
                                TextSpan(
                                  text: "${log['company']} ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const TextSpan(
                                  text: "→ ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                TextSpan(
                                  text: log['leadName'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "via ${log['via']}  ·  ${log['time']}",
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Delivery Status Pill & Retry Link
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDelivered
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDelivered
                                  ? const Color(0xFFA7F3D0)
                                  : const Color(0xFFFECACA),
                            ),
                          ),
                          child: Text(
                            log['status'] as String,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isDelivered
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                        if (!isDelivered) ...[
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _handleRetry(log['leadName'] as String, log['id'] as String),
                            child: const Text(
                              "Retry",
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0052FF),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 56,
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
