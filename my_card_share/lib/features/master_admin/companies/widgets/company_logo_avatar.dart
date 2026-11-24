import 'package:flutter/material.dart';
import '../../../../core/utils/app_image_helper.dart';

/// Interactive & Real Company Logo Widget with cascading real-time logo fetchers:
/// 1. Custom uploaded logoUrl (Firebase Storage, network, base64, data URI)
/// 2. Clearbit Logo API (`https://logo.clearbit.com/<domain>`)
/// 3. Google High-Res Favicon API (`https://www.google.com/s2/favicons?domain=<domain>&sz=128`)
/// 4. Unavatar API (`https://unavatar.io/<domain>`)
/// 5. Graceful styled fallback to company initials with brand styling
class CompanyLogoAvatar extends StatefulWidget {
  final String? logoUrl;
  final String companyName;
  final String? domain;
  final double size;
  final bool isCircle;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  const CompanyLogoAvatar({
    super.key,
    this.logoUrl,
    required this.companyName,
    this.domain,
    this.size = 44,
    this.isCircle = true,
    this.borderRadius = 10,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<CompanyLogoAvatar> createState() => _CompanyLogoAvatarState();
}

class _CompanyLogoAvatarState extends State<CompanyLogoAvatar> {
  int _currentCandidateIndex = 0;
  late List<String> _candidates;

  @override
  void initState() {
    super.initState();
    _buildCandidates();
  }

  @override
  void didUpdateWidget(covariant CompanyLogoAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logoUrl != widget.logoUrl ||
        oldWidget.companyName != widget.companyName ||
        oldWidget.domain != widget.domain) {
      _currentCandidateIndex = 0;
      _buildCandidates();
    }
  }

  void _buildCandidates() {
    final list = <String>[];

    // Only display explicit uploaded logoUrl (Firebase Storage, network URL, base64)
    // Never auto-fetch arbitrary external company logos from third-party APIs
    if (widget.logoUrl != null && widget.logoUrl!.trim().isNotEmpty) {
      list.add(widget.logoUrl!.trim());
    }

    _candidates = list;
  }

  String _getInitials() {
    final clean = widget.companyName.trim();
    if (clean.isEmpty) return 'CO';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _onImageError() {
    if (mounted && _currentCandidateIndex < _candidates.length - 1) {
      setState(() {
        _currentCandidateIndex++;
      });
    } else if (mounted) {
      setState(() {
        _currentCandidateIndex = _candidates.length; // triggers fallback initials
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? const Color(0xFFFFF7ED);
    final txtColor = widget.textColor ?? const Color(0xFFD4642C);
    final initials = _getInitials();

    Widget content;

    if (_currentCandidateIndex < _candidates.length) {
      final url = _candidates[_currentCandidateIndex];

      if (url.startsWith('data:image') || url.startsWith('assets/')) {
        content = AppImageHelper.buildImage(
          url,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          fallback: _buildInitialsWidget(bgColor, txtColor, initials),
        );
      } else {
        content = Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.network(
            url,
            key: ValueKey(url),
            width: widget.size - 8,
            height: widget.size - 8,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _onImageError());
              return _buildInitialsWidget(bgColor, txtColor, initials);
            },
          ),
        );
      }
    } else {
      content = _buildInitialsWidget(bgColor, txtColor, initials);
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: widget.isCircle ? null : BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: const Color(0xFFFED7AA),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: content),
    );
  }

  Widget _buildInitialsWidget(Color bgColor, Color txtColor, String initials) {
    return Container(
      width: widget.size,
      height: widget.size,
      color: bgColor,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: widget.size * 0.36,
          fontWeight: FontWeight.w900,
          color: txtColor,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
