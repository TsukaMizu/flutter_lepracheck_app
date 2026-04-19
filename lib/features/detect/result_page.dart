import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/history_entry.dart';
import '../../data/history_store.dart';

/// Halaman hasil deteksi yang menampilkan label prediksi dan nilai confidence.
///
/// Halaman ini juga menyimpan hasil ke riwayat lokal (Hive) secara otomatis
/// saat pertama kali ditampilkan.
class ResultPage extends StatefulWidget {
  final String imagePath;
  final String label;
  final double confidence;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.label,
    required this.confidence,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  // Flag untuk memastikan penyimpanan ke riwayat hanya terjadi sekali,
  // meskipun widget di-rebuild (misalnya karena rotasi layar).
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveOnce();
  }

  /// Menyimpan hasil deteksi ke penyimpanan lokal (Hive) tepat sekali.
  ///
  /// ID entri dibuat dari timestamp mikro-detik untuk memastikan keunikan.
  Future<void> _saveOnce() async {
    if (_saved) return;
    _saved = true;

    final entry = HistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      imagePath: widget.imagePath,
      label: widget.label,
      confidence: widget.confidence,
    );

    await HistoryStore.add(entry);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isIndication = widget.label == 'indikasi';

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: widget.imagePath.isEmpty
                      ? const ColoredBox(color: Colors.black12)
                      : Image.file(File(widget.imagePath), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isIndication ? 'Indikasi' : 'Tidak ada indikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isIndication ? cs.error : cs.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Confidence: ${(widget.confidence * 100).toStringAsFixed(0)}%'),
                      const SizedBox(height: 12),
                      const Text('Hasil ini hanya screening, bukan diagnosis dokter.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/detect'),
                child: const Text('Deteksi Lagi'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.go('/history'),
                child: const Text('Lihat Riwayat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
