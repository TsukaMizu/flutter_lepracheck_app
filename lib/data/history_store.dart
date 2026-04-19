import 'package:hive/hive.dart';
import 'history_entry.dart';

/// Menyimpan dan mengambil riwayat skrining menggunakan Hive (local storage).
class HistoryStore {
  static const boxName = 'history_box';

  static Future<Box> _box() async => Hive.openBox(boxName);

  /// Menambahkan entri riwayat baru ke penyimpanan lokal.
  static Future<void> add(HistoryEntry entry) async {
    final box = await _box();
    await box.put(entry.id, entry.toMap());
  }

  /// Mengambil semua entri riwayat, diurutkan dari yang terbaru.
  static Future<List<HistoryEntry>> getAll() async {
    final box = await _box();
    final items = box.values
        .whereType<Map>()
        .map(HistoryEntry.fromMap)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  /// Mengambil satu entri riwayat terbaru. Mengembalikan null jika belum ada riwayat.
  static Future<HistoryEntry?> getLatest() async {
    final all = await getAll();
    return all.isEmpty ? null : all.first;
  }

  /// Mengambil satu entri riwayat berdasarkan [id]. Mengembalikan null jika tidak ditemukan.
  static Future<HistoryEntry?> getById(String id) async {
    final box = await _box();
    final raw = box.get(id);
    if (raw == null || raw is! Map<dynamic, dynamic>) return null;
    return HistoryEntry.fromMap(raw);
  }

  /// Menghapus satu entri berdasarkan [id].
  static Future<void> removeById(String id) async {
    final box = await _box();
    await box.delete(id);
  }

  /// Menghapus seluruh riwayat skrining.
  static Future<void> clear() async {
    final box = await _box();
    await box.clear();
  }
}