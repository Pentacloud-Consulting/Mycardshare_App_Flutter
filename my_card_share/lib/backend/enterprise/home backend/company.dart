import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile/enterprise_profile_store.dart';
import '../multiple store/enterprise_multi_store.dart';

/// Data model representing company profile details for header components.
class EnterpriseCompanyData {
  final String uid;
  final String companyName;
  final String? logoUrl;
  final String? bannerUrl;
  final String industry;
  final String plan;

  const EnterpriseCompanyData({
    required this.uid,
    required this.companyName,
    this.logoUrl,
    this.bannerUrl,
    this.industry = '',
    this.plan = 'free',
  });

  factory EnterpriseCompanyData.fromFirestore(
      String uid, Map<String, dynamic> data) {
    return EnterpriseCompanyData(
      uid: uid,
      companyName: data['companyName'] ?? data['fullName'] ?? 'Enterprise Company',
      logoUrl: data['logoUrl'] as String?,
      bannerUrl: data['bannerUrl'] as String?,
      industry: data['industry'] ?? '',
      plan: data['plan'] ?? 'free',
    );
  }
}

/// Service handling real company metadata fetching and real-time streaming.
class EnterpriseCompanyService {
  EnterpriseCompanyService._internal();
  static final EnterpriseCompanyService instance =
      EnterpriseCompanyService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Real-time stream of company data from Firestore enterprises/{uid}.
  Stream<EnterpriseCompanyData> streamCompanyData([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const EnterpriseCompanyData(
        uid: '',
        companyName: 'My Enterprise',
      ));
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .snapshots()
        .map((snap) {
      if (snap.exists && snap.data() != null) {
        return EnterpriseCompanyData.fromFirestore(targetUid, snap.data()!);
      }

      // Check in-memory EnterpriseProfileStore fallback
      final storedProfile = EnterpriseProfileStore.instance.currentProfile;
      if (storedProfile != null) {
        return EnterpriseCompanyData(
          uid: storedProfile.uid,
          companyName: storedProfile.companyName,
          logoUrl: storedProfile.logoUrl,
          bannerUrl: storedProfile.bannerUrl,
          industry: storedProfile.industry,
          plan: storedProfile.plan,
        );
      }

      // Check multi store user fallback
      final email = _auth.currentUser?.email;
      if (email != null) {
        final multiStoreUser = EnterpriseMultiStore.instance.getUser(email);
        if (multiStoreUser != null) {
          return EnterpriseCompanyData(
            uid: targetUid,
            companyName: multiStoreUser.companyName,
          );
        }
      }

      return EnterpriseCompanyData(
        uid: targetUid,
        companyName: _auth.currentUser?.displayName ?? 'My Enterprise',
      );
    });
  }
}

/// Real UI Widget corresponding to Image 1 (Company Logo & Company Name).
/// Replaces hardcoded company header with real Firestore streamed data.
class EnterpriseCompanyHeaderWidget extends StatelessWidget {
  final TextStyle? nameStyle;
  final double logoSize;
  final VoidCallback? onTap;

  const EnterpriseCompanyHeaderWidget({
    super.key,
    this.nameStyle,
    this.logoSize = 36.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<EnterpriseCompanyData>(
      stream: EnterpriseCompanyService.instance.streamCompanyData(uid),
      builder: (context, snapshot) {
        final company = snapshot.data ??
            EnterpriseCompanyData(
              uid: uid ?? '',
              companyName:
                  EnterpriseProfileStore.instance.currentProfile?.companyName ??
                      'My Enterprise',
              logoUrl:
                  EnterpriseProfileStore.instance.currentProfile?.logoUrl,
            );

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Company Logo Badge
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0052FF).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: company.logoUrl != null &&
                          company.logoUrl!.trim().isNotEmpty
                      ? Image.network(
                          company.logoUrl!,
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, trace) => Center(
                            child: Icon(
                              Icons.business_rounded,
                              color: Colors.white,
                              size: logoSize * 0.55,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.business_rounded,
                            color: Colors.white,
                            size: logoSize * 0.55,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 10),

              // Company Name Text
              Flexible(
                child: Text(
                  company.companyName,
                  style: nameStyle ??
                      const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
