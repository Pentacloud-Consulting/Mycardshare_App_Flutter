import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/profile/enterprise_profile_store.dart';
import '../../../../core/utils/app_image_helper.dart';

class BrandLivePreview extends StatelessWidget {
  final Color selectedColor;
  final String selectedTemplateId;
  final String? companyName;

  const BrandLivePreview({
    super.key,
    required this.selectedColor,
    required this.selectedTemplateId,
    this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBrandColor =
        (selectedColor == const Color(0xFF0052FF) || selectedColor == const Color(0xFF0F172A) && selectedTemplateId == "modern_glass")
            ? const Color(0xFFD4642C)
            : selectedColor;

    Color cardBgPrimary = effectiveBrandColor;
    Color cardBgSecondary = effectiveBrandColor.withValues(alpha: 0.75);
    Color cardTextColor = Colors.white;

    switch (selectedTemplateId) {
      case "sunset_orange":
        cardBgPrimary = const Color(0xFFD4642C);
        cardBgSecondary = const Color(0xFFF97316);
        cardTextColor = Colors.white;
        break;
      case "minimal_dark":
        cardBgPrimary = const Color(0xFF0F172A);
        cardBgSecondary = const Color(0xFF1E293B);
        cardTextColor = Colors.white;
        break;
      case "corporate_clean":
        cardBgPrimary = Colors.white;
        cardBgSecondary = const Color(0xFFF1F5F9);
        cardTextColor = const Color(0xFF0F172A);
        break;
      case "luxury_gold":
        cardBgPrimary = const Color(0xFF18181B);
        cardBgSecondary = const Color(0xFF27272A);
        cardTextColor = const Color(0xFFFFD700);
        break;
      case "emerald_executive":
        cardBgPrimary = const Color(0xFF064E3B);
        cardBgSecondary = const Color(0xFF059669);
        cardTextColor = Colors.white;
        break;
      case "royal_slate":
        cardBgPrimary = const Color(0xFF1E1B4B);
        cardBgSecondary = const Color(0xFF312E81);
        cardTextColor = Colors.white;
        break;
      case "bold_gradient":
        cardBgPrimary = const Color(0xFF7C3AED);
        cardBgSecondary = const Color(0xFFEC4899);
        cardTextColor = Colors.white;
        break;
      case "modern_glass":
      default:
        cardBgPrimary = effectiveBrandColor;
        cardBgSecondary = const Color(0xFFE8824E);
        cardTextColor = Colors.white;
        break;
    }

    // Read real company name from EnterpriseProfileStore or passed controller parameter
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final profile = EnterpriseProfileStore.instance.currentProfile;

    return StreamBuilder<EnterpriseProfileData?>(
      stream: uid.isNotEmpty
          ? EnterpriseProfileStore.instance.profileStream(uid)
          : const Stream.empty(),
      builder: (context, snapshot) {
        final liveProfile = snapshot.data ?? profile;

        final String finalCompanyName;
        final cName = companyName?.trim();
        if (cName != null && cName.isNotEmpty) {
          finalCompanyName = cName;
        } else if (liveProfile != null &&
            liveProfile.companyName.trim().isNotEmpty &&
            liveProfile.companyName.trim() != 'Zuhaib') {
          finalCompanyName = liveProfile.companyName.trim();
        } else {
          finalCompanyName = 'My Company';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "LIVE PREVIEW",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: Color(0xFF16A34A),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Real-time",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Mini Employee Card Mockup — uses real company name
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [cardBgPrimary, cardBgSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: cardTextColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cardBgPrimary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar with real company logo image or icon & badge
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: cardTextColor.withValues(alpha: 0.2),
                          backgroundImage: AppImageHelper.getImageProvider(liveProfile?.logoUrl),
                          child: (liveProfile?.logoUrl == null ||
                                  liveProfile!.logoUrl!.isEmpty)
                              ? Icon(
                                  Icons.person_rounded,
                                  color: cardTextColor,
                                  size: 26,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: effectiveBrandColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.business_rounded,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Employee Name",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: cardTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Job Title",
                            style: TextStyle(
                              fontSize: 12,
                              color: cardTextColor.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.business_rounded,
                                size: 12,
                                color: cardTextColor.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  finalCompanyName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: cardTextColor.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.qr_code_2_rounded,
                      color: cardTextColor.withValues(alpha: 0.85),
                      size: 32,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



