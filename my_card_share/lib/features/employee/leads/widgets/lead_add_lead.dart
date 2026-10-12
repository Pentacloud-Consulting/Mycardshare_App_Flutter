import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/employee_join/lead/add_lead.dart';

/// Modal Bottom Sheet & Dialog for adding leads for an individual user or multiple users.
/// Can be invoked from Master Admin Leads Audit, Enterprise, or Individual Leads screen.
class LeadAddLeadSheet extends StatefulWidget {
  final String? defaultTargetUid;
  final bool allowMultiUser;

  const LeadAddLeadSheet({
    super.key,
    this.defaultTargetUid,
    this.allowMultiUser = true,
  });

  /// Static helper to show the sheet from anywhere
  static Future<void> show(
    BuildContext context, {
    String? defaultTargetUid,
    bool allowMultiUser = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LeadAddLeadSheet(
        defaultTargetUid: defaultTargetUid,
        allowMultiUser: allowMultiUser,
      ),
    );
  }

  @override
  State<LeadAddLeadSheet> createState() => _LeadAddLeadSheetState();
}

class _LeadAddLeadSheetState extends State<LeadAddLeadSheet> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  // Assignment State
  bool _isMultiUserMode = false;
  String _selectedSingleUid = '';
  final Set<String> _selectedMultiUids = {};
  List<Map<String, dynamic>> _availableUsers = [];
  bool _isLoadingUsers = true;

  // Lead Properties
  String _selectedStatus = 'New';
  String _selectedSource = 'via Manual';
  bool _isSubmitting = false;

  final List<String> _statuses = ['New', 'Contacted', 'Qualified', 'Lost'];
  final List<String> _sources = [
    'via Manual',
    'via QR Scan',
    'via Website',
    'via Referral',
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await AddLeadService.instance.fetchAssignableUsers();
      if (!mounted) return;

      setState(() {
        _availableUsers = users;
        _isLoadingUsers = false;

        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final initialUid = widget.defaultTargetUid ?? currentUid;

        if (users.any((u) => u['uid'] == initialUid)) {
          _selectedSingleUid = initialUid;
        } else if (users.isNotEmpty) {
          _selectedSingleUid = users.first['uid'] as String;
        }

        if (_selectedSingleUid.isNotEmpty) {
          _selectedMultiUids.add(_selectedSingleUid);
        }
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingUsers = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isMultiUserMode && _selectedMultiUids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one user to assign the lead to"),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_isMultiUserMode && _selectedSingleUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a target user"),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_isMultiUserMode) {
        final leads = await AddLeadService.instance.addLeadForMultipleUsers(
          targetUids: _selectedMultiUids.toList(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          company: _companyController.text.trim(),
          notes: _notesController.text.trim(),
          status: _selectedStatus,
          source: _selectedSource,
        );

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✓ Lead '${_nameController.text.trim()}' successfully assigned to ${leads.length} users!",
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final lead = await AddLeadService.instance.addLead(
          targetUid: _selectedSingleUid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          company: _companyController.text.trim(),
          notes: _notesController.text.trim(),
          status: _selectedStatus,
          source: _selectedSource,
        );

        if (!mounted) return;
        Navigator.pop(context);

        if (lead != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✓ Lead '${lead.name}' successfully added!"),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving lead: $e"),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                width: 44,
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
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Color(0xFF0052FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Add New Lead",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        _isMultiUserMode
                            ? "Assign lead to multiple users simultaneously"
                            : "Directly capture and assign lead",
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 14),

            // Scrollable Form Fields
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Multi-User vs Single Assignee Toggle (if enabled)
                    if (widget.allowMultiUser) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Assignment Mode",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(3),
                            child: Row(
                              children: [
                                _buildModeTab(
                                  label: "Single User",
                                  isSelected: !_isMultiUserMode,
                                  onTap: () => setState(() => _isMultiUserMode = false),
                                ),
                                _buildModeTab(
                                  label: "Multiple Users",
                                  isSelected: _isMultiUserMode,
                                  onTap: () => setState(() => _isMultiUserMode = true),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // User Picker Section
                      if (_isLoadingUsers)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(color: Color(0xFF0052FF)),
                        )
                      else if (_isMultiUserMode)
                        _buildMultiUserSelector()
                      else
                        _buildSingleUserDropdown(),

                      const SizedBox(height: 16),
                    ],

                    // Contact Name Field
                    _buildField(
                      controller: _nameController,
                      label: "Full Name",
                      hint: "e.g. Michael Chang",
                      icon: Icons.person_outline_rounded,
                      required: true,
                    ),
                    const SizedBox(height: 14),

                    // Company Name Field
                    _buildField(
                      controller: _companyController,
                      label: "Company / Organization",
                      hint: "e.g. Acme Tech Solutions",
                      icon: Icons.apartment_rounded,
                      required: true,
                    ),
                    const SizedBox(height: 14),

                    // Job Title Field
                    _buildField(
                      controller: _roleController,
                      label: "Job Title / Role",
                      hint: "e.g. VP of Business Development",
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 14),

                    // Email Address Field
                    _buildField(
                      controller: _emailController,
                      label: "Email Address",
                      hint: "e.g. michael@acmetech.com",
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      required: true,
                    ),
                    const SizedBox(height: 14),

                    // Phone Number Field
                    _buildField(
                      controller: _phoneController,
                      label: "Phone Number",
                      hint: "e.g. +1 555-0199",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Status Chips
                    const Text(
                      "Lead Status",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _statuses.map((status) {
                        final isSelected = _selectedStatus == status;
                        Color statusColor = const Color(0xFF0052FF);
                        if (status == 'Qualified') statusColor = const Color(0xFF10B981);
                        if (status == 'Contacted') statusColor = const Color(0xFFF59E0B);
                        if (status == 'Lost') statusColor = const Color(0xFF64748B);

                        return ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedStatus = status);
                          },
                          selectedColor: statusColor.withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? statusColor : const Color(0xFF64748B),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? statusColor : const Color(0xFFE2E8F0),
                            ),
                          ),
                          backgroundColor: Colors.white,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Source Chips
                    const Text(
                      "Lead Source",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sources.map((src) {
                        final isSelected = _selectedSource == src;
                        return ChoiceChip(
                          label: Text(src),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedSource = src);
                          },
                          selectedColor: const Color(0xFFEFF6FF),
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? const Color(0xFF0052FF) : const Color(0xFF64748B),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF0052FF) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          backgroundColor: Colors.white,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Notes Field
                    _buildField(
                      controller: _notesController,
                      label: "Notes & Follow-up Details",
                      hint: "Key discussion points, meeting dates, or interest area...",
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
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
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isMultiUserMode
                                ? Icons.group_add_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isMultiUserMode
                                ? "Assign Lead to ${_selectedMultiUids.length} Users"
                                : "Add Lead to Contact Vault",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF0052FF) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleUserDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _availableUsers.any((u) => u['uid'] == _selectedSingleUid)
              ? _selectedSingleUid
              : (_availableUsers.isNotEmpty ? _availableUsers.first['uid'] : null),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF64748B)),
          items: _availableUsers.map((u) {
            return DropdownMenuItem<String>(
              value: u['uid'] as String,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFF0052FF).withValues(alpha: 0.12),
                    child: Text(
                      (u['name'] as String).substring(0, 1.clamp(0, (u['name'] as String).length)),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0052FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${u['name']} (${u['role'].isNotEmpty ? u['role'] : 'Member'})",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedSingleUid = val);
          },
        ),
      ),
    );
  }

  Widget _buildMultiUserSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Selected: ${_selectedMultiUids.length} of ${_availableUsers.length}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0052FF),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedMultiUids.length == _availableUsers.length) {
                      _selectedMultiUids.clear();
                    } else {
                      _selectedMultiUids.addAll(_availableUsers.map((u) => u['uid'] as String));
                    }
                  });
                },
                child: Text(
                  _selectedMultiUids.length == _availableUsers.length
                      ? "Clear All"
                      : "Select All",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 130),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _availableUsers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, idx) {
                final user = _availableUsers[idx];
                final uid = user['uid'] as String;
                final isChecked = _selectedMultiUids.contains(uid);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isChecked) {
                        _selectedMultiUids.remove(uid);
                      } else {
                        _selectedMultiUids.add(uid);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          isChecked
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 18,
                          color: isChecked ? const Color(0xFF0052FF) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user['name'] as String,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                              color: const Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          user['role'] as String,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            if (required)
              const Text(
                " *",
                style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
          validator: (val) {
            if (required && (val == null || val.trim().isEmpty)) {
              return "Please enter $label";
            }
            if (keyboardType == TextInputType.emailAddress &&
                val != null &&
                val.trim().isNotEmpty &&
                !val.contains('@')) {
              return "Please enter a valid email address";
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
