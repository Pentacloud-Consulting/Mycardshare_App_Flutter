import 'package:flutter/material.dart';
import '../../../../backend/individual/qr_scan/slug_validator.dart';

/// Card Slug editor widget with real-time availability check.
///
/// Shows:
///  • A spinner while checking
///  • A green ✓ icon when the slug is free
///  • A red ✗ icon + error banner when the slug is already taken
///
/// Pass [currentUserSlug] (the slug the user already owns) so re-saving
/// the same slug never triggers a false "taken" error.
class ProfileSlugSection extends StatefulWidget {
  final TextEditingController slugController;

  /// The slug already owned by the current user (pre-loaded from their profile).
  /// Prevents a false "slug taken" error when they save without changing it.
  final String? currentUserSlug;

  const ProfileSlugSection({
    super.key,
    required this.slugController,
    this.currentUserSlug,
  });

  @override
  State<ProfileSlugSection> createState() => _ProfileSlugSectionState();
}

class _ProfileSlugSectionState extends State<ProfileSlugSection> {
  String? _slugError;
  bool _slugChecking = false;
  bool _slugAvailable = false;

  @override
  void initState() {
    super.initState();
    // If the field already has a value (editing existing profile),
    // treat it as "available" initially — it's their own slug.
    _slugAvailable = widget.slugController.text.trim().isNotEmpty;
  }

  void _onSlugChanged(String value) {
    setState(() {
      _slugError = null;
      _slugAvailable = false;
    });

    final slug = value.trim().toLowerCase();
    if (slug.isEmpty) return;

    // Debounce: wait 800 ms after user stops typing
    Future.delayed(const Duration(milliseconds: 800), () async {
      if (!mounted) return;
      // Only run if the field still has this slug
      if (_slugController.text.trim().toLowerCase() != slug) return;

      setState(() => _slugChecking = true);

      final result = await SlugValidatorService.checkSlug(
        slug,
        currentUserSlug: widget.currentUserSlug,
      );

      if (!mounted) return;
      setState(() {
        _slugChecking = false;
        if (!result.isAvailable) {
          _slugError =
              'Slug "$slug" is already taken by ${result.existingCard?.fullName ?? "another user"}';
          _slugAvailable = false;
        } else {
          _slugError = null;
          _slugAvailable = true;
        }
      });
    });
  }

  TextEditingController get _slugController => widget.slugController;

  @override
  Widget build(BuildContext context) {
    final hasText = _slugController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label + status ────────────────────────────────────────────────────
        Row(
          children: [
            const Text(
              'Card Slug',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            if (_slugChecking)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: Color(0xFF0052FF),
                ),
              )
            else if (_slugError != null)
              const Icon(Icons.cancel_rounded,
                  color: Color(0xFFDC2626), size: 16)
            else if (hasText && _slugAvailable)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 16),
          ],
        ),

        const SizedBox(height: 10),

        // ── Slug input row ────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _slugError != null
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.link_rounded,
                  color: _slugError != null
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF64748B),
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'mycardshare.com/card/',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _slugController,
                    onChanged: _onSlugChanged,
                    style: TextStyle(
                      fontSize: 13,
                      color: _slugError != null
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF0066FF),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      hintText: 'your-name',
                      hintStyle: TextStyle(
                          color: Color(0xFFCBD5E1), fontSize: 12.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Error banner ──────────────────────────────────────────────────────
        if (_slugError != null) ...[
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Color(0xFFDC2626), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _slugError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // ── Hint text ─────────────────────────────────────────────────────────
        if (_slugError == null) ...[
          const SizedBox(height: 6),
          const Text(
            'This is your unique public card URL. Only lowercase letters, numbers and hyphens.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
          ),
        ],
      ],
    );
  }
}


