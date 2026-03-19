import 'dart:convert';
import 'package:flutter/services.dart';

import 'education_article.dart';

class EducationRepository {
  static Future<List<EducationArticle>> load() async {
    final raw = await rootBundle.loadString('lib/assets/education/education.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(EducationArticle.fromJson).toList();
  }
}