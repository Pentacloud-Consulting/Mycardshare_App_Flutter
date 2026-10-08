import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/settings/admin_roles.dart';

/// Opens the Admin Roles & Security Permissions Management Screen on rootNavigator.
Future<void> showAdminRolesPage(BuildContext context, {String? uid}) async {
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (ctx) => EnterpriseAdminRolesScreen(uid: uid),
    ),
  );
}

/// Settings Security Row Widget for Admin Roles (Image 1 style).
class SettingsAdminRolesRow extends StatelessWidget {
  final VoidCallback? onTap;
  final String? uid;

  const SettingsAdminRolesRow({
    super.key,
    this.onTap,
    this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<List<AdminRoleMember>>(
      stream: EnterpriseAdminRolesService.instance.streamAdmins(targetUid),
      builder: (context, snapshot) {
        final admins = snapshot.data ?? [];
        final countText = admins.isNotEmpty ? "${admins.length} ${admins.length == 1 ? 'Admin' : 'Admins'}" : '1 Admin';

        return InkWell(
          onTap: onTap ?? () => showAdminRolesPage(context, uid: targetUid),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // Soft Blue Square with Admin Shield Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Color(0xFF0052FF),
                    size: 17,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Admin Roles",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Text(
                  countText,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Full Dedicated Screen Page for Admin Roles & Workspace Security Permissions.
class EnterpriseAdminRolesScreen extends StatefulWidget {
  final String? uid;

  const EnterpriseAdminRolesScreen({
    super.key,
    this.uid,
  });

  @override
  State<EnterpriseAdminRolesScreen> createState() => _EnterpriseAdminRolesScreenState();
}

class _EnterpriseAdminRolesScreenState extends State<EnterpriseAdminRolesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAssignAdminModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AssignAdminRoleModal(uid: widget.uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetUid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Admin Roles & Permissions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<List<AdminRoleMember>>(
        stream: EnterpriseAdminRolesService.instance.streamAdmins(targetUid, _searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0052FF)),
            );
          }

          final admins = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                const Text(
                  "Workspace Administrators",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Control who has administrator access to manage workspace settings, billing, and team cards.",
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      hintText: "Search admins by name or email...",
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Admins List Cards
                if (admins.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.admin_panel_settings_outlined, size: 40, color: Color(0xFF94A3B8)),
                        SizedBox(height: 12),
                        Text(
                          "No admin members found",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Try adjusting your search query or assign a new admin role below.",
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Column(
                    children: admins.map((admin) {
                      return _buildAdminCard(context, admin, targetUid);
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 20),

                // Assign Admin Role Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _openAssignAdminModal(context),
                    icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                    label: const Text(
                      "Assign New Admin Role",
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, AdminRoleMember admin, String? targetUid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar Circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: admin.isOwner ? const Color(0xFFEFF4FF) : const Color(0xFFF3E8FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    admin.initials,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: admin.isOwner ? const Color(0xFF0052FF) : const Color(0xFF7C3AED),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            admin.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: admin.isOwner
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFEFF4FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            admin.roleTitle,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: admin.isOwner
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF0052FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      admin.email,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Actions menu (if not Owner)
              if (!admin.isOwner)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8), size: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (val) async {
                    if (targetUid == null) return;
                    if (val == 'revoke') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Revoke Admin Privileges?"),
                          content: Text("Are you sure you want to change ${admin.name}'s role back to standard Employee?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              child: const Text("Revoke", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await EnterpriseAdminRolesService.instance.revokeAdminRole(
                          uid: targetUid,
                          employeeId: admin.id,
                        );
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'revoke',
                      child: Row(
                        children: [
                          Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text("Revoke Admin Access", style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Permissions Tags List
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: admin.permissions.map((perm) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Text(
                      perm,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Modal Bottom Sheet for assigning a new admin role.
class AssignAdminRoleModal extends StatefulWidget {
  final String? uid;

  const AssignAdminRoleModal({super.key, this.uid});

  @override
  State<AssignAdminRoleModal> createState() => _AssignAdminRoleModalState();
}

class _AssignAdminRoleModalState extends State<AssignAdminRoleModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'Super Admin';
  bool _isSaving = false;

  final List<String> _selectedPermissions = ['Manage Team', 'Card Editor', 'Analytics'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final success = await EnterpriseAdminRolesService.instance.assignAdminRole(
      uid: widget.uid ?? FirebaseAuth.instance.currentUser!.uid,
      name: _nameController.text,
      email: _emailController.text,
      roleTitle: _selectedRole,
      permissions: _selectedPermissions,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text("Assigned $_selectedRole role to ${_emailController.text}!")),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Assign New Admin Role",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Full Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Admin Full Name",
                  hintText: "e.g. Sarah Jenkins",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? "Enter full name" : null,
              ),
              const SizedBox(height: 14),

              // Work Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Work Email Address",
                  hintText: "sarah@yourcompany.com",
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF0052FF)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                validator: (val) => (val == null || !val.contains('@')) ? "Enter valid work email" : null,
              ),
              const SizedBox(height: 14),

              // Role Tier Dropdown
              const Text("Admin Access Level", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'Super Admin', child: Text("Super Admin (Full Workspace Access)")),
                      DropdownMenuItem(value: 'Admin', child: Text("Admin (Team & Card Management)")),
                      DropdownMenuItem(value: 'Billing Manager', child: Text("Billing Manager (Subscriptions & Receipts Only)")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRole = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Grant Admin Access", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
