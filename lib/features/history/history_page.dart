import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/history_entry.dart';
import '../../data/history_query.dart';
import '../../data/history_store.dart';
import '../../utils/date_format_id.dart';

enum _ExportFormat { excel, pdf }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryEntry> _allItems = [];
  HistoryQuery _listQuery = const HistoryQuery();
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

  Future<void> _deleteEntry(HistoryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus riwayat skrining ini? '
          'Data dan gambar terkait akan dihapus secara permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await HistoryStore.removeById(entry.id);
      if (mounted) {
        setState(() {
          _allItems.removeWhere((e) => e.id == entry.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Riwayat berhasil dihapus.')),
        );
      }
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Semua Riwayat'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus seluruh riwayat skrining? '
          'Semua data dan gambar tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Ya, Hapus Semua'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await HistoryStore.clear();
      if (mounted) {
        setState(() {
          _allItems = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua riwayat berhasil dihapus.')),
        );
      }
    }
  }

  List<HistoryEntry> get _filtered => filterHistoryEntries(_allItems, _listQuery);

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

  static String _monthYearLabel(DateTime dt) => DateFormatId.monthYearLabelUpper(dt);

  static String _formatDateTime(DateTime dt) => DateFormatId.dateTimeWib(dt);

  static String _maskNik(String? nik) {
    if (nik == null || nik.length < 4) return '-';
    final suffix = nik.substring(nik.length - 4);
    return '************$suffix';
  }

  String _exportFileName(String extension) {
    final timestampMillis = DateTime.now().millisecondsSinceEpoch;
    return 'riwayat_skrining_$timestampMillis.$extension';
  }

  Future<void> _showExportDialog() async {
    if (_allItems.isEmpty) return;

    _ExportFormat format = _ExportFormat.excel;
    var query = HistoryQuery(resultFilter: _listQuery.resultFilter);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Export Riwayat',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 12),
              SegmentedButton<_ExportFormat>(
                segments: const [
                  ButtonSegment(
                    value: _ExportFormat.excel,
                    label: Text('Excel'),
                    icon: Icon(Icons.table_chart_outlined),
                  ),
                  ButtonSegment(
                    value: _ExportFormat.pdf,
                    label: Text('PDF'),
                    icon: Icon(Icons.picture_as_pdf_outlined),
                  ),
                ],
                selected: {format},
                onSelectionChanged: (value) =>
                    setModalState(() => format = value.first),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<HistoryResultFilter>(
                value: query.resultFilter,
                decoration: const InputDecoration(
                  labelText: 'Filter Hasil',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: HistoryResultFilter.semua,
                    child: Text('Semua'),
                  ),
                  DropdownMenuItem(
                    value: HistoryResultFilter.indikasi,
                    child: Text('Indikasi'),
                  ),
                  DropdownMenuItem(
                    value: HistoryResultFilter.tidakIndikasi,
                    child: Text('Tidak Ada Indikasi'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setModalState(() => query = query.copyWith(resultFilter: value));
                },
              ),
              const SizedBox(height: 12),
              SegmentedButton<HistoryDateFilterMode>(
                segments: const [
                  ButtonSegment(
                    value: HistoryDateFilterMode.semua,
                    label: Text('Semua'),
                  ),
                  ButtonSegment(
                    value: HistoryDateFilterMode.bulan,
                    label: Text('Bulan'),
                  ),
                  ButtonSegment(
                    value: HistoryDateFilterMode.rentang,
                    label: Text('Rentang'),
                  ),
                ],
                selected: {query.dateMode},
                onSelectionChanged: (value) {
                  setModalState(() {
                    query = query.copyWith(dateMode: value.first);
                  });
                },
              ),
              const SizedBox(height: 10),
              if (query.dateMode == HistoryDateFilterMode.bulan)
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: query.month ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked == null) return;
                    setModalState(() {
                      query = query.copyWith(month: DateTime(picked.year, picked.month));
                    });
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    query.month == null
                        ? 'Pilih Bulan'
                        : DateFormatId.monthYear(query.month!),
                  ),
                ),
              if (query.dateMode == HistoryDateFilterMode.rentang)
                OutlinedButton.icon(
                  onPressed: () async {
                    final currentRange = query.range;
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDateRange: currentRange == null
                          ? null
                          : DateTimeRange(
                              start: currentRange.start,
                              end: currentRange.end,
                            ),
                    );
                    if (picked == null) return;
                    setModalState(() {
                      query = query.copyWith(
                        range: DateTimeRangeValue(
                          start: picked.start,
                          end: picked.end,
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(
                    query.range == null
                        ? 'Pilih Rentang Tanggal'
                        : '${DateFormatId.dateOnly(query.range!.start)} - ${DateFormatId.dateOnly(query.range!.end)}',
                  ),
                ),
              const SizedBox(height: 10),
              Text('Data terpilih: ${filterHistoryEntries(_allItems, query).length}'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (query.dateMode == HistoryDateFilterMode.bulan &&
                            query.month == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Silakan pilih bulan terlebih dahulu.')),
                          );
                          return;
                        }
                        if (query.dateMode == HistoryDateFilterMode.rentang &&
                            query.range == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Silakan pilih rentang tanggal terlebih dahulu.')),
                          );
                          return;
                        }
                        context.pop();
                        await _export(format, query);
                      },
                      child: const Text('Export'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _export(_ExportFormat format, HistoryQuery query) async {
    final items = filterHistoryEntries(_allItems, query);
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diekspor')),
      );
      return;
    }

    try {
      if (format == _ExportFormat.excel) {
        await _exportExcel(items);
      } else {
        await _exportPdf(items);
      }
    } catch (e, st) {
      debugPrint('Gagal export riwayat: $e');
      debugPrint('$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat membuat file export. Silakan coba lagi.'),
        ),
      );
    }
  }

  Future<void> _exportExcel(List<HistoryEntry> items) async {
    final excel = Excel.createExcel();
    final sheet = excel['Riwayat'];
    sheet.appendRow([
      TextCellValue('Tanggal'),
      TextCellValue('Nama'),
      TextCellValue('NIK'),
      TextCellValue('Alamat'),
      TextCellValue('Hasil'),
      TextCellValue('Confidence'),
      TextCellValue('Latitude'),
      TextCellValue('Longitude'),
    ]);

    for (final e in items) {
      sheet.appendRow([
        TextCellValue(DateFormatId.dateTimeWib(e.createdAt)),
        TextCellValue(e.patientName ?? '-'),
        TextCellValue(_maskNik(e.nik)),
        TextCellValue(e.address ?? '-'),
        TextCellValue(e.label == 'indikasi' ? 'Indikasi' : 'Tidak Ada Indikasi'),
        TextCellValue('${(e.confidence * 100).toStringAsFixed(1)}%'),
        TextCellValue(e.latitude?.toStringAsFixed(6) ?? '-'),
        TextCellValue(e.longitude?.toStringAsFixed(6) ?? '-'),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Gagal membuat file excel');
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${_exportFileName('xlsx')}';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(path)],
      text: 'Export riwayat skrining',
    );
  }

  Future<void> _exportPdf(List<HistoryEntry> items) async {
    final indikasiCount = items.where((e) => e.label == 'indikasi').length;
    final tidakIndikasiCount = items.length - indikasiCount;
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Laporan Riwayat Skrining', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Total data: ${items.length}'),
          pw.Text('Jumlah indikasi: $indikasiCount'),
          pw.Text('Jumlah tidak indikasi: $tidakIndikasiCount'),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: const ['Tanggal', 'Nama', 'NIK', 'Alamat', 'Hasil', 'Confidence', 'Latitude', 'Longitude'],
            data: items
                .map(
                  (e) => [
                    DateFormatId.dateOnly(e.createdAt),
                    e.patientName ?? '-',
                    _maskNik(e.nik),
                    e.address ?? '-',
                    e.label == 'indikasi' ? 'Indikasi' : 'Tidak Ada Indikasi',
                    '${(e.confidence * 100).toStringAsFixed(1)}%',
                    e.latitude?.toStringAsFixed(6) ?? '-',
                    e.longitude?.toStringAsFixed(6) ?? '-',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final fileName = _exportFileName('pdf');
    await Printing.sharePdf(bytes: bytes, filename: fileName);
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
        actions: [
          if (_allItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.map_outlined),
              tooltip: 'Lihat di Peta',
              onPressed: () => context.push('/history/map'),
            ),
          if (_allItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.ios_share_outlined),
              tooltip: 'Export',
              onPressed: _showExportDialog,
            ),
          if (_allItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Hapus Semua Riwayat',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: Column(
        children: [
          _FilterChips(
            active: _listQuery.resultFilter,
            onChanged: (f) => setState(() {
              _listQuery = _listQuery.copyWith(resultFilter: f);
            }),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyHistoryState(onStart: () => context.go('/detect'))
                : _GroupedHistoryList(
                    sections: sections,
                    formatDateTime: _formatDateTime,
                    onOpen: (e) {
                      context.push('/history/detail/${e.id}').then((_) {
                        if (mounted) _loadHistory();
                      });
                    },
                    onDelete: _deleteEntry,
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
  final HistoryResultFilter active;
  final ValueChanged<HistoryResultFilter> onChanged;

  const _FilterChips({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget chip(HistoryResultFilter filter, String label) {
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
          chip(HistoryResultFilter.semua, 'Semua'),
          chip(HistoryResultFilter.indikasi, 'Indikasi'),
          chip(HistoryResultFilter.tidakIndikasi, 'Tidak Ada Indikasi'),
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
  final void Function(HistoryEntry) onDelete;

  const _GroupedHistoryList({
    required this.sections,
    required this.formatDateTime,
    required this.onOpen,
    required this.onDelete,
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
            onDelete: () => onDelete(e),
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
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.entry,
    required this.formattedTime,
    required this.onOpen,
    required this.onDelete,
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
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          tooltip: 'Hapus',
                          onPressed: onDelete,
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
