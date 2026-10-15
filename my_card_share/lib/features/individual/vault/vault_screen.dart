import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/vault_provider.dart';
import '../../../services/Individual/manual/manual_add_contact_dialog.dart';
import 'widgets/vault_category.dart';
import 'widgets/vault_contact_card.dart';
import 'widgets/vault_search_bar.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openManualEntry() {
    showDialog(
      context: context,
      builder: (_) => const ManualAddContactDialog(),
    );
  }

  void _confirmAndDeleteContact(Map<String, String> contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Delete Contact?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        content: Text(
          "Are you sure you want to delete ${contact['name'] ?? 'this contact'} from your Contact Vault?",
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(vaultNotifierProvider.notifier).deleteContact(
                    id: contact['id'],
                    name: contact['name'] ?? '',
                    email: contact['email'],
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("✓ ${contact['name'] ?? 'Contact'} removed from Vault"),
                  backgroundColor: const Color(0xFF0F172A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allContacts = ref.watch(vaultNotifierProvider);

    final filteredContacts = allContacts.where((contact) {
      final tagMatch = _selectedFilter == 'all' ||
          contact['tag']!.toLowerCase() == _selectedFilter.toLowerCase() ||
          (_selectedFilter.toLowerCase() == 'ocr' && contact['tag']!.toLowerCase() == 'ocr') ||
          (_selectedFilter.toLowerCase() == 'ai scan' && contact['tag']!.toLowerCase() == 'ocr');

      final queryMatch = _searchQuery.isEmpty ||
          contact['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          contact['company']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (contact['role'] != null && contact['role']!.toLowerCase().contains(_searchQuery.toLowerCase()));

      return tagMatch && queryMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      // ── Manual Entry FAB — bottom-right corner ──
      floatingActionButton: _ManualEntryFab(onTap: _openManualEntry),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              VaultSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
              ),

              const SizedBox(height: 14),

              // Category Pills Row (All, AI Scan, Voice, Manual)
              VaultCategory(
                selectedFilter: _selectedFilter,
                onFilterSelected: (filterId) {
                  setState(() {
                    _selectedFilter = filterId;
                  });
                },
              ),

              const SizedBox(height: 18),

              // Contact Cards List
              if (filteredContacts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "No contacts found in vault",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredContacts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredContacts[index];
                    return VaultContactCard(
                      id: item['id'],
                      name: item['name']!,
                      role: item['role'] ?? '',
                      company: item['company']!,
                      phone: item['phone'],
                      email: item['email'],
                      website: item['website'],
                      address: item['address'],
                      dateAdded: item['dateAdded'] ?? 'Just now',
                      tag: item['tag']!,
                      initials: item['initials'],
                      onDelete: () => _confirmAndDeleteContact(item),
                    );
                  },
                ),

              // Extra bottom padding so FAB doesn't cover last card
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium floating "Enter Manually" FAB — bottom-right corner of Vault
// ─────────────────────────────────────────────────────────────────────────────
class _ManualEntryFab extends StatefulWidget {
  final VoidCallback onTap;
  const _ManualEntryFab({required this.onTap});

  @override
  State<_ManualEntryFab> createState() => _ManualEntryFabState();
}

class _ManualEntryFabState extends State<_ManualEntryFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF0052FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x500052FF),
                blurRadius: 18,
                spreadRadius: 0,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
