import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Opens a rich custom color picker bottom sheet.
/// Returns the selected [Color] or `null` if cancelled.
Future<Color?> showCustomColorPicker(
  BuildContext context, {
  Color initialColor = const Color(0xFF0052FF),
}) {
  return showModalBottomSheet<Color>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CustomColorPickerSheet(initialColor: initialColor),
  );
}

class _CustomColorPickerSheet extends StatefulWidget {
  final Color initialColor;
  const _CustomColorPickerSheet({required this.initialColor});

  @override
  State<_CustomColorPickerSheet> createState() => _CustomColorPickerSheetState();
}

class _CustomColorPickerSheetState extends State<_CustomColorPickerSheet> {
  late double _hue; // 0..360
  late double _saturation; // 0..1
  late double _value; // 0..1
  late TextEditingController _hexController;

  static const List<Color> _presetSwatches = [
    Color(0xFF0052FF), // Electric Blue
    Color(0xFF7C3AED), // Purple Accent
    Color(0xFF0D9488), // Teal Modern
    Color(0xFF059669), // Emerald Green
    Color(0xFFD97706), // Amber Warm
    Color(0xFFE11D48), // Rose Bold
    Color(0xFFDB2777), // Pink Accent
    Color(0xFF4F46E5), // Indigo Deep
    Color(0xFF0284C7), // Sky Blue
    Color(0xFF0F172A), // Dark Navy
    Color(0xFF475569), // Slate Gray
    Color(0xFF65A30D), // Lime Vibrant
  ];

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _hexController = TextEditingController(text: _colorToHex(widget.initialColor));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color get _currentColor =>
      HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();

  static String _colorToHex(Color color) {
    return color.toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
  }

  void _updateFromHex(String rawHex) {
    final clean = rawHex.replaceAll('#', '').trim();
    if (clean.length == 6) {
      final val = int.tryParse('FF$clean', radix: 16);
      if (val != null) {
        final c = Color(val);
        final hsv = HSVColor.fromColor(c);
        setState(() {
          _hue = hsv.hue;
          _saturation = hsv.saturation;
          _value = hsv.value;
        });
      }
    }
  }

  void _setColor(Color color) {
    final hsv = HSVColor.fromColor(color);
    setState(() {
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _value = hsv.value;
      _hexController.text = _colorToHex(color);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final currentHex = _colorToHex(_currentColor);

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Custom Brand Color",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Live Preview Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: _currentColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _currentColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.palette_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "BANNER PREVIEW",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "#$currentHex",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Hue Gradient Slider
              const Text(
                "Color Hue",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF0000),
                      Color(0xFFFFFF00),
                      Color(0xFF00FF00),
                      Color(0xFF00FFFF),
                      Color(0xFF0000FF),
                      Color(0xFFFF00FF),
                      Color(0xFFFF0000),
                    ],
                  ),
                ),
                child: SliderTheme(
                  data: SliderThemeData(
                    trackShape: const RectangularSliderTrackShape(),
                    thumbShape: const _CustomColorThumbShape(),
                    overlayShape: SliderComponentShape.noOverlay,
                    trackHeight: 28,
                  ),
                  child: Slider(
                    value: _hue,
                    min: 0,
                    max: 360,
                    onChanged: (val) {
                      setState(() {
                        _hue = val;
                        _hexController.text = _colorToHex(_currentColor);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Saturation / Shade Slider
              const Text(
                "Saturation & Tone",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      HSVColor.fromAHSV(1.0, _hue, 0.0, _value).toColor(),
                      HSVColor.fromAHSV(1.0, _hue, 1.0, _value).toColor(),
                    ],
                  ),
                ),
                child: SliderTheme(
                  data: SliderThemeData(
                    trackShape: const RectangularSliderTrackShape(),
                    thumbShape: const _CustomColorThumbShape(),
                    overlayShape: SliderComponentShape.noOverlay,
                    trackHeight: 28,
                  ),
                  child: Slider(
                    value: _saturation,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (val) {
                      setState(() {
                        _saturation = val;
                        _hexController.text = _colorToHex(_currentColor);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // HEX Code Input & Quick Presets Row
              Row(
                children: [
                  // Hex Input Field
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "HEX Code",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _hexController,
                          maxLength: 6,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            color: Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            prefixText: "# ",
                            prefixStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                            ),
                            counterText: "",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF0052FF),
                                width: 2,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-fA-F0-9]')),
                          ],
                          onChanged: _updateFromHex,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Confirm Select Button
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(_currentColor),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Apply Color",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Presets Palette Grid
              const Text(
                "Quick Swatches",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presetSwatches.map((color) {
                  final isSelected = _currentColor.toARGB32() == color.toARGB32();
                  return GestureDetector(
                    onTap: () => _setColor(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3.0)
                            : null,
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          else
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
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
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomColorThumbShape extends SliderComponentShape {
  const _CustomColorThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(20, 20);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final paintShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center + const Offset(0, 2), 11, paintShadow);

    final paintOuter = Paint()..color = Colors.white;
    canvas.drawCircle(center, 11, paintOuter);

    final paintInner = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(center, 7, paintInner);
  }
}


