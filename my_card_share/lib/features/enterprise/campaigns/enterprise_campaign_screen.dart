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
    DateTime? startDate;
    DateTime? endDate;
    String dateError = "";

    String formatDate(DateTime d) =>
        "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Title + Close (X)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Create Campaign",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 1. CAMPAIGN NAME *
                  const Text(
                    "CAMPAIGN NAME *",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 7),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: "e.g. Summer Launch",
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD4642C), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. DESCRIPTION
                  const Text(
                    "DESCRIPTION",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 7),
                  TextField(
                    controller: descController,
                    minLines: 2,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: "What is this campaign about?",
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD4642C), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Two Columns: AREA / EMIRATE & BUDGET (AED)
                  Row(
                    children: [
                      // Area / Emirate
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "AREA / EMIRATE",
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 7),
                            TextField(
                              controller: areaController,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: "Dubai",
                                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFD4642C), width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Budget (AED)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "BUDGET (AED)",
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 7),
                            TextField(
                              controller: budgetController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: "50000",
                                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFD4642C), width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 4. Two Columns: START DATE & END DATE
                  Row(
                    children: [
                      // Start Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "START DATE",
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 7),
                            InkWell(
                              onTap: () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: startDate ?? now,
                                  firstDate: DateTime(now.year - 1),
                                  lastDate: DateTime(now.year + 10),
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    startDate = picked;
                                    if (endDate != null && endDate!.isBefore(startDate!)) {
                                      dateError = "End date cannot be earlier than start date.";
                                    } else {
                                      dateError = "";
                                    }
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      startDate != null ? formatDate(startDate!) : "dd-mm-yyyy",
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: startDate != null ? FontWeight.w600 : FontWeight.w400,
                                        color: startDate != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                      color: Color(0xFF64748B),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // End Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "END DATE",
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 7),
                            InkWell(
                              onTap: () async {
                                final now = DateTime.now();
                                final initial = endDate ?? (startDate?.add(const Duration(days: 14)) ?? now.add(const Duration(days: 14)));
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: initial,
                                  firstDate: DateTime(now.year - 1),
                                  lastDate: DateTime(now.year + 10),
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    endDate = picked;
                                    if (startDate != null && endDate!.isBefore(startDate!)) {
                                      dateError = "End date cannot be earlier than start date.";
                                    } else {
                                      dateError = "";
                                    }
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      endDate != null ? formatDate(endDate!) : "dd-mm-yyyy",
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: endDate != null ? FontWeight.w600 : FontWeight.w400,
                                        color: endDate != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                      color: Color(0xFF64748B),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (dateError.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dateError,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFDC2626)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Bottom Action Buttons (Pill buttons matching Web Image 3)
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            "CANCEL",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Create Campaign Button
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8824E),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Campaign name is required.")),
                              );
                              return;
                            }
                            if (dateError.isNotEmpty) return;

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
                                    Text("Creating campaign... ⏳"),
                                  ],
                                ),
                                duration: Duration(milliseconds: 1500),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            final budget = double.tryParse(budgetController.text.trim());
                            final durationDays = (startDate != null && endDate != null)
                                ? endDate!.difference(startDate!).inDays.clamp(1, 365)
                                : 14;

                            final res = await UnifiedCampaignService.createCampaign(
                              isEnterprise: true,
                              name: name,
                              description: descController.text.trim(),
                              area: areaController.text.trim(),
                              budget: budget,
                              durationDays: durationDays,
                              startDate: startDate,
                              endDate: endDate,
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
                                    content: Text("Failed to create campaign: ${res['error'] ?? 'Unknown error'}"),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                "CREATE CAMPAIGN",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
                        Text("AED $budget", style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFD4642C))),
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
          Icon(icon, size: 18, color: const Color(0xFFD4642C)),
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
                    const Color(0xFFFED7AA).withValues(alpha: 0.35),
                    const Color(0xFFFFF7ED).withValues(alpha: 0.15),
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


