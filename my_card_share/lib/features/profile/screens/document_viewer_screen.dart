import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// Clean and modern in-app document viewer screen.
/// Supports viewing PDF documents, image files, and Word/DOC files with fallback options.
class DocumentViewerScreen extends StatefulWidget {
  final String title;
  final String documentUrl;
  final String? fileName;
  final VoidCallback? onShare;

  const DocumentViewerScreen({
    super.key,
    required this.title,
    required this.documentUrl,
    this.fileName,
    this.onShare,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  late PdfViewerController _pdfViewerController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  bool get _isPdf {
    final clean = widget.documentUrl.toLowerCase();
    final name = (widget.fileName ?? '').toLowerCase();
    // Default to PDF unless clearly image or word doc
    if (_isImage || _isDocx) return false;
    return clean.contains('.pdf') || name.endsWith('.pdf') || clean.contains('firebasestorage');
  }

  bool get _isImage {
    final clean = widget.documentUrl.toLowerCase();
    final name = (widget.fileName ?? '').toLowerCase();
    return clean.contains('.png') ||
        clean.contains('.jpg') ||
        clean.contains('.jpeg') ||
        clean.contains('.webp') ||
        name.endsWith('.png') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.webp');
  }

  bool get _isDocx {
    final clean = widget.documentUrl.toLowerCase();
    final name = (widget.fileName ?? '').toLowerCase();
    return clean.contains('.doc') ||
        clean.contains('.docx') ||
        name.endsWith('.doc') ||
        name.endsWith('.docx');
  }

  Future<void> _openExternal() async {
    final clean = widget.documentUrl.trim();
    if (clean.isEmpty) return;
    try {
      final uri = Uri.parse(clean);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open document: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _openWithGoogleDocs() async {
    final clean = widget.documentUrl.trim();
    if (clean.isEmpty) return;
    try {
      final gDocsUrl =
          'https://docs.google.com/viewer?url=${Uri.encodeComponent(clean)}';
      await launchUrl(Uri.parse(gDocsUrl),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      _openExternal();
    }
  }

  void _shareDocument() {
    if (widget.onShare != null) {
      widget.onShare!();
    } else {
      Share.share(
        '📄 ${widget.title}: ${widget.documentUrl}',
        subject: widget.title,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.fileName != null && widget.fileName!.isNotEmpty)
              Text(
                widget.fileName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11.5,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFF2563EB)),
            tooltip: 'Share',
            onPressed: _shareDocument,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFF0F172A)),
            tooltip: 'Open in Browser',
            onPressed: _openExternal,
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isImage) {
      return _buildImageViewer();
    }

    if (_isDocx) {
      return _buildDocxViewer();
    }

    if (_isPdf) {
      return _buildPdfViewer();
    }

    return _buildPdfViewer();
  }

  Widget _buildImageViewer() {
    return Center(
      child: InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.8,
        maxScale: 4.0,
        child: Image.network(
          widget.documentUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF2563EB),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorState('Failed to load image preview.');
          },
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    return Stack(
      children: [
        SfPdfViewer.network(
          widget.documentUrl,
          controller: _pdfViewerController,
          canShowScrollHead: true,
          canShowScrollStatus: true,
          enableDoubleTapZooming: true,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = details.description;
              });
            }
          },
        ),
        if (_isLoading)
          Container(
            color: const Color(0xFFF8FAFC),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading document...',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDocxViewer() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.description_rounded,
                    size: 36,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.fileName ?? 'Document File',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Microsoft Word / Document format. You can preview it with Google Docs or open it directly in external apps.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openWithGoogleDocs,
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text('Preview in Google Docs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openExternal,
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open with Device App'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 30,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Could not load preview in-app',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openExternal,
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open in Browser / External App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
