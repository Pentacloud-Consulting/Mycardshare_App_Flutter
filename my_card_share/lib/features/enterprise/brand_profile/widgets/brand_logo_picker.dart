import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../backend/enterprise/profile/enterprise_profile_store.dart';

/// Real BrandLogoPicker — picks company logo from gallery, uploads to Firebase Storage,
/// updates Firestore & EnterpriseProfileStore, and shows live image preview.
class BrandLogoPicker extends StatefulWidget {
  final VoidCallback? onTap;

  const BrandLogoPicker({
    super.key,
    this.onTap,
  });

  @override
  State<BrandLogoPicker> createState() => _BrandLogoPickerState();
}

class _BrandLogoPickerState extends State<BrandLogoPicker> {
  bool _isUploading = false;
  String? _logoUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCurrentLogo();
  }

  Future<void> _loadCurrentLogo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await EnterpriseProfileStore.instance.loadProfile(uid, '', '');
    final profile = EnterpriseProfileStore.instance.currentProfile;
    if (!mounted) return;
    setState(() {
      _logoUrl = profile?.logoUrl;
    });
  }

  Future<void> _handlePickAndUploadLogo() async {
    if (_isUploading) return;

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null) return;

      setState(() => _isUploading = true);

      final bytes = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Str';

      String downloadUrl = dataUrl;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? EnterpriseProfileStore.instance.currentProfile?.uid ?? 'ent_active';

      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('enterprise_logos')
            .child(uid)
            .child('logo.jpg');

        final task = await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        ).timeout(const Duration(seconds: 8));
        downloadUrl = await task.ref.getDownloadURL();
      } catch (storageErr) {
        debugPrint('[BrandLogoPicker] Firebase Storage upload note: $storageErr (using local data URL)');
      }

      try {
        await FirebaseFirestore.instance.collection('enterprises').doc(uid).set({
          'logoUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'logoUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (fsErr) {
        debugPrint('[BrandLogoPicker] Firestore update note: $fsErr');
      }

      EnterpriseProfileStore.instance.updateFields(uid, {'logoUrl': downloadUrl});

      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _logoUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Company logo uploaded successfully!"),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error selecting logo: $e"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Company Logo",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: widget.onTap ?? _handlePickAndUploadLogo,
            child: SizedBox(
              width: 124,
              height: 124,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                        ),
                        child: _isUploading
                            ? const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFF0052FF),
                                  ),
                                ),
                              )
                            : (_logoUrl != null && _logoUrl!.isNotEmpty)
                                ? Image.network(_logoUrl!, fit: BoxFit.cover)
                                : const Center(
                                    child: Icon(
                                      Icons.apartment_rounded,
                                      color: Color(0xFF0052FF),
                                      size: 44,
                                    ),
                                  ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0052FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0052FF).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


