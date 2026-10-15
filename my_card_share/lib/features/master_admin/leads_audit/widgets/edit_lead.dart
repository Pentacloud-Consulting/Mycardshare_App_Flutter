import 'package:flutter/material.dart';

/// Clean Edit dialog/sheet for Master Admin lead audits to modify lead details or delivery status.
class MasterAdminEditLeadSheet extends StatefulWidget {
  final Map<String, dynamic> log;
  final Function(Map<String, dynamic> updatedLog)? onLogUpdated;

  const MasterAdminEditLeadSheet({
    super.key,
    required this.log,
    this.onLogUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> log,
    Function(Map<String, dynamic> updatedLog)? onLogUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MasterAdminEditLeadSheet(
        log: log,
        onLogUpdated: onLogUpdated,
      ),
    );
  }

  @override
  State<MasterAdminEditLeadSheet> createState() => _MasterAdminEditLeadSheetState();
}

class _MasterAdminEditLeadSheetState extends State<MasterAdminEditLeadSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _viaController;

  late String _selectedStatus;
  bool _isSaving = false;

  final List<String> _statuses = ['Delivered', 'Failed', 'Retrying'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.log['leadName']?.toString() ?? '');
    _companyController = TextEditingController(text: widget.log['company']?.toString() ?? '');
    _viaController = TextEditingController(text: widget.log['via']?.toString() ?? 'public_card_form');

    final currentStatus = widget.log['status']?.toString() ?? 'Delivered';
    _selectedStatus = _statuses.contains(currentStatus) ? currentStatus : 'Delivered';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _viaController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updated = Map<String, dynamic>.from(widget.log);
    updated['leadName'] = _nameController.text.trim();
    updated['company'] = _companyController.text.trim();
    updated['via'] = _viaController.text.trim();
    updated['status'] = _selectedStatus;
    updated['isDelivered'] = _selectedStatus == 'Delivered';

    if (widget.onLogUpdated != null) {
      widget.onLogUpdated!(updated);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Lead Audit Log updated successfully!"),
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
                      "Edit Lead Audit",
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
                      "Delivery Status",
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
                        Color color = const Color(0xFF10B981);
                        if (status == 'Failed') color = const Color(0xFFEF4444);
                        if (status == 'Retrying') color = const Color(0xFFF59E0B);

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
                      label: "Lead Contact Name *",
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Name is required" : null,
                    ),

                    const SizedBox(height: 14),

                    _buildInputField(
                      controller: _companyController,
                      label: "Target Company",
                      icon: Icons.business_rounded,
                    ),

                    const SizedBox(height: 14),

                    _buildInputField(
                      controller: _viaController,
                      label: "Captured Via (Channel/Webhook)",
                      icon: Icons.alt_route_rounded,
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
