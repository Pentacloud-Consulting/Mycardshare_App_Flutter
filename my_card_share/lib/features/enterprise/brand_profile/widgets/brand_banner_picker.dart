import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/lock_banner/lock_banner.dart';
import '../../../../backend/enterprise/profile/enterprise_profile_store.dart';

/// Real BrandBannerPicker — uploads enterprise banner to Firebase Storage,
/// displays the live uploaded image, and locks it for all employees.
class BrandBannerPicker extends StatefulWidget {
  final bool showLockToggle;

  const BrandBannerPicker({
    super.key,
    this.showLockToggle = false,
  });

  @override
  State<BrandBannerPicker> createState() => _BrandBannerPickerState();
}

class _BrandBannerPickerState extends State<BrandBannerPicker> {
  bool _isUploading = false;
  bool _isLocked = false;
  String? _bannerUrl;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentBanner();
  }

  Future<void> _loadCurrentBanner() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final data = await LockBannerService.instance.fetchBanner(uid);
    if (!mounted) return;
    setState(() {
      _bannerUrl = data?.bannerUrl;
      _isLocked = data?.isLocked ?? false;
    });
  }

  Future<void> _handleUpload() async {
    if (_isUploading) return;
    setState(() => _isUploading = true);

    final result = await LockBannerService.instance.pickAndUploadBanner(
      lockAfterUpload: _isLocked,
    );

    if (!mounted) return;
    setState(() {
      _isUploading = false;
      if (result.isSuccess && result.bannerUrl != null) {
        _bannerUrl = result.bannerUrl;

        // Also update EnterpriseProfileStore cache
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          EnterpriseProfileStore.instance.updateFields(uid, {
            'bannerUrl': result.bannerUrl,
          });
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.message),
      backgroundColor:
          result.isSuccess ? const Color(0xFF0F172A) : Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _handleLockToggle(bool locked) async {
    final result = await LockBannerService.instance.setLocked(locked: locked);
    if (!mounted) return;
    setState(() => _isLocked = locked);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.message),
      backgroundColor: const Color(0xFF0F172A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _handleRemove() async {
    setState(() => _isRemoving = true);
    final result = await LockBannerService.instance.removeBanner();
    if (!mounted) return;
    setState(() {
      _isRemoving = false;
      if (result.isSuccess) {
        _bannerUrl = null;
        _isLocked = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.message),
      backgroundColor: const Color(0xFF0F172A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Title ────────────────────────────────────────────────
        const Text(
          'Cover Banner',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        // ── Banner Display / Upload Area ─────────────────────────────────
        StreamBuilder<LockedBannerData?>(
          stream: uid.isNotEmpty
              ? LockBannerService.instance.bannerStream(uid)
              : const Stream.empty(),
          builder: (context, snapshot) {
            final liveBannerUrl = snapshot.data?.bannerUrl ?? _bannerUrl;
            final liveIsLocked = snapshot.data?.isLocked ?? _isLocked;

            if (snapshot.hasData && snapshot.data != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _isLocked != liveIsLocked) {
                  setState(() => _isLocked = liveIsLocked);
                }
              });
            }

            return GestureDetector(
              onTap: _isUploading ? null : _handleUpload,
              child: Stack(
                children: [
                  // ── Banner Container ─────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: liveBannerUrl == null
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF0052FF),
                                Color(0xFF7C3AED),
                                Color(0xFF38BDF8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      image: liveBannerUrl != null
                          ? DecorationImage(
                              image: NetworkImage(liveBannerUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0052FF).withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: liveBannerUrl == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 32,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap to upload company banner',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Recommended: 1200 × 400 px',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        Colors.white.withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),

                  // ── Upload Loading Overlay ───────────────────────────
                  if (_isUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    ),

                  // ── Lock Badge (top-left) ────────────────────────────
                  if (liveIsLocked)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded,
                                color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Locked for all employees',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Camera / Change Badge (bottom-right) ─────────────
                  if (!_isUploading)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF0F172A).withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Color(0xFF0052FF),
                          size: 15,
                        ),
                      ),
                    ),

                  // ── Remove Button (top-right, only when image exists) ─
                  if (liveBannerUrl != null && !_isRemoving)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _handleRemove,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color:
                                Colors.red.shade600.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 13),
                        ),
                      ),
                    ),

                  if (_isRemoving)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(
                              strokeWidth: 1.8, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        if (widget.showLockToggle) ...[
          const SizedBox(height: 16),
          // ── Lock Toggle Row ──────────────────────────────────────────────
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
                        'Lock banner for all employees',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: _isLocked,
                      activeTrackColor: const Color(0xFF0052FF),
                      onChanged: _handleLockToggle,
                    ),
                  ],
                ),
                if (_isLocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Employees cannot override the organization\'s banner on their digital business cards.',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}




