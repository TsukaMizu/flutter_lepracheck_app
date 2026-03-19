import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tentang')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: cs.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LepraCheck', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  SizedBox(height: 8),
                  Text(
                    'Aplikasi screening kusta berbasis gambar.\n'
                    'Hasil bukan pengganti diagnosis dokter.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Disclaimer', style: TextStyle(fontWeight: FontWeight.w900)),
                  SizedBox(height: 8),
                  Text(
                    'Jika terdapat keluhan/bercak mati rasa/luka yang tidak sembuh, '
                    'segera periksa ke fasilitas kesehatan terdekat.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}