import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/history_store.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Trick sederhana agar FutureBuilder refresh
  int _reloadTick = 0;

  void _reload() => setState(() => _reloadTick++);

  Future<void> _confirmClearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua riwayat?'),
        content: const Text('Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (ok != true) return;

    await HistoryStore.clear();
    _reload();
  }

  Future<void> _deleteOne(String id) async {
    await HistoryStore.removeById(id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            tooltip: 'Hapus semua',
            onPressed: _confirmClearAll,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: FutureBuilder(
        // pakai _reloadTick biar FutureBuilder rebuild
        future: HistoryStore.getAll().then((v) => (_reloadTick, v)).then((t) => t.$2),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('Belum ada riwayat.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final e = items[i];
              final isIndication = e.label == 'indikasi';

              return Dismissible(
                key: ValueKey(e.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus item ini?'),
                      content: const Text('Tindakan ini tidak bisa dibatalkan.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                      ],
                    ),
                  );
                  return ok == true;
                },
                onDismissed: (_) => _deleteOne(e.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onErrorContainer),
                ),
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: File(e.imagePath).existsSync()
                          ? Image.file(File(e.imagePath), fit: BoxFit.cover)
                          : const ColoredBox(color: Colors.black12),
                    ),
                  ),
                  title: Text(
                    isIndication ? 'Indikasi' : 'Tidak ada indikasi',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isIndication ? Theme.of(context).colorScheme.error : null,
                    ),
                  ),
                  subtitle: Text(
                    '${e.createdAt.toLocal()} • ${(e.confidence * 100).toStringAsFixed(0)}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(
                    '/detect/result?path=${Uri.encodeComponent(e.imagePath)}&label=${e.label}&conf=${e.confidence}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}