import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImageValidationPage extends StatelessWidget {
  final String imagePath;

  const ImageValidationPage({super.key, required this.imagePath});

  bool get _hasImage => imagePath.isNotEmpty && File(imagePath).existsSync();

  @override
  Widget build(BuildContext context) {
    final has = _hasImage;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/detect'),
        ),
        title: const Text('Review Foto'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indikator langkah
              _StepIndicator(totalSteps: 3, currentStep: 1),
              const SizedBox(height: 20),

              // Kontainer gambar
              _ImageContainer(imagePath: imagePath, hasImage: has),
              const SizedBox(height: 16),

              // Kartu analisis kualitas foto (mockup statis untuk demo)
              const _QualityAnalysisCard(),
              const SizedBox(height: 8),

              // Teks disclaimer
              const Text(
                '* Analisis di atas adalah estimasi awal untuk keperluan pratinjau. '
                'Keputusan akhir ditentukan oleh model AI saat pemrosesan.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Tombol Gunakan Foto Ini
              FilledButton(
                onPressed: has
                    ? () => context.go(
                        '/detect/generated?path=${Uri.encodeComponent(imagePath)}')
                    : null,
                child: const Text('Gunakan Foto Ini'),
              ),
              const SizedBox(height: 10),

              // Tombol Ambil Ulang
              OutlinedButton(
                onPressed: () => context.go('/detect'),
                child: const Text('Ambil Ulang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Indikator langkah berupa garis horizontal berwarna.
class _StepIndicator extends StatelessWidget {
  final int totalSteps;
  // 0-indexed: steps up to and including currentStep are highlighted as active.
  // e.g. currentStep=1 with 3 totalSteps highlights steps 0 and 1 (camera done, review active).
  final int currentStep;

  const _StepIndicator({required this.totalSteps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF1565C0);
    final inactiveColor = Colors.grey.shade300;

    return Row(
      children: List.generate(totalSteps, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: i <= currentStep ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

/// Kontainer menampilkan gambar dengan sudut membulat dan bayangan.
class _ImageContainer extends StatelessWidget {
  final String imagePath;
  final bool hasImage;

  const _ImageContainer({required this.imagePath, required this.hasImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: !hasImage
            ? Container(
                color:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: Text('Gambar tidak ditemukan'),
                ),
              )
            : Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
      ),
    );
  }
}

/// Kartu analisis kualitas foto (tampilan statis untuk demo UI).
class _QualityAnalysisCard extends StatelessWidget {
  const _QualityAnalysisCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analisis Kualitas Foto',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            _QualityRow(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              label: 'Fokus: Bagus',
            ),
            const SizedBox(height: 8),
            _QualityRow(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              label: 'Pencahayaan: Cukup',
            ),
            const SizedBox(height: 8),
            _QualityRow(
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.orange,
              label: 'Area Lesi: Mungkin terpotong',
            ),
          ],
        ),
      ),
    );
  }
}

class _QualityRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _QualityRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}