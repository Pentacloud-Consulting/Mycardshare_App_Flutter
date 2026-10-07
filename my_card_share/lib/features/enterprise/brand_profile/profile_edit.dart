import 'package:flutter/material.dart';
import 'widgets/brand_detail.dart';

/// Real Enterprise Profile Edit & Branding Customization Screen.
/// Renders EnterpriseBrandDetailWidget with all collapsible brand controls and real-time live preview.
class EnterpriseProfileEditScreen extends StatelessWidget {
  const EnterpriseProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text(
          "Edit Enterprise Profile",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF64748B), size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: EnterpriseBrandDetailWidget(),
      ),
    );
  }
}


