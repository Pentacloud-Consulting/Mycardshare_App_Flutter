class CardModel {
  final String id;
  final String name;
  final String title;
  final String company;
  final String email;
  final String phone;

  const CardModel({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.email,
    required this.phone,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'company': company,
        'email': email,
        'phone': phone,
      };
}
