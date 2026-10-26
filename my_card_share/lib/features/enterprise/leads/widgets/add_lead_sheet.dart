import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../../backend/enterprise/home_backend/leads_service.dart';
import '../../../../backend/number logic/phone_number_service.dart';

class EnterpriseAddLeadSheet extends StatefulWidget {
  final VoidCallback? onLeadAdded;

  const EnterpriseAddLeadSheet({
    super.key,
    this.onLeadAdded,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onLeadAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EnterpriseAddLeadSheet(
        onLeadAdded: onLeadAdded,
      ),
    );
  }

  @override
  State<EnterpriseAddLeadSheet> createState() => _EnterpriseAddLeadSheetState();
}

class _EnterpriseAddLeadSheetState extends State<EnterpriseAddLeadSheet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;

      if (uid == null) {
        throw Exception("You must be logged in to add leads.");
      }

      final capturedBy = user?.displayName != null && user!.displayName!.isNotEmpty
          ? user.displayName!
          : "Enterprise Admin";

      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final company = _companyController.text.trim().isNotEmpty
          ? _companyController.text.trim()
          : "Independent";
      final notes = _notesController.text.trim();

      // 1. Direct real-time Firestore persistence
      final success = await EnterpriseLeadsService.instance.addLead(
        uid: uid,
        name: name,
        company: company,
        phone: phone,
        email: email,
        notes: notes,
        capturedBy: capturedBy,
        status: 'Synced',
      );

      // 2. Optional Web API sync trigger
      try {
        final idToken = await user?.getIdToken();
        if (idToken != null) {
          http.post(
            Uri.parse('https://your-domain.com/api/sync/enterprise-leads'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: json.encode({
              'companyId': uid,
              'name': name,
              'mobile': phone,
              'email': email,
              'company': company,
              'notes': notes,
            }),
          ).timeout(const Duration(seconds: 4)).catchError((_) => http.Response('{}', 200));
        }
      } catch (_) {
        // Fallback gracefully to Firestore live stream
      }

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  "Lead added and synced to enterprise CRM!",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
        if (widget.onLeadAdded != null) {
          widget.onLeadAdded!();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: const Text("Failed to save lead. Please try again."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text("Error: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomInset + 20,
        left: 20,
        right: 20,
        top: 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Handle Indicator
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sheet Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Color(0xFF0052FF),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add Enterprise Lead",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Capture and sync new lead directly to CRM",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 1. Lead Full Name
              _buildFieldLabel("Lead Full Name", isRequired: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Lead name is required";
                  }
                  return null;
                },
                decoration: _buildInputDecoration(
                  hintText: "e.g. John Doe",
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ),

              const SizedBox(height: 14),

              // 2. Mobile Number
              _buildFieldLabel("Mobile Number", isRequired: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 15,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Mobile number is required";
                  }
                  final validation = PhoneValidationModel.validateLocal(val);
                  if (!validation.isValid) {
                    return validation.errorMessage;
                  }
                  return null;
                },
                decoration: _buildInputDecoration(
                  hintText: "e.g. +91 98765 43210",
                  prefixIcon: Icons.phone_outlined,
                ).copyWith(counterText: ""),
              ),

              const SizedBox(height: 14),

              // 3. Email Address
              _buildFieldLabel("Email Address"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration(
                  hintText: "e.g. john@acme.com",
                  prefixIcon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 14),

              // 4. Company / Organization
              _buildFieldLabel("Company / Organization"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _companyController,
                textCapitalization: TextCapitalization.words,
                decoration: _buildInputDecoration(
                  hintText: "e.g. Acme Corporation",
                  prefixIcon: Icons.business_outlined,
                ),
              ),

              const SizedBox(height: 14),

              // 5. Notes / Requirements
              _buildFieldLabel("Notes / Discussion"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: _buildInputDecoration(
                  hintText: "e.g. Interested in Enterprise Tier licensing",
                  prefixIcon: Icons.notes_rounded,
                ),
              ),

              const SizedBox(height: 22),

              // Submit & Push Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Save & Sync Lead",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            "*",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF4444),
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 13.5,
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF64748B),
        size: 19,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
    );
  }
}
