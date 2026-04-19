import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Model data yang merepresentasikan hasil prediksi ML.
///
/// [label]      : 'indikasi' atau 'tidak_indikasi'
/// [confidence] : nilai probabilitas dalam rentang 0.0–1.0
class MlResult {
  final String label; // "indikasi" / "tidak_indikasi"
  final double confidence;

  const MlResult({
    required this.label,
    required this.confidence,
  });

  /// Membuat [MlResult] dari JSON response API.
  factory MlResult.fromJson(Map<String, dynamic> json) {
    return MlResult(
      label: (json['label'] as String?) ?? 'tidak_indikasi',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Layanan inferensi ML jarak jauh melalui FastAPI.
///
/// Digunakan sebagai fallback apabila [TfliteMlService] gagal
/// (misalnya file model belum ada di perangkat).
/// Mengirim gambar ke endpoint `/predict` menggunakan multipart/form-data
/// dan mengembalikan [MlResult] dari response JSON server.
class RemoteMlService {
  /// URL dasar server FastAPI. Contoh: 'http://192.168.1.5:8000'.
  /// Gunakan alamat IPv4 laptop, bukan localhost, karena emulator/HP
  /// Android tidak dapat mengakses 127.0.0.1 dari luar perangkat.
  final String baseUrl;
  const RemoteMlService({required this.baseUrl});

  /// Mengirim [imageFile] ke endpoint `/predict` dan mengembalikan [MlResult].
  /// Melempar [Exception] jika server mengembalikan status error.
  Future<MlResult> predictImageFile(File imageFile) async {
    final uri = Uri.parse('$baseUrl/predict');
    final req = http.MultipartRequest('POST', uri);

    req.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('ML service error ${res.statusCode}: $body');
    }

    final map = jsonDecode(body) as Map<String, dynamic>;
    return MlResult.fromJson(map);
  }
}
