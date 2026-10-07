import 'package:flutter/material.dart';
import 'scan_profile_view.dart';
import '../lead/active_lead.dart';

/// Screen displayed when a user scans any card's QR code or opens a public card link.
/// Matches Image 2 layout with "Save Contact", "Add to Wallet", and "Exchange Contact".
class ScanCardShowScreen extends StatefulWidget {
  final String cardSlug;

  const ScanCardShowScreen({
    super.key,
    required this.cardSlug,
  });

  @override
  State<ScanCardShowScreen> createState() => _ScanCardShowScreenState();
}

class _ScanCardShowScreenState extends State<ScanCardShowScreen> {
  late Future<PublicProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ScanProfileViewService.instance.fetchProfileBySlug(widget.cardSlug);
  }

  void _onSaveContact(PublicProfileData profile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✓ Saved ${profile.fullName}'s contact to your phone!"),
        backgroundColor: const Color(0xFF0052FF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onExchangeContact(PublicProfileData profile) {
    ActiveLeadService.showLeadExchangeModal(context, profile: profile);
  }

  void _onShareContact(PublicProfileData profile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✓ ${profile.fullName}'s card link copied to clipboard!"),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Public Profile",
          style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<PublicProfileData>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0052FF)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                "Unable to load profile",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
              ),
            );
          }

          final profile = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Header Banner Card (Image 2 style teal gradient)
                  Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x200D9488),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Networking Status Badge
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircleAvatar(
                                      radius: 4,
                                      backgroundColor: Color(0xFF10B981),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      profile.userStatus.isNotEmpty ? profile.userStatus.toUpperCase() : "ACTIVELY NETWORKING",
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0052FF),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Slogan Text
                            const Text(
                              "People\nBuild\nBetter\nFutures",
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.1,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "PENTACLOUD\nPEOPLE • PLACES • POSSIBILITIES",
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withAlpha(200),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Avatar circle overlapping
                      Positioned(
                        bottom: -45,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEFF6FF),
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x15000000),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: (profile.avatarUrl.isNotEmpty)
                                ? Image.network(
                                    profile.avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Center(
                                      child: Text(
                                        profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'Z',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0052FF),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'Z',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0052FF),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 55),

                  // Full Name
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (profile.jobTitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.jobTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0052FF),
                      ),
                    ),
                  ],
                  if (profile.company.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      profile.company,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Action Buttons (Email & Call)
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionPill(
                          icon: Icons.mail_outline_rounded,
                          label: "Email",
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionPill(
                          icon: Icons.phone_outlined,
                          label: "Call",
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quote / Bio Box
                  if (profile.bio.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.format_quote_rounded, color: Color(0xFF38BDF8), size: 24),
                          const SizedBox(height: 4),
                          Text(
                            profile.bio,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Big Save Contact Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _onSaveContact(profile),
                      icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        "Save Contact",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007FFF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bottom Action Buttons: "Add to Wallet" & "Exchange Contact" (Image 2 style)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _onShareContact(profile),
                          icon: const Icon(Icons.wallet_outlined, size: 18, color: Color(0xFF0052FF)),
                          label: const Text(
                            "Add to Wallet",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0052FF)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _onExchangeContact(profile),
                          icon: const Icon(Icons.group_add_outlined, size: 18, color: Color(0xFF0052FF)),
                          label: const Text(
                            "Exchange Con...",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0052FF)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "CONNECT  •  COLLABORATE  •  GROW",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF0F172A)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


