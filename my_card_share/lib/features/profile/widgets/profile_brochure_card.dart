import 'package:flutter/material.dart';
import '../../../backend/brochure/brochure_service.dart';
import '../screens/document_viewer_screen.dart';

/// Reusable, high-fidelity Company Brochure section widget for Profile Screens & Editors.
/// Supports document picking, uploading to Firebase Storage, viewing, sharing, and removing.
class ProfileBrochureCard extends StatefulWidget {
  final String uid;
  final String? currentBrochureUrl;
  final String? currentBrochureFileName;
  final String companyOrUserName;
  final bool isEditable;
  final Function(String? newUrl, String? newFileName)? onBrochureChanged;

  const ProfileBrochureCard({
    super.key,
    required this.uid,
    this.currentBrochureUrl,
    this.currentBrochureFileName,
    required this.companyOrUserName,
    this.isEditable = true,
    this.onBrochureChanged,
  });

  @override
  State<ProfileBrochureCard> createState() => _ProfileBrochureCardState();
}

class _ProfileBrochureCardState extends State<ProfileBrochureCard> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _brochureUrl;
  String? _brochureFileName;

  @override
  void initState() {
    super.initState();
    _brochureUrl = widget.currentBrochureUrl;
    _brochureFileName = widget.currentBrochureFileName;
  }

  @override
  void didUpdateWidget(covariant ProfileBrochureCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentBrochureUrl != oldWidget.currentBrochureUrl) {
      _brochureUrl = widget.currentBrochureUrl;
    }
    if (widget.currentBrochureFileName != oldWidget.currentBrochureFileName) {
      _brochureFileName = widget.currentBrochureFileName;
    }
  }

  Future<void> _pickAndUploadBrochure() async {
    try {
      final file = await BrochureService.instance.pickBrochureFile();
      if (file == null) return;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.05;
      });

      final url = await BrochureService.instance.uploadBrochure(
        file: file,
        uid: widget.uid,
        onProgress: (p) => setState(() => _uploadProgress = p),
      );

      await BrochureService.instance.saveBrochureToFirestore(
        uid: widget.uid,
        brochureUrl: url,
        fileName: file.name,
        fileSize: file.size,
      );

      setState(() {
        _brochureUrl = url;
        _brochureFileName = file.name;
        _isUploading = false;
      });

      widget.onBrochureChanged?.call(url, file.name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company brochure uploaded successfully!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on TimeoutException {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload timed out. Check your internet connection and try again.'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload brochure: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeBrochure() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Brochure?'),
        content: const Text(
          'Are you sure you want to remove your company brochure from your card?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await BrochureService.instance.removeBrochure(
        uid: widget.uid,
        currentBrochureUrl: _brochureUrl,
      );

      setState(() {
        _brochureUrl = null;
        _brochureFileName = null;
      });

      widget.onBrochureChanged?.call(null, null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brochure removed successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasBrochure = _brochureUrl != null && _brochureUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF0052FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Company Brochure / Catalog',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      hasBrochure
                          ? (_brochureFileName ?? 'Brochure document attached')
                          : 'Share your company deck, brochure, or portfolio',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: hasBrochure
                            ? const Color(0xFF10B981)
                            : const Color(0xFF64748B),
                        fontWeight: hasBrochure
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hasBrochure && widget.isEditable)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFFEF4444), size: 20),
                  tooltip: 'Remove Brochure',
                  onPressed: _removeBrochure,
                ),
            ],
          ),

          if (_isUploading) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF0052FF)),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Uploading brochure... ${(_uploadProgress * 100).toInt()}%',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],

          const SizedBox(height: 14),

          // Action Buttons
          if (hasBrochure)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0052FF),
                      side: const BorderSide(color: Color(0xFF0052FF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: const Text('View',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DocumentViewerScreen(
                            title: 'Company Brochure',
                            documentUrl: _brochureUrl!,
                            fileName: _brochureFileName ?? 'Brochure.pdf',
                            onShare: () => BrochureService.shareBrochure(
                              brochureUrl: _brochureUrl!,
                              companyOrUserName: widget.companyOrUserName,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    onPressed: () => BrochureService.shareBrochure(
                      brochureUrl: _brochureUrl!,
                      companyOrUserName: widget.companyOrUserName,
                    ),
                  ),
                ),
                if (widget.isEditable) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.upload_file_rounded,
                        size: 18, color: Color(0xFF0F172A)),
                    tooltip: 'Replace Brochure',
                    onPressed: _isUploading ? null : _pickAndUploadBrochure,
                  ),
                ],
              ],
            )
          else if (widget.isEditable)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text(
                  'Upload Company Brochure (PDF/DOC)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: _isUploading ? null : _pickAndUploadBrochure,
              ),
            ),
        ],
      ),
    );
  }
}
