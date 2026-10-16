import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'voice_service.dart';
import '../../../backend/Camera Card Scan & Voice/camera/camera_card_scan_service.dart';
import '../../../backend/Camera Card Scan & Voice/voice/voice_add_service.dart' as camera_voice_backend;

class VoiceScanModal extends ConsumerStatefulWidget {
  const VoiceScanModal({super.key});

  @override
  ConsumerState<VoiceScanModal> createState() => _VoiceScanModalState();
}

class _VoiceScanModalState extends ConsumerState<VoiceScanModal> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnim;
  late TextEditingController _transcriptController;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSuccess = false;
  String? _statusMessage;
  ExtractedCardContact? _extractedContact;

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    if (_isProcessing) return;

    if (_isListening) {
      // User tapped mic again to stop listening and process
      _finishListeningAndParse();
      return;
    }

    // Start listening state
    setState(() {
      _isListening = true;
      _isSuccess = false;
      _statusMessage = "Listening... Speak contact name, role, company, or email...";
    });
    _animController.repeat(reverse: true);
  }

  Future<void> _finishListeningAndParse([String? explicitText]) async {
    _animController.stop();
    _animController.reset();

    final text = (explicitText ?? _transcriptController.text).trim();

    if (text.isEmpty) {
      setState(() {
        _isListening = false;
        _isProcessing = false;
        _statusMessage = "Please enter or speak contact details (e.g., 'Met Alex, CTO at Acme, alex@acme.com')";
      });
      return;
    }

    setState(() {
      _isListening = false;
      _isProcessing = true;
      _statusMessage = "Extracting contact with AI...";
    });

    try {
      // Real AI Extraction & Sync to Backend / Vault
      final ExtractedCardContact extracted =
          await camera_voice_backend.VoiceAddService.extractFromSpokenTranscript(
        transcript: text,
        saveToVault: true,
      );

      if (!mounted) return;

      // Update local state and persist to Firestore
      await VoiceService.saveContact(
        ref,
        name: extracted.fullName.isNotEmpty ? extracted.fullName : 'Contact',
        role: extracted.jobTitle.isNotEmpty ? extracted.jobTitle : 'Contact',
        company: extracted.company.isNotEmpty ? extracted.company : 'Independent',
        phone: extracted.phone,
        email: extracted.email,
      );

      setState(() {
        _isProcessing = false;
        _isSuccess = true;
        _extractedContact = extracted;
        _statusMessage = "✓ Saved ${extracted.fullName} to Vault!";
      });

      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      context.push('/portal/vault');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✓ ${extracted.fullName} saved to Contact Vault!"),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _statusMessage = "Error parsing contact. Please check details.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Voice Add Contact",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Spoken Transcript / Editable Input Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isSuccess
                        ? const Color(0xFF4ADE80)
                        : _isListening
                            ? const Color(0xFFA855F7)
                            : Colors.white.withAlpha(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _transcriptController,
                      maxLines: 3,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                      cursorColor: const Color(0xFFA855F7),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Speak or type contact info...\n\"Met John Doe, Design Lead at Figma. Email john@figma.com\"",
                        hintStyle: TextStyle(
                          color: Colors.white.withAlpha(90),
                          fontSize: 14,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    if (_isSuccess && _extractedContact != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA855F7).withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFA855F7)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Parsed by AI: ${_extractedContact!.fullName} • ${_extractedContact!.company}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_statusMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _isListening
                              ? const Color(0xFFE9D5FF)
                              : Colors.white70,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Action Buttons if text typed or dictated
              if (_transcriptController.text.trim().isNotEmpty && !_isListening && !_isSuccess)
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : () => _finishListeningAndParse(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(_isProcessing ? "Processing with AI..." : "Process with AI"),
                ),

              const Spacer(),

              // Pulsing Mic Button
              ScaleTransition(
                scale: _pulseAnim,
                child: GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [const Color(0xFFEC4899), const Color(0xFFEF4444)]
                            : [const Color(0xFFA855F7), const Color(0xFFEC4899)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening
                                  ? const Color(0xFFEC4899)
                                  : const Color(0xFFA855F7))
                              .withAlpha(120),
                          blurRadius: 26,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                          : Icon(
                              _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Text(
                _isProcessing
                    ? "Saving to Vault..."
                    : _isListening
                        ? "Tap mic to finish speaking"
                        : _isSuccess
                            ? "Saved!"
                            : "Tap mic to speak or enter text above",
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}


