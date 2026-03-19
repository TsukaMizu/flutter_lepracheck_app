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
      appBar: AppBar(title: const Text('Validasi Gambar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Cek gambar sebelum diproses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: !has
                    ? const Center(child: Text('Gambar tidak ditemukan'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(File(imagePath), fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  has
                      ? 'Pastikan gambar jelas dan tidak blur.'
                      : 'Silakan ulangi dan pilih gambar.',
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/detect'),
                    child: const Text('Ulangi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: has
                        ? () => context.go('/detect/generated?path=${Uri.encodeComponent(imagePath)}')
                        : null,
                    child: const Text('Proses'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}