class MasterIndividualModel {
  final String id;
  final String name;
  final String email;
  final String plan; // 'Free', 'Pro', 'Deactivated'
  final String cardSlug;
  final int views;
  final bool isDeactivated;
  final DateTime? createdAt;

  const MasterIndividualModel({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
    required this.cardSlug,
    this.views = 0,
    this.isDeactivated = false,
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
    final isDeact = (data['isDeactivated'] as bool?) == true || (data['status'] == 'Suspended');
    final p = data['plan'] as String? ?? 'Pro';
    return MasterIndividualModel(
      id: id,
      name: data['fullName'] ?? data['name'] ?? data['email']?.toString().split('@').first ?? 'Individual User',
      email: data['email'] ?? '',
      plan: isDeact ? 'Deactivated' : (p.isEmpty ? 'Pro' : p),
      cardSlug: data['cardSlug'] ?? data['slug'] ?? id,
      views: (data['views'] as num?)?.toInt() ?? 0,
      isDeactivated: isDeact,
    );
  }
}
