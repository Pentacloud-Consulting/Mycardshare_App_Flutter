import 'package:flutter/material.dart';
import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';
import 'active_lead.dart';
import '../notification/lead_requirest.dart';

/// Exchange Contact service connecting front-end user forms, active lead store, and dynamic notification dispatching.
class ExchangeContactService {
  ExchangeContactService._internal();
  static final ExchangeContactService instance = ExchangeContactService._internal();

  /// Opens the Exchange Contact Form modal for a given user profile or target UID
  void showExchangeContactModal(
    BuildContext context, {
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
    String? targetUid,
  }) {
    final activeProfile = profile ?? IndividualProfileStore.instance.activeProfile;
    final resolvedUid = publicProfile?.uid ?? activeProfile?.uid ?? targetUid ?? 'user_default';
    final resolvedName = publicProfile?.fullName ?? activeProfile?.fullName ?? 'Card Owner';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ExchangeContactSheet(
        targetUid: resolvedUid,
        targetName: resolvedName,
      ),
    );
  }
}

class _ExchangeContactSheet extends StatefulWidget {
  final String targetUid;
  final String targetName;

  const _ExchangeContactSheet({
    required this.targetUid,
    required this.targetName,
  });

  @override
  State<_ExchangeContactSheet> createState() => _ExchangeContactSheetState();
}

class _ExchangeContactSheetState extends State<_ExchangeContactSheet> {
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
      targetUid: widget.targetUid,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      company: _companyController.text.trim().isNotEmpty
          ? _companyController.text.trim()
          : 'Independent',
      notes: _notesController.text.trim(),
      source: 'via Exchange Contact',
      status: 'New',
    );

    // 1. Submit lead to Firestore, Next.js API, and increment real counters
    await ActiveLeadService.instance.submitLead(lead);

    // 2. Dispatch real lead request notification to recipient & app screen
    await LeadRequestNotification.instance.sendLeadNotification(widget.targetUid, lead);

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);

    // 3. Show mobile floating notification screen banner
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "✓ Contact shared with ${widget.targetName}! Notification sent.",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0052FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
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
        boxShadow: [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
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
                        const Text(
                          "Exchange Contact",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Share your contact details with ${widget.targetName}",
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
              _buildInput("Company / Organization", _companyController, Icons.apartment_rounded),
              const SizedBox(height: 12),
              _buildInput("Notes / Message (Optional)", _notesController, Icons.chat_bubble_outline_rounded, maxLines: 2),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Send Contact & Notify",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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


