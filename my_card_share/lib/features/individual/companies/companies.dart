import 'package:flutter/material.dart';

class IndividualCompaniesScreen extends StatelessWidget {
  const IndividualCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Associated Companies')),
      body: const Center(child: Text('Associated Companies')),
    );
  }
}
