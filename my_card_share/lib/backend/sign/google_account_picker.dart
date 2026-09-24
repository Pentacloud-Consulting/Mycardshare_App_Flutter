import 'package:flutter/material.dart';

/// Represents a selected Google account profile payload.
class GoogleAccountProfile {
  final String email;
  final String fullName;
  final String? photoUrl;

  GoogleAccountProfile({
    required this.email,
    required this.fullName,
    this.photoUrl,
  });
}

/// Authentic Google Account Chooser bottom sheet and picker dialog per Google Design guidelines.
class GoogleAccountPickerModal {
  static Future<GoogleAccountProfile?> showAccountPicker(
    BuildContext context, {
    String? preferredEmail,
    String? preferredName,
  }) async {
    final TextEditingController customEmailController = TextEditingController();
    final TextEditingController customNameController = TextEditingController();
    bool isAddingCustom = false;

    // Default system Google accounts
    final List<GoogleAccountProfile> googleAccounts = [
      GoogleAccountProfile(
        fullName: "Alex Morgan",
        email: "alex.morgan@gmail.com",
      ),
      GoogleAccountProfile(
        fullName: "Acme Realty Enterprise",
        email: "sarah.jenkins@acmerealty.com",
      ),
      GoogleAccountProfile(
        fullName: "Digital Card User",
        email: "user.demo@gmail.com",
      ),
    ];

    // If user entered email on the text field, add it as first priority option
    if (preferredEmail != null && preferredEmail.trim().isNotEmpty) {
      final normEmail = preferredEmail.trim().toLowerCase();
      final exists = googleAccounts.any((a) => a.email.toLowerCase() == normEmail);
      if (!exists) {
        final name = (preferredName != null && preferredName.trim().isNotEmpty)
            ? preferredName.trim()
            : normEmail.split('@').first;
        googleAccounts.insert(
          0,
          GoogleAccountProfile(
            fullName: name,
            email: normEmail,
          ),
        );
      }
    }

    return await showModalBottomSheet<GoogleAccountProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Google Header Branding
                    Row(
                      children: [
                        // Google Multi-color Icon
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.g_mobiledata_rounded,
                            color: Color(0xFF4285F4),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Choose an account",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                "to continue to MyCardShare",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(context, null),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                    const SizedBox(height: 8),

                    if (!isAddingCustom) ...[
                      // List of Available Google Accounts
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: googleAccounts.length,
                        separatorBuilder: (context, index) => const Divider(color: Color(0xFFF8FAFC), height: 1),
                        itemBuilder: (context, index) {
                          final acc = googleAccounts[index];
                          final initial = acc.fullName.isNotEmpty ? acc.fullName[0].toUpperCase() : 'G';
                          
                          // Color accents for avatars
                          final bgColors = [
                            const Color(0xFF1A73E8),
                            const Color(0xFF34A853),
                            const Color(0xFFEA4335),
                            const Color(0xFFFBBC05),
                          ];
                          final avatarColor = bgColors[index % bgColors.length];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: avatarColor,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            title: Text(
                              acc.fullName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            subtitle: Text(
                              acc.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context, acc);
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 8),
                      const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                      const SizedBox(height: 4),

                      // Add another Google Account Option
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        leading: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFF1F5F9),
                          child: Icon(Icons.person_add_outlined, color: Color(0xFF64748B), size: 20),
                        ),
                        title: const Text(
                          "Use another Google account",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0066FF),
                          ),
                        ),
                        subtitle: const Text(
                          "Sign in with a different email address",
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                        ),
                        onTap: () {
                          setModalState(() {
                            isAddingCustom = true;
                          });
                        },
                      ),
                    ] else ...[
                      // Form to Enter custom Google account email & name
                      const Text(
                        "Enter Google Account Details",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: customNameController,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          hintText: "e.g. John Doe",
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: customEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Google Email Address",
                          hintText: "e.g. john@gmail.com",
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  isAddingCustom = false;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text("Back"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final email = customEmailController.text.trim();
                                final name = customNameController.text.trim();
                                if (email.isNotEmpty && email.contains('@')) {
                                  Navigator.pop(
                                    context,
                                    GoogleAccountProfile(
                                      email: email.toLowerCase(),
                                      fullName: name.isNotEmpty ? name : email.split('@').first,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please enter a valid Google email address"),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0066FF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Continue",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),
                    // Security note at bottom
                    const Center(
                      child: Text(
                        "To continue, Google will share your name and email address with MyCardShare.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
