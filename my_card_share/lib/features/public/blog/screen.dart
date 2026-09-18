import 'package:flutter/material.dart';

class BlogListingScreen extends StatelessWidget {
  const BlogListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog')),
      body: const Center(child: Text('Blog Listing')),
    );
  }
}
