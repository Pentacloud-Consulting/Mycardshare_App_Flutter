import 'package:flutter/material.dart';

import 'widgets/campaign_summary_card.dart';
import 'widgets/campaign_filter_chips.dart';
import 'widgets/campaign_grid_cards.dart';

import '../../../backend/campaign/unified_campaign_service.dart';

class EnterpriseCampaignsScreen extends StatefulWidget {
  const EnterpriseCampaignsScreen({super.key});

  @override
  State<EnterpriseCampaignsScreen> createState() => _EnterpriseCampaignsScreenState();
}

class _EnterpriseCampaignsScreenState extends State<EnterpriseCampaignsScreen> {
  String _selectedFilter = "All";
  bool _isLoading = false;
  int _activeCampaignsCount = 0;
  String _totalScansThisMonth = "0";
  List<Map<String, dynamic>> _campaignList = [];

  @override
  void initState() {
    super.initState();
    _loadCampaignData();
  }

  Future<void> _loadCampaignData() async {
    setState(() => _isLoading = true);
    final data = await UnifiedCampaignService.fetchCampaigns(
      isEnterprise: true,
      status: _selectedFilter.toLowerCase(),
    );

    if (mounted) {
      setState(() {
        final summary = data["summary"] is Map<String, dynamic> ? data["summary"] : {};
        _activeCampaignsCount = summary["activeCampaignsCount"] is int
            ? summary["activeCampaignsCount"]
            : int.tryParse(summary["activeCampaignsCount"]?.toString() ?? "0") ?? 0;
        _totalScansThisMonth = summary["totalScansThisMonth"]?.toString() ?? "0";
        _campaignList = data["campaigns"] is List
            ? List<Map<String, dynamic>>.from(data["campaigns"])
            : [];
        _isLoading = false;
      });
    }
  }

  void _handleNewCampaign() {
    _showCreateCampaignDialog(context);
  }

  void _showCreateCampaignDialog(BuildContext context) {
    final nameController = TextEditingController();
    final daysController = TextEditingController(text: "14");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Create New Campaign 📢",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Launch a dynamic QR campaign for your workspace to track scans and lead conversions.",
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Campaign Name",
                hintText: "e.g. GITEX Dubai 2026",
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Duration (Days)",
                hintText: "14",
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Text("Creating marketing campaign... ⏳"),
                    ],
                  ),
                  duration: Duration(milliseconds: 1500),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              final res = await UnifiedCampaignService.createCampaign(
                isEnterprise: true,
                name: name,
                durationDays: int.tryParse(daysController.text.trim()) ?? 14,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                if (res["success"] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF16A34A),
                      behavior: SnackBarBehavior.floating,
                      content: Text("🎉 Campaign '$name' created successfully!"),
                    ),
                  );
                  _loadCampaignData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFFDC2626),
                      behavior: SnackBarBehavior.floating,
                      content: Text(res["error"] ?? "Failed to create campaign"),
                    ),
                  );
                }
              }
            },
            child: const Text("Create Campaign", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleCampaignTap(Map<String, dynamic> campaign) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Campaign: ${campaign["title"]} - ${campaign["scans"]} scans (${campaign["conv"]} conversion)"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Stack(
        children: [
          // Top-Right Soft Baby-Blue Gradient Blob
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.18),
                    const Color(0xFF0052FF).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Gradient Summary Card
                  CampaignSummaryCard(
                    activeCampaignsCount: _activeCampaignsCount,
                    totalScansCount: _totalScansThisMonth,
                  ),

                  const SizedBox(height: 18),

                  // 2. Horizontal Scrollable Filter Chips (All, Active, Ended)
                  CampaignFilterChips(
                    selectedFilter: _selectedFilter,
                    onSelected: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      _loadCampaignData();
                    },
                  ),

                  const SizedBox(height: 18),

                  // 3. 2-Column Grid of Campaign Cards + Dashed New Campaign Card
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    CampaignGridCards(
                      selectedFilter: _selectedFilter,
                      campaigns: _campaignList,
                      onNewCampaignTap: _handleNewCampaign,
                      onCampaignTap: _handleCampaignTap,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


