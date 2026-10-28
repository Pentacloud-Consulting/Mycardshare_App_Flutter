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

    final rawPlan = (data['plan'] ?? data['subscriptionPlan'] ?? data['tier'] ?? '').toString().trim();
    final isUserPro = data['isPro'] == true ||
        data['isPremium'] == true ||
        rawPlan.toLowerCase() == 'pro' ||
        rawPlan.toLowerCase() == 'premium';

    final resolvedPlan = isDeact
        ? 'Deactivated'
        : (isUserPro
            ? 'Pro'
            : (rawPlan.isNotEmpty && rawPlan.toLowerCase() != 'pro' ? rawPlan : 'Free'));

    final rawEmail = (data['email'] ??
            data['userEmail'] ??
            data['emailAddress'] ??
            data['mail'] ??
            (id.contains('@') ? id : ''))
        .toString()
        .trim();
    final resolvedPhone = (data['phoneNumber'] ??
            data['phone'] ??
            data['mobile'] ??
            data['contactNumber'] ??
            '')
        .toString()
        .trim();
    final resolvedEmail = rawEmail.isNotEmpty
        ? rawEmail
        : (resolvedPhone.isNotEmpty ? '$resolvedPhone@user.phone' : '$id@mycardshare.internal');
    final resolvedName = (data['fullName'] ??
            data['name'] ??
            data['displayName'] ??
            data['userName'] ??
            (rawEmail.contains('@')
                ? rawEmail.split('@').first
                : (resolvedPhone.isNotEmpty ? resolvedPhone : 'Individual User')))
        .toString()
        .trim();
    final resolvedAvatar = data['profilePhoto'] ??
        data['avatarUrl'] ??
        data['photoUrl'] ??
        data['photoURL'] ??
        data['picture'];

    return MasterIndividualModel(
      id: id,
      name: resolvedName,
      email: resolvedEmail,
      phone: resolvedPhone,
      avatarUrl: resolvedAvatar,
      plan: resolvedPlan,
      status: isDeletionPending ? 'DELETION_PENDING' : (isDeact ? 'DEACTIVATED' : 'ACTIVE'),
      cardSlug: data['cardSlug'] ?? data['slug'] ?? id,
      views: (data['views'] as num?)?.toInt() ?? (data['cardViews'] as num?)?.toInt() ?? 0,
      isDeactivated: isDeact,
      deletionReason: data['deletionReason'] ?? data['reason'],
      deletionRequest: data['deletionRequest'],
    );
  }

  factory MasterIndividualModel.fromIndividualUserModel(IndividualUserModel u) {
    final isDeact = u.status == 'DEACTIVATED' || u.status == 'DELETION_PENDING';
    final reason = u.deletionRequest != null ? u.deletionRequest!['reason']?.toString() : null;
    final resolvedPlan = isDeact
        ? 'Deactivated'
        : (u.isPro ? 'Pro' : (u.plan.toLowerCase() == 'pro' ? 'Pro' : 'Free'));

    return MasterIndividualModel(
      id: u.userId,
      name: u.fullName,
      email: u.email,
      phone: u.phone,
      avatarUrl: u.avatarUrl,
      plan: resolvedPlan,
      status: u.status,
      cardSlug: u.cardSlug,
      views: u.views,
      isDeactivated: isDeact,
      deletionReason: reason,
      deletionRequest: u.deletionRequest,
    );
  }
}
