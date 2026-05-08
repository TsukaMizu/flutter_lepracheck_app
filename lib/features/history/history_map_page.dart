import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../data/history_entry.dart';
import '../../data/history_query.dart';
import '../../data/history_store.dart';
import '../../utils/date_format_id.dart';

class HistoryMapPage extends StatefulWidget {
  const HistoryMapPage({super.key});

  @override
  State<HistoryMapPage> createState() => _HistoryMapPageState();
}

class _HistoryMapPageState extends State<HistoryMapPage> {
  List<HistoryEntry> _allItems = [];
  HistoryQuery _query = const HistoryQuery();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await HistoryStore.getAll();
    if (!mounted) return;
    setState(() {
      _allItems = items;
      _loading = false;
    });
  }

  List<HistoryEntry> get _filteredWithCoords {
    return filterHistoryEntries(_allItems, _query)
        .where((e) => e.latitude != null && e.longitude != null)
        .toList();
  }

  void _showMarkerSummary(HistoryEntry entry) {
    final isIndikasi = entry.label == 'indikasi';
    final hasil = isIndikasi ? 'Indikasi' : 'Tidak Ada Indikasi';
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasil,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text('Tanggal: ${DateFormatId.dateTimeWib(entry.createdAt)}'),
              Text('Nama: ${entry.patientName?.isNotEmpty == true ? entry.patientName : '-'}'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  context.pop();
                  context.push('/history/detail/${entry.id}');
                },
                child: const Text('Buka Detail'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        appBar: AppBar(title: Text('Peta Riwayat Skrining')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final entries = _filteredWithCoords;
    final initialCenter = entries.isNotEmpty
        ? LatLng(entries.first.latitude!, entries.first.longitude!)
        : const LatLng(-2.5489, 118.0149);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Riwayat Skrining'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  selected: _query.resultFilter == HistoryResultFilter.semua,
                  label: const Text('Semua'),
                  onSelected: (_) => setState(() {
                    _query = _query.copyWith(resultFilter: HistoryResultFilter.semua);
                  }),
                ),
                ChoiceChip(
                  selected: _query.resultFilter == HistoryResultFilter.indikasi,
                  label: const Text('Indikasi'),
                  onSelected: (_) => setState(() {
                    _query = _query.copyWith(resultFilter: HistoryResultFilter.indikasi);
                  }),
                ),
                ChoiceChip(
                  selected: _query.resultFilter == HistoryResultFilter.tidakIndikasi,
                  label: const Text('Tidak Ada Indikasi'),
                  onSelected: (_) => setState(() {
                    _query = _query.copyWith(resultFilter: HistoryResultFilter.tidakIndikasi);
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Belum ada data lokasi untuk ditampilkan di peta.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: initialCenter,
                      initialZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'flutter_lepracheck_app',
                      ),
                      MarkerLayer(
                        markers: entries
                            .map(
                              (entry) => Marker(
                                width: 40,
                                height: 40,
                                point: LatLng(entry.latitude!, entry.longitude!),
                                child: GestureDetector(
                                  onTap: () => _showMarkerSummary(entry),
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 34,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
