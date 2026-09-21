import 'package:flutter/material.dart';

class CardTemplateOption {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;

  const CardTemplateOption({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
  });
}

class BrandTemplateSelector extends StatelessWidget {
  final String selectedTemplateId;
  final ValueChanged<String> onTemplateSelected;

  static const List<CardTemplateOption> templates = [
    CardTemplateOption(
      id: "modern_glass",
      name: "Modern Glass",
      primaryColor: Color(0xFF0052FF),
      secondaryColor: Color(0xFF38BDF8),
      textColor: Colors.white,
    ),
    CardTemplateOption(
      id: "minimal_dark",
      name: "Minimal Dark",
      primaryColor: Color(0xFF0F172A),
      secondaryColor: Color(0xFF1E293B),
      textColor: Colors.white,
    ),
    CardTemplateOption(
      id: "corporate_clean",
      name: "Corporate Clean",
      primaryColor: Color(0xFFF8FAFC),
      secondaryColor: Color(0xFFE2E8F0),
      textColor: Color(0xFF0F172A),
    ),
    CardTemplateOption(
      id: "bold_gradient",
      name: "Bold Gradient",
      primaryColor: Color(0xFF7C3AED),
      secondaryColor: Color(0xFFEC4899),
      textColor: Colors.white,
    ),
  ];

  const BrandTemplateSelector({
    super.key,
    required this.selectedTemplateId,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Default Card Template",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = templates[index];
              final isSelected = item.id == selectedTemplateId;

              return GestureDetector(
                onTap: () => onTemplateSelected(item.id),
                child: SizedBox(
                  width: 120,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 110,
                            width: 120,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [item.primaryColor, item.secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0052FF)
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? const Color(0xFF0052FF).withValues(alpha: 0.2)
                                      : const Color(0xFF0F172A).withValues(alpha: 0.05),
                                  blurRadius: isSelected ? 12 : 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : item.textColor.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 14,
                                        color: isSelected
                                            ? item.primaryColor
                                            : item.textColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 16,
                                      color: item.textColor.withValues(alpha: 0.8),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  width: 45,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: item.textColor.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  width: 30,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: item.textColor.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0052FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF0052FF)
                              : const Color(0xFF475569),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
