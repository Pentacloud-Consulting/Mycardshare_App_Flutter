import 'package:flutter/material.dart';

class CampaignSummaryCard extends StatelessWidget {
  final int activeCampaignsCount;
  final String totalScansCount;

  const CampaignSummaryCard({
    super.key,
    this.activeCampaignsCount = 4,
    this.totalScansCount = "1,447",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052FF).withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$activeCampaignsCount Active Campaigns",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$totalScansCount total scans this month",
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFFE0F2FE),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
