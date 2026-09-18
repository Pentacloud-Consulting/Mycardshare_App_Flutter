import 'card_model.dart';

class VaultModel {
  final String id;
  final List<CardModel> savedCards;

  const VaultModel({
    required this.id,
    required this.savedCards,
  });

  factory VaultModel.fromJson(Map<String, dynamic> json) {
    return VaultModel(
      id: json['id'] as String? ?? '',
      savedCards: (json['savedCards'] as List<dynamic>?)
              ?.map((e) => CardModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'savedCards': savedCards.map((c) => c.toJson()).toList(),
      };
}
