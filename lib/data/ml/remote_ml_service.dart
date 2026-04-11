import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class MlResult {
  final String label; // "indikasi" / "tidak_indikasi"
  final double confidence;

  const MlResult({
    required this.label,
    required this.confidence,
  });

  factory MlResult.fromJson(Map<String, dynamic> json) {
    return MlResult(
      label: (json['label'] as String?) ?? 'tidak_indikasi',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RemoteMlService {
  final String baseUrl;
  const RemoteMlService({required this.baseUrl});

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