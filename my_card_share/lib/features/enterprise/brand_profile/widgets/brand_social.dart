import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../backend/enterprise/social_redirect/enterprise_social_redirect.dart';

/// Supported Enterprise Social Platform Definition
class SocialPlatformOption {
  final String key;
  final String label;
  final dynamic icon;
  final Color color;
  final String hint;

  const SocialPlatformOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.hint,
  });
}

const List<SocialPlatformOption> kSupportedSocialPlatforms = [
  SocialPlatformOption(
    key: 'linkedin',
    label: 'LinkedIn',
    icon: FontAwesomeIcons.linkedin,
    color: Color(0xFF0A66C2),
    hint: 'https://linkedin.com/company/yourbrand',
  ),
  SocialPlatformOption(
    key: 'twitter',
    label: 'Twitter / X',
    icon: FontAwesomeIcons.xTwitter,
    color: Color(0xFF0F172A),
    hint: 'https://x.com/yourbrand',
  ),
  SocialPlatformOption(
    key: 'instagram',
    label: 'Instagram',
    icon: FontAwesomeIcons.instagram,
    color: Color(0xFFE4405F),
    hint: 'https://instagram.com/yourbrand',
  ),
  SocialPlatformOption(
    key: 'whatsapp',
    label: 'WhatsApp',
    icon: FontAwesomeIcons.whatsapp,
    color: Color(0xFF25D366),
    hint: '+1234567890 or wa.me/number',
  ),
  SocialPlatformOption(
    key: 'youtube',
    label: 'YouTube',
    icon: FontAwesomeIcons.youtube,
    color: Color(0xFFFF0000),
    hint: 'https://youtube.com/@yourbrand',
  ),
  SocialPlatformOption(
    key: 'github',
    label: 'GitHub',
    icon: FontAwesomeIcons.github,
    color: Color(0xFF24292E),
    hint: 'https://github.com/yourbrand',
  ),
  SocialPlatformOption(
    key: 'facebook',
    label: 'Facebook',
    icon: FontAwesomeIcons.facebook,
    color: Color(0xFF1877F2),
    hint: 'https://facebook.com/yourbrand',
  ),
  SocialPlatformOption(
    key: 'telegram',
    label: 'Telegram',
    icon: FontAwesomeIcons.telegram,
    color: Color(0xFF26A5E4),
    hint: 'https://t.me/yourbrand',
  ),
  SocialPlatformOption(
    key: 'pinterest',
    label: 'Pinterest',
    icon: FontAwesomeIcons.pinterest,
    color: Color(0xFFBD081C),
    hint: 'https://pinterest.com/yourbrand',
  ),
  SocialPlatformOption(
    key: 'website',
    label: 'Company Website',
    icon: FontAwesomeIcons.globe,
    color: Color(0xFF0052FF),
    hint: 'https://yourbrand.com',
  ),
  SocialPlatformOption(
    key: 'tiktok',
    label: 'TikTok',
    icon: FontAwesomeIcons.tiktok,
    color: Color(0xFF000000),
    hint: 'https://tiktok.com/@yourbrand',
  ),
  SocialPlatformOption(
    key: 'threads',
    label: 'Threads',
    icon: FontAwesomeIcons.threads,
    color: Color(0xFF000000),
    hint: 'https://threads.net/@yourbrand',
  ),
  SocialPlatformOption(
    key: 'snapchat',
    label: 'Snapchat',
    icon: FontAwesomeIcons.snapchat,
    color: Color(0xFFFFFC00),
    hint: 'https://snapchat.com/add/yourbrand',
  ),
  SocialPlatformOption(
    key: 'discord',
    label: 'Discord',
    icon: FontAwesomeIcons.discord,
    color: Color(0xFF5865F2),
    hint: 'https://discord.gg/yourinvite',
  ),
  SocialPlatformOption(
    key: 'medium',
    label: 'Medium',
    icon: FontAwesomeIcons.medium,
    color: Color(0xFF000000),
    hint: 'https://medium.com/@yourbrand',
  ),
];

/// Dynamic Enterprise BrandSocialWidget — clean interface to select platform, paste link, and add.
class BrandSocialWidget extends StatefulWidget {
  final Map<String, String>? initialLinks;
  final Function(Map<String, String>)? onChanged;

  const BrandSocialWidget({
    super.key,
    this.initialLinks,
    this.onChanged,
  });

  @override
  State<BrandSocialWidget> createState() => _BrandSocialWidgetState();
}

