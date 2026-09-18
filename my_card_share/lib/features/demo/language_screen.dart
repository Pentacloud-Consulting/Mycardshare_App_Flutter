import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = "English";

  final List<String> _languages = [
    "English",
    "Tamil",
    "Arabic",
    "Spanish",
    "Turkish",
    "Malayalam",
    "Hindi",
    "Urdu",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE8ECEF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF2C3333), size: 20),
            ),
          ),
        ),
        title: const Text(
          "Language",
          style: TextStyle(color: Color(0xFF2C3333), fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECEF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Color(0xFF888888)),
                    hintText: "Search",
                    hintStyle: TextStyle(color: Color(0xFF888888)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Personalize your app experience with your preferred\nlanguage and regional format.",
                style: TextStyle(color: Color(0xFF777777), fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _languages.length,
                  separatorBuilder: (context, index) => const Divider(color: Color(0xFFEEEEEE), height: 1),
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = lang == _selectedLanguage;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedLanguage = lang;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang,
                              style: const TextStyle(
                                color: Color(0xFF2C3333),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Color(0xFF2988FA), size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
