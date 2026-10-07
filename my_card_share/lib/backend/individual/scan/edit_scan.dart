import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'card_scan_service.dart';

/// Data model for editing a scanned contact — holds all editable fields.
class EditScanData {
  String name;
  String role;
  String company;
  String phone;
  String email;
  String website;
  String address;
  String note;
  String tag;
  String? imagePath;

  EditScanData({
    this.name = '',
    this.role = '',
    this.company = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.address = '',
    this.note = '',
    this.tag = 'OCR',
    this.imagePath,
  });

  factory EditScanData.fromScanned(ScannedContactData d) => EditScanData(
        name: d.name,
        role: d.role,
        company: d.company,
        phone: d.phone,
        email: d.email,
        website: d.website,
        address: d.address,
        tag: d.tag,
        imagePath: d.imagePath,
      );

  ScannedContactData toScannedContact(String id) => ScannedContactData(
        id: id,
        name: name.trim(),
        role: role.trim(),
        company: company.trim(),
        phone: phone.trim(),
        email: email.trim(),
        website: website.trim(),
        address: address.trim(),
        tag: tag,
        imagePath: imagePath,
      );
}

/// Backend service for editing already-scanned contacts before saving.
/// Handles: field editing, Firestore update/save, validation, and delete.
class EditScanService {
  EditScanService._internal();
  static final EditScanService instance = EditScanService._internal();

  // ── Validation ─────────────────────────────────────────────────────────────

  /// Returns null if valid, error message if invalid.
  String? validateName(String name) {
    if (name.trim().isEmpty) return 'Name is required';
    if (name.trim().length < 2) return 'Name too short';
    return null;
  }

  String? validateEmail(String email) {
    if (email.trim().isEmpty) return null; // optional
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(email.trim())) return 'Invalid email address';
    return null;
  }

  String? validatePhone(String phone) {
    if (phone.trim().isEmpty) return null; // optional
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return 'Phone too short (min 7 digits)';
    return null;
  }

  /// Validates all fields, returns map of fieldName→error or empty map if valid.
  Map<String, String> validateAll(EditScanData data) {
    final errors = <String, String>{};
    final nameErr = validateName(data.name);
    if (nameErr != null) errors['name'] = nameErr;
    final emailErr = validateEmail(data.email);
    if (emailErr != null) errors['email'] = emailErr;
    final phoneErr = validatePhone(data.phone);
    if (phoneErr != null) errors['phone'] = phoneErr;
    return errors;
  }

  // ── Firestore operations ───────────────────────────────────────────────────

  /// Saves (creates/updates) an edited contact in Firestore.
  /// Returns true on success, false on failure.
  Future<bool> saveContact({
    required EditScanData data,
    String? existingId,
    required BuildContext context,
  }) async {
    final errors = validateAll(data);
    if (errors.isNotEmpty) {
      final msg = errors.values.first;
      _showSnack(context, '⚠ $msg', isError: true);
      return false;
    }

    final id = existingId ?? 'scan_${DateTime.now().millisecondsSinceEpoch}';
    final contact = data.toScannedContact(id);

    // 1. Save to Firestore
    await CardScanService.instance.saveScannedContact(contact);

    if (context.mounted) {
      _showSnack(context, '✓ ${contact.name} saved to Contact Vault!');
    }
    return true;
  }

  /// Updates an existing contact document in Firestore with new field values.
  Future<bool> updateContact({
    required String contactId,
    required EditScanData data,
    required BuildContext context,
  }) async {
    final errors = validateAll(data);
    if (errors.isNotEmpty) {
      _showSnack(context, '⚠ ${errors.values.first}', isError: true);
      return false;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showSnack(context, 'Not logged in', isError: true);
      return false;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .doc(contactId)
          .update({
        'name': data.name.trim(),
        'role': data.role.trim(),
        'company': data.company.trim(),
        'phone': data.phone.trim(),
        'email': data.email.trim(),
        'website': data.website.trim(),
        'address': data.address.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (context.mounted) {
        _showSnack(context, '✓ ${data.name} updated successfully!');
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        _showSnack(context, 'Update failed: $e', isError: true);
      }
      return false;
    }
  }

  /// Deletes a contact from Firestore. Returns true on success.
  Future<bool> deleteContact({
    required String contactId,
    required BuildContext context,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .doc(contactId)
          .delete();

      if (context.mounted) {
        _showSnack(context, 'Contact deleted');
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        _showSnack(context, 'Delete failed: $e', isError: true);
      }
      return false;
    }
  }

  // ── Inline field edit modal ────────────────────────────────────────────────

  /// Shows a bottom sheet dialog to edit a single field.
  /// Returns the new value or null if cancelled.
  Future<String?> showInlineEditSheet(
    BuildContext context, {
    required String fieldLabel,
    required String currentValue,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) async {
    final ctrl = TextEditingController(text: currentValue);
    String? result;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit $fieldLabel',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: fieldLabel,
                  labelStyle: const TextStyle(color: Color(0xFF64748B)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF0052FF), width: 2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFD),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        result = ctrl.text;
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    ctrl.dispose();
    return result;
  }

  // ── Confirm delete dialog ──────────────────────────────────────────────────

  /// Shows a confirmation dialog before deleting a contact.
  Future<bool> showDeleteConfirmDialog(
    BuildContext context, {
    required String contactName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Contact',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        content: Text(
          'Are you sure you want to delete "$contactName"? This action cannot be undone.',
          style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Utility ────────────────────────────────────────────────────────────────

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF0052FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}


