class CompanyModel {
  final String id;
  final String name;
  final String domain;
  final int totalEmployees;

  const CompanyModel({
    required this.id,
    required this.name,
    required this.domain,
    required this.totalEmployees,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      totalEmployees: json['totalEmployees'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'domain': domain,
        'totalEmployees': totalEmployees,
      };
}
