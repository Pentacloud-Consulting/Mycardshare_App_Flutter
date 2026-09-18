import 'package:flutter/material.dart';

class WorkforceScreen extends StatelessWidget {
  const WorkforceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workforce'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Workforce Screen (/portal/workforce)'),
      ),
    );
  }
}
