import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'remote_ml_service.dart';

/// Local on-device ML inference using TensorFlow Lite.
///
/// Model spec:
///   Input  : [1, 64, 64, 3]  float32, RGB normalised 0–1
///   Output : [1, 1]          float32, probability (0–1)
///   Threshold ≥ 0.5  → "tidak_indikasi" (Normal)
///   Threshold  < 0.5 → "indikasi"       (Kusta)
///
/// **Initialisation**: the interpreter is loaded lazily on the first call to
/// [predictImageFile]. To avoid a delay on the first prediction, call
/// [loadModel] explicitly during app startup (e.g. in `main()` or
/// `initState` of your entry widget).
class TfliteMlService {
  static const _modelAsset = 'assets/models/model.tflite';
  static const _inputSize = 64;
  static const _threshold = 0.5;

  Interpreter? _interpreter;

  /// Loads the TFLite model from the bundled assets.
  /// Throws an [Exception] if the model asset is missing or corrupt.
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
    } catch (e) {
      throw Exception('Gagal memuat model TFLite: $e');
    }
  }

  /// Returns [true] if the model has been loaded and is ready.
  bool get isLoaded => _interpreter != null;

  /// Runs inference on [imageFile].
  ///
  /// The image is resized to 64×64 and each channel is normalised to [0,1]
  /// before being fed into the interpreter.
  Future<MlResult> predictImageFile(File imageFile) async {
    if (_interpreter == null) {
      await loadModel();
    }
    final interpreter = _interpreter!;

    // Decode image
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Gagal membaca file gambar: ${imageFile.path}');
    }

    // Resize to model input size
    final resized =
        img.copyResize(decoded, width: _inputSize, height: _inputSize);

    // Build a flat Float32List for the input tensor [1, 64, 64, 3].
    // Using a flat buffer avoids the overhead of deeply-nested dart Lists.
    final inputBuffer =
        Float32List(_inputSize * _inputSize * 3);
    var idx = 0;
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        inputBuffer[idx++] = pixel.r / 255.0;
        inputBuffer[idx++] = pixel.g / 255.0;
        inputBuffer[idx++] = pixel.b / 255.0;
      }
    }
    // Reshape to [1, 64, 64, 3] as required by interpreter.run()
    final input = inputBuffer.reshape([1, _inputSize, _inputSize, 3]);

    // Prepare output tensor [1, 1]
    final output = [List.filled(1, 0.0)];

    interpreter.run(input, output);

    final probability = (output[0][0] as num).toDouble();
    final label =
        probability >= _threshold ? 'tidak_indikasi' : 'indikasi';

    return MlResult(label: label, confidence: probability);
  }

  /// Releases interpreter resources.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
