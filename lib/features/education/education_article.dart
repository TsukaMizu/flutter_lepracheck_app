class EducationArticle {
  final String id;
  final String title;
  final String body;
  final String category;
  final String imageUrl;
  final String readTime;
  final bool isFeatured;

  EducationArticle({
    required this.id,
    required this.title,
    required this.body,
    this.category = 'Umum',
    this.imageUrl = '',
    this.readTime = '5 menit baca',
    this.isFeatured = false,
  });

  factory EducationArticle.fromJson(Map<String, dynamic> json) {
    return EducationArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      body: (json['body'] ?? json['content'] ?? '') as String,
      category: (json['category'] ?? 'Umum') as String,
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '') as String,
      readTime: (json['readTime'] ?? json['read_time'] ?? '5 menit baca') as String,
      isFeatured: (json['isFeatured'] ?? json['is_featured'] ?? false) as bool,
    );
  }
}