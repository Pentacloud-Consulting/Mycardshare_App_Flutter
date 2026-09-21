import 'package:flutter/material.dart';

import 'widgets/campaign_summary_card.dart';
import 'widgets/campaign_filter_chips.dart';
import 'widgets/campaign_grid_cards.dart';

class EnterpriseCampaignsScreen extends StatefulWidget {
  const EnterpriseCampaignsScreen({super.key});

  @override
  State<EnterpriseCampaignsScreen> createState() => _EnterpriseCampaignsScreenState();
}

class _EnterpriseCampaignsScreenState extends State<EnterpriseCampaignsScreen> {
  String _selectedFilter = "All";

  void _handleNewCampaign() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Creating new marketing campaign..."),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleCampaignTap(Map<String, dynamic> campaign) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Opened analytics for ${campaign["title"]}"),
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
                  const CampaignSummaryCard(
                    activeCampaignsCount: 4,
                    totalScansCount: "1,447",
                  ),

                  const SizedBox(height: 18),

                  // 2. Horizontal Scrollable Filter Chips (All, Active, Ended)
                  CampaignFilterChips(
                    selectedFilter: _selectedFilter,
                    onSelected: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  // 3. 2-Column Grid of Campaign Cards + Dashed New Campaign Card
                  CampaignGridCards(
                    selectedFilter: _selectedFilter,
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
