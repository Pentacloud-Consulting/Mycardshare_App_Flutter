import 'package:flutter/material.dart';
import '../../../../backend/individual/qr scan/individual_generate_qr.dart';

class CardFooterActions extends StatelessWidget {
  final String name;
  final VoidCallback? onSaveContactTap;
  final VoidCallback? onAddToWalletTap;
  final VoidCallback? onExchangeContactTap;
  final VoidCallback? onQrTap;
  final bool showBranding;

  const CardFooterActions({
    super.key,
    this.name = "Sarah Khan",
    this.onSaveContactTap,
    this.onAddToWalletTap,
    this.onExchangeContactTap,
    this.onQrTap,
    this.showBranding = true,
  });

  void _showQrModal(BuildContext context) {
    IndividualGenerateQR.showModal(context, name: name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Save Contact Primary Gradient Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0052FF), Color(0xFF0088FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x350052FF),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onSaveContactTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Contact saved to your phone!"),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.download_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Save Contact",
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Secondary Outlined Action Buttons with Center QR Grid Button
        Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF0066FF), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x100066FF),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: onAddToWalletTap ??
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Adding to Wallet...")),
                            );
                          },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF0066FF), size: 18),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Add to Wallet",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0066FF),
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF0066FF), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x100066FF),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: onExchangeContactTap ??
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Opening Exchange Contact modal...")),
                            );
                          },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, right: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.people_alt_rounded, color: Color(0xFF0066FF), size: 18),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Exchange Contact",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0066FF),
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Center Circular QR Grid Button (Image 2 exact replica)
            GestureDetector(
              onTap: onQrTap ?? () => _showQrModal(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF38BDF8), width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x250066FF),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF0066FF),
                  size: 22,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Footer Branding: CONNECT • COLLABORATE • GROW
        if (showBranding)
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "CONNECT  •  COLLABORATE  •  GROW",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 24,
                  height: 2,
                  color: const Color(0xFF93C5FD),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
