import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/ml/remote_ml_service.dart';
import '../../data/ml/tflite_ml_service.dart';

/// Halaman pemrosesan inferensi ML.
///
/// Halaman ini hanya menampilkan loading indicator selama proses deteksi berlangsung,
/// kemudian secara otomatis berpindah ke [ResultPage] setelah selesai.
class GeneratedPage extends StatefulWidget {
  final String imagePath;
  const GeneratedPage({super.key, required this.imagePath});

  @override
  State<GeneratedPage> createState() => _GeneratedPageState();
}

class _GeneratedPageState extends State<GeneratedPage> {
  // Flag untuk memastikan inferensi hanya dijalankan sekali,
  // bahkan jika widget di-rebuild.
  bool _started = false;

  // Inferensi lokal (on-device) menggunakan TFLite — prioritas utama.
  // Tidak memerlukan jaringan sama sekali.
  final _tflite = TfliteMlService();

  // Inferensi jarak jauh via FastAPI — hanya digunakan sebagai fallback
  // jika TFLite gagal (misalnya model.tflite belum dimasukkan ke assets).
  // Ganti IP di sini sesuai alamat laptop saat demo.
  final _remote = const RemoteMlService(baseUrl: 'http://10.45.109.198:8000');

  @override
  void initState() {
    super.initState();
    _runOnce();
  }

  @override
  void dispose() {
    // Bebaskan sumber daya interpreter TFLite saat halaman ditutup.
    _tflite.dispose();
    super.dispose();
  }

  /// Menjalankan proses inferensi satu kali secara asinkron.
  ///
  /// Strategi: TFLite diutamakan (offline-first). Jika TFLite gagal,
  /// aplikasi mencoba memanggil API jarak jauh sebagai cadangan.
  /// Jika keduanya gagal, pesan error ditampilkan dan pengguna dikembalikan
  /// ke halaman kamera.
  Future<void> _runOnce() async {
    if (_started) return;
    _started = true;

    try {
      final file = File(widget.imagePath);
      if (!await file.exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar tidak ditemukan.')),
        );
        context.go('/detect');
        return;
      }

      // Coba inferensi lokal (TFLite) terlebih dahulu.
      // Jika gagal, gunakan API jarak jauh sebagai fallback.
      late MlResult result;
      try {
        result = await _tflite.predictImageFile(file);
      } catch (tfliteError) {
        debugPrint('TFLite inference failed, falling back to remote: $tfliteError');
        result = await _remote.predictImageFile(file);
      }

      if (!mounted) return;
      // Navigasi ke halaman hasil dengan meneruskan label dan confidence
      // melalui query parameter.
      context.go(
        '/detect/result?path=${Uri.encodeComponent(widget.imagePath)}'
        '&label=${Uri.encodeComponent(result.label)}'
        '&conf=${result.confidence}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memproses ML: $e')),
      );
      context.go('/detect');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan loading sementara model memproses gambar.
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Sedang memproses gambar...\nMohon tunggu.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
