import 'package:flutter/material.dart';

class BlogDetailScreen extends StatelessWidget {
  final String? slug;

  const BlogDetailScreen({super.key, this.slug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog Detail')),
      body: Center(child: Text('Blog Post: ${slug ?? "Detail"}')),
    );
  }
}
