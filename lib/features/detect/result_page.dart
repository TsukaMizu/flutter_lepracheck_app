import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Halaman hasil deteksi yang menampilkan label prediksi dan nilai confidence.
///
/// Pengguna dapat menekan tombol "Lengkapi Data Laporan" untuk mengisi data
/// pasien (NIK, Nama, Alamat, GPS) sebelum laporan disimpan ke riwayat.
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
  /// Menampilkan dialog konfirmasi sebelum meninggalkan halaman tanpa menyimpan.
  ///
  /// [onConfirm] dipanggil jika pengguna memilih "Ya, Tinggalkan".
  Future<void> _showDiscardWarningDialog(VoidCallback onConfirm) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Data Belum Disimpan'),
        content: const Text(
          'Jika Anda meninggalkan halaman ini, hasil skrining dan gambar '
          'tidak akan tersimpan ke riwayat. Anda yakin ingin melanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            child: const Text('Ya, Tinggalkan'),
          ),
        ],
      ),
    );
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
              // Tombol utama: arahkan ke form data pasien sebelum menyimpan laporan
              FilledButton.icon(
                onPressed: () => context.go(
                  '/detect/form'
                  '?path=${Uri.encodeComponent(widget.imagePath)}'
                  '&label=${Uri.encodeComponent(widget.label)}'
                  '&conf=${widget.confidence}',
                ),
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('Lengkapi Data Laporan'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _showDiscardWarningDialog(
                  () => context.go('/detect'),
                ),
                child: const Text('Deteksi Lagi'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => _showDiscardWarningDialog(
                  () => context.go('/history'),
                ),
                child: const Text('Lihat Riwayat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

