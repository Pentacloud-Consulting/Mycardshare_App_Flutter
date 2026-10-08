import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/settings/payment_method.dart';

/// Opens the Payment Method Management Screen as a full page overlay (rootNavigator).
Future<void> showPaymentMethodPage(BuildContext context, {String? uid}) async {
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (ctx) => EnterprisePaymentMethodScreen(uid: uid),
    ),
  );
}

/// Settings Row Widget displaying real stream of primary payment method (Image 1 style).
class SettingsPaymentMethodRow extends StatelessWidget {
  final VoidCallback? onTap;
  final String? uid;

  const SettingsPaymentMethodRow({
    super.key,
    this.onTap,
    this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<PaymentMethodData?>(
      stream: EnterprisePaymentMethodService.instance.streamPrimaryPaymentMethod(targetUid),
      builder: (context, snapshot) {
        final payment = snapshot.data;
        final trailingText = payment != null && payment.last4.isNotEmpty
            ? payment.formattedLast4
            : 'Not set';

        return InkWell(
          onTap: onTap ?? () => showPaymentMethodPage(context, uid: targetUid),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // Soft Mint Square with Credit Card Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.credit_card_rounded,
                    color: Color(0xFF0D9488),
                    size: 17,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Payment Method",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Text(
                  trailingText,
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

/// Dedicated Screen Page for managing Enterprise Payment Methods.
class EnterprisePaymentMethodScreen extends StatefulWidget {
  final String? uid;

  const EnterprisePaymentMethodScreen({
    super.key,
    this.uid,
  });

  @override
  State<EnterprisePaymentMethodScreen> createState() => _EnterprisePaymentMethodScreenState();
}

class _EnterprisePaymentMethodScreenState extends State<EnterprisePaymentMethodScreen> {
  void _openAddCardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddPaymentCardModal(uid: widget.uid),
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
          "Payment Method",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<List<PaymentMethodData>>(
        stream: EnterprisePaymentMethodService.instance.streamPaymentMethods(targetUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
            );
          }

          final paymentMethods = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                const Text(
                  "Saved Payment Methods",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Manage credit cards used for your team plan subscriptions and seat add-ons.",
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 18),

                // Empty state or Card List
                if (paymentMethods.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCCFBF1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.credit_card_rounded,
                            size: 26,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "No Payment Method Saved",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Add a primary credit or debit card to ensure seamless workspace billing.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Column(
                    children: paymentMethods.map((card) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.credit_card_rounded, color: Colors.white, size: 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      card.brand,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                if (card.isPrimary)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0052FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "DEFAULT",
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "••••  ••••  ••••  ${card.last4}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "CARD HOLDER",
                                      style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      card.holderName.isNotEmpty ? card.holderName.toUpperCase() : "ENTERPRISE ADMIN",
                                      style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      "EXPIRES",
                                      style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      card.formattedExpiry.isNotEmpty ? card.formattedExpiry : "MM/YY",
                                      style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Remove Payment Card?"),
                                        content: Text("Are you sure you want to remove card ending in ${card.last4}?"),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                            child: const Text("Remove", style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await EnterprisePaymentMethodService.instance.deletePaymentMethod(card.id, targetUid);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 20),

                // Add New Card Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _openAddCardSheet(context),
                    icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    label: const Text(
                      "Add New Payment Card",
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
}

/// Modal Bottom Sheet for adding a real new payment card.
class AddPaymentCardModal extends StatefulWidget {
  final String? uid;

  const AddPaymentCardModal({super.key, this.uid});

  @override
  State<AddPaymentCardModal> createState() => _AddPaymentCardModalState();
}

class _AddPaymentCardModalState extends State<AddPaymentCardModal> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _holderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final expiryParts = _expiryController.text.split('/');
    final expMonth = expiryParts.isNotEmpty ? expiryParts[0].trim() : '';
    final expYear = expiryParts.length > 1 ? expiryParts[1].trim() : '';

    final success = await EnterprisePaymentMethodService.instance.savePaymentMethod(
      cardNumber: _cardNumberController.text,
      expMonth: expMonth,
      expYear: expYear,
      holderName: _holderController.text,
      uid: widget.uid,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text("Payment card saved successfully!"),
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
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
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
                    "Add Payment Card",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Cardholder Name
              TextFormField(
                controller: _holderController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Cardholder Name",
                  hintText: "e.g. John Doe",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? "Enter cardholder name" : null,
              ),
              const SizedBox(height: 14),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: InputDecoration(
                  labelText: "Card Number",
                  hintText: "4242 4242 4242 4242",
                  prefixIcon: const Icon(Icons.credit_card_rounded, color: Color(0xFF7C3AED)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 13) {
                    return "Enter valid card number (13-16 digits)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  // Expiry Date (MM/YY)
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(5),
                      ],
                      decoration: InputDecoration(
                        labelText: "Expiry (MM/YY)",
                        hintText: "12/28",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                      validator: (val) => (val == null || !val.contains('/')) ? "Format: MM/YY" : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // CVC
                  Expanded(
                    child: TextFormField(
                      controller: _cvcController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        labelText: "CVC / CVV",
                        hintText: "123",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                      validator: (val) => (val == null || val.length < 3) ? "3-4 digits" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _handleSaveCard,
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Save Payment Card", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
