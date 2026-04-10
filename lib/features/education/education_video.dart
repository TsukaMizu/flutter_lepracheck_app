class EducationVideo {
  final String id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String duration;

  EducationVideo({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
  });

  factory EducationVideo.fromJson(Map<String, dynamic> json) {
    return EducationVideo(
      id: json['id'] as String,
      title: json['title'] as String,
      videoUrl: (json['videoUrl'] ?? json['video_url'] ?? '') as String,
      thumbnailUrl: (json['thumbnailUrl'] ?? json['thumbnail_url'] ?? '') as String,
      duration: (json['duration'] ?? '00:00') as String,
    );
  }
}
