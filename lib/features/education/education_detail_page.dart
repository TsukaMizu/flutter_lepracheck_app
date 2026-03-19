import 'package:flutter/material.dart';
import 'education_article.dart';

class EducationDetailPage extends StatelessWidget {
  final EducationArticle article;
  const EducationDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(article.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(article.body, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}