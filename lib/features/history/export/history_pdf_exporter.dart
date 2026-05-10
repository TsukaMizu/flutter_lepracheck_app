import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/history_entry.dart';
import '../../../data/history_query.dart';
import '../../../utils/date_format_id.dart';

class HistoryPdfExporter {
  static Future<Uint8List> build({
    required List<HistoryEntry> items,
    required HistoryQuery query,
    required DateTime exportedAt,
  }) async {
    if (items.isEmpty) {
      throw ArgumentError('Data riwayat kosong, PDF tidak dapat dibuat.');
    }

    final logo = await _loadLogoOrNull();
    final stats = _buildStats(items);
    final periodLabel = _buildPeriodLabel(query, items);
    final exportLabel = DateFormatId.dateTimeWib(exportedAt);
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 40),
        build: (context) => [
          _buildHeader(logo: logo, exportLabel: exportLabel),
          pw.SizedBox(height: 12),
          _buildStatsSection(
            periodLabel: periodLabel,
            stats: stats,
          ),
          pw.SizedBox(height: 14),
          _buildTable(items),
        ],
        footer: (context) => _buildFooter(
          logo: logo,
          exportLabel: exportLabel,
          pageNumber: context.pageNumber,
          pagesCount: context.pagesCount,
        ),
      ),
    );

    return doc.save();
  }

  static Future<pw.MemoryImage?> _loadLogoOrNull() async {
    try {
      final data = await rootBundle.load('assets/images/logo.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  static _PdfStats _buildStats(List<HistoryEntry> items) {
    final total = items.length;
    final avg = items.fold<double>(0, (sum, e) => sum + e.confidence) / total;
    final highest = items
        .map((e) => e.confidence)
        .reduce((a, b) => a > b ? a : b);
    final lowest = items
        .map((e) => e.confidence)
        .reduce((a, b) => a < b ? a : b);
    final indikasi = items.where((e) => e.label == 'indikasi').length;
    return _PdfStats(
      total: total,
      averageConfidence: avg,
      highestConfidence: highest,
      lowestConfidence: lowest,
      indikasiCount: indikasi,
      tidakIndikasiCount: total - indikasi,
    );
  }

  static String _buildPeriodLabel(HistoryQuery query, List<HistoryEntry> items) {
    switch (query.dateMode) {
      case HistoryDateFilterMode.bulan:
        if (query.month != null) return DateFormatId.monthYear(query.month!);
        return 'Semua Tanggal';
      case HistoryDateFilterMode.rentang:
        if (query.range != null) {
          return '${DateFormatId.dateOnly(query.range!.start)} - ${DateFormatId.dateOnly(query.range!.end)}';
        }
        return 'Semua Tanggal';
      case HistoryDateFilterMode.semua:
        final sorted = [...items]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        final start = sorted.first.createdAt;
        final end = sorted.last.createdAt;
        if (start.year == end.year &&
            start.month == end.month &&
            start.day == end.day) {
          return DateFormatId.dateOnly(start);
        }
        return '${DateFormatId.dateOnly(start)} - ${DateFormatId.dateOnly(end)}';
    }
  }

  static pw.Widget _buildHeader({
    required pw.MemoryImage? logo,
    required String exportLabel,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null)
                pw.Container(
                  width: 34,
                  height: 34,
                  margin: const pw.EdgeInsets.only(right: 8),
                  child: pw.Image(logo, fit: pw.BoxFit.contain),
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LepraCheck',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.Text(
                    'Laporan Riwayat Skrining',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.blueGrey700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Center(
            child: pw.Text(
              'LAPORAN HASIL SKRINING',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.topRight,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.blue100),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Tanggal Export',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    exportLabel,
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildStatsSection({
    required String periodLabel,
    required _PdfStats stats,
  }) {
    pw.Widget card(String title, String value) {
      return pw.Container(
        width: 120,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey700),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      );
    }

    String percent(double value) => '${(value * 100).toStringAsFixed(1)}%';

    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        card('Periode Data', periodLabel),
        card('Total Data', '${stats.total}'),
        card('Rata-rata Confidence', percent(stats.averageConfidence)),
        card('Confidence Tertinggi', percent(stats.highestConfidence)),
        card('Confidence Terendah', percent(stats.lowestConfidence)),
        card('Jumlah Indikasi', '${stats.indikasiCount}'),
        card('Jumlah Tidak Indikasi', '${stats.tidakIndikasiCount}'),
      ],
    );
  }

  static pw.Widget _buildTable(List<HistoryEntry> items) {
    pw.Widget headerCell(String text) => pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        );

    pw.Widget bodyCell(String text) => pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
        );

    pw.Widget mapsCell(HistoryEntry e) {
      final lat = e.latitude;
      final lng = e.longitude;
      if (lat == null || lng == null) return bodyCell('-');
      final url = 'https://www.google.com/maps?q=$lat,$lng';
      return pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.UrlLink(
          destination: url,
          child: pw.Text(
            'Lihat Lokasi',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.blue800,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
      columnWidths: const {
        0: pw.FixedColumnWidth(20),
        1: pw.FlexColumnWidth(1.6),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.3),
        4: pw.FlexColumnWidth(2.2),
        5: pw.FlexColumnWidth(1.1),
        6: pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue700),
          children: [
            headerCell('No'),
            headerCell('Tanggal'),
            headerCell('Nama'),
            headerCell('NIK'),
            headerCell('Alamat'),
            headerCell('Confidence'),
            headerCell('Maps'),
          ],
        ),
        ...items.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final item = entry.value;
          return pw.TableRow(
            verticalAlignment: pw.TableCellVerticalAlignment.middle,
            decoration: pw.BoxDecoration(
              color: index.isEven ? PdfColors.grey100 : PdfColors.white,
            ),
            children: [
              bodyCell('$index'),
              bodyCell(DateFormatId.dateTimeWib(item.createdAt)),
              bodyCell(item.patientName ?? '-'),
              bodyCell(_maskNik(item.nik)),
              bodyCell(item.address ?? '-'),
              bodyCell('${(item.confidence * 100).toStringAsFixed(1)}%'),
              mapsCell(item),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildFooter({
    required pw.MemoryImage? logo,
    required String exportLabel,
    required int pageNumber,
    required int pagesCount,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Row(
              children: [
                if (logo != null)
                  pw.Container(
                    width: 14,
                    height: 14,
                    margin: const pw.EdgeInsets.only(right: 6),
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                pw.Text(
                  'LepraCheck • Skrining awal, bukan diagnosis medis.',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey700),
                ),
              ],
            ),
          ),
          pw.Text(
            'Halaman $pageNumber dari $pagesCount',
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.SizedBox(width: 10),
          pw.Text(
            'Dicetak pada $exportLabel',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  static String _maskNik(String? nik) {
    if (nik == null || nik.length < 4) return '-';
    final suffix = nik.substring(nik.length - 4);
    return '************$suffix';
  }
}

class _PdfStats {
  final int total;
  final double averageConfidence;
  final double highestConfidence;
  final double lowestConfidence;
  final int indikasiCount;
  final int tidakIndikasiCount;

  const _PdfStats({
    required this.total,
    required this.averageConfidence,
    required this.highestConfidence,
    required this.lowestConfidence,
    required this.indikasiCount,
    required this.tidakIndikasiCount,
  });
}
