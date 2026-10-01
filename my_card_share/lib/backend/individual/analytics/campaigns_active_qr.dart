import '../previews/individual_metrics_store.dart';

class CampaignsActiveQrData {
  final int activeCampaignsCount;
  final int totalQrScans;
  final String topPerformingCampaign;

  const CampaignsActiveQrData({
    required this.activeCampaignsCount,
    required this.totalQrScans,
    required this.topPerformingCampaign,
  });
}

class CampaignsActiveQrService {
  CampaignsActiveQrService._internal();
  static final CampaignsActiveQrService instance = CampaignsActiveQrService._internal();

  CampaignsActiveQrData getActiveQrData() {
    final scans = IndividualMetricsStore.instance.metrics.scans;
    return CampaignsActiveQrData(
      activeCampaignsCount: scans > 0 ? 1 : 0,
      totalQrScans: scans,
      topPerformingCampaign: scans > 0 ? "Direct QR Share" : "None",
    );
  }
}
