import '../../../core/validators/contact_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'manual_service.dart';
import '../../../backend/individual/scan/manual_entry_service.dart';

import '../../../providers/vault_provider.dart';

class ManualAddContactDialog extends ConsumerStatefulWidget {
  const ManualAddContactDialog({super.key});

  @override
  ConsumerState<ManualAddContactDialog> createState() => _ManualAddContactDialogState();
}

class _ManualAddContactDialogState extends ConsumerState<ManualAddContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isSaving = false;

  void _saveContact() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid phone number (min 10 digits) and email."),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final title = _titleController.text.trim();
      final company = _companyController.text.trim();
      final phone = ContactValidator.formatPhoneNumber(_phoneController.text.trim());
      final email = _emailController.text.trim();

      // 🛡️ Find existing contact with matching details in the Vault
      final existingContact = ref.read(vaultNotifierProvider.notifier).findExistingContact(
            name: name,
            phone: phone,
            email: email,
            company: company,
          );

      bool isUpdatingExisting = false;

      if (existingContact != null) {
        final existingName = existingContact['name'] ?? name;
        final shouldUpdate = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Contact Already Exists',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
            content: Text(
              'A contact matching "$existingName" with similar details is already in your Contact Vault.\n\nWould you like to update the existing contact instead of creating a duplicate?',
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B), height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Update Contact'),
              ),
            ],
          ),
        );

        if (shouldUpdate != true) {
          return; // User canceled; stay on dialog to adjust fields
        }
        isUpdatingExisting = true;
      }

      setState(() {
        _isSaving = true;
      });

      // 1. Instant optimistic update to Riverpod Vault state (deduplicated)
      try {
        ManualService.saveContact(
          ref,
          name: name,
          role: title.isNotEmpty ? title : 'Contact',
          company: company.isNotEmpty ? company : 'Independent',
          phone: phone,
          email: email,
        );
      } catch (e) {
        debugPrint("[ManualAddContactDialog] Local state update note: $e");
      }

      // 2. Persist to Firestore & metrics in background / asynchronously
      try {
        final manualContact = ManualEntryService.instance.createManualContact(
          name: name,
          role: title,
          company: company,
          phone: phone,
          email: email,
        );
        await ManualEntryService.instance.saveManualContact(manualContact);
      } catch (e) {
        debugPrint("[ManualAddContactDialog] Persistence note: $e");
      }

      if (!mounted) return;

      // Close dialog safely
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Navigate to vault or notify user
      try {
        final currentPath = GoRouterState.of(context).uri.path;
        if (currentPath != '/portal/vault') {
          context.push('/portal/vault');
        }
      } catch (_) {
        context.push('/portal/vault');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUpdatingExisting
                ? "✓ $name updated in Contact Vault!"
                : "✓ $name added to Contact Vault!",
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enter Contact Manually',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  _nameController,
                  "Full Name",
                  Icons.person_outline_rounded,
                  required: true,
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Name is required" : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(_titleController, "Job Title / Role", Icons.badge_outlined),
                const SizedBox(height: 12),
                _buildTextField(_companyController, "Company", Icons.apartment_rounded),
                const SizedBox(height: 12),
                _buildTextField(
                  _phoneController,
                  "Phone Number",
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  hintText: "+91 98765 43210",
                  maxLength: 20,
                  required: true,
                  validator: (v) => ContactValidator.validatePhone(v, required: true),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  _emailController,
                  "Email Address",
                  Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  hintText: "example@mail.com",
                  required: true,
                  validator: (v) => ContactValidator.validateEmail(v, required: true),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                          )
                        : const Text(
                            "Save to Contact Vault",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator ??
          (val) {
            if (required && (val == null || val.trim().isEmpty)) {
              return "Please enter $label";
            }
            return null;
          },
      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        counterText: "",
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0066FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }
}


