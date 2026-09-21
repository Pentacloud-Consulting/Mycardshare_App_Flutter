import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../Nav/enterprice nav/enterprise_profile_menu.dart';
import 'widgets/brand_logo_picker.dart';
import 'widgets/brand_banner_picker.dart';
import 'widgets/brand_color_selector.dart';
import 'widgets/brand_template_selector.dart';
import 'widgets/brand_live_preview.dart';
import 'widgets/brand_save_button.dart';

/// Main Enterprise Profile Hub Screen (contains Image 1 Box header card)
class EnterpriseProfileScreen extends StatelessWidget {
  const EnterpriseProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image 1 Box: Enterprise Header Card (taps navigate to Brand Profile Editor)
          GestureDetector(
            onTap: () => context.push('/enterprise/brand-profile'),
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
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.business_rounded, color: Color(0xFF0052FF), size: 30),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Acme Realty Group",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Enterprise Pro Plan · 34 Employees",
                          style: TextStyle(fontSize: 13, color: Color(0xFFE0F2FE)),
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
class EnterpriseBrandProfileScreen extends StatefulWidget {
  const EnterpriseBrandProfileScreen({super.key});

  @override
  State<EnterpriseBrandProfileScreen> createState() => _EnterpriseBrandProfileScreenState();
}

class _EnterpriseBrandProfileScreenState extends State<EnterpriseBrandProfileScreen> {
  Color _selectedColor = const Color(0xFF0052FF);
  bool _isLocked = true;
  String _selectedTemplateId = "modern_glass";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background with soft baby-blue gradient blob in top-right corner
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF38BDF8).withValues(alpha: 0.18),
                  const Color(0xFF0052FF).withValues(alpha: 0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Scrollable Screen Content
        SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo Section
              const BrandLogoPicker(),

              const SizedBox(height: 24),

              // Cover Banner Section
              const BrandBannerPicker(),

              const SizedBox(height: 24),

              // Brand Color Section & Lock Toggle
              BrandColorSelector(
                selectedColor: _selectedColor,
                onColorSelected: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                isLocked: _isLocked,
                onLockChanged: (val) {
                  setState(() {
                    _isLocked = val;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Default Card Template Section
              BrandTemplateSelector(
                selectedTemplateId: _selectedTemplateId,
                onTemplateSelected: (id) {
                  setState(() {
                    _selectedTemplateId = id;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Live Preview Section
              BrandLivePreview(
                selectedColor: _selectedColor,
                selectedTemplateId: _selectedTemplateId,
              ),

              const SizedBox(height: 28),

              // Save Changes Button
              BrandSaveButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Brand Profile saved! Workspace cards updated.",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF0F172A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
