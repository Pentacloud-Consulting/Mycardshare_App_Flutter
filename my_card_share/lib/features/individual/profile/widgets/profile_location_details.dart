import 'package:flutter/material.dart';

/// Clean, high-fidelity Location and Professional Details section matching Uilora / Web DBC spec.
class ProfileLocationDetails extends StatelessWidget {
  final TextEditingController cityController;
  final TextEditingController countryController;
  final TextEditingController addressController;
  final TextEditingController focusAreasController;
  final TextEditingController experienceController;
  final TextEditingController calendlyController;

  const ProfileLocationDetails({
    super.key,
    required this.cityController,
    required this.countryController,
    required this.addressController,
    required this.focusAreasController,
    required this.experienceController,
    required this.calendlyController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Location & Address
        const Text(
          "Location & Address",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildInputField(
                icon: Icons.location_city_rounded,
                label: "City",
                hint: "e.g. Mumbai / Dubai",
                controller: cityController,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInputField(
                icon: Icons.public_rounded,
                label: "Country",
                hint: "e.g. India / UAE",
                controller: countryController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        _buildInputField(
          icon: Icons.map_outlined,
          label: "Address",
          hint: "Business street or office address",
          controller: addressController,
        ),

        const SizedBox(height: 20),

        // Section 2: Professional Highlights
        const Text(
          "Professional Focus & Booking",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        _buildInputField(
          icon: Icons.tag_rounded,
          label: "Focus Areas",
          hint: "e.g. AI, Fintech, Growth Strategy",
          controller: focusAreasController,
        ),
        const SizedBox(height: 8),

        _buildInputField(
          icon: Icons.work_outline_rounded,
          label: "Experience",
          hint: "e.g. 8+ years leading design systems",
          controller: experienceController,
        ),
        const SizedBox(height: 8),

        _buildInputField(
          icon: Icons.calendar_today_rounded,
          label: "Calendly",
          hint: "https://calendly.com/your-link",
          controller: calendlyController,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
