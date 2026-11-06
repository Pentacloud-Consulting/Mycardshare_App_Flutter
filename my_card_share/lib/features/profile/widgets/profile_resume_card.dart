import 'dart:async';
import 'package:flutter/material.dart';
import '../../../backend/individual/profile/individual_profile_store.dart';
import '../../../backend/resume/resume_service.dart';
import '../../../backend/brochure/brochure_service.dart';
import '../screens/document_viewer_screen.dart';

/// Custom Painter for dashed outline buttons matching the Web Documents design
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  DashedRectPainter({
    this.color = const Color(0xFF93C5FD),
    this.strokeWidth = 1.2,
    this.gap = 4.0,
    this.dash = 6.0,
    this.radius = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length =
            (distance + dash < metric.length) ? dash : metric.length - distance;
        final extract = metric.extractPath(distance, distance + length);
        canvas.drawPath(extract, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dash != oldDelegate.dash ||
      gap != oldDelegate.gap ||
      radius != oldDelegate.radius;
}

/// Unified Documents widget (Resume / CV + Company Brochure) matching the Web Documents section.
class ProfileResumeCard extends StatefulWidget {
  final String uid;
  final String? currentResumeUrl;
  final String? currentResumeFileName;
  final String? currentBrochureUrl;
  final String? currentBrochureFileName;
  final String candidateName;
  final String? companyOrUserName;
  final String? jobTitle;
  final String? enterpriseUid;
  final String? employeeDocId;
  final bool isEditable;
  final Function(String? newUrl, String? newFileName)? onResumeChanged;
  final Function(String? newUrl, String? newFileName)? onBrochureChanged;

  const ProfileResumeCard({
    super.key,
    required this.uid,
    this.currentResumeUrl,
    this.currentResumeFileName,
    this.currentBrochureUrl,
    this.currentBrochureFileName,
    required this.candidateName,
    this.companyOrUserName,
    this.jobTitle,
    this.enterpriseUid,
    this.employeeDocId,
    this.isEditable = true,
    this.onResumeChanged,
    this.onBrochureChanged,
  });

  @override
  State<ProfileResumeCard> createState() => _ProfileResumeCardState();
}

class _ProfileResumeCardState extends State<ProfileResumeCard> {
  bool _isUploadingResume = false;
  double _resumeUploadProgress = 0.0;
  String? _resumeUrl;
  String? _resumeFileName;

  bool _isUploadingBrochure = false;
  double _brochureUploadProgress = 0.0;
  String? _brochureUrl;
  String? _brochureFileName;

  @override
  void initState() {
    super.initState();
    _resumeUrl = widget.currentResumeUrl ??
        IndividualProfileStore.instance.activeProfile?.resumeUrl;
    _resumeFileName = widget.currentResumeFileName ??
        IndividualProfileStore.instance.activeProfile?.resumeFileName;

    _brochureUrl = widget.currentBrochureUrl ??
        IndividualProfileStore.instance.activeProfile?.brochureUrl;
    _brochureFileName = widget.currentBrochureFileName ??
        IndividualProfileStore.instance.activeProfile?.brochureFileName;
  }

  @override
  void didUpdateWidget(covariant ProfileResumeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentResumeUrl != oldWidget.currentResumeUrl) {
      _resumeUrl = widget.currentResumeUrl;
    }
    if (widget.currentResumeFileName != oldWidget.currentResumeFileName) {
      _resumeFileName = widget.currentResumeFileName;
    }
    if (widget.currentBrochureUrl != oldWidget.currentBrochureUrl) {
      _brochureUrl = widget.currentBrochureUrl;
    }
    if (widget.currentBrochureFileName != oldWidget.currentBrochureFileName) {
      _brochureFileName = widget.currentBrochureFileName;
    }
  }

  // ── Resume Operations ──────────────────────────────────────────────
  Future<void> _pickAndUploadResume() async {
    try {
      final file = await ResumeService.instance.pickResumeFile();
      if (file == null) return;

      setState(() {
        _isUploadingResume = true;
        _resumeUploadProgress = 0.05;
      });

      final downloadUrl = await ResumeService.instance.uploadResume(
        file: file,
        uid: widget.uid,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _resumeUploadProgress = progress);
          }
        },
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw TimeoutException(
            'Upload timed out. Please check your connection and try again.'),
      );

      await ResumeService.instance.saveResumeToFirestore(
        uid: widget.uid,
        resumeUrl: downloadUrl,
        fileName: file.name,
        fileSize: file.size,
        enterpriseUid: widget.enterpriseUid,
        employeeDocId: widget.employeeDocId,
      );

      if (mounted) {
        setState(() {
          _resumeUrl = downloadUrl;
          _resumeFileName = file.name;
          _isUploadingResume = false;
        });

        widget.onResumeChanged?.call(downloadUrl, file.name);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        'Resume "${file.name}" uploaded successfully!')),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        setState(() => _isUploadingResume = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Upload timed out. Check your internet connection and try again.'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingResume = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload resume: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _removeResume() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Resume?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to remove your uploaded resume? Anyone scanning your card will no longer be able to download it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ResumeService.instance.removeResume(
        uid: widget.uid,
        currentResumeUrl: _resumeUrl,
        enterpriseUid: widget.enterpriseUid,
        employeeDocId: widget.employeeDocId,
      );

      if (mounted) {
        setState(() {
          _resumeUrl = null;
          _resumeFileName = null;
        });

        widget.onResumeChanged?.call(null, null);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Resume removed successfully.'),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove resume: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _openResume() {
    if (_resumeUrl != null && _resumeUrl!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DocumentViewerScreen(
            title: "Resume / CV",
            documentUrl: _resumeUrl!,
            fileName: _resumeFileName ?? "Resume.pdf",
            onShare: _shareResume,
          ),
        ),
      );
    }
  }

  void _shareResume() {
    if (_resumeUrl != null && _resumeUrl!.isNotEmpty) {
      ResumeService.shareResume(
        resumeUrl: _resumeUrl!,
        candidateName: widget.candidateName,
        jobTitle: widget.jobTitle,
      );
    }
  }

  // ── Brochure Operations ────────────────────────────────────────────
  Future<void> _pickAndUploadBrochure() async {
    try {
      final file = await BrochureService.instance.pickBrochureFile();
      if (file == null) return;

      setState(() {
        _isUploadingBrochure = true;
        _brochureUploadProgress = 0.05;
      });

      final downloadUrl = await BrochureService.instance.uploadBrochure(
        file: file,
        uid: widget.uid,
        onProgress: (p) {
          if (mounted) {
            setState(() => _brochureUploadProgress = p);
          }
        },
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw TimeoutException(
            'Upload timed out. Please check your connection and try again.'),
      );

      await BrochureService.instance.saveBrochureToFirestore(
        uid: widget.uid,
        brochureUrl: downloadUrl,
        fileName: file.name,
        fileSize: file.size,
      );

      if (mounted) {
        setState(() {
          _brochureUrl = downloadUrl;
          _brochureFileName = file.name;
          _isUploadingBrochure = false;
        });

        widget.onBrochureChanged?.call(downloadUrl, file.name);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        'Company brochure "${file.name}" uploaded successfully!')),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        setState(() => _isUploadingBrochure = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Upload timed out. Check your internet connection and try again.'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingBrochure = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload brochure: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _removeBrochure() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Brochure?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to remove your company brochure? Anyone scanning your card will no longer be able to download it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Remove'),
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

      if (mounted) {
        setState(() {
          _brochureUrl = null;
          _brochureFileName = null;
        });

        widget.onBrochureChanged?.call(null, null);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Brochure removed successfully.'),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove brochure: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _openBrochure() {
    if (_brochureUrl != null && _brochureUrl!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DocumentViewerScreen(
            title: "Company Brochure",
            documentUrl: _brochureUrl!,
            fileName: _brochureFileName ?? "Brochure.pdf",
            onShare: _shareBrochure,
          ),
        ),
      );
    }
  }

  void _shareBrochure() {
    if (_brochureUrl != null && _brochureUrl!.isNotEmpty) {
      BrochureService.shareBrochure(
        brochureUrl: _brochureUrl!,
        companyOrUserName: widget.companyOrUserName ?? widget.candidateName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResume = _resumeUrl != null && _resumeUrl!.trim().isNotEmpty;
    final hasBrochure = _brochureUrl != null && _brochureUrl!.trim().isNotEmpty;
    final hasAnyDocument = hasResume || hasBrochure;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Documents",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.isEditable
                ? "Upload your resume or company brochure (PDF, DOC, DOCX — max 50MB). These will be visible and downloadable on your public card."
                : "Documents visible and downloadable on your public card.",
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // In View Mode: If neither resume nor brochure is added, show clean empty state
          if (!widget.isEditable && !hasAnyDocument) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.folder_open_rounded,
                        size: 22,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "You have not added resume or brochure yet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "You can upload your documents anytime from Edit Profile.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // 1. Resume / CV Sub-card
            _buildDocumentItem(
              title: "Resume / CV",
              icon: Icons.description_outlined,
              fileUrl: _resumeUrl,
              fileName: _resumeFileName,
              isUploading: _isUploadingResume,
              uploadProgress: _resumeUploadProgress,
              uploadButtonText: "Upload Resume",
              onUpload: _pickAndUploadResume,
              onOpen: _openResume,
              onShare: _shareResume,
              onDelete: _removeResume,
            ),

            const SizedBox(height: 12),

            // 2. Company Brochure Sub-card
            _buildDocumentItem(
              title: "Company Brochure",
              icon: Icons.menu_book_outlined,
              fileUrl: _brochureUrl,
              fileName: _brochureFileName,
              isUploading: _isUploadingBrochure,
              uploadProgress: _brochureUploadProgress,
              uploadButtonText: "Upload Brochure",
              onUpload: _pickAndUploadBrochure,
              onOpen: _openBrochure,
              onShare: _shareBrochure,
              onDelete: _removeBrochure,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required IconData icon,
    required String? fileUrl,
    required String? fileName,
    required bool isUploading,
    required double uploadProgress,
    required String uploadButtonText,
    required VoidCallback onUpload,
    required VoidCallback onOpen,
    required VoidCallback onShare,
    required VoidCallback onDelete,
  }) {
    final hasFile = fileUrl != null && fileUrl.trim().isNotEmpty;

    // In View Mode (not editable) when this specific file is not added
    if (!hasFile && !widget.isEditable) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Not added yet",
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
              ),
              child: const Text(
                "Not Added",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDBEAFE), width: 0.8),
                ),
                child: Center(
                  child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (hasFile) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            hasFile
                                ? (fileName ?? "Document uploaded")
                                : "No file uploaded",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: hasFile
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF64748B),
                              fontWeight:
                                  hasFile ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasFile && widget.isEditable) ...[
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFFECACA), width: 0.8),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Uploading State
          if (isUploading) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Uploading document, please wait...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: uploadProgress > 0 ? uploadProgress : null,
                backgroundColor: const Color(0xFFDBEAFE),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                minHeight: 4,
              ),
            ),
          ],

          // File actions (view/share) when file is present and not uploading
          if (hasFile && !isUploading) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: const Text('View', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFFDBEAFE)),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_rounded, size: 14),
                    label: const Text('Share', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Upload button when no file and editable and not uploading
          if (!hasFile && widget.isEditable && !isUploading) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: CustomPaint(
                painter: DashedRectPainter(
                  color: const Color(0xFF93C5FD),
                  strokeWidth: 1.4,
                ),
                child: TextButton.icon(
                  onPressed: onUpload,
                  icon: const Icon(Icons.upload_rounded,
                      size: 16, color: Color(0xFF2563EB)),
                  label: Text(
                    uploadButtonText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
