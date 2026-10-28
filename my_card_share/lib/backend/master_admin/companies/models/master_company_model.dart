class MasterCompanyModel {
  final String id;
  final String name;
  final String email;
  final String plan;
  final int employeeCount;
  final String status; // 'Active', 'Pending', 'Suspended'
  final String? domain;
  final String? logoUrl;
  final DateTime? createdAt;

  const MasterCompanyModel({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
    required this.employeeCount,
    required this.status,
    this.domain,
    this.logoUrl,
    this.createdAt,
  });

  String get initials {
    final clean = name.trim();
    if (clean.isEmpty) return 'CO';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory MasterCompanyModel.fromMap(String id, Map<String, dynamic> data) {
    final approvalStatus = (data['approvalStatus'] as String? ?? '').toLowerCase().trim();
    final statusStr = (data['status'] as String? ?? '').toLowerCase().trim();
    final isSuspended = data['isSuspended'] == true || statusStr == 'suspended' || approvalStatus == 'rejected';

    String resolvedStatus = 'Active';
    if (isSuspended) {
      resolvedStatus = 'Suspended';
    } else if (approvalStatus == 'approved' || statusStr == 'active') {
      resolvedStatus = 'Active';
    } else if (approvalStatus == 'pending' || statusStr == 'pending') {
      resolvedStatus = 'Pending';
    }

    final rawDomain = (data['domain'] ??
            data['customDomain'] ??
            data['website'] ??
            data['websiteUrl'] ??
            '')
        .toString()
        .trim();
    final rawLogo = data['logoUrl'] ??
        data['companyLogo'] ??
        data['logo'] ??
        data['avatarUrl'] ??
        data['profilePhoto'] ??
        data['photoUrl'] ??
        data['photoURL'] ??
        data['brandLogo'] ??
        data['imageUrl'] ??
        data['image'] ??
        data['icon'];
    final resolvedLogo = (rawLogo is String && rawLogo.trim().isNotEmpty) ? rawLogo.trim() : null;

    return MasterCompanyModel(
      id: id,
      name: data['companyName'] ?? data['name'] ?? 'Enterprise Company',
      email: data['email'] ?? data['adminEmail'] ?? '',
      plan: data['planName'] ?? data['plan'] ?? 'Enterprise Pro',
      employeeCount: (data['employeeCount'] as num?)?.toInt() ?? 
                     (data['employeeLimit'] is int ? data['employeeLimit'] : 0),
      status: resolvedStatus,
      domain: rawDomain.isNotEmpty ? rawDomain : '${id.toLowerCase()}.mycardshare.com',
      logoUrl: resolvedLogo,
    );
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
