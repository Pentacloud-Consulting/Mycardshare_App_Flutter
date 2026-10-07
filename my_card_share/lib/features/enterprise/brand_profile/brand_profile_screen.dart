import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Nav/enterprice nav/enterprise_profile_menu.dart';
import 'widgets/brand_detail.dart';
import '../../../backend/enterprise/profile/enterprise_profile_store.dart';

/// Main Enterprise Profile Hub Screen (contains Image 1 Box header card)
class EnterpriseProfileScreen extends StatelessWidget {
  const EnterpriseProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image 1 Box: Enterprise Header Card — reads real data from Firestore
          StreamBuilder<EnterpriseProfileData?>(
            stream: uid.isNotEmpty
                ? EnterpriseProfileStore.instance.profileStream(uid)
                : const Stream.empty(),
            builder: (context, snapshot) {
              final profile = snapshot.data ??
                  EnterpriseProfileStore.instance.currentProfile;

              final companyName =
                  profile?.companyName ?? 'My Company';
              final plan = profile?.plan ?? 'free';
              final employeeCount = profile?.employeeCount ?? 0;
              final logoUrl = profile?.logoUrl;

              return GestureDetector(
                onTap: () => context.push('/enterprise/profile-view'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0052FF).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        backgroundImage: (logoUrl != null && logoUrl.isNotEmpty)
                            ? NetworkImage(logoUrl)
                            : null,
                        child: (logoUrl == null || logoUrl.isEmpty)
                            ? const Icon(Icons.business_rounded,
                                color: Color(0xFF0052FF), size: 30)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${plan[0].toUpperCase()}${plan.substring(1)} Plan'
                              '${employeeCount > 0 ? ' · $employeeCount Employee${employeeCount == 1 ? '' : 's'}' : ''}',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFFE0F2FE)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Enterprise Profile Menu Hub
          const EnterpriseProfileMenuHub(),
        ],
      ),
    );
  }
}


/// Dedicated Brand Profile Screen for customization
class EnterpriseBrandProfileScreen extends StatelessWidget {
  const EnterpriseBrandProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFD),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: EnterpriseBrandDetailWidget(),
      ),
    );
  }
}


