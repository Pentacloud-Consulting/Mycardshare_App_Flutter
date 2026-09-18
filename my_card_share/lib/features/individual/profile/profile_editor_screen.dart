import 'package:flutter/material.dart';
import 'widgets/profile_basic_info.dart';
import 'widgets/profile_contact_details.dart';
import 'widgets/profile_live_card_preview.dart';
import 'widgets/profile_slug_section.dart';
import 'widgets/profile_social_links.dart';
import 'widgets/profile_template_selector.dart';

class ProfileEditorScreen extends StatefulWidget {
  const ProfileEditorScreen({super.key});

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  int _selectedTemplateIndex = 0;

  final TextEditingController _nameController = TextEditingController(text: "Alex Stanton");
  final TextEditingController _roleController = TextEditingController(text: "Product Designer");
  final TextEditingController _companyController = TextEditingController(text: "Acme Realty Group");
  final TextEditingController _bioController = TextEditingController(
    text: "Passionate about creating meaningful digital experiences and connecting with amazing people.",
  );

  final TextEditingController _phoneController = TextEditingController(text: "+1 415 555 0123");
  final TextEditingController _emailController = TextEditingController(text: "alex.stanton@example.com");
  final TextEditingController _websiteController = TextEditingController(text: "https://www.alexstanton.com");

  final TextEditingController _slugController = TextEditingController(text: "alex-stanton");

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _roleController.addListener(() => setState(() {}));
    _companyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _companyController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Card Preview Banner
              ProfileLiveCardPreview(
                name: _nameController.text.isEmpty ? "Alex Stanton" : _nameController.text,
                role: _roleController.text.isEmpty ? "Product Designer" : _roleController.text,
                company: _companyController.text.isEmpty ? "Acme Realty Group" : _companyController.text,
                status: "Actively Networking",
                selectedTemplateIndex: _selectedTemplateIndex,
              ),

              const SizedBox(height: 20),

              // Template Themes Selector
              ProfileTemplateSelector(
                selectedIndex: _selectedTemplateIndex,
                onSelectTemplate: (index) {
                  setState(() {
                    _selectedTemplateIndex = index;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Basic Info Inputs
              ProfileBasicInfo(
                nameController: _nameController,
                roleController: _roleController,
                companyController: _companyController,
                bioController: _bioController,
              ),

              const SizedBox(height: 20),

              // Contact Details Inputs
              ProfileContactDetails(
                phoneController: _phoneController,
                emailController: _emailController,
                websiteController: _websiteController,
              ),

              const SizedBox(height: 20),

              // Social Links Section
              const ProfileSocialLinks(),

              const SizedBox(height: 20),

              // Card Slug Section
              ProfileSlugSection(
                slugController: _slugController,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
