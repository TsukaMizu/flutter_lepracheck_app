class EducationArticle {
  final String id;
  final String title;
  final String body;

  EducationArticle({required this.id, required this.title, required this.body});

  factory EducationArticle.fromJson(Map<String, dynamic> json) {
    return EducationArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}