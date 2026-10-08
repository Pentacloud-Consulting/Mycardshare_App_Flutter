import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_backend/employees_page.dart';
import '../multiple_store/enterprise_multi_store.dart';
import '../profile/enterprise_profile_store.dart';
import 'invite_link.dart';

export 'popup_invite.dart';
export 'invite_link.dart';

/// Opens the complete, real-time Enterprise Invite Form Page Modal.
Future<void> showEnterpriseInviteModal(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const EnterpriseInviteFormModal(),
  );
}

/// Floating or Inline "+ Invite" Button Widget (Image 2 style)
class EnterpriseInviteButton extends StatelessWidget {
  final VoidCallback? onTap;

  const EnterpriseInviteButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => showEnterpriseInviteModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0052FF).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              "Invite",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Real-Time Enterprise Invite Form Page Modal Sheet
class EnterpriseInviteFormModal extends StatefulWidget {
  const EnterpriseInviteFormModal({super.key});

  @override
  State<EnterpriseInviteFormModal> createState() => _EnterpriseInviteFormModalState();
}

class _EnterpriseInviteFormModalState extends State<EnterpriseInviteFormModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Single Add Employee Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String _selectedRole = 'Employee';

  // Batch Invite Controllers
  final TextEditingController _batchEmailController = TextEditingController();
  final List<String> _invitedEmailsList = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _titleController.dispose();
    _batchEmailController.dispose();
    super.dispose();
  }

  void _addBatchEmail() {
    final em = _batchEmailController.text.trim();
    if (em.isNotEmpty && em.contains('@')) {
      setState(() {
        if (!_invitedEmailsList.contains(em)) {
          _invitedEmailsList.add(em);
        }
        _batchEmailController.clear();
      });
    } else if (em.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a valid email address."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// Submit Direct Single Employee Addition
  Future<void> _submitSingleEmployee() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final title = _titleController.text.trim();

    if (uid == null || name.isEmpty || email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please provide a valid employee name and work email."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await EnterpriseEmployeesService.instance.addEmployee(
        uid: uid,
        name: name,
        email: email,
        roleTitle: title.isNotEmpty ? title : 'Employee',
        role: _selectedRole,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Successfully added $name to your workspace!"),
              backgroundColor: const Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add employee: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Submit Batch Email Invitations (Updates Firestore invitedEmails array)
  Future<void> _submitBatchInvites() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (_invitedEmailsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please add at least one email address to send invites."),
          backgroundColor: Colors.amber[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Merge with existing invitedEmails in enterprises/{uid}
      final docRef = FirebaseFirestore.instance.collection('enterprises').doc(uid);
      await docRef.set({
        'invitedEmails': FieldValue.arrayUnion(_invitedEmailsList),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Sync multi store
      final companyName =
          EnterpriseProfileStore.instance.currentProfile?.companyName ?? 'Enterprise Workspace';
      for (final email in _invitedEmailsList) {
        EnterpriseMultiStore.instance.saveUser(
          companyName: companyName,
          email: email,
          password: 'Password123!',
          role: 'Employee',
        );
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invited ${_invitedEmailsList.length} member(s) to workspace!"),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error sending invites: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4.5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 14),

          // Header Title + Close Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person_add_rounded, color: Color(0xFF0052FF), size: 24),
                    SizedBox(width: 10),
                    Text(
                      "Add & Invite Team",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Segmented Tab Bar: Direct Add vs Invite by Email/Link
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelColor: const Color(0xFF0052FF),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: "Add Member"),
                Tab(text: "Invite by Email"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Views Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDirectAddTab(),
                _buildInviteLinkAndEmailTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: DIRECT MEMBER ADD ---
  Widget _buildDirectAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Full Name"),
          _buildInputField(
            controller: _nameController,
            hint: "e.g. Alex Stanton",
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),

          _buildLabel("Work Email"),
          _buildInputField(
            controller: _emailController,
            hint: "e.g. alex.stanton@company.com",
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),

          _buildLabel("Job Title"),
          _buildInputField(
            controller: _titleController,
            hint: "e.g. Chief Operations Officer",
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 14),

          _buildLabel("Access Role"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRole,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'Employee',
                    child: Text("Employee (Standard Card User)"),
                  ),
                  DropdownMenuItem(
                    value: 'Admin',
                    child: Text("Admin (Full Workspace Controls)"),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isSubmitting ? null : _submitSingleEmployee,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Add Team Member Now",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- TAB 2: INVITE LINK & BATCH EMAILS (Matching Onboarding Step 2) ---
  Widget _buildInviteLinkAndEmailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unique Per-Enterprise Invite Link Card (Image 1)
          const EnterpriseInviteLinkWidget(),

          const SizedBox(height: 16),

          // Email Input Field + Add Button
          _buildLabel("Or Invite Team Members by Email"),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _batchEmailController,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      hintText: "Enter email (e.g. employee@company.com)",
                      prefixIcon: Icon(Icons.mail_outline_rounded, color: Color(0xFF64748B), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    onSubmitted: (_) => _addBatchEmail(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: _addBatchEmail,
                    child: const Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Chips List of added emails
          if (_invitedEmailsList.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_invitedEmailsList.length, (index) {
                final em = _invitedEmailsList[index];
                return Chip(
                  backgroundColor: const Color(0xFFEFF4FF),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  label: Text(em, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0052FF))),
                  deleteIcon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                  onDeleted: () {
                    setState(() {
                      _invitedEmailsList.removeAt(index);
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
          ],

          // Batch Send Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isSubmitting ? null : _submitBatchInvites,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      "Send ${_invitedEmailsList.isEmpty ? '' : '${_invitedEmailsList.length} '}Workspace Invite(s)",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}


