import 'package:flutter/material.dart';

class ProfileTemplateSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectTemplate;

  const ProfileTemplateSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelectTemplate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Template",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All templates opened")),
                );
              },
              child: const Text(
                "See All",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0066FF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTemplateTile(
                index: 0,
                colors: [const Color(0xFF0052FF), const Color(0xFF38BDF8)],
              ),
              const SizedBox(width: 10),
              _buildTemplateTile(
                index: 1,
                colors: [const Color(0xFF833AB4), const Color(0xFFC13584)],
              ),
              const SizedBox(width: 10),
              _buildTemplateTile(
                index: 2,
                colors: [const Color(0xFF0D9488), const Color(0xFF2DD4BF)],
              ),
              const SizedBox(width: 10),
              _buildTemplateTile(
                index: 3,
                colors: [const Color(0xFF0F172A), const Color(0xFF334155)],
              ),
              const SizedBox(width: 10),
              _buildTemplateTile(
                index: 4,
                colors: [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
                isLight: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateTile({
    required int index,
    required List<Color> colors,
    bool isLight = false,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onSelectTemplate(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0052FF)
                : isLight
                    ? const Color(0xFFCBD5E1)
                    : Colors.transparent,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0x300052FF) : const Color(0x08000000),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0052FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
