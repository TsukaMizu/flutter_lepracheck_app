import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/history_store.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _formatDate(DateTime dt) {
    // Simple format biar mirip desain (tanpa intl dulu)
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final day = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    return '$day, ${dt.day} $month ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: HistoryStore.getLatest(),
          builder: (context, snapshot) {
            final latest = snapshot.data;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              children: [
                // Header: avatar + LepraCheck + bell
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: cs.primaryContainer,
                      child: Icon(Icons.person_outline, color: cs.onPrimaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'LepraCheck',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  'Selamat Datang Di Aplikasi LepraCheck',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(DateTime.now()),
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 18),

                // Card biru "Mulai Skrining"
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E6FB8), Color(0xFF1F6FEB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.center_focus_strong, color: Colors.white),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'AI Powered',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'MULAI SKRINING',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Periksa kulitmu sekarang dengan teknologi AI kami.',
                          style: TextStyle(color: Colors.white, height: 1.25),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: cs.primary,
                            ),
                            onPressed: () => context.go('/detect'),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Mulai Sekarang'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Skrining terakhir header
                Row(
                  children: [
                    const Text('Skrining Terakhir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/history'),
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Skrining terakhir card
                if (snapshot.connectionState != ConnectionState.done)
                  const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                else if (latest == null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Belum ada riwayat skrining.',
                        style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                else
                  Card(
                    child: ListTile(
                      onTap: () => context.go(
                        '/detect/result?path=${Uri.encodeComponent(latest.imagePath)}&label=${latest.label}&conf=${latest.confidence}',
                      ),
                      leading: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFFAF2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
                      ),
                      title: Text(
                        'Laporan Skrining',
                        style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface),
                      ),
                      subtitle: Text(
                        latest.label == 'indikasi' ? 'Risiko TINGGI' : 'Risiko RENDAH',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: latest.label == 'indikasi' ? cs.error : const Color(0xFF16A34A),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),

                const SizedBox(height: 22),

                const Text('Fitur Lainnya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _FeatureTile(
                        icon: Icons.school_outlined,
                        label: 'Belajar',
                        onTap: () => context.go('/education'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FeatureTile(
                        icon: Icons.local_hospital_outlined,
                        label: 'Klinik',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur Klinik belum tersedia (MVP).')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FeatureTile(
                        icon: Icons.menu_book_outlined,
                        label: 'Riwayat',
                        onTap: () => context.go('/history'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FeatureTile(
                        icon: Icons.info_outline,
                        label: 'Tentang',
                        onTap: () => context.go('/about'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Tahukah Kamu card + gambar internet
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD6E3FF)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: cs.primary),
                            const SizedBox(width: 8),
                            Text(
                              'TAHUKAH KAMU?',
                              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Kusta dapat disembuhkan sepenuhnya jika dideteksi sejak dini. '
                          'Obat-obatan tersedia gratis di Puskesmas terdekat.',
                          style: TextStyle(color: cs.onSurface, height: 1.35, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            // placeholder; bisa kamu ganti kapan saja
                            'https://images.unsplash.com/photo-1580281657527-47f249e8f1df?auto=format&fit=crop&w=1200&q=60',
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}