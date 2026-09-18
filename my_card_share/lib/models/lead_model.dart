class LeadModel {
  final String id;
  final String name;
  final String company;
  final String email;
  final String status;

  const LeadModel({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    required this.status,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      company: json['company'] as String? ?? '',
      email: json['email'] as String? ?? '',
      status: json['status'] as String? ?? 'new',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'company': company,
        'email': email,
        'status': status,
      };
}
