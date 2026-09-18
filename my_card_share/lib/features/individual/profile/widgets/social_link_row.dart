import 'package:flutter/material.dart';

class SocialLinkRow extends StatelessWidget {
  final String platform;
  final String value;

  const SocialLinkRow({
    super.key,
    required this.platform,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.link, color: Color(0xFF0052FF)),
          const SizedBox(width: 12),
          Text(platform, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}
