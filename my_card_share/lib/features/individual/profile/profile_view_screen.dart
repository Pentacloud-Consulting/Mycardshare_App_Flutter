import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_style_widgets.dart';
import '../../auth/back/smart_back_handler.dart';
import 'profile_editor_screen.dart';
import 'widgets/profile_live_card_preview.dart';
import '../../public_card/public_card_screen.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  bool _isPublished = true;
  final GlobalKey _publishBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Hardcoded dummy data to simulate the view
    const name = "Alex Stanton";
    const role = "Product Designer";
    const company = "Acme Realty Group";
    const bio =
        "Passionate about creating meaningful connections and building brands that make a difference. Always open to new opportunities and collaborations.";
    const status = "ACTIVELY NETWORKING";
    final phone = "+1 415 555 0123";
    final email = "alex.stanton@example.com";
    final website = "https://www.alexstanton.com";
    final slug = "alex-stanton";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interactive Live Card Preview
              ProfileLiveCardPreview(
                name: name,
                role: role,
                company: company,
                status: status,
                isPublished: _isPublished,
              ),
              const SizedBox(height: 24),
              
              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: ClayButton(
                      key: _publishBtnKey,
                      label: _isPublished ? "Publish" : "Unpublished",
                      icon: _isPublished ? Icons.public_rounded : Icons.public_off_rounded,
                      gradient: _isPublished, // true = blue gradient, false = soft clay style
                      onTap: () async {
                        final RenderBox button = _publishBtnKey.currentContext!.findRenderObject() as RenderBox;
                        final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
                        final RelativeRect position = RelativeRect.fromRect(
                          Rect.fromPoints(
                            button.localToGlobal(button.size.bottomLeft(Offset.zero), ancestor: overlay),
                            button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                          ),
                          Offset.zero & overlay.size,
                        );
                        
                        final value = await showMenu<bool>(
                          context: context,
                          position: position,
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          items: [
                            const PopupMenuItem(
                              value: true,
                              child: Row(
                                children: [
                                  Icon(Icons.public_rounded, color: AppColors.primary, size: 20),
                                  SizedBox(width: 8),
                                  Text('Publish'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: false,
                              child: Row(
                                children: [
                                  Icon(Icons.public_off_rounded, color: Colors.grey, size: 20),
                                  SizedBox(width: 8),
                                  Text('Unpublish'),
                                ],
                              ),
                            ),
                          ],
                        );
                        
                        if (value != null && mounted) {
                          setState(() {
                            _isPublished = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClayButton(
                      label: "View Card",
                      icon: Icons.visibility_rounded,
                      onTap: () {
                        Navigator.of(context, rootNavigator: false).push(
                          SmoothPageRoute(
                            page: const PublicCardScreen(showBottomNav: false),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Basic Info",
                    style: AppTextStyles.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          SmoothPageRoute(page: const ProfileEditorScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildViewCard(
                children: [
                  _buildViewRow(Icons.person_rounded, "Full Name", name),
                  const Divider(color: Color(0xFFF1F5F9), height: 24),
                  _buildViewRow(Icons.work_rounded, "Job Title", role),
                  const Divider(color: Color(0xFFF1F5F9), height: 24),
                  _buildViewRow(Icons.business_rounded, "Company", company),
                  const Divider(color: Color(0xFFF1F5F9), height: 24),
                  _buildViewRow(Icons.edit_note_rounded, "Bio", bio, isMultiLine: true),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                "Contact Details",
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildViewCard(
                children: [
                  _buildViewRow(Icons.phone_rounded, "Phone", phone),
                  const Divider(color: Color(0xFFF1F5F9), height: 24),
                  _buildViewRow(Icons.email_rounded, "Email", email),
                  const Divider(color: Color(0xFFF1F5F9), height: 24),
                  _buildViewRow(Icons.language_rounded, "Website", website),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Text(
                "Card Link",
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildViewCard(
                children: [
                  _buildViewRow(Icons.link_rounded, "Slug", slug),
                ],
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildViewRow(IconData icon, String label, String value, {bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                  height: isMultiLine ? 1.4 : 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
