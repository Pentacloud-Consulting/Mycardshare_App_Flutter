import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../backend/enterprise/profile/enterprise_profile_store.dart';
import '../../../../backend/enterprise/qr_scan/slug_validator.dart';
import '../../../../backend/enterprise/qr_scan/slug_backend_service.dart';

/// ────────────────────────────────────────────────────────────────────────────
/// EnterpriseBrandSlugWidget
/// ────────────────────────────────────────────────────────────────────────────
/// Editable Enterprise Card Slug & Link Section matching the clean UI style
/// of Workspace Invite Link widget.
/// 
/// Real-time slug availability check via [EnterpriseSlugValidatorService]
/// Real-time Firestore + MongoDB sync via [EnterpriseSlugBackendService]
class EnterpriseBrandSlugWidget extends StatefulWidget {
  const EnterpriseBrandSlugWidget({super.key});

  @override
  State<EnterpriseBrandSlugWidget> createState() =>
      _EnterpriseBrandSlugWidgetState();
}

class _EnterpriseBrandSlugWidgetState extends State<EnterpriseBrandSlugWidget> {
  late TextEditingController _slugController;
  bool _isEditing = false;
  bool _isChecking = false;
  bool _isSaving = false;
  bool _isAvailable = true;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final currentSlug =
        EnterpriseProfileStore.instance.currentProfile?.cardSlug ?? '';
    _slugController = TextEditingController(text: currentSlug);
  }

  @override
  void dispose() {
    _slugController.dispose();
    super.dispose();
  }

  Future<void> _validateSlug(String val) async {
    final clean = val.trim().toLowerCase();
    if (clean.isEmpty) {
      setState(() {
        _isChecking = false;
        _isAvailable = false;
        _validationError = "Slug cannot be empty";
      });
      return;
    }

    setState(() => _isChecking = true);

    final currentSlug =
        EnterpriseProfileStore.instance.currentProfile?.cardSlug;
    final result = await EnterpriseSlugValidatorService.checkSlug(
      clean,
      currentUserSlug: currentSlug,
    );

    if (!mounted) return;

    setState(() {
      _isChecking = false;
      _isAvailable = result.isAvailable;
      if (result.isAvailable) {
        _validationError = null;
      } else {
        final owner = result.existingCard?.fullName ?? 'another user';
        _validationError = "Slug taken by $owner";
      }
    });
  }

  Future<void> _saveSlug() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    final newSlug = _slugController.text.trim().toLowerCase();
    if (newSlug.isEmpty || !_isAvailable) return;

    setState(() => _isSaving = true);

    try {
      // 1. Update Firestore enterprises/{uid}
      await FirebaseFirestore.instance.collection('enterprises').doc(uid).set({
        'cardSlug': newSlug,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // 2. Local profile store update
      final active = EnterpriseProfileStore.instance.currentProfile;
      if (active != null) {
        final updatedProfile = active.copyWith(cardSlug: newSlug);
        EnterpriseProfileStore.instance.setCurrentProfile(updatedProfile);

        // 3. Sync to MongoDB API via EnterpriseSlugBackendService
        await EnterpriseSlugBackendService.instance.ensureSlugSynced(
          newSlug,
          updatedProfile.toFirestore(),
        );
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✓ Card URL updated: mycardshare.com/card/$newSlug"),
            backgroundColor: const Color(0xFF0052FF),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update slug: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _copyCardLink(String slug) {
    final cleanSlug = slug.isEmpty ? 'enterprise' : slug;
    final url = "https://mycardshare.com/card/$cleanSlug";
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Enterprise card link copied to clipboard!"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<EnterpriseProfileData?>(
      stream: uid.isNotEmpty
          ? EnterpriseProfileStore.instance.profileStream(uid)
          : const Stream.empty(),
      builder: (context, snapshot) {
        final profile =
            snapshot.data ?? EnterpriseProfileStore.instance.currentProfile;
        final currentSlug = profile?.cardSlug ??
            EnterpriseProfileData.generateCardSlug(
                profile?.companyName ?? 'enterprise');

        if (!_isEditing && _slugController.text != currentSlug) {
          _slugController.text = currentSlug;
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title & Edit/Cancel Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Brand Card Link & Slug",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                        if (!_isEditing) {
                          _slugController.text = currentSlug;
                          _validationError = null;
                        }
                      });
                    },
                    icon: Icon(
                      _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                      size: 15,
                      color: const Color(0xFF0052FF),
                    ),
                    label: Text(
                      _isEditing ? "Cancel" : "Edit Slug",
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0052FF),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Input Box matching Workspace Invite Link design
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _validationError != null
                        ? Colors.redAccent
                        : (_isAvailable && _isEditing)
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Text(
                      "mycardshare.com/card/",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _slugController,
                        enabled: _isEditing && !_isSaving,
                        onChanged: (val) => _validateSlug(val),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          hintText: "custom-slug",
                          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_isChecking)
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0052FF),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: _isEditing
                            ? ElevatedButton(
                                onPressed: (_isAvailable && !_isSaving)
                                    ? _saveSlug
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0052FF),
                                  disabledBackgroundColor:
                                      const Color(0xFF94A3B8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Text(
                                        "Save",
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              )
                            : ElevatedButton(
                                onPressed: () => _copyCardLink(currentSlug),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0052FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                ),
                                child: const Text(
                                  "Copy Link",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                  ],
                ),
              ),

              if (_validationError != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.redAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _validationError!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ] else if (_isEditing && _isAvailable) ...[
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 4),
                    Text(
                      "Slug is available!",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}


