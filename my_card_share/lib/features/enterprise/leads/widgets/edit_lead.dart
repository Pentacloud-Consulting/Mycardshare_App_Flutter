import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/home_backend/leads_service.dart';

/// Clean Edit Lead sheet for Enterprise leads allowing updating:
/// Name, Company, Email, and Sync/Lead Status!
class EnterpriseEditLeadSheet extends StatefulWidget {
  final Map<String, dynamic> lead;
  final Function(Map<String, dynamic> updatedLead)? onLeadUpdated;

  const EnterpriseEditLeadSheet({
    super.key,
    required this.lead,
    this.onLeadUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> lead,
    Function(Map<String, dynamic> updatedLead)? onLeadUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EnterpriseEditLeadSheet(
        lead: lead,
        onLeadUpdated: onLeadUpdated,
      ),
    );
  }

  @override
  State<EnterpriseEditLeadSheet> createState() => _EnterpriseEditLeadSheetState();
}

class _EnterpriseEditLeadSheetState extends State<EnterpriseEditLeadSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _emailController;

  late String _selectedStatus;
  bool _isSaving = false;

  final List<String> _statuses = ['Synced', 'Failed'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lead['name']?.toString() ?? '');
    _companyController = TextEditingController(text: widget.lead['company']?.toString() ?? '');
    _emailController = TextEditingController(text: widget.lead['email']?.toString() ?? '');

    final currentStatus = widget.lead['status']?.toString() ?? 'Synced';
    _selectedStatus = _statuses.contains(currentStatus) ? currentStatus : 'Synced';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final leadId = widget.lead['id']?.toString() ?? '';

    if (uid != null && leadId.isNotEmpty) {
      await EnterpriseLeadsService.instance.updateLead(
        uid: uid,
        leadId: leadId,
        name: _nameController.text.trim(),
        company: _companyController.text.trim(),
        email: _emailController.text.trim(),
        status: _selectedStatus,
      );
    }

    final updatedMap = Map<String, dynamic>.from(widget.lead);
    updatedMap['name'] = _nameController.text.trim();
    updatedMap['company'] = _companyController.text.trim();
    updatedMap['email'] = _emailController.text.trim();
    updatedMap['status'] = _selectedStatus;

    if (widget.onLeadUpdated != null) {
      widget.onLeadUpdated!(updatedMap);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, updatedMap);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Enterprise Lead updated successfully!"),
          ],
        ),
        backgroundColor: Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 2000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                      "Edit Enterprise Lead",
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

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sync Status",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _statuses.map((status) {
                        final isSelected = _selectedStatus == status;
                        final color = status == 'Synced' ? const Color(0xFF10B981) : const Color(0xFFEF4444);
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

                    _buildInputField(
                      controller: _nameController,
                      label: "Contact Name *",
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Name is required" : null,
                    ),

                    const SizedBox(height: 14),

                    _buildInputField(
                      controller: _companyController,
                      label: "Company / Account",
                      icon: Icons.business_rounded,
                    ),

                    const SizedBox(height: 14),

                    _buildInputField(
                      controller: _emailController,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

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
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
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
          ),
        ),
      ],
    );
  }
}
