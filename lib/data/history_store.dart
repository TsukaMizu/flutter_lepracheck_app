import 'package:hive/hive.dart';
import 'history_entry.dart';

class HistoryStore {
  static const boxName = 'history_box';

  static Future<Box> _box() async => Hive.openBox(boxName);

  static Future<void> add(HistoryEntry entry) async {
    final box = await _box();
    await box.put(entry.id, entry.toMap());
  }

  static Future<List<HistoryEntry>> getAll() async {
    final box = await _box();
    final items = box.values
        .whereType<Map>()
        .map(HistoryEntry.fromMap)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<HistoryEntry?> getLatest() async {
    final all = await getAll();
    return all.isEmpty ? null : all.first;
  }

  // tambahkan di dalam class HistoryStore

static Future<void> removeById(String id) async {
  final box = await _box();
  await box.delete(id);
}

static Future<void> clear() async {
  final box = await _box();
  await box.clear();
}
}