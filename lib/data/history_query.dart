import 'history_entry.dart';

enum HistoryResultFilter { semua, indikasi, tidakIndikasi }

enum HistoryDateFilterMode { semua, bulan, rentang }

class HistoryQuery {
  final HistoryResultFilter resultFilter;
  final HistoryDateFilterMode dateMode;
  final DateTime? month;
  final DateTimeRangeValue? range;

  const HistoryQuery({
    this.resultFilter = HistoryResultFilter.semua,
    this.dateMode = HistoryDateFilterMode.semua,
    this.month,
    this.range,
  });

  HistoryQuery copyWith({
    HistoryResultFilter? resultFilter,
    HistoryDateFilterMode? dateMode,
    DateTime? month,
    DateTimeRangeValue? range,
  }) {
    return HistoryQuery(
      resultFilter: resultFilter ?? this.resultFilter,
      dateMode: dateMode ?? this.dateMode,
      month: month ?? this.month,
      range: range ?? this.range,
    );
  }
}

class DateTimeRangeValue {
  final DateTime start;
  final DateTime end;

  const DateTimeRangeValue({
    required this.start,
    required this.end,
  });
}

List<HistoryEntry> filterHistoryEntries(List<HistoryEntry> items, HistoryQuery query) {
  return items.where((entry) {
    final resultOk = switch (query.resultFilter) {
      HistoryResultFilter.semua => true,
      HistoryResultFilter.indikasi => entry.label == 'indikasi',
      HistoryResultFilter.tidakIndikasi => entry.label == 'tidak_indikasi',
    };
    if (!resultOk) return false;

    switch (query.dateMode) {
      case HistoryDateFilterMode.semua:
        return true;
      case HistoryDateFilterMode.bulan:
        if (query.month == null) return true;
        return entry.createdAt.year == query.month!.year &&
            entry.createdAt.month == query.month!.month;
      case HistoryDateFilterMode.rentang:
        if (query.range == null) return true;
        final start = DateTime(
          query.range!.start.year,
          query.range!.start.month,
          query.range!.start.day,
        );
        final end = DateTime(
          query.range!.end.year,
          query.range!.end.month,
          query.range!.end.day,
          23,
          59,
          59,
          999,
        );
        return !entry.createdAt.isBefore(start) && !entry.createdAt.isAfter(end);
    }
  }).toList();
}
