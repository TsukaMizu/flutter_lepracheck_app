/// Model data untuk satu entri riwayat skrining.
///
/// Field pasien (nik, patientName, address, latitude, longitude) bersifat
/// opsional (nullable) agar backward-compatible dengan data lama yang
/// tidak memiliki informasi pasien.
class HistoryEntry {
  final String id; // uuid-like sederhana
  final DateTime createdAt;
  final String imagePath;
  final String label; // 'indikasi' / 'tidak_indikasi'
  final double confidence;

  // Data pasien (diisi melalui PatientFormPage, bisa null untuk data lama)
  final String? nik;
  final String? patientName;
  final String? address;
  final double? latitude;
  final double? longitude;

  HistoryEntry({
    required this.id,
    required this.createdAt,
    required this.imagePath,
    required this.label,
    required this.confidence,
    this.nik,
    this.patientName,
    this.address,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'imagePath': imagePath,
        'label': label,
        'confidence': confidence,
        if (nik != null) 'nik': nik,
        if (patientName != null) 'patientName': patientName,
        if (address != null) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

  static HistoryEntry fromMap(Map map) => HistoryEntry(
        id: map['id'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        imagePath: map['imagePath'] as String,
        label: map['label'] as String,
        confidence: (map['confidence'] as num).toDouble(),
        nik: map['nik'] as String?,
        patientName: map['patientName'] as String?,
        address: map['address'] as String?,
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
      );
}