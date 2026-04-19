import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/history_entry.dart';
import '../../data/history_store.dart';

enum _HistoryFilter { all, indikasi, tidakIndikasi }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryEntry> _allItems = [];
  _HistoryFilter _activeFilter = _HistoryFilter.all;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await HistoryStore.getAll();
    if (mounted) {
      setState(() {
        _allItems = items;
        _loading = false;
      });
    }
  }

  List<HistoryEntry> get _filtered => switch (_activeFilter) {
        _HistoryFilter.indikasi =>
          _allItems.where((e) => e.label == 'indikasi').toList(),
        _HistoryFilter.tidakIndikasi =>
          _allItems.where((e) => e.label == 'tidak_indikasi').toList(),
        _HistoryFilter.all => _allItems,
      };

  /// Groups items (already sorted newest-first) into ordered sections by month-year.
  List<({String header, List<HistoryEntry> items})> _groupByMonth(
      List<HistoryEntry> items) {
    final seen = <String>[];
    final map = <String, List<HistoryEntry>>{};
    for (final e in items) {
      final key = _monthYearLabel(e.createdAt);
      if (!map.containsKey(key)) {
        seen.add(key);
        map[key] = [];
      }
      map[key]!.add(e);
    }
    return [for (final k in seen) (header: k, items: map[k]!)];
  }

  static String _monthYearLabel(DateTime dt) {
    const months = [
      'JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI',
      'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  static String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $h:$m WIB';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _filtered;
    final sections = _groupByMonth(filtered);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Skrining'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _FilterChips(
            active: _activeFilter,
            onChanged: (f) => setState(() => _activeFilter = f),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyHistoryState(onStart: () => context.go('/detect'))
                : _GroupedHistoryList(
                    sections: sections,
                    formatDateTime: _formatDateTime,
                    onOpen: (e) => context.push('/history/detail/${e.id}'),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips row
// ---------------------------------------------------------------------------

class _FilterChips extends StatelessWidget {
  final _HistoryFilter active;
  final ValueChanged<_HistoryFilter> onChanged;

  const _FilterChips({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget chip(_HistoryFilter filter, String label) {
      final isActive = active == filter;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(label),
          selected: isActive,
          onSelected: (_) => onChanged(filter),
          selectedColor: cs.primary,
          checkmarkColor: cs.onPrimary,
          labelStyle: TextStyle(
            color: isActive ? cs.onPrimary : cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: cs.surface,
          side: BorderSide(color: isActive ? cs.primary : cs.outline),
          showCheckmark: false,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          chip(_HistoryFilter.all, 'Semua'),
          chip(_HistoryFilter.indikasi, 'Indikasi'),
          chip(_HistoryFilter.tidakIndikasi, 'Tidak Ada Indikasi'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grouped list
// ---------------------------------------------------------------------------

class _GroupedHistoryList extends StatelessWidget {
  final List<({String header, List<HistoryEntry> items})> sections;
  final String Function(DateTime) formatDateTime;
  final void Function(HistoryEntry) onOpen;

  const _GroupedHistoryList({
    required this.sections,
    required this.formatDateTime,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    // Flatten sections into a mixed list of headers and entries.
    final rows = <Object>[];
    for (final s in sections) {
      rows.add(s.header);
      rows.addAll(s.items);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final row = rows[i];
        if (row is String) {
          return _MonthHeader(label: row);
        }
        final e = row as HistoryEntry;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _HistoryCard(
            entry: e,
            formattedTime: formatDateTime(e.createdAt),
            onOpen: () => onOpen(e),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Month section header
// ---------------------------------------------------------------------------

class _MonthHeader extends StatelessWidget {
  final String label;
  const _MonthHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

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
              style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  height: 1.35),
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

// ---------------------------------------------------------------------------
// History card
// ---------------------------------------------------------------------------

class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final String formattedTime;
  final VoidCallback onOpen;

  const _HistoryCard({
    required this.entry,
    required this.formattedTime,
    required this.onOpen,
  });

  /// Membuka Google Maps di browser/aplikasi eksternal menggunakan
  /// koordinat yang tersimpan di entri riwayat.
  Future<void> _openMap(BuildContext context) async {
    final lat = entry.latitude!;
    final lng = entry.longitude!;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isIndication = entry.label == 'indikasi';
    final displayLabel = isIndication ? 'Indikasi' : 'Tidak Ada Indikasi';

    final iconBg =
        isIndication ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);
    final iconColor =
        isIndication ? const Color(0xFFF57C00) : const Color(0xFF2E7D32);
    final badgeBg =
        isIndication ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);
    final badgeText =
        isIndication ? const Color(0xFFE65100) : const Color(0xFF2E7D32);

    // Tentukan apakah ada data pasien yang perlu ditampilkan
    final hasPatientName =
        entry.patientName != null && entry.patientName!.isNotEmpty;
    final hasNik = entry.nik != null && entry.nik!.isNotEmpty;
    final hasAddress = entry.address != null && entry.address!.isNotEmpty;
    final hasCoords = entry.latitude != null && entry.longitude != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left status icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(
                isIndication
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_rounded,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Right badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          displayLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: badgeText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),

                  // Data pasien (ditampilkan jika tersedia)
                  if (hasPatientName) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.patientName!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (hasNik) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge_outlined,
                            size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          'NIK: ${entry.nik!}',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (hasAddress) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.home_outlined,
                            size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.address!,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Baris bawah: Lihat Detail + Buka Peta (jika ada koordinat)
                  Row(
                    children: [
                      InkWell(
                        onTap: onOpen,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            'Lihat Detail >',
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (hasCoords) ...[
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => _openMap(context),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map_outlined,
                                    size: 14, color: cs.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Buka Peta',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: cs.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}