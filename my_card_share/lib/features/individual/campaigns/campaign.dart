import 'package:flutter/material.dart';
import '../../../backend/campaign/unified_campaign_service.dart';

class IndividualCampaignScreen extends StatefulWidget {
  const IndividualCampaignScreen({super.key});

  @override
  State<IndividualCampaignScreen> createState() => _IndividualCampaignScreenState();
}

class _IndividualCampaignScreenState extends State<IndividualCampaignScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _summary = {};
  List<dynamic> _campaigns = [];

  @override
  void initState() {
    super.initState();
    _loadCampaignData();
  }

  Future<void> _loadCampaignData() async {
    setState(() => _isLoading = true);
    final data = await UnifiedCampaignService.fetchCampaigns(isEnterprise: false);

    if (mounted) {
      setState(() {
        _summary = data['summary'] is Map<String, dynamic> ? data['summary'] : {};
        _campaigns = data['campaigns'] is List ? List.from(data['campaigns']) : [];
        _isLoading = false;
      });
    }
  }

  void _openCreateCampaignDialog() {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Create QR Campaign",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Track scans, leads, and conversion rates from physical print, events, or social banners.",
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Campaign Name (e.g. Dubai Expo Flyer)",
                hintText: "Enter campaign title",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final n = nameCtrl.text.trim();
              if (n.isNotEmpty) {
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Creating marketing campaign... ⏳"),
                    duration: Duration(milliseconds: 1500),
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                final res = await UnifiedCampaignService.createCampaign(
                  isEnterprise: false,
                  name: n,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  if (res["success"] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Campaign '$n' created successfully!"),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    _loadCampaignData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res["error"] ?? "Failed to create campaign"),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text("Create Campaign", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalScans = _summary['totalScans'] ?? (_campaigns.fold<int>(0, (acc, c) => acc + ((c['scans'] as num?)?.toInt() ?? 0)));
    final totalLeads = _summary['totalLeads'] ?? (_campaigns.fold<int>(0, (acc, c) => acc + ((c['leads'] as num?)?.toInt() ?? 0)));
    final activeCount = _campaigns.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateCampaignDialog,
        backgroundColor: const Color(0xFF0052FF),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Create Campaign", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCampaignData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Metric Summary Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      label: "Active Campaigns",
                      value: "$activeCount",
                      icon: Icons.campaign_rounded,
                      color: const Color(0xFF0052FF),
                      bg: const Color(0xFFEFF6FF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      label: "Total Scans",
                      value: "$totalScans",
                      icon: Icons.qr_code_scanner_rounded,
                      color: const Color(0xFF10B981),
                      bg: const Color(0xFFECFDF5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      label: "Leads Won",
                      value: "$totalLeads",
                      icon: Icons.person_add_alt_1_rounded,
                      color: const Color(0xFF8B5CF6),
                      bg: const Color(0xFFF5F3FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                "ACTIVE CAMPAIGNS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_campaigns.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.campaign_outlined, size: 36, color: Color(0xFF0052FF)),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "No Campaigns Created Yet",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Generate trackable QR codes for your flyers, business events, or brochures to measure scans and leads.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0052FF),
                          side: const BorderSide(color: Color(0xFF0052FF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _openCreateCampaignDialog,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text("Launch Your First Campaign"),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _campaigns.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final camp = _campaigns[index];
                    final name = camp['name'] ?? 'Campaign ${index + 1}';
                    final scans = camp['scans'] ?? 0;
                    final leads = camp['leads'] ?? 0;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF0052FF), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Trackable Link · High-Res QR Ready",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "$scans Scans",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "$leads Leads",
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF10B981)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
