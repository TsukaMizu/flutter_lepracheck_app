import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Halaman hasil deteksi yang menampilkan label prediksi dan nilai confidence.
///
/// Pengguna dapat menekan tombol "Lengkapi Data Laporan" untuk mengisi data
/// pasien (NIK, Nama, Alamat, GPS) sebelum laporan disimpan ke riwayat.
class ResultPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isIndication = label == 'indikasi';

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
                  child: imagePath.isEmpty
                      ? const ColoredBox(color: Colors.black12)
                      : Image.file(File(imagePath), fit: BoxFit.cover),
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
                      Text('Confidence: ${(confidence * 100).toStringAsFixed(0)}%'),
                      const SizedBox(height: 12),
                      const Text('Hasil ini hanya screening, bukan diagnosis dokter.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tombol utama: arahkan ke form data pasien sebelum menyimpan laporan
              FilledButton.icon(
                onPressed: () => context.go(
                  '/detect/form'
                  '?path=${Uri.encodeComponent(imagePath)}'
                  '&label=${Uri.encodeComponent(label)}'
                  '&conf=$confidence',
                ),
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('Lengkapi Data Laporan'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.go('/detect'),
                child: const Text('Deteksi Lagi'),
              ),
              const SizedBox(height: 10),
              TextButton(
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

