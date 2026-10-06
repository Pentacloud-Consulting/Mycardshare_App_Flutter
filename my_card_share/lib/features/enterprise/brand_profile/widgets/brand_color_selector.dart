import 'package:flutter/material.dart';
import '../../../../backend/enterprise/lock_banner/custom_color_picker.dart';

class BrandColorOption {
  final String name;
  final Color color;
  const BrandColorOption({required this.name, required this.color});
}

class BrandColorSelector extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final bool isLocked;
  final ValueChanged<bool> onLockChanged;

  static const List<BrandColorOption> defaultColors = [
    BrandColorOption(name: "Primary Blue",   color: Color(0xFF0052FF)),
    BrandColorOption(name: "Purple Accent",  color: Color(0xFF7C3AED)),
    BrandColorOption(name: "Teal Modern",    color: Color(0xFF0D9488)),
    BrandColorOption(name: "Dark Navy",      color: Color(0xFF0F172A)),
    BrandColorOption(name: "Amber Warm",     color: Color(0xFFD97706)),
    BrandColorOption(name: "Rose Bold",      color: Color(0xFFE11D48)),
  ];

  const BrandColorSelector({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    required this.isLocked,
    required this.onLockChanged,
  });

  @override
  State<BrandColorSelector> createState() => _BrandColorSelectorState();
}

class _BrandColorSelectorState extends State<BrandColorSelector> {
  /// Stores a custom color picked by the user (not in the default palette).
  Color? _customColor;

  bool get _isCustomSelected =>
      _customColor != null &&
      !BrandColorSelector.defaultColors
          .any((o) => o.color == widget.selectedColor) &&
      widget.selectedColor == _customColor;

  Future<void> _openColorPicker() async {
    final picked = await showCustomColorPicker(
      context,
      initialColor: _customColor ?? widget.selectedColor,
    );
    if (picked == null || !mounted) return;
    setState(() => _customColor = picked);
    widget.onColorSelected(picked);
  }

  Widget _buildSwatch(Color color, {bool isCustom = false}) {
    final isSelected = widget.selectedColor == color;
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: GestureDetector(
        onTap: () {
          widget.onColorSelected(color);
          if (isCustom) setState(() => _customColor = color);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 38, height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            border: isSelected ? Border.all(color: color, width: 2.0) : null,
          ),
          child: Container(
            width: isSelected ? 28 : 32,
            height: isSelected ? 28 : 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 2.0) : null,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  blurRadius: 4, offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Brand Color",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 12),

        // ── Swatch Row ──────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Default palette
              ...BrandColorSelector.defaultColors.map(
                (item) => _buildSwatch(item.color),
              ),

              // Custom color swatch (shown after picking)
              if (_customColor != null) _buildSwatch(_customColor!, isCustom: true),

              // + button — opens full color picker
              GestureDetector(
                onTap: _openColorPicker,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: _isCustomSelected
                        ? const Color(0xFF0052FF).withValues(alpha: 0.08)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isCustomSelected
                          ? const Color(0xFF0052FF)
                          : const Color(0xFFCBD5E1),
                      width: _isCustomSelected ? 2.0 : 1.2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: _isCustomSelected
                          ? const Color(0xFF0052FF)
                          : const Color(0xFF475569),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Lock Toggle Row ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Lock brand color for all employees",
                      style: TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: widget.isLocked,
                    activeTrackColor: const Color(0xFF0052FF),
                    onChanged: widget.onLockChanged,
                  ),
                ],
              ),
              if (widget.isLocked)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Employees cannot override the organization\'s official brand palette on their digital business cards.',
                    style: TextStyle(
                      fontSize: 12, color: const Color(0xFF64748B), height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

