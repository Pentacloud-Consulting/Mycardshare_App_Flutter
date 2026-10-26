import '../../master_individuals_service.dart';

class MasterIndividualModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String plan; // 'Free', 'Pro', 'Deactivated'
  final String status; // 'ACTIVE', 'DEACTIVATED', 'DELETION_PENDING'
  final String cardSlug;
  final int views;
  final bool isDeactivated;
  final String? deletionReason;
  final Map<String, dynamic>? deletionRequest;
  final DateTime? createdAt;

  const MasterIndividualModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarUrl,
    required this.plan,
    this.status = 'ACTIVE',
    required this.cardSlug,
    this.views = 0,
    this.isDeactivated = false,
    this.deletionReason,
    this.deletionRequest,
    this.createdAt,
  });

  String get initials {
    final clean = name.trim();
    if (clean.isEmpty) return 'U';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory MasterIndividualModel.fromMap(String id, Map<String, dynamic> data) {
    final rawStatus = (data['status'] ?? '').toString().toUpperCase();
    final isDeletionPending = rawStatus == 'DELETION_PENDING' || data['deletion_pending'] == true;
    final isDeact = (data['isDeactivated'] as bool?) == true ||
        rawStatus == 'SUSPENDED' ||
        rawStatus == 'DEACTIVATED' ||
        isDeletionPending;
    final p = data['plan'] as String? ?? 'Pro';

    return MasterIndividualModel(
      id: id,
      name: data['fullName'] ?? data['name'] ?? data['email']?.toString().split('@').first ?? 'Individual User',
      email: data['email'] ?? '',
      phone: data['phoneNumber'] ?? data['phone'] ?? '',
      avatarUrl: data['profilePhoto'] ?? data['avatarUrl'],
      plan: isDeact ? 'Deactivated' : (p.isEmpty ? 'Pro' : p),
      status: isDeletionPending ? 'DELETION_PENDING' : (isDeact ? 'DEACTIVATED' : 'ACTIVE'),
      cardSlug: data['cardSlug'] ?? data['slug'] ?? id,
      views: (data['views'] as num?)?.toInt() ?? 0,
      isDeactivated: isDeact,
      deletionReason: data['deletionReason'] ?? data['reason'],
      deletionRequest: data['deletionRequest'],
    );
  }

  factory MasterIndividualModel.fromIndividualUserModel(IndividualUserModel u) {
    final isDeact = u.status == 'DEACTIVATED' || u.status == 'DELETION_PENDING';
    final reason = u.deletionRequest != null ? u.deletionRequest!['reason']?.toString() : null;

    return MasterIndividualModel(
      id: u.userId,
      name: u.fullName,
      email: u.email,
      phone: u.phone,
      avatarUrl: u.avatarUrl,
      plan: isDeact ? 'Deactivated' : u.plan,
      status: u.status,
      cardSlug: u.cardSlug,
      views: 0,
      isDeactivated: isDeact,
      deletionReason: reason,
      deletionRequest: u.deletionRequest,
    );
  }
}
