import 'package:flutter/material.dart';
import '../../../../backend/individual/qr scan/individual_generate_qr.dart';
import '../../../../backend/individual/profile/individual_profile_store.dart';
import '../../../../backend/individual/multiple store/individual_multi_store.dart';
import '../../../../backend/individual/connects/save_contact.dart';
import '../../../../backend/individual/wallet/add_to_wallet.dart';
import '../../../../backend/individual/lead/exchange_contact.dart';
import '../../../../backend/individual/connects/share.dart';

class CardFooterActions extends StatelessWidget {
  final String name;
  final bool isOwnerView;
  final bool? showQrButton;
  final VoidCallback? onSaveContactTap;
  final VoidCallback? onAddToWalletTap;
  final VoidCallback? onExchangeContactTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onQrTap;
  final bool showBranding;

  const CardFooterActions({
    super.key,
    this.name = "Sarah Khan",
    this.isOwnerView = true,
    this.showQrButton,
    this.onSaveContactTap,
    this.onAddToWalletTap,
    this.onExchangeContactTap,
    this.onShareTap,
    this.onQrTap,
    this.showBranding = true,
  });

  void _showQrModal(BuildContext context) {
    IndividualGenerateQR.showModal(context, name: name);
  }

  @override
  Widget build(BuildContext context) {
    final String leftLabel = isOwnerView ? "Add to Wallet" : "Share Card";
    final IconData leftIcon = isOwnerView ? Icons.account_balance_wallet_rounded : Icons.ios_share_rounded;
    final VoidCallback leftAction = isOwnerView
        ? (onAddToWalletTap ?? () => AddToWalletService.instance.showSelectWalletModal(context))
        : (onShareTap ?? () => ShareCardService.instance.shareCard(context: context));

    final String rightLabel = isOwnerView ? "QR Code" : "Exchange Contact";
    final IconData rightIcon = isOwnerView ? Icons.grid_view_rounded : Icons.people_alt_rounded;
    final VoidCallback rightAction = isOwnerView
        ? (onQrTap ?? () => _showQrModal(context))
        : (onExchangeContactTap ?? () => ExchangeContactService.instance.showExchangeContactModal(context));

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
                  () async {
                    final activeProfile = IndividualProfileStore.instance.activeProfile;
                    final storedUser = IndividualMultiStore.instance.getAllUsers().firstOrNull;
                    final contactData = ContactExportData.fromProfile(
                      activeProfile,
                      defaultName: name,
                      defaultEmail: storedUser?.email,
                    );

                    final success = await SaveContactService.instance.saveContactToPhone(contactData);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? "Saving ${contactData.fullName} to mobile contacts..."
                                : "Contact details: ${contactData.fullName} (${contactData.phoneNumber})",
                          ),
                          backgroundColor: const Color(0xFF0052FF),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
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

        // Secondary Action Buttons (Styled matching Save Contact blue gradient)
        Row(
          children: [
            // Left Pill: Add to Wallet (Owner) or Share Card (Visitor)
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0052FF), Color(0xFF0088FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x300052FF),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: leftAction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(leftIcon, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                leftLabel,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Right Pill: QR Code (Owner) or Exchange Contact (Visitor)
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0052FF), Color(0xFF0088FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x300052FF),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: rightAction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(rightIcon, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                rightLabel,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
