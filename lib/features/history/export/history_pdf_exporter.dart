import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/history_entry.dart';
import '../../../data/history_query.dart';
import '../../../utils/date_format_id.dart';

class HistoryPdfExporter {
  static const _noteConfidence =
      '*Confidence adalah persentase tingkat keyakinan model pada hasil skrining.';

  static Future<Uint8List> build({
    required List<HistoryEntry> items,
    required HistoryQuery query,
    DateTime? exportedAt,
  }) async {
    if (items.isEmpty) {
      throw ArgumentError('Data riwayat kosong, PDF tidak dapat dibuat.');
    }

    final doc = pw.Document();
    final time = exportedAt ?? DateTime.now();
    final logo = await _loadLogo();
    final sortedItems = [...items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final summary = _PdfSummary.fromEntries(sortedItems);

    doc.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 28),
        footer: (context) => _buildFooter(
          logo,
          pageNumber: context.pageNumber,
          pagesCount: context.pagesCount,
          exportedAt: time,
        ),
        build: (_) => [
          _buildHeader(logo, exportedAt: time),
          pw.SizedBox(height: 12),
          _buildSummaryCards(periodLabel(query, sortedItems), summary),
          pw.SizedBox(height: 12),
          _buildDataTable(sortedItems),
          pw.SizedBox(height: 6),
          pw.Text(
            _noteConfidence,
            style: pw.TextStyle(
              fontSize: 8,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static String periodLabel(HistoryQuery query, List<HistoryEntry> items) {
    if (query.dateMode == HistoryDateFilterMode.bulan && query.month != null) {
      final firstDay = DateTime(query.month!.year, query.month!.month, 1);
      final lastDay = DateTime(query.month!.year, query.month!.month + 1, 0);
      return '${DateFormatId.dateOnly(firstDay)} - ${DateFormatId.dateOnly(lastDay)}';
    }
    if (query.dateMode == HistoryDateFilterMode.rentang && query.range != null) {
      return '${DateFormatId.dateOnly(query.range!.start)} - ${DateFormatId.dateOnly(query.range!.end)}';
    }
    if (items.isEmpty) return '-';

    var oldest = items.first.createdAt;
    var latest = items.first.createdAt;
    for (final entry in items) {
      if (entry.createdAt.isBefore(oldest)) oldest = entry.createdAt;
      if (entry.createdAt.isAfter(latest)) latest = entry.createdAt;
    }
    return '${DateFormatId.dateOnly(oldest)} - ${DateFormatId.dateOnly(latest)}';
  }

  static String? googleMapsUrl(HistoryEntry entry) {
    final lat = entry.latitude;
    final lng = entry.longitude;
    if (lat == null || lng == null) return null;
    return 'https://www.google.com/maps?q=$lat,$lng';
  }

  static Future<pw.MemoryImage?> _loadLogo() async {
    try {
      final bytes = await rootBundle.load('assets/images/logo.png');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _buildHeader(
    pw.MemoryImage? logo, {
    required DateTime exportedAt,
  }) {
    const accent = PdfColor.fromInt(0xFF0F4C81);
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: accent, width: 1.4),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              _logoWidget(logo, size: 36),
              pw.SizedBox(width: 8),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LepraCheck',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                  pw.Text(
                    'Aplikasi skrining awal',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  ),
                ],
              ),
            ],
          ),
          pw.Spacer(),
          pw.Column(
            children: [
              pw.Text(
                'LAPORAN HASIL SKRINING',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                  color: accent,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Laporan ini berisi hasil skrining yang diperoleh dari sistem.',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: pw.BoxDecoration(
              color: accent,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                const pw.Text(
                  'Tanggal Export',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 8),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  DateFormatId.dateTimeWib(exportedAt),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCards(String period, _PdfSummary summary) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _summaryCard('Periode Data', period),
        _summaryCard('Total Data', '${summary.total}'),
        _summaryCard('Rata-rata Confidence', '${summary.avgPercent.toStringAsFixed(1)}%'),
        _summaryCard('Confidence Tertinggi', '${summary.maxPercent.toStringAsFixed(1)}%'),
        _summaryCard('Confidence Terendah', '${summary.minPercent.toStringAsFixed(1)}%'),
        _summaryCard('Indikasi / Tidak Ada', '${summary.indikasi} / ${summary.tidakIndikasi}'),
      ],
    );
  }

  static pw.Widget _summaryCard(String title, String value) {
    return pw.Container(
      width: 168,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDataTable(List<HistoryEntry> items) {
    const headerColor = PdfColor.fromInt(0xFF0F4C81);

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: headerColor),
        children: [
          _tableHeader('No'),
          _tableHeader('Tanggal'),
          _tableHeader('Nama'),
          _tableHeader('NIK'),
          _tableHeader('Alamat'),
          _tableHeader('Hasil'),
          _tableHeader('Confidence'),
          _tableHeader('Lokasi'),
        ],
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final mapUrl = googleMapsUrl(item);
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i.isEven ? PdfColors.grey50 : PdfColors.white,
          ),
          children: [
            _tableCell('${i + 1}'),
            _tableCell(DateFormatId.dateOnly(item.createdAt)),
            _tableCell(item.patientName ?? '-'),
            _tableCell(item.nik ?? '-'),
            _tableCell(item.address ?? '-'),
            _tableCell(item.label == 'indikasi' ? 'Indikasi' : 'Tidak Ada Indikasi'),
            _tableCell('${(item.confidence * 100).toStringAsFixed(1)}%'),
            _tableCellWidget(
              mapUrl == null
                  ? pw.Text('-', style: const pw.TextStyle(fontSize: 8))
                  : pw.UrlLink(
                      destination: mapUrl,
                      child: pw.Text(
                        'Lihat Lokasi',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.blue700,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
      columnWidths: const {
        0: pw.FixedColumnWidth(20),
        1: pw.FixedColumnWidth(58),
        2: pw.FixedColumnWidth(76),
        3: pw.FixedColumnWidth(70),
        4: pw.FlexColumnWidth(2),
        5: pw.FixedColumnWidth(72),
        6: pw.FixedColumnWidth(52),
        7: pw.FixedColumnWidth(58),
      },
      children: rows,
    );
  }

  static pw.Widget _buildFooter(
    pw.MemoryImage? logo, {
    required int pageNumber,
    required int pagesCount,
    required DateTime exportedAt,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Row(
        children: [
          _logoWidget(logo, size: 14),
          pw.SizedBox(width: 5),
          const pw.Text(
            'LepraCheck • Hasil skrining awal',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.Spacer(),
          pw.Text(
            'Halaman $pageNumber dari $pagesCount',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            'Dicetak ${DateFormatId.dateTimeWib(exportedAt)}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static pw.Widget _logoWidget(pw.MemoryImage? logo, {double size = 24}) {
    if (logo == null) {
      return pw.Container(
        width: size,
        height: size,
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
          borderRadius: pw.BorderRadius.circular(4),
        ),
      );
    }
    return pw.Image(logo, width: size, height: size, fit: pw.BoxFit.contain);
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return _tableCellWidget(
      pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8),
      ),
    );
  }

  static pw.Widget _tableCellWidget(pw.Widget child) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: child,
    );
  }
}

class _PdfSummary {
  final int total;
  final int indikasi;
  final int tidakIndikasi;
  final double avgPercent;
  final double maxPercent;
  final double minPercent;

  const _PdfSummary({
    required this.total,
    required this.indikasi,
    required this.tidakIndikasi,
    required this.avgPercent,
    required this.maxPercent,
    required this.minPercent,
  });

  factory _PdfSummary.fromEntries(List<HistoryEntry> items) {
    if (items.isEmpty) {
      return const _PdfSummary(
        total: 0,
        indikasi: 0,
        tidakIndikasi: 0,
        avgPercent: 0,
        maxPercent: 0,
        minPercent: 0,
      );
    }

    final confidences = items.map((entry) => entry.confidence * 100).toList();
    final total = items.length;
    final indikasi = items.where((entry) => entry.label == 'indikasi').length;

    return _PdfSummary(
      total: total,
      indikasi: indikasi,
      tidakIndikasi: total - indikasi,
      avgPercent: confidences.reduce((a, b) => a + b) / total,
      maxPercent: confidences.reduce((a, b) => a > b ? a : b),
      minPercent: confidences.reduce((a, b) => a < b ? a : b),
    );
  }
}
