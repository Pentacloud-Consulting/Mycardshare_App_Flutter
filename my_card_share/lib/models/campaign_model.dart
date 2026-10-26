class CampaignModel {
  final String id;
  final String name; // 👈 Real user label
  final int scans;
  final int leadsWon;
  final String qrCodeUrl;
  final String status;
  final String targetUrl;

  CampaignModel({
    required this.id,
    required this.name,
    required this.scans,
    required this.leadsWon,
    required this.qrCodeUrl,
    required this.status,
    required this.targetUrl,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json, [int index = 0]) {
    // ⚡ FIX: Check all possible keys before falling back to index
    final String resolvedName = (json['name'] ?? 
                                json['title'] ?? 
                                json['label'] ?? 
                                json['campaignName'] ?? 
                                'Campaign ${index + 1}').toString();
    return CampaignModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: resolvedName,
      scans: (json['scans'] ?? json['totalScans'] ?? json['views'] ?? 0) is num
          ? (json['scans'] ?? json['totalScans'] ?? json['views'] ?? 0).toInt()
          : int.tryParse(json['scans']?.toString() ?? '0') ?? 0,
      leadsWon: (json['leadsWon'] ?? json['leads'] ?? json['leadsCount'] ?? 0) is num
          ? (json['leadsWon'] ?? json['leads'] ?? json['leadsCount'] ?? 0).toInt()
          : int.tryParse(json['leadsWon']?.toString() ?? '0') ?? 0,
      qrCodeUrl: (json['qrCodeUrl'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      targetUrl: (json['targetUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': name,
      'label': name,
      'campaignName': name,
      'scans': scans,
      'leadsWon': leadsWon,
      'leads': leadsWon,
      'qrCodeUrl': qrCodeUrl,
      'status': status,
      'targetUrl': targetUrl,
    };
  }
}
