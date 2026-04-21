import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

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
}

/// Layanan inferensi ML secara lokal (on-device) menggunakan TensorFlow Lite.
///
/// Keunggulan pendekatan ini: aplikasi dapat melakukan deteksi 100% offline
/// tanpa memerlukan koneksi jaringan ke server.
///
/// Spesifikasi model:
///   Input  : [1, 64, 64, 3]  → batch=1, tinggi=64, lebar=64, channel RGB
///                               Nilai setiap piksel dinormalisasi ke rentang 0.0–1.0
///                               dengan cara membagi nilai asli (0–255) dengan 255.0.
///   Output : [1, 1]           → satu nilai probabilitas dalam rentang 0.0–1.0
///   Threshold:
///     - nilai ≥ 0.5 → "tidak_indikasi" (gambar tergolong normal)
///     - nilai  < 0.5 → "indikasi"       (terdeteksi lesi yang mencurigakan)
///
/// Catatan inisialisasi: interpreter dimuat secara lazy pada pemanggilan pertama
/// [predictImageFile]. Untuk menghindari jeda di prediksi pertama, panggil
/// [loadModel] secara eksplisit saat startup (misalnya di dalam `main()` atau
/// `initState` widget utama).
class TfliteMlService {
  // Path asset model TFLite yang sudah didaftarkan di pubspec.yaml.
  static const _modelAsset = 'assets/models/model.tflite';
  // Ukuran input gambar yang diharapkan model: 64×64 piksel.
  static const _inputSize = 64;
  // Ambang batas (threshold) untuk menentukan kelas prediksi.
  static const _threshold = 0.5;

  Interpreter? _interpreter;

  /// Memuat model TFLite dari folder assets.
  /// Melempar [Exception] jika file model tidak ditemukan atau rusak.
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
    } catch (e) {
      throw Exception('Gagal memuat model TFLite: $e');
    }
  }

  /// Mengembalikan [true] jika model sudah dimuat dan siap digunakan.
  bool get isLoaded => _interpreter != null;

  /// Menjalankan inferensi pada [imageFile] dan mengembalikan [MlResult].
  ///
  /// Proses pra-pemrosesan gambar:
  ///   1. Decode: membaca bytes gambar dari file.
  ///   2. Resize: mengubah ukuran gambar menjadi 64×64 piksel.
  ///   3. Normalisasi: membagi nilai R, G, B (0–255) dengan 255.0
  ///      sehingga tiap kanal berada dalam rentang [0.0, 1.0].
  ///   4. Reshape: menyusun data menjadi tensor [1, 64, 64, 3] (Float32).
  ///
  /// Proses ini identik dengan pra-pemrosesan yang dilakukan di server Python,
  /// sehingga hasil prediksi konsisten antara on-device dan API.
  Future<MlResult> predictImageFile(File imageFile) async {
    // Muat model secara lazy jika belum dimuat sebelumnya.
    if (_interpreter == null) {
      await loadModel();
    }
    final interpreter = _interpreter!;

    // Langkah 1: Baca dan decode file gambar menjadi objek Image.
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Gagal membaca file gambar: ${imageFile.path}');
    }

    // Langkah 2: Ubah ukuran gambar menjadi 64×64 sesuai input model.
    final resized =
        img.copyResize(decoded, width: _inputSize, height: _inputSize);

    // Langkah 3 & 4: Bangun buffer Float32 flat untuk tensor input [1, 64, 64, 3].
    // Menggunakan buffer flat (bukan List bersarang) untuk menghindari overhead alokasi.
    final inputBuffer =
        Float32List(_inputSize * _inputSize * 3);
    var idx = 0;
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        // Normalisasi setiap kanal warna ke rentang [0.0, 1.0].
        inputBuffer[idx++] = pixel.r / 255.0;
        inputBuffer[idx++] = pixel.g / 255.0;
        inputBuffer[idx++] = pixel.b / 255.0;
      }
    }
    // Reshape buffer menjadi [1, 64, 64, 3] sesuai yang diharapkan interpreter.
    final input = inputBuffer.reshape([1, _inputSize, _inputSize, 3]);

    // Siapkan tensor output berbentuk [1, 1] untuk menampung nilai probabilitas.
    final output = [List.filled(1, 0.0)];

    // Jalankan inferensi model.
    interpreter.run(input, output);

    // Terapkan threshold untuk menentukan label hasil.
    final probability = (output[0][0] as num).toDouble();
    final label =
        probability >= _threshold ? 'tidak_indikasi' : 'indikasi';

    return MlResult(label: label, confidence: probability);
  }

  /// Melepaskan sumber daya interpreter ketika tidak lagi dibutuhkan.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
