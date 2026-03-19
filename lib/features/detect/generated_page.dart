import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/ml/remote_ml_service.dart';

class GeneratedPage extends StatefulWidget {
  final String imagePath;
  const GeneratedPage({super.key, required this.imagePath});

  @override
  State<GeneratedPage> createState() => _GeneratedPageState();
}

class _GeneratedPageState extends State<GeneratedPage> {
  bool _started = false;

  // GANTI sesuai IP laptop kamu saat demo
  // Tips: kalau IP sering berubah, nanti kita bisa bikin halaman Settings sederhana.
  final _ml = const RemoteMlService(baseUrl: 'http://10.45.109.198:8000');

  @override
  void initState() {
    super.initState();
    _runOnce();
  }

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

      final result = await _ml.predictImageFile(file);

      if (!mounted) return;
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