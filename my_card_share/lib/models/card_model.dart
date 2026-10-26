class CardModel {
  final String id;
  final String name;
  final String title;
  final String company;
  final String email;
  final String phone;
  final String? avatarUrl;

  const CardModel({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.email,
    required this.phone,
    this.avatarUrl,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawPfp = json['avatarUrl'] ??
        json['photoURL'] ??
        json['picture'] ??
        json['profilePhoto'] ??
        json['profileImage'] ??
        json['photoUrl'];
    final String? pfp = (rawPfp != null && rawPfp.toString().trim().isNotEmpty)
        ? rawPfp.toString().trim()
        : null;

    return CardModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['fullName'] ?? '',
      title: json['title'] as String? ?? json['jobTitle'] ?? '',
      company: json['company'] as String? ?? json['companyName'] ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phoneNumber'] ?? '',
      avatarUrl: pfp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'company': company,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
      };
}

class UserProfileModel {
  final String uid;
  final String fullName;
  final String email;
  final String? avatarUrl; // 👈 PFP
  final String? jobTitle;
  final String? company;

  UserProfileModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.jobTitle,
    this.company,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // ⚡ FIX: Google picture, photoURL, aur avatarUrl teeno fallback check
    final dynamic rawPfp = json['avatarUrl'] ??
        json['photoURL'] ??
        json['picture'] ??
        json['profilePhoto'] ??
        json['profileImage'] ??
        json['photoUrl'];
    final String? pfp = (rawPfp != null && rawPfp.toString().trim().isNotEmpty)
        ? rawPfp.toString().trim()
        : null;

    return UserProfileModel(
      uid: json['uid'] ?? '',
      fullName: json['fullName'] ?? json['displayName'] ?? json['name'] ?? 'User',
      email: json['email'] ?? '',
      avatarUrl: pfp,
      jobTitle: json['jobTitle'] ?? json['role'] ?? 'Member',
      company: json['company'] ?? json['companyName'] ?? 'MyCardShare Member',
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'avatarUrl': avatarUrl,
        'jobTitle': jobTitle,
        'company': company,
      };
}
