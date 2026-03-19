class HistoryEntry {
  final String id; // uuid-like sederhana
  final DateTime createdAt;
  final String imagePath;
  final String label; // 'indikasi' / 'tidak_indikasi'
  final double confidence;

  HistoryEntry({
    required this.id,
    required this.createdAt,
    required this.imagePath,
    required this.label,
    required this.confidence,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'imagePath': imagePath,
        'label': label,
        'confidence': confidence,
      };

  static HistoryEntry fromMap(Map map) => HistoryEntry(
        id: map['id'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        imagePath: map['imagePath'] as String,
        label: map['label'] as String,
        confidence: (map['confidence'] as num).toDouble(),
      );
}