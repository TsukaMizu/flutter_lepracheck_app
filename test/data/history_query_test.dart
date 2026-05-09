import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lepracheck_app/data/history_entry.dart';
import 'package:flutter_lepracheck_app/data/history_query.dart';

void main() {
  HistoryEntry entry({
    required String id,
    required DateTime createdAt,
    required String label,
  }) {
    return HistoryEntry(
      id: id,
      createdAt: createdAt,
      imagePath: '/tmp/$id.jpg',
      label: label,
      confidence: 0.9,
    );
  }

  final items = <HistoryEntry>[
    entry(
      id: 'a',
      createdAt: DateTime(2026, 5, 1, 8, 0),
      label: 'indikasi',
    ),
    entry(
      id: 'b',
      createdAt: DateTime(2026, 5, 31, 23, 59),
      label: 'tidak_indikasi',
    ),
    entry(
      id: 'c',
      createdAt: DateTime(2026, 4, 10, 12, 0),
      label: 'indikasi',
    ),
  ];

  test('filter hasil indikasi bekerja', () {
    final result = filterHistoryEntries(
      items,
      const HistoryQuery(resultFilter: HistoryResultFilter.indikasi),
    );

    expect(result.map((e) => e.id), ['a', 'c']);
  });

  test('filter bulan+tahun hanya mengambil data di bulan tersebut', () {
    final result = filterHistoryEntries(
      items,
      const HistoryQuery(
        dateMode: HistoryDateFilterMode.bulan,
        month: DateTime(2026, 5),
      ),
    );

    expect(result.map((e) => e.id), ['a', 'b']);
  });

  test('filter rentang inklusif (start == end) tetap mengambil data hari itu', () {
    final result = filterHistoryEntries(
      items,
      const HistoryQuery(
        dateMode: HistoryDateFilterMode.rentang,
        range: DateTimeRangeValue(
          start: DateTime(2026, 5, 31),
          end: DateTime(2026, 5, 31),
        ),
      ),
    );

    expect(result.map((e) => e.id), ['b']);
  });
}
