import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// ============================================================
/// CLAYMORPHISM — puffy, soft 3D cards & primary buttons.
/// Use for: main content cards, dashboard tiles, primary CTAs.
/// ============================================================
class ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;

  const ClayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.color = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            offset: const Offset(8, 8),
            blurRadius: 20,
            spreadRadius: -4,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }
}

class ClayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? leadingWidget;
  final bool gradient; // true = filled brand gradient, false = outlined clay

  const ClayButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.leadingWidget,
    this.gradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient
              ? const LinearGradient(colors: AppColors.primaryGradient)
              : null,
          color: gradient ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: gradient ? null : Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: gradient ? 0.35 : 0.08),
              offset: const Offset(0, 8),
              blurRadius: 18,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingWidget != null) ...[
              leadingWidget!,
              const SizedBox(width: 10),
            ] else if (icon != null) ...[
              Icon(icon,
                  color: gradient ? Colors.white : AppColors.primary,
                  size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.textTheme.labelLarge?.copyWith(
                color: gradient ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// GLASSMORPHISM — frosted blur overlay panels.
/// Use for: modals, floating status pills over banners, sheets
/// that sit on top of colorful/gradient backgrounds.
/// ============================================================
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.blur = 16,
    this.opacity = 0.55,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Pill-shaped glass badge — used for status tags floating over
/// banners/cover images (e.g. "Actively Networking").
class GlassPill extends StatelessWidget {
  final String label;
  final Color dotColor;

  const GlassPill(
      {super.key, required this.label, this.dotColor = AppColors.success});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// NEUMORPHISM — soft embossed elements. Use SPARINGLY: icon
/// buttons, toggle-style controls, small input chips — never a
/// full screen background, it needs a flat matte base to read.
/// ============================================================
class NeuBox extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool pressed; // true = inset/pressed look, false = raised

  const NeuBox({
    super.key,
    required this.child,
    this.radius = 16,
    this.padding = const EdgeInsets.all(12),
    this.pressed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.neuBase,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: pressed
            ? const []
            : [
                BoxShadow(
                  color: AppColors.neuShadowDark.withValues(alpha: 0.6),
                  offset: const Offset(4, 4),
                  blurRadius: 10,
                ),
                const BoxShadow(
                  color: AppColors.neuShadowLight,
                  offset: Offset(-4, -4),
                  blurRadius: 10,
                ),
              ],
      ),
      child: child,
    );
  }
}

class NeuIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const NeuIconButton(
      {super.key, required this.icon, required this.onTap, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeuBox(
        radius: size / 2,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: AppColors.primary, size: size * 0.45),
        ),
      ),
    );
  }
}
