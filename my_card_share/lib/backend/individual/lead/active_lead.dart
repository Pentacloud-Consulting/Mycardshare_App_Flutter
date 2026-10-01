import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api_service.dart';
import '../scan_profile_view/scan_profile_view.dart';
import '../previews/user_leads.dart';
import '../previews/individual_metrics_store.dart';
import '../notification/lead_requirest.dart';

class LeadData {
  final String id;
  final String targetUid;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String notes;
  final String status; // 'New', 'Contacted', 'Qualified', 'Lost'
  final String source; // 'via QR scan', 'via Voice', 'via Manual'
  final DateTime createdAt;

  LeadData({
    required this.id,
    required this.targetUid,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    this.notes = '',
    this.status = 'New',
    this.source = 'via QR scan',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get initials {
    if (name.trim().isEmpty) return 'LD';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetUid': targetUid,
        'name': name,
        'email': email,
        'phone': phone,
        'company': company,
        'notes': notes,
        'status': status,
        'source': source,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LeadData.fromJson(Map<String, dynamic> json) {
    return LeadData(
      id: json['id'] ?? '',
      targetUid: json['targetUid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      company: json['company'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'New',
      source: json['source'] ?? 'via QR scan',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Active lead submission service to capture visitor details when "Exchange Contact" is clicked.
class ActiveLeadService {
  ActiveLeadService._internal();
  static final ActiveLeadService instance = ActiveLeadService._internal();

  /// Submits lead data to Firestore & Next.js API, updates real metric counters, and triggers notifications.
  Future<void> submitLead(LeadData lead) async {
    debugPrint('[ActiveLeadService] Submitting new lead for target UID: ${lead.targetUid}');
    
    try {
      // 1. Save to Firestore under target user's leads collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(lead.targetUid)
          .collection('leads')
          .doc(lead.id)
          .set(lead.toJson());

      debugPrint('[ActiveLeadService] Saved lead ${lead.id} to Firestore for ${lead.targetUid}');
    } catch (e) {
      debugPrint('[ActiveLeadService] Firestore save notice: $e');
    }

    // 2. Post lead to Next.js API /api/leads/create in background (MongoDB & CRM sync)
    try {
      final Uri url = Uri.parse('${IndividualApiService.baseUrl}/api/leads/create');
      http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cardId': lead.targetUid,
          'fullName': lead.name,
          'email': lead.email,
          'mobile': lead.phone,
          'company': lead.company,
          'notes': lead.notes,
          'capturedVia': 'public_card_form',
        }),
      ).catchError((_) => http.Response('', 500));
    } catch (apiErr) {
      debugPrint('[ActiveLeadService] API lead sync notice: $apiErr');
    }

    // 3. Add lead to local UserLeadsService store
    UserLeadsService.instance.addLead(lead.targetUid, lead);

    // 4. Increment real Leads count on Home Dashboard box
    await IndividualMetricsStore.instance.incrementLeads(lead.targetUid);

    // 5. Send lead notification to card owner
    await LeadRequestNotification.instance.sendLeadNotification(lead.targetUid, lead);
  }

  /// Opens the Exchange Contact Form modal dialog (Matching Image 3 specs)
  static void showLeadExchangeModal(BuildContext context, {required PublicProfileData profile}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LeadExchangeFormSheet(profile: profile),
    );
  }
}

class _LeadExchangeFormSheet extends StatefulWidget {
  final PublicProfileData profile;

  const _LeadExchangeFormSheet({required this.profile});

  @override
  State<_LeadExchangeFormSheet> createState() => _LeadExchangeFormSheetState();
}

class _LeadExchangeFormSheetState extends State<_LeadExchangeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final leadId = 'lead_${DateTime.now().millisecondsSinceEpoch}';
    final lead = LeadData(
      id: leadId,
      targetUid: widget.profile.uid,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      company: _companyController.text.trim().isNotEmpty
          ? _companyController.text.trim()
          : 'Independent',
      notes: _notesController.text.trim(),
      source: 'via QR scan',
      status: 'New',
    );

    await ActiveLeadService.instance.submitLead(lead);

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✓ Contact shared with ${widget.profile.fullName}!"),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Exchange Contact",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          "Share your info with ${widget.profile.fullName}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form fields
              _buildInput("Full Name *", _nameController, Icons.person_outline_rounded, required: true),
              const SizedBox(height: 12),
              _buildInput("Email Address *", _emailController, Icons.mail_outline_rounded, required: true, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildInput("Phone Number *", _phoneController, Icons.phone_outlined, required: true, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildInput("Company", _companyController, Icons.apartment_rounded),
              const SizedBox(height: 12),
              _buildInput("Notes / Message (Optional)", _notesController, Icons.chat_bubble_outline_rounded, maxLines: 2),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          "Send Contact Details",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (val) {
        if (required && (val == null || val.trim().isEmpty)) {
          return "Please enter $label";
        }
        return null;
      },
      style: const TextStyle(fontSize: 14.5, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, size: 19, color: const Color(0xFF0052FF)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
        ),
      ),
    );
  }
}
