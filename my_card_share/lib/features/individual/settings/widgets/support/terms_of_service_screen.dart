import 'package:flutter/material.dart';

class SupportTermsOfServiceScreen extends StatelessWidget {
  const SupportTermsOfServiceScreen({super.key});

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
                            color: Color(0xFFF3E8FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: Color(0xFF9333EA),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Terms of Service",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Pentacloud Consulting • Effective Date: Sept 2026",
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    _buildSectionTitle("1. Acceptance of Terms"),
                    _buildSectionBody(
                      "By downloading, accessing, or using the My Card Share application, you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, you must not access or use the application.",
                    ),
                    const SizedBox(height: 18),

                    _buildSectionTitle("2. Subscription & Billing"),
                    _buildSectionBody(
                      "My Card Share offers Free, Pro, and Enterprise subscription plans:\n"
                      "• Subscriptions automatically renew at the end of each billing cycle unless cancelled at least 24 hours prior to renewal.\n"
                      "• All payments are processed securely through App Store / Play Store or integrated payment gateways.\n"
                      "• Refund Policy: Refunds are subject to platform policy and applicable local consumer protection regulations. Pro-rated refunds are evaluated upon request through support.",
                    ),
                    const SizedBox(height: 18),

                    _buildSectionTitle("3. Acceptable Use Policy"),
                    _buildSectionBody(
                      "You agree to use My Card Share responsibly and ethically:\n"
                      "• Spam & Fraud Prohibition: You strictly agree not to use the platform for sending unsolicited commercial spam, phishing, or distributing fraudulent contact cards.\n"
                      "• Authentic Leads: Creating fake leads, artificial scan inflation, or impersonating individuals or companies is strictly prohibited.",
                    ),
                    const SizedBox(height: 18),

                    _buildSectionTitle("4. Account Termination"),
                    _buildSectionBody(
                      "Pentacloud Consulting reserves the right to suspend, disable, or permanently terminate your account without prior notice in the event of:\n"
                      "• Severe or repeated violations of this Acceptable Use Policy or Terms of Service.\n"
                      "• Abusive behavior, platform exploitation, or non-payment of subscription fees.",
                    ),
                    const SizedBox(height: 18),

                    _buildSectionTitle("5. Limitation of Liability"),
                    _buildSectionBody(
                      "To the maximum extent permitted by applicable law, Pentacloud Consulting and its affiliates shall not be liable for any indirect, incidental, special, or consequential damages, including loss of data, loss of business revenue, or temporary service downtime resulting from platform maintenance or network outages.",
                    ),
                    const SizedBox(height: 18),

                    _buildSectionTitle("6. Governing Law & Jurisdiction"),
                    _buildSectionBody(
                      "These Terms of Service and any dispute or claim arising out of or in connection with them shall be governed by and construed in accordance with the laws of Dubai, United Arab Emirates (UAE). Both parties submit to the exclusive jurisdiction of the competent courts in Dubai, UAE.",
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

