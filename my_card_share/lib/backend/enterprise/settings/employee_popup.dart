import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view_employee/view_employee.dart';
import 'company_employee.dart';

/// Opens the Employee Limit & Seat Capacity Popup Dialog / Modal Sheet.
Future<void> showEmployeeLimitPopup(
  BuildContext context, {
  String? uid,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => EmployeeLimitPopupModal(uid: uid),
  );
}

/// Modal Popup Sheet for Viewing & Increasing Employee Seat Limits.
/// Connected with Firestore, CompanyEmployeeService, and EnterpriseProfileStore.
class EmployeeLimitPopupModal extends StatefulWidget {
  final String? uid;

  const EmployeeLimitPopupModal({
    super.key,
    this.uid,
  });

  @override
  State<EmployeeLimitPopupModal> createState() => _EmployeeLimitPopupModalState();
}

class _EmployeeLimitPopupModalState extends State<EmployeeLimitPopupModal> {
  // Employee Limit Tier Options from enterprise_onboarding_screen.dart
  static const List<String> _employeeLimitOptions = [
    "1 - 10 employees",
    "Up to 50 employees",
    "51 - 200 employees",
    "201 - 500 employees",
    "500+ employees",
  ];

  String _selectedTier = "Up to 50 employees";
  bool _isSaving = false;
  bool _initialized = false;

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await CompanyEmployeeService.instance.updateEmployeeLimit(
        limitOption: _selectedTier,
        uid: widget.uid,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("Workspace employee limit updated to $_selectedTier!"),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0D9488),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update limit: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetUid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<CompanySettingsData>(
      stream: CompanyEmployeeService.instance.streamCompanySettings(targetUid),
      builder: (context, settingsSnap) {
        final settings = settingsSnap.data ?? CompanySettingsData.defaultData();

        if (!_initialized && settingsSnap.hasData) {
          _selectedTier = settings.employeeLimitStr;
          _initialized = true;
        }

        return StreamBuilder<int>(
          stream: ViewEmployeeService.instance.streamEmployeeCount(targetUid),
          builder: (context, countSnap) {
            final usedCount = countSnap.data ?? 0;
            final maxLimit = settings.maxLimit;
            final usagePercent = (maxLimit > 0) ? (usedCount / maxLimit).clamp(0.0, 1.0) : 0.0;

            return Container(
              padding: const EdgeInsets.all(22.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle Bar
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

                  // Header Title + Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFBF1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.group_outlined,
                              color: Color(0xFF0D9488),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Employee Limit",
                            style: TextStyle(
                              fontSize: 18,
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
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Real-Time Capacity Usage Progress Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Workspace Capacity Usage",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                            Text(
                              "$usedCount / $maxLimit used",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0D9488),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Animated Usage Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: usagePercent,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              usagePercent >= 0.9
                                  ? const Color(0xFFEF4444)
                                  : usagePercent >= 0.75
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF0D9488),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Your team is currently using ${(usagePercent * 100).toInt()}% of available workspace employee seats.",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section Title: Select New Capacity Tier
                  const Text(
                    "Increase or Select Employee Seat Tier",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Choose how many total employee seats your workspace needs.",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tiers Options List
                  Column(
                    children: _employeeLimitOptions.map((tier) {
                      final isSelected = _selectedTier == tier;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTier = tier),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.8 : 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: isSelected ? const Color(0xFF0D9488) : const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    tier,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                              if (settings.employeeLimitStr == tier)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "Current Plan",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "Update Employee Limit",
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
