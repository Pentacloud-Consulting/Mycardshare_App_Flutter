import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VoiceScanModal extends StatefulWidget {
  const VoiceScanModal({super.key});

  @override
  State<VoiceScanModal> createState() => _VoiceScanModalState();
}

class _VoiceScanModalState extends State<VoiceScanModal> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnim;

  bool _isListening = false;
  bool _isSuccess = false;
  String _transcript = "Tap microphone and speak contact details out loud...";

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    if (_isListening) return;

    setState(() {
      _isListening = true;
      _transcript = "Listening... Speak clearly...";
    });
    _animController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    setState(() {
      _transcript = '"Met Sarah Jenkins, VP of Marketing at CloudScale. Her email is sarah@cloudscale.io"';
    });

    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    _animController.stop();
    setState(() {
      _isListening = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    context.go('/portal/vault');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✓ Sarah Jenkins added to Contact Vault via Voice Add!"),
        backgroundColor: Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Transcript Display Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isSuccess
                        ? const Color(0xFFA855F7)
                        : Colors.white.withAlpha(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _transcript,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isListening
                            ? const Color(0xFFE9D5FF)
                            : _isSuccess
                                ? const Color(0xFF4ADE80)
                                : Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                        fontStyle: _isListening ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    if (_isSuccess) ...[
                      const SizedBox(height: 12),
                      const Chip(
                        avatar: Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                        label: Text("Parsed by AI • Saved to Vault"),
                        backgroundColor: Color(0xFFA855F7),
                        labelStyle: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA855F7).withAlpha(100),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Text(
                _isListening
                    ? "Tap when finished speaking"
                    : _isSuccess
                        ? "Saved!"
                        : "Tap mic to start speaking",
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
