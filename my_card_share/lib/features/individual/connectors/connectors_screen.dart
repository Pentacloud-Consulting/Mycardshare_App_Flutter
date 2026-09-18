import 'package:flutter/material.dart';

class ConnectorsScreen extends StatelessWidget {
  const ConnectorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connectors & Integrations'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Connectors Screen (/portal/connectors)'),
      ),
    );
  }
}
