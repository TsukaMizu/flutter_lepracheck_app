import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/history_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: HistoryStore.getLatest(),
        builder: (context, snapshot) {
          final latest = snapshot.data;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                color: cs.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Skrining Terakhir',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),

                      if (snapshot.connectionState != ConnectionState.done)
                        const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
                      else if (latest == null)
                        const Text('Belum ada riwayat skrining. Mulai dari tab Deteksi.')
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 88,
                                height: 88,
                                child: File(latest.imagePath).existsSync()
                                    ? Image.file(File(latest.imagePath), fit: BoxFit.cover)
                                    : const ColoredBox(color: Colors.black12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    latest.label == 'indikasi' ? 'Indikasi' : 'Tidak ada indikasi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: latest.label == 'indikasi' ? cs.error : cs.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Confidence: ${(latest.confidence * 100).toStringAsFixed(0)}%'),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Waktu: ${latest.createdAt.toLocal()}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 12),

                      if (latest != null)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context.go(
                                  '/detect/result?path=${Uri.encodeComponent(latest.imagePath)}&label=${latest.label}&conf=${latest.confidence}',
                                ),
                                child: const Text('Lihat Detail'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context.go('/history'),
                                child: const Text('Riwayat'),
                              ),
                            ),
                          ],
                        )
                      else
                        OutlinedButton(
                          onPressed: () => context.go('/history'),
                          child: const Text('Buka Riwayat'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.go('/detect'),
                icon: const Icon(Icons.document_scanner_outlined),
                label: const Text('Mulai Deteksi'),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Catatan: hasil ini hanya screening, bukan pengganti diagnosis dokter.',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}