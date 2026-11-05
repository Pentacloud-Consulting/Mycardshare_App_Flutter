import 'package:flutter/material.dart';
import '../../../backend/individual/profile/individual_profile_store.dart';
import '../../../backend/resume/resume_service.dart';
import '../../../backend/brochure/brochure_service.dart';

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
      ResumeService.openResume(_resumeUrl!);
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
      BrochureService.openBrochure(_brochureUrl!);
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
          const SizedBox(height: 8),
          const Text(
            "Upload your resume or company brochure (PDF, DOC, DOCX — max 50MB). These will be visible and downloadable on your public card.",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF2563EB),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasFile
                          ? (fileName ?? "Document uploaded")
                          : "No file uploaded",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: hasFile
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF64748B),
                        fontWeight:
                            hasFile ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasFile && widget.isEditable)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined,
                          color: Color(0xFF2563EB), size: 18),
                      tooltip: "View Document",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onOpen,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444), size: 18),
                      tooltip: "Delete Document",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onDelete,
                    ),
                  ],
                ),
            ],
          ),
          if (isUploading) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: uploadProgress,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                minHeight: 5,
              ),
            ),
          ] else if (hasFile) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.visibility_rounded,
                        size: 14, color: Colors.white),
                    label: const Text(
                      "View / Open",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_rounded,
                        size: 14, color: Color(0xFF2563EB)),
                    label: const Text(
                      "Share",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                if (widget.isEditable) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onUpload,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text(
                      "Replace",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB)),
                    ),
                  ),
                ],
              ],
            ),
          ] else if (widget.isEditable) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: onUpload,
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: DashedRectPainter(
                  color: const Color(0xFF93C5FD),
                  strokeWidth: 1.2,
                  dash: 6.0,
                  gap: 4.0,
                  radius: 12.0,
                ),
                child: Container(
                  height: 44,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.file_upload_outlined,
                          size: 18, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Text(
                        uploadButtonText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
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

typedef ProfileDocumentsCard = ProfileResumeCard;
