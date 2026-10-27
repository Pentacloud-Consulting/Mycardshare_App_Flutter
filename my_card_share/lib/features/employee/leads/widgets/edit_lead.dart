import '../../../../core/validators/contact_validator.dart';
import 'package:flutter/material.dart';
import '../../../../backend/individual/lead/active_lead.dart';
import '../../../../backend/individual/previews/user_leads.dart';

/// Clean and comprehensive Edit Lead sheet for Employee leads allowing full updates:
/// Name, Company, Email, Phone, Website, Location, Notes, and Lead Status!
class EditLeadSheet extends StatefulWidget {
  final LeadData lead;
  final String? targetUid;
  final Function(LeadData updatedLead)? onLeadUpdated;

  const EditLeadSheet({
    super.key,
    required this.lead,
    this.targetUid,
    this.onLeadUpdated,
  });

  static Future<LeadData?> show(
    BuildContext context, {
    required LeadData lead,
    String? targetUid,
    Function(LeadData updatedLead)? onLeadUpdated,
  }) {
    return showModalBottomSheet<LeadData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditLeadSheet(
        lead: lead,
        targetUid: targetUid,
        onLeadUpdated: onLeadUpdated,
      ),
    );
  }

  @override
  State<EditLeadSheet> createState() => _EditLeadSheetState();
}

class _EditLeadSheetState extends State<EditLeadSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  late String _selectedStatus;
  bool _isSaving = false;

  final List<String> _statuses = ['New', 'Contacted', 'Qualified', 'Lost'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lead.name);
    _companyController = TextEditingController(text: widget.lead.company);
    _emailController = TextEditingController(text: widget.lead.email);
    _phoneController = TextEditingController(text: widget.lead.phone);
    _websiteController = TextEditingController(text: widget.lead.website);
    _locationController = TextEditingController(text: widget.lead.location);
    _notesController = TextEditingController(text: widget.lead.notes);

    final currentStatus = widget.lead.status;
    _selectedStatus = _statuses.firstWhere(
      (s) => s.toLowerCase() == currentStatus.toLowerCase(),
      orElse: () => 'New',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'contacted':
        return const Color(0xFFEAB308);
      case 'qualified':
        return const Color(0xFF3B82F6);
      case 'lost':
        return const Color(0xFFEF4444);
      case 'new':
      default:
        return const Color(0xFF16A34A);
    }
  }

  Future<void> _handleSave() async {
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

    setState(() => _isSaving = true);

    final formattedPhone = ContactValidator.formatPhoneNumber(_phoneController.text.trim());
    final updatedLead = widget.lead.copyWith(
      name: _nameController.text.trim(),
      company: _companyController.text.trim().isNotEmpty
          ? _companyController.text.trim()
          : 'Independent',
      email: _emailController.text.trim(),
      phone: formattedPhone,
      website: _websiteController.text.trim(),
      location: _locationController.text.trim(),
      notes: _notesController.text.trim(),
      status: _selectedStatus,
    );

    final effectiveUid = widget.targetUid ?? widget.lead.targetUid;
    await UserLeadsService.instance.updateLead(effectiveUid, updatedLead);

    if (widget.onLeadUpdated != null) {
      widget.onLeadUpdated!(updatedLead);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, updatedLead);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text("Lead updated successfully (${updatedLead.status})!"),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0052FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit_note_rounded, color: Color(0xFF0052FF), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Edit Lead",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Scrollable Form Fields
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Selector
                    const Text(
                      "Lead Status",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _statuses.map((status) {
                        final isSelected = _selectedStatus.toLowerCase() == status.toLowerCase();
                        final color = _getStatusColor(status);
                        return ChoiceChip(
                          label: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: color,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? color : const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          onSelected: (val) {
                            if (val) setState(() => _selectedStatus = status);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Full Name
                    _buildInputField(
                      controller: _nameController,
                      label: "Full Name *",
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Name is required" : null,
                    ),

                    const SizedBox(height: 14),

                    // Company
                    _buildInputField(
                      controller: _companyController,
                      label: "Company / Organization",
                      icon: Icons.business_rounded,
                    ),

                    const SizedBox(height: 14),

                    // Phone & Email
                    _buildInputField(
                      controller: _phoneController,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => ContactValidator.validatePhone(v, required: false),
                    ),

                    const SizedBox(height: 14),

                    _buildInputField(
                      controller: _emailController,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => ContactValidator.validateEmail(v, required: false),
                    ),

                    const SizedBox(height: 14),

                    // Website & Location
                    _buildInputField(
                      controller: _websiteController,
                      label: "Website URL",
                      icon: Icons.language_rounded,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 14),

                    _buildInputField(
                      controller: _locationController,
                      label: "Location / City",
                      icon: Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 14),

                    // Notes
                    _buildInputField(
                      controller: _notesController,
                      label: "Conversation Notes",
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Action Buttons Row (Cancel & Save)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052FF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            "Save Changes",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: keyboardType == TextInputType.phone ? 15 : null,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18),
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
              borderSide: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
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
        ),
      ],
    );
  }
}
