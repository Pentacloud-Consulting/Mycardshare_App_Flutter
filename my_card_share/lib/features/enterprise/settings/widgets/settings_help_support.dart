import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/settings/help_support.dart';

/// Opens the full Help & Support Screen on rootNavigator.
Future<void> showHelpSupportPage(BuildContext context, {String? uid}) async {
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (ctx) => EnterpriseHelpSupportScreen(uid: uid),
    ),
  );
}

/// Opens the dedicated Account Manager direct contact modal sheet.
Future<void> showAccountManagerContactModal(BuildContext context, {String? uid}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ContactAccountManagerModal(uid: uid),
  );
}

/// Full Dedicated Help & Support Screen Page for Enterprise.
class EnterpriseHelpSupportScreen extends StatefulWidget {
  final String? uid;

  const EnterpriseHelpSupportScreen({
    super.key,
    this.uid,
  });

  @override
  State<EnterpriseHelpSupportScreen> createState() => _EnterpriseHelpSupportScreenState();
}

class _EnterpriseHelpSupportScreenState extends State<EnterpriseHelpSupportScreen> {
  int? _expandedFaqIndex;

  void _openNewTicketModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateSupportTicketModal(uid: widget.uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetUid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
    final faqs = EnterpriseHelpSupportService.getFaqs();

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
          "Help & Support Center",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<List<SupportTicketModel>>(
        stream: EnterpriseHelpSupportService.instance.streamSupportTickets(targetUid),
        builder: (context, snapshot) {
          final tickets = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Quick Action Row (Account Manager & New Ticket)
                Row(
                  children: [
                    // Card 1: Dedicated Account Manager
                    Expanded(
                      child: GestureDetector(
                        onTap: () => showAccountManagerContactModal(context, uid: targetUid),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0D9488),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 18),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Account Manager",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Direct VIP Priority",
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Card 2: Create Support Ticket
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openNewTicketModal(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEFF4FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_task_rounded, color: Color(0xFF0052FF), size: 18),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Open Ticket",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Submit Support Query",
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── FAQ Accordion Section ─────────────────────────────────────
                const Text(
                  "Frequently Asked Questions",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Quick solutions for common enterprise workspace configurations.",
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),

                Column(
                  children: List.generate(faqs.length, (index) {
                    final isExpanded = _expandedFaqIndex == index;
                    final faq = faqs[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: isExpanded,
                          onExpansionChanged: (val) {
                            setState(() {
                              _expandedFaqIndex = val ? index : null;
                            });
                          },
                          leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF0052FF), size: 20),
                          title: Text(
                            faq['question']!,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                faq['answer']!,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // ── Stream of Real Support Tickets ────────────────────────────
                const Text(
                  "Your Support Tickets",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Track live updates on submitted inquiries and support requests.",
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),

                if (tickets.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.confirmation_number_outlined, size: 36, color: Color(0xFF94A3B8)),
                        SizedBox(height: 10),
                        Text(
                          "No Support Tickets Yet",
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "When you submit a support ticket or request, status updates will appear here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Column(
                    children: tickets.map((t) {
                      final isOpen = t.status.toLowerCase() == 'open';
                      final isResolved = t.status.toLowerCase() == 'resolved';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF4FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    t.category,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0052FF)),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isResolved
                                        ? const Color(0xFFDCFCE7)
                                        : isOpen
                                            ? const Color(0xFFFEF3C7)
                                            : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    t.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isResolved
                                          ? const Color(0xFF16A34A)
                                          : isOpen
                                              ? const Color(0xFFD97706)
                                              : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t.subject,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Modal Bottom Sheet for creating a new support ticket in Firestore.
class CreateSupportTicketModal extends StatefulWidget {
  final String? uid;

  const CreateSupportTicketModal({super.key, this.uid});

  @override
  State<CreateSupportTicketModal> createState() => _CreateSupportTicketModalState();
}

class _CreateSupportTicketModalState extends State<CreateSupportTicketModal> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'General Inquiry';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General Inquiry',
    'Billing & Subscription',
    'Custom Domain & DNS',
    'Employee Cards & Seats',
    'Technical Support',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final success = await EnterpriseHelpSupportService.instance.submitSupportTicket(
      subject: _subjectController.text,
      category: _selectedCategory,
      message: _messageController.text,
      uid: widget.uid,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text("Support ticket submitted! We will respond shortly."),
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
                    "Submit Support Ticket",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Category Selector
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "Query Category",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),

              // Subject
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: "Subject",
                  hintText: "Brief summary of your inquiry...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? "Enter ticket subject" : null,
              ),
              const SizedBox(height: 14),

              // Message Body
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Describe Your Request / Problem",
                  hintText: "Provide details to help us assist you faster...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(14),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? "Enter message details" : null,
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
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Submit Ticket", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal Bottom Sheet for contacting Dedicated Account Manager.
class ContactAccountManagerModal extends StatefulWidget {
  final String? uid;

  const ContactAccountManagerModal({super.key, this.uid});

  @override
  State<ContactAccountManagerModal> createState() => _ContactAccountManagerModalState();
}

class _ContactAccountManagerModalState extends State<ContactAccountManagerModal> {
  final _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    setState(() => _isSending = true);
    final success = await EnterpriseHelpSupportService.instance.contactAccountManager(
      message: msg,
      uid: widget.uid,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.headset_mic_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text("VIP Message sent! Your Account Manager will contact you shortly."),
              ],
            ),
            backgroundColor: const Color(0xFF0D9488),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Contact Dedicated Manager",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "As an Enterprise workspace, you have dedicated priority support. Send a direct note to your account manager.",
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.35),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type your request or question here...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSending ? null : _handleSend,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                label: _isSending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Send VIP Message", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
