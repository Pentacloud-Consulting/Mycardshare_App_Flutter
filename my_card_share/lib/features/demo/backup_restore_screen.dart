import 'package:flutter/material.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _autoBackup = true;

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
          "Backup & Restore",
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
              // Last Backup Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Last Backup", style: TextStyle(color: Color(0xFF2C3333), fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text("Today, 04:32 PM · 24.8 MB", style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8ECEF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.check, size: 14, color: Color(0xFF2C3333)),
                              SizedBox(width: 4),
                              Text("Upto Date", style: TextStyle(color: Color(0xFF2C3333), fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.cloud_download, color: Color(0xFF3892F7), size: 60),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Settings Items
              _buildSettingItem(
                title: "Auto Backup",
                subtitle: "Automatically back up your\ncards and contacts.",
                trailing: Switch(
                  value: _autoBackup,
                  onChanged: (val) {
                    setState(() => _autoBackup = val);
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF2C3333),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFD9D9D9),
                ),
              ),
              const SizedBox(height: 24),
              _buildSettingItem(
                title: "Backup Now",
                subtitle: "Save your latest data.\nSize : 24 MB",
                trailing: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 16),
                  label: const Text("Backup", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3892F7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSettingItem(
                title: "Restore Backup",
                subtitle: "Recover your saved data.",
                trailing: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3892F7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    elevation: 0,
                  ),
                  child: const Text("Restore", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
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
                  child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({required String title, required String subtitle, required Widget trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF2C3333), fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF888888), fontSize: 12, height: 1.4)),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}
