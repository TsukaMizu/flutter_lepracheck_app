import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class DetectPage extends StatefulWidget {
  const DetectPage({super.key});

  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  final picker = ImagePicker();
  File? imageFile;
  String? error;

  Future<void> _pick(ImageSource source) async {
    setState(() => error = null);

    try {
      final xfile = await picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (xfile == null) return;
      setState(() => imageFile = File(xfile.path));
    } catch (e) {
      setState(() => error = 'Gagal mengambil gambar: $e');
    }
  }

  void _next() {
    final img = imageFile;
    if (img == null) {
      setState(() => error = 'Silakan ambil / pilih gambar dulu.');
      return;
    }
    context.go('/detect/validate?path=${Uri.encodeComponent(img.path)}');
  }

  @override
  Widget build(BuildContext context) {
    final img = imageFile;

    return Scaffold(
      appBar: AppBar(title: const Text('Deteksi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ambil foto atau unggah gambar',
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
                child: img == null
                    ? const Center(child: Text('Belum ada gambar'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(img, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _next,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Lanjut'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hanya screening, bukan diagnosis.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}