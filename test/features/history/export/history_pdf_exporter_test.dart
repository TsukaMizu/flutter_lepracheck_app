import 'package:flutter_lepracheck_app/data/history_entry.dart';
import 'package:flutter_lepracheck_app/data/history_query.dart';
import 'package:flutter_lepracheck_app/features/history/export/history_pdf_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('build melempar ArgumentError saat data kosong', () async {
    expect(
      () => HistoryPdfExporter.build(
        items: const [],
        query: const HistoryQuery(),
        exportedAt: DateTime(2026, 5, 10, 10, 30),
      ),
      throwsArgumentError,
    );
  });

  test('build menghasilkan bytes PDF untuk data valid', () async {
    final bytes = await HistoryPdfExporter.build(
      items: [
        HistoryEntry(
          id: '1',
          createdAt: DateTime(2026, 5, 1, 8, 0),
          imagePath: '/tmp/image.jpg',
          label: 'indikasi',
          confidence: 0.82,
          nik: '1234567890123456',
          patientName: 'Budi',
          address: 'Jakarta',
          latitude: -6.2,
          longitude: 106.816666,
        ),
      ],
      query: const HistoryQuery(),
      exportedAt: DateTime(2026, 5, 10, 10, 30),
    );

    expect(bytes, isNotEmpty);
  });
}
