import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:go_router/go_router.dart';

import '../../data/history_entry.dart';
import '../../data/history_store.dart';

/// Halaman form pengisian data pasien setelah hasil skrining ditampilkan.
///
/// Menerima data hasil deteksi ([imagePath], [label], [confidence]) dari
/// [ResultPage], kemudian menggabungkannya dengan data yang diisi pengguna
/// (NIK, Nama, Alamat, dan koordinat GPS) lalu menyimpannya sebagai
/// [HistoryEntry] ke penyimpanan lokal.
class PatientFormPage extends StatefulWidget {
  final String imagePath;
  final String label;
  final double confidence;

  const PatientFormPage({
    super.key,
    required this.imagePath,
    required this.label,
    required this.confidence,
  });

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  // Koordinat GPS yang berhasil diambil (bisa null jika belum/gagal)
  double? _latitude;
  double? _longitude;

  bool _fetchingLocation = false;
  bool _saving = false;

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Mengambil lokasi GPS saat ini dengan timeout 10 detik.
  ///
  /// Fail-gracefully: jika permission ditolak atau timeout habis,
  /// akan muncul SnackBar informatif tanpa membuat aplikasi freeze.
  Future<void> _fetchLocation() async {
    setState(() => _fetchingLocation = true);

    try {
      final loc = Location();

      // Cek apakah layanan lokasi aktif di perangkat
      bool serviceEnabled = await loc.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await loc.requestService();
        if (!serviceEnabled) {
          _showLocationError('Layanan GPS tidak aktif. Aktifkan GPS di pengaturan perangkat.');
          return;
        }
      }

      // Cek dan minta permission lokasi
      PermissionStatus permission = await loc.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await loc.requestPermission();
        if (permission != PermissionStatus.granted) {
          _showLocationError('Izin lokasi ditolak. Lokasi tidak bisa diambil secara otomatis.');
          return;
        }
      }

      if (permission == PermissionStatus.deniedForever) {
        _showLocationError(
          'Izin lokasi ditolak permanen. Buka Pengaturan > Izin Aplikasi untuk mengaktifkannya.',
        );
        return;
      }

      // Ambil posisi dengan timeout 10 detik agar tidak freeze saat demo
      final locData = await loc.getLocation().timeout(const Duration(seconds: 10));

      if (mounted) {
        if (locData.latitude != null && locData.longitude != null) {
          setState(() {
            _latitude = locData.latitude;
            _longitude = locData.longitude;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lokasi berhasil diambil: ${locData.latitude!.toStringAsFixed(5)}, ${locData.longitude!.toStringAsFixed(5)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _showLocationError('Gagal mendapat lokasi otomatis. Silakan isi alamat manual.');
        }
      }
    } on TimeoutException {
      _showLocationError('Gagal mendapat lokasi otomatis. Silakan isi alamat manual.');
    } catch (e) {
      _showLocationError('Gagal mendapat lokasi otomatis. Silakan isi alamat manual.');
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  void _showLocationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Menyimpan data laporan (gabungan hasil ML + data pasien) ke riwayat lokal,
  /// kemudian navigasi kembali ke Beranda.
  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final entry = HistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        imagePath: widget.imagePath,
        label: widget.label,
        confidence: widget.confidence,
        nik: _nikController.text.trim().isEmpty ? null : _nikController.text.trim(),
        patientName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
      );

      await HistoryStore.add(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil disimpan.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan laporan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isIndication = widget.label == 'indikasi';

    return Scaffold(
      appBar: AppBar(title: const Text('Form Data Laporan')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ringkasan hasil deteksi
                Card(
                  elevation: 0,
                  color: isIndication
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFE8F5E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          isIndication
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_rounded,
                          color: isIndication
                              ? const Color(0xFFF57C00)
                              : const Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hasil Skrining: ${isIndication ? "Indikasi" : "Tidak Ada Indikasi"}'
                            ' (${(widget.confidence * 100).toStringAsFixed(0)}%)',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isIndication
                                  ? const Color(0xFFE65100)
                                  : const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Lengkapi Data Pasien',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Data ini bersifat opsional, namun sangat membantu untuk keperluan pelaporan.',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                // Field NIK
                TextFormField(
                  controller: _nikController,
                  decoration: const InputDecoration(
                    labelText: 'NIK (Nomor Induk Kependudukan)',
                    hintText: 'Contoh: 3273010101010001',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                  ],
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length != 16) {
                      return 'NIK harus terdiri dari 16 digit';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Field Nama Lengkap
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap Pasien',
                    hintText: 'Contoh: Budi Santoso',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 12),

                // Field Alamat
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Rumah',
                    hintText: 'Contoh: Jl. Merdeka No. 1, Kel. Sukamaju, Kec. Cibeunying',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home_outlined),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 16),

                // Seksi Lokasi GPS
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: cs.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Titik Lokasi (GPS)',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_latitude != null && _longitude != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Lat: ${_latitude!.toStringAsFixed(6)}\nLng: ${_longitude!.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Koordinat belum diambil.',
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _fetchingLocation ? null : _fetchLocation,
                            icon: _fetchingLocation
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location),
                            label: Text(
                              _fetchingLocation
                                  ? 'Mengambil lokasi...'
                                  : (_latitude != null
                                      ? 'Perbarui Lokasi'
                                      : 'Ambil Lokasi Saat Ini'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tombol Simpan
                FilledButton.icon(
                  onPressed: _saving ? null : _saveReport,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Menyimpan...' : 'Simpan Laporan'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),

                const SizedBox(height: 10),

                // Tombol Lewati (tanpa menyimpan)
                TextButton(
                  onPressed: _saving ? null : () => context.go('/home'),
                  child: const Text('Lewati, Kembali ke Beranda'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
