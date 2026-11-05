import 'package:flutter/material.dart';
import '../campaigns/campaign.dart' as ind_campaign;

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ind_campaign.IndividualCampaignScreen();
  }
}
