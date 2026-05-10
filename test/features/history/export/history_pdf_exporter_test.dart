import 'package:flutter_lepracheck_app/data/history_entry.dart';
import 'package:flutter_lepracheck_app/data/history_query.dart';
import 'package:flutter_lepracheck_app/features/history/export/history_pdf_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  HistoryEntry entry({
    required String id,
    required DateTime createdAt,
    double? latitude,
    double? longitude,
  }) {
    return HistoryEntry(
      id: id,
      createdAt: createdAt,
      imagePath: '/tmp/$id.jpg',
      label: 'indikasi',
      confidence: 0.91,
      latitude: latitude,
      longitude: longitude,
    );
  }

  group('HistoryPdfExporter', () {
    test('periodLabel untuk mode bulan menggunakan awal-akhir bulan', () {
      final result = HistoryPdfExporter.periodLabel(
        const HistoryQuery(
          dateMode: HistoryDateFilterMode.bulan,
          month: DateTime(2026, 5),
        ),
        const [],
      );

      expect(result, '01 Mei 2026 - 31 Mei 2026');
    });

    test('periodLabel mode semua menggunakan rentang data aktual', () {
      final items = [
        entry(id: 'a', createdAt: DateTime(2026, 5, 11)),
        entry(id: 'b', createdAt: DateTime(2026, 4, 2)),
      ];

      final result = HistoryPdfExporter.periodLabel(
        const HistoryQuery(),
        items,
      );

      expect(result, '02 Apr 2026 - 11 Mei 2026');
    });

    test('googleMapsUrl menghasilkan link maps jika ada koordinat', () {
      final result = HistoryPdfExporter.googleMapsUrl(
        entry(
          id: 'x',
          createdAt: DateTime(2026, 5, 11),
          latitude: -6.2,
          longitude: 106.8,
        ),
      );

      expect(result, 'https://www.google.com/maps?q=-6.2,106.8');
    });

    test('googleMapsUrl null jika koordinat tidak lengkap', () {
      final result = HistoryPdfExporter.googleMapsUrl(
        entry(id: 'x', createdAt: DateTime(2026, 5, 11), latitude: -6.2),
      );

      expect(result, isNull);
    });
  });
}
