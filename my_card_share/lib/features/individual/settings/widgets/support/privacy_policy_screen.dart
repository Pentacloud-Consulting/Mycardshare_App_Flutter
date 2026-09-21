import 'package:flutter/material.dart';

class SupportPrivacyPolicyScreen extends StatelessWidget {
  const SupportPrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document Header Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDCFCE7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_user_outlined,
                            color: Color(0xFF16A34A),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Privacy Policy",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "GDPR & CCPA Compliant • Last Updated: Sept 2026",
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    _buildSectionTitle("1. Information We Collect"),
                    _buildSectionBody(
                      "We collect personal and usage information to power your digital business card experience:\n"
                      "• Profile & Contact Details: Name, email address, phone number, company title, and custom card data.\n"
                      "• Scanned Contacts: Paper business cards scanned using our OCR camera features.\n"
                      "• Location Data: Optional geographic location used strictly for proximity card sharing and localized analytics.\n"
                      "• Device & System Info: Device model, operating system version, and IP address for security and diagnostics.",
                    ),
                    const SizedBox(height: 18),

                    _buildSectionTitle("2. How We Use Your Data"),
                    _buildSectionBody(
                      "Your information is utilized solely for product functionality and platform enhancement:\n"
                      "• Digital Card Rendering: Displaying your customized profile card across web and mobile.\n"
                      "• Real-Time Lead Notifications: Alerting you instantly when your card is viewed or saved.\n"
                      "• Analytics & Insights: Generating performance metrics, scan statistics, and engagement trends.\n"
                      "• AI OCR & Voice Processing: Secure transmission of image and voice audio snippets to AI processing providers (Google Gemini & HuggingFace models) strictly to extract contact info and transcription.",
                    ),
                    const SizedBox(height: 18),

                    _buildSectionTitle("3. Data Sharing & Third-Party Integrations"),
                    _buildSectionBody(
                      "We do NOT sell your personal data to advertisers. We share data only through authorized integrations:\n"
                      "• CRM Integrations: When enabled by you, card lead data is dispatched to connected third-party platforms such as Zapier, HubSpot, and Salesforce.\n"
                      "• Service Infrastructure: Core infrastructure cloud providers assisting in hosting and delivery under strict confidentiality terms.",
                    ),
                    const SizedBox(height: 18),

                    _buildSectionTitle("4. Your Rights & Data Controls"),
                    _buildSectionBody(
                      "You retain full ownership and control over your personal information:\n"
                      "• Data Export: Download all your lead contacts and profile data in CSV/JSON format at any time.\n"
                      "• Account Deletion: Permanently erase your account, digital cards, and lead history directly from Settings.\n"
                      "• Marketing Opt-Out: Easily unsubscribe from non-essential promotional communications and email updates.",
                    ),
                    const SizedBox(height: 18),

                    _buildSectionTitle("5. Data Security & Storage Practices"),
                    _buildSectionBody(
                      "We enforce enterprise-grade security protocols to protect your information:\n"
                      "• Encryption: End-to-end TLS 1.3 encryption in transit and AES-256 encryption for data at rest.\n"
                      "• Storage Infrastructure: Distributed and redundant storage utilizing secure Firebase Cloud and MongoDB Atlas environments with strict role-based access control.",
                    ),
                    const SizedBox(height: 18),

                    _buildSectionTitle("6. Contact Us"),
                    _buildSectionBody(
                      "If you have questions, concerns, or requests regarding your data privacy, please contact our Data Privacy Team:\n"
                      "• Email: privacy@mycardshare.com\n"
                      "• Support Desk: Visit our Help & Support section within the app for direct inquiry submission.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
    );
  }

  static Widget _buildSectionBody(String body) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        body,
        style: const TextStyle(
          fontSize: 13.5,
          color: Color(0xFF475569),
          height: 1.5,
        ),
      ),
    );
  }
}