class _BrandSocialWidgetState extends State<BrandSocialWidget> {
  final Map<String, String> _addedLinks = {};
  SocialPlatformOption _selectedPlatform = kSupportedSocialPlatforms.first;
  final TextEditingController _linkInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSocials();
  }

  @override
  void dispose() {
    _linkInputController.dispose();
    super.dispose();
  }

  Future<void> _loadSocials() async {
    if (widget.initialLinks != null && widget.initialLinks!.isNotEmpty) {
      setState(() {
        _addedLinks.clear();
        _addedLinks.addAll(widget.initialLinks!);
      });
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('enterprises').doc(uid).get();
      if (doc.exists && doc.data() != null && mounted) {
        final data = doc.data()!;
        final rawMap = data['socialLinks'] as Map<String, dynamic>? ??
            data['socials'] as Map<String, dynamic>? ??
            {};
        setState(() {
          _addedLinks.clear();
          rawMap.forEach((k, v) {
            if (v != null && v.toString().trim().isNotEmpty) {
              _addedLinks[k.toString().toLowerCase()] = v.toString().trim();
            }
          });
        });
        _notifyChanged();
      }
    } catch (e) {
      debugPrint('[BrandSocialWidget] Error loading social links: $e');
    }
  }

  void _notifyChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_addedLinks);
    }
  }

  Future<void> _saveToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('enterprises').doc(uid).set({
        'socialLinks': _addedLinks,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[BrandSocialWidget] Error persisting socials to Firestore: $e');
    }
  }

  void _addPlatformLink() {
    final rawInput = _linkInputController.text.trim();
    if (rawInput.isEmpty) return;

    final formatted = EnterpriseSocialRedirectService.formatFullUrl(_selectedPlatform.key, rawInput);

    setState(() {
      _addedLinks[_selectedPlatform.key] = formatted.isNotEmpty ? formatted : rawInput;
      _linkInputController.clear();
    });

    _notifyChanged();
    _saveToFirestore();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✓ ${_selectedPlatform.label} link added successfully!"),
        backgroundColor: const Color(0xFF0052FF),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removePlatformLink(String platformKey) {
    setState(() {
      _addedLinks.remove(platformKey);
    });
    _notifyChanged();
    _saveToFirestore();
  }

  SocialPlatformOption _getPlatformMeta(String key) {
    return kSupportedSocialPlatforms.firstWhere(
      (p) => p.key == key.toLowerCase() || p.label.toLowerCase().contains(key.toLowerCase()),
      orElse: () => SocialPlatformOption(
        key: key,
        label: key[0].toUpperCase() + key.substring(1),
        icon: FontAwesomeIcons.globe,
        color: const Color(0xFF0052FF),
        hint: 'https://$key.com',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. SELECT PLATFORM & ADD LINK BOX ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add Enterprise Social Channel",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              // Platform Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SocialPlatformOption>(
                    value: _selectedPlatform,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedPlatform = val);
                      }
                    },
                    items: kSupportedSocialPlatforms.map((opt) {
                      return DropdownMenuItem<SocialPlatformOption>(
                        value: opt,
                        child: Row(
                          children: [
                            FaIcon(opt.icon, color: opt.color, size: 16),
                            const SizedBox(width: 10),
                            Text(
                              opt.label,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Link Input & Add Button Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: TextField(
                        controller: _linkInputController,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: _selectedPlatform.hint,
                          hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: FaIcon(_selectedPlatform.icon, color: _selectedPlatform.color, size: 16),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _addPlatformLink,
                    icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                    label: const Text(
                      "Add",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── 2. ADDED SOCIAL PLATFORMS LIST ─────────────────────────────────────────────
        if (_addedLinks.isNotEmpty) ...[
          const Text(
            "Active Enterprise Profiles",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _addedLinks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = _addedLinks.entries.elementAt(index);
              final meta = _getPlatformMeta(entry.key);
              final url = entry.value;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: FaIcon(meta.icon, color: meta.color, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meta.label,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Test Launch Link
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFF0052FF), size: 18),
                      tooltip: "Test Open Link",
                      onPressed: () => EnterpriseSocialRedirectService.launchSocialPlatform(
                        platform: entry.key,
                        rawInput: url,
                        context: context,
                      ),
                    ),
                    // Delete Link
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                      tooltip: "Remove Link",
                      onPressed: () => _removePlatformLink(entry.key),
                    ),
                  ],
                ),
              );
            },
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Center(
              child: Text(
                "No social platforms added yet. Select a platform above and click Add!",
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}


