import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/history_entry.dart';
import '../../data/history_store.dart';

/// Halaman detail riwayat skrining yang menampilkan informasi lengkap
/// termasuk data pasien (NIK, Nama, Alamat) dan lokasi (Geotagging).
///
/// Halaman ini bersifat *read-only* dan hanya membaca data dari [HistoryStore].
class HistoryDetailPage extends StatefulWidget {
  final String id;

  const HistoryDetailPage({super.key, required this.id});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  HistoryEntry? _entry;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    try {
      final entry = await HistoryStore.getById(widget.id);
      if (mounted) {
        setState(() {
          _entry = entry;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String id) async {
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
      try {
        await HistoryStore.removeById(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Riwayat berhasil dihapus.')),
          );
          context.pop();
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus riwayat. Silakan coba lagi.'),
            ),
          );
        }
      }
    }
  }

  Future<void> _openMap(HistoryEntry entry) async {
    final lat = entry.latitude;
    final lng = entry.longitude;
    if (lat == null || lng == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
        );
      }
    }
  }

  static String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $h:$m WIB';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Riwayat')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error || _entry == null) {
      final message = _error
          ? 'Terjadi kesalahan saat memuat data riwayat.'
          : 'Riwayat skrining ini mungkin telah dihapus atau tidak tersedia.';
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Riwayat')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Data tidak ditemukan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go('/history'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali ke Riwayat'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final entry = _entry!;
    final cs = Theme.of(context).colorScheme;
    final isIndication = entry.label == 'indikasi';
    final displayLabel = isIndication ? 'Indikasi' : 'Tidak Ada Indikasi';

    final resultBg =
        isIndication ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);
    final resultColor =
        isIndication ? const Color(0xFFF57C00) : const Color(0xFF2E7D32);
    final resultIcon =
        isIndication ? Icons.warning_amber_rounded : Icons.check_circle_rounded;

    final hasNik = entry.nik != null && entry.nik!.isNotEmpty;
    final hasPatientName =
        entry.patientName != null && entry.patientName!.isNotEmpty;
    final hasAddress = entry.address != null && entry.address!.isNotEmpty;
    final hasPatientData = hasNik || hasPatientName || hasAddress;
    final hasCoords = entry.latitude != null && entry.longitude != null;

    final confidencePct = (entry.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Riwayat'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus Riwayat',
            onPressed: () =>
                _showDeleteConfirmationDialog(context, entry.id),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gambar kulit yang diperiksa
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: File(entry.imagePath).existsSync()
                    ? Image.file(
                        File(entry.imagePath),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 220,
                        color: cs.surfaceContainerHighest,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_outlined,
                                size: 48, color: cs.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text(
                              'Gambar tidak tersedia',
                              style:
                                  TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Kartu hasil deteksi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: resultBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(resultIcon, color: resultColor, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayLabel,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: resultColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Confidence: $confidencePct%',
                            style: TextStyle(
                              fontSize: 13,
                              color: resultColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tanggal pemeriksaan
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    _formatDateTime(entry.createdAt),
                    style:
                        TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                ],
              ),

              // Kartu data pasien (hanya tampil jika ada data)
              if (hasPatientData) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_pin_outlined,
                              size: 18, color: cs.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Data Pasien',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (hasPatientName) ...[
                        _DataRow(
                          icon: Icons.person_outline,
                          label: 'Nama Pasien',
                          value: entry.patientName!,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (hasNik) ...[
                        _DataRow(
                          icon: Icons.badge_outlined,
                          label: 'NIK',
                          value: entry.nik!,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (hasAddress)
                        _DataRow(
                          icon: Icons.home_outlined,
                          label: 'Alamat Rumah',
                          value: entry.address!,
                        ),
                    ],
                  ),
                ),
              ],

              // Tombol buka lokasi di peta (hanya tampil jika ada koordinat)
              if (hasCoords) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _openMap(entry),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Buka Lokasi di Peta'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: cs.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widget: satu baris data pasien
// ---------------------------------------------------------------------------

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
