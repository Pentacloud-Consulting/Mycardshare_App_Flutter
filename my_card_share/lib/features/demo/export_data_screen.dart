import 'package:flutter/material.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  final Map<String, bool> _selectedData = {
    "Business Cards": true,
    "Contacts": true,
    "Analytics": true,
    "Account Settings": true,
  };

  String _selectedFormat = "PDF";
  final List<String> _formats = ["PDF", "CSV", "VCard"];

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
          "Export Data",
          style: TextStyle(color: Color(0xFF2C3333), fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Select Data Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Data", style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                    const SizedBox(height: 12),
                    ..._selectedData.keys.map((key) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedData[key] = !_selectedData[key]!;
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _selectedData[key]! ? const Color(0xFF2C3333) : Colors.transparent,
                                  border: Border.all(color: const Color(0xFF2C3333), width: 2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: _selectedData[key]! ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(key, style: const TextStyle(color: Color(0xFF2C3333), fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Export Format Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Export Format", style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                    const SizedBox(height: 16),
                    Row(
                      children: _formats.map((format) {
                        final isSelected = _selectedFormat == format;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFormat = format;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF3892F7) : const Color(0xFFDFDFDF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                format,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF2C3333),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
              
              const Spacer(),
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3892F7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text("Export Data", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
