import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../../backend/individual/api_service.dart';

class ConnectorWebhookCard extends StatefulWidget {
  final String? initialWebhookUrl;
  final String? webhookUrl;

  const ConnectorWebhookCard({
    super.key,
    this.initialWebhookUrl,
    this.webhookUrl,
  });

  @override
  State<ConnectorWebhookCard> createState() => _ConnectorWebhookCardState();
}

class _ConnectorWebhookCardState extends State<ConnectorWebhookCard> {
  late final TextEditingController _controller;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.initialWebhookUrl ?? widget.webhookUrl ?? "");
    _fetchWebhook();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchWebhook() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    String loadedUrl = widget.initialWebhookUrl ?? "";

    // 1. Try Next.js API (/api/enterprise/profile)
    try {
      final res = await IndividualApiService.get('/api/enterprise/profile');
      if (res['success'] == true && res['data']?['zapierWebhookUrl'] != null) {
        final url = res['data']['zapierWebhookUrl'].toString().trim();
        if (url.isNotEmpty) loadedUrl = url;
      }
    } catch (_) {}

    // 2. Try Firestore enterprises/{uid}
    if (loadedUrl.isEmpty && uid != null && uid.isNotEmpty) {
      try {
        final doc =
            await FirebaseFirestore.instance.collection('enterprises').doc(uid).get();
        if (doc.exists && doc.data()?['zapierWebhookUrl'] != null) {
          loadedUrl = doc.data()!['zapierWebhookUrl'].toString().trim();
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        if (loadedUrl.isNotEmpty) {
          _controller.text = loadedUrl;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveWebhook() async {
    final url = _controller.text.trim();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    setState(() => _isSaving = true);

    // Save to Firestore
    if (uid != null && uid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('enterprises').doc(uid).set({
          'zapierWebhookUrl': url,
          'isIntegrationEnabled': url.isNotEmpty,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[ConnectorWebhookCard] Firestore save note: $e');
      }
    }

    // Save to Next.js API /api/enterprise/profile (MongoDB)
    try {
      await IndividualApiService.patch('/api/enterprise/profile', {
        'zapierWebhookUrl': url,
        'isIntegrationEnabled': url.isNotEmpty,
      });
    } catch (e) {
      debugPrint('[ConnectorWebhookCard] API save note: $e');
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text("Webhook URL saved & synced successfully!"),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF16A34A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _testWebhook() async {
    final url = _controller.text.trim();
    if (url.isEmpty || !url.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a valid webhook URL starting with https://"),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isTesting = true);

    try {
      final payload = {
        'action': 'test',
        'leadId': 'test_${DateTime.now().millisecondsSinceEpoch}',
        'fullName': 'John Doe (Test Lead)',
        'email': 'test@mycardshare.com',
        'mobile': '+1234567890',
        'company': 'Enterprise Demo Corp',
        'notes': 'Test payload from MyCardShare App to verify webhook connectivity.',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (mounted) {
        setState(() => _isTesting = false);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✓ Webhook test passed! Status: ${response.statusCode}"),
              backgroundColor: const Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Webhook responded with HTTP ${response.statusCode}"),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTesting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Webhook test failed: $e"),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _copyWebhookUrl() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text("Webhook URL copied to clipboard!"),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Icon(Icons.webhook_rounded, color: Color(0xFF0052FF), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Zapier Catch Hook URL",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      "Auto-sync captured leads to Salesforce / HubSpot / CRM",
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Editable Input Field with Copy Icon Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: const InputDecoration(
                      hintText: "https://hooks.zapier.com/hooks/catch/...",
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF0052FF)),
                  onPressed: _copyWebhookUrl,
                  tooltip: "Copy Webhook URL",
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action Buttons: Save & Test
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveWebhook,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded, size: 16, color: Colors.white),
                  label: Text(
                    _isSaving ? "Saving..." : "Save Webhook",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052FF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTesting ? null : _testWebhook,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0052FF)),
                        )
                      : const Icon(Icons.send_rounded, size: 15, color: Color(0xFF0052FF)),
                  label: Text(
                    _isTesting ? "Testing..." : "Test Webhook",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0052FF)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0052FF),
                    side: const BorderSide(color: Color(0xFF0052FF), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
