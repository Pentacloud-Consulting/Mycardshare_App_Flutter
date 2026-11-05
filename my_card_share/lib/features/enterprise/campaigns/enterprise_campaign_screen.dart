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
    final descController = TextEditingController();
    final areaController = TextEditingController();
    final budgetController = TextEditingController();
    final daysController = TextEditingController(text: "14");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Create New Campaign 📢",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Launch a dynamic QR marketing campaign for your workspace to track scans, leads, and ROI.",
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Campaign Name *",
                  hintText: "e.g. GITEX Dubai 2026",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: areaController,
                decoration: InputDecoration(
                  labelText: "Target Area / Emirate",
                  hintText: "e.g. Downtown Dubai / Abu Dhabi",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: budgetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Budget (AED)",
                        hintText: "e.g. 5000",
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
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
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Description / Objective",
                  hintText: "Campaign notes or goal...",
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

              final budget = double.tryParse(budgetController.text.trim());
              final durationDays = int.tryParse(daysController.text.trim()) ?? 14;

              final res = await UnifiedCampaignService.createCampaign(
                isEnterprise: true,
                name: name,
                description: descController.text.trim(),
                area: areaController.text.trim(),
                budget: budget,
                durationDays: durationDays,
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
    final title = (campaign["title"] ?? campaign["name"] ?? "Campaign").toString();
    final status = (campaign["status"] ?? "Active").toString();
    final scans = campaign["scans"] ?? 0;
    final conv = campaign["conv"] ?? "0%";
    final leads = campaign["leads"] ?? campaign["leadsWon"] ?? 0;
    final area = campaign["area"]?.toString() ?? "";
    final budget = campaign["budget"]?.toString() ?? "";
    final desc = campaign["description"]?.toString() ?? "";
    final campId = campaign["id"]?.toString() ?? "";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.toLowerCase() == "active" ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: status.toLowerCase() == "active" ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              if (desc.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailMetric("Total Scans", "$scans", Icons.qr_code_2_rounded),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDetailMetric("Leads Won", "$leads", Icons.people_outline_rounded),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDetailMetric("Conversion", "$conv", Icons.trending_up_rounded),
                  ),
                ],
              ),
              if (area.isNotEmpty || budget.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      if (area.isNotEmpty) ...[
                        const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(area, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                      ],
                      if (area.isNotEmpty && budget.isNotEmpty) const Spacer(),
                      if (budget.isNotEmpty) ...[
                        const Icon(Icons.account_balance_wallet_outlined, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text("AED $budget", style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0052FF))),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        if (campId.isNotEmpty) {
                          await UnifiedCampaignService.toggleCampaignStatus(
                            isEnterprise: true,
                            campaignId: campId,
                            currentStatus: status,
                          );
                          _loadCampaignData();
                        }
                      },
                      icon: Icon(
                        status.toLowerCase() == "active" ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                        size: 18,
                      ),
                      label: Text(status.toLowerCase() == "active" ? "End Campaign" : "Activate"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        if (campId.isNotEmpty) {
                          await UnifiedCampaignService.deleteCampaign(
                            isEnterprise: true,
                            campaignId: campId,
                          );
                          _loadCampaignData();
                        }
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text("Delete"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0052FF)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)), textAlign: TextAlign.center),
        ],
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


