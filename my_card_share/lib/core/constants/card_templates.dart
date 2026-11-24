import 'package:flutter/material.dart';

class CardTemplateModel {
  final int id;
  final String name;
  final String category;
  final List<Color> gradient;
  final bool isLight;

  const CardTemplateModel({
    required this.id,
    required this.name,
    required this.category,
    required this.gradient,
    this.isLight = false,
  });
}

class CardTemplates {
  CardTemplates._();

  static const List<CardTemplateModel> all = [
    CardTemplateModel(
      id: 0,
      name: 'Matte Orange (Brand)',
      category: 'Brand',
      gradient: [Color(0xFFD4642C), Color(0xFFE8824E)],
    ),
    CardTemplateModel(
      id: 1,
      name: 'Cyber Purple',
      category: 'Vibrant',
      gradient: [Color(0xFF833AB4), Color(0xFFC13584)],
    ),
    CardTemplateModel(
      id: 2,
      name: 'Emerald Jade',
      category: 'Modern',
      gradient: [Color(0xFF0D9488), Color(0xFF2DD4BF)],
    ),
    CardTemplateModel(
      id: 3,
      name: 'Midnight Dark',
      category: 'Executive',
      gradient: [Color(0xFF0F172A), Color(0xFF334155)],
    ),
    CardTemplateModel(
      id: 4,
      name: 'Frost Pearl',
      category: 'Minimal',
      gradient: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
      isLight: true,
    ),
    CardTemplateModel(
      id: 5,
      name: 'Royal Blue',
      category: 'Executive',
      gradient: [Color(0xFF0052FF), Color(0xFF38BDF8)],
    ),
    CardTemplateModel(
      id: 6,
      name: 'Warm Gold',
      category: 'Luxe',
      gradient: [Color(0xFFD97706), Color(0xFFFBBF24)],
    ),
    CardTemplateModel(
      id: 7,
      name: 'Sunset Terracotta',
      category: 'Brand',
      gradient: [Color(0xFFEA580C), Color(0xFFF97316)],
    ),
    CardTemplateModel(
      id: 8,
      name: 'Crimson Rose',
      category: 'Vibrant',
      gradient: [Color(0xFFE11D48), Color(0xFFFB7185)],
    ),
    CardTemplateModel(
      id: 9,
      name: 'Ocean Breeze',
      category: 'Modern',
      gradient: [Color(0xFF0284C7), Color(0xFF06B6D4)],
    ),
    CardTemplateModel(
      id: 10,
      name: 'Forest Emerald',
      category: 'Nature',
      gradient: [Color(0xFF15803D), Color(0xFF4ADE80)],
    ),
    CardTemplateModel(
      id: 11,
      name: 'Minimal Slate',
      category: 'Minimal',
      gradient: [Color(0xFF475569), Color(0xFF94A3B8)],
    ),
  ];

  static List<List<Color>> get initialSwatches => all.take(5).map((t) => t.gradient).toList();

  static CardTemplateModel getTemplate(int index) {
    if (index >= 0 && index < all.length) {
      return all[index];
    }
    return all[0];
  }

  static List<Color> getGradient(int index) {
    if (index >= 0 && index < all.length) {
      return all[index].gradient;
    }
    return all[0].gradient;
  }

  static bool isLight(int index) {
    if (index >= 0 && index < all.length) {
      return all[index].isLight;
    }
    return false;
  }
}
