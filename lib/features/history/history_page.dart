import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/history_entry.dart';
import '../../data/history_store.dart';
import '../../widgets/confirm_dialog.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _reloadTick = 0;
  void _reload() => setState(() => _reloadTick++);

Future<void> _confirmClearAll() async {
  final ok = await showConfirmDialog(
    context: context,
    title: 'Hapus semua riwayat?',
    message: 'Tindakan ini tidak bisa dibatalkan.',
    cancelText: 'Batal',
    confirmText: 'Hapus',
    destructive: true,
  );

  if (!ok) return;

  await HistoryStore.clear();
  _reload();
}

  Future<void> _deleteOne(String id) async {
    await HistoryStore.removeById(id);
    _reload();
  }

  String _formatDayMonth(DateTime dt) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN', 'JUL', 'AGS', 'SEP', 'OKT', 'NOV', 'DES'];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Menu',
            onSelected: (v) {
              if (v == 'clear') _confirmClearAll();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'clear', child: Text('Hapus semua')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<HistoryEntry>>(
        future: HistoryStore.getAll().then((v) => (_reloadTick, v)).then((t) => t.$2),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return _EmptyHistoryState(
              onStart: () => context.go('/detect'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final e = items[i];
              return _HistoryCard(
                entry: e,
                dayMonth: _formatDayMonth(e.createdAt),
                onOpen: () => context.go(
                  '/detect/result?path=${Uri.encodeComponent(e.imagePath)}&label=${e.label}&conf=${e.confidence}',
                ),
               onDelete: () async {
  final ok = await showConfirmDialog(
    context: context,
    title: 'Hapus item ini?',
    message: 'Tindakan ini tidak bisa dibatalkan.',
    cancelText: 'Batal',
    confirmText: 'Hapus',
    destructive: true,
  );

  if (ok) {
    await _deleteOne(e.id);
  }
},
                colorScheme: cs,
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  final VoidCallback onStart;
  const _EmptyHistoryState({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(Icons.history, size: 40, color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum ada riwayat skrining',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Hasil skrining kamu akan tampil di sini setelah melakukan deteksi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600, height: 1.35),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 220,
              height: 52,
              child: FilledButton(
                onPressed: onStart,
                child: const Text('Mulai Skrining'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final String dayMonth;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final ColorScheme colorScheme;

  const _HistoryCard({
    required this.entry,
    required this.dayMonth,
    required this.onOpen,
    required this.onDelete,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isIndication = entry.label == 'indikasi';
    final riskText = isIndication ? 'Risiko TINGGI' : 'Risiko RENDAH';
    final riskColor = isIndication ? colorScheme.error : const Color(0xFF16A34A);
    final subtitleColor = isIndication ? colorScheme.error : const Color(0xFF16A34A);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onOpen,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: File(entry.imagePath).existsSync()
                      ? Image.file(File(entry.imagePath), fit: BoxFit.cover)
                      : const ColoredBox(color: Colors.black12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            dayMonth,
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(entry.confidence * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Laporan Skrining',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      riskText,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_right, color: colorScheme.outline),
                  const SizedBox(height: 6),
                  IconButton(
                    tooltip: 'Hapus',
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, color: riskColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}