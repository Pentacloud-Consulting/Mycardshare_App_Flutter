import 'package:flutter/material.dart';

class BrandColorOption {
  final String name;
  final Color color;

  const BrandColorOption({required this.name, required this.color});
}

class BrandColorSelector extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final bool isLocked;
  final ValueChanged<bool> onLockChanged;

  static const List<BrandColorOption> defaultColors = [
    BrandColorOption(name: "Primary Blue", color: Color(0xFF0052FF)),
    BrandColorOption(name: "Purple Accent", color: Color(0xFF7C3AED)),
    BrandColorOption(name: "Teal Modern", color: Color(0xFF0D9488)),
    BrandColorOption(name: "Dark Navy", color: Color(0xFF0F172A)),
    BrandColorOption(name: "Amber Warm", color: Color(0xFFD97706)),
    BrandColorOption(name: "Rose Bold", color: Color(0xFFE11D48)),
  ];

  const BrandColorSelector({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    required this.isLocked,
    required this.onLockChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Brand Color",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Swatch Row (Compact, Clean, Smooth Ring Glow)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...defaultColors.map((item) {
                final isSelected = item.color == selectedColor;
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: GestureDetector(
                    onTap: () => onColorSelected(item.color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? item.color.withValues(alpha: 0.15)
                            : Colors.transparent,
                        border: isSelected
                            ? Border.all(color: item.color, width: 2.0)
                            : null,
                      ),
                      child: Container(
                        width: isSelected ? 28 : 32,
                        height: isSelected ? 28 : 32,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2.0)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              }),

              // Custom Color Circle with Plus Icon
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Open HEX color picker dialog..."),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Color(0xFF475569),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lock Toggle Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  "Lock brand color for all employees",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Switch.adaptive(
                value: isLocked,
                activeTrackColor: const Color(0xFF0052FF),
                onChanged: onLockChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
