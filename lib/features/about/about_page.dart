import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const appVersionText = 'v1.0.2 (Build 2405)';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          _HeroCard(cs: cs),
          const SizedBox(height: 18),

          const Text(
            'Tentang LepraCheck',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'LepraCheck adalah alat skrining dini penyakit kusta menggunakan teknologi kecerdasan buatan (AI). '
            'Aplikasi ini dirancang untuk membantu identifikasi awal lesi kulit yang mencurigakan secara mandiri '
            'dan cepat.',
            style: TextStyle(
              height: 1.55,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),
          _WarningBox(cs: cs),
          const SizedBox(height: 18),

          const Text(
            'Teknologi AI',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _AiTechCard(cs: cs),

          const SizedBox(height: 18),

          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                Text(
                  'VERSI APLIKASI',
                  style: TextStyle(
                    letterSpacing: 2,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurfaceVariant.withOpacity(0.70),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  appVersionText,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final ColorScheme cs;
  const _HeroCard({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E6FB8), Color(0xFF2C86D3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // highlight circle kanan (dekor)
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Konten di-center-kan (horizontal & vertical)
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon container
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title center
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'LepraCheck AI',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  final ColorScheme cs;
  const _WarningBox({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE2B8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFB45309)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  height: 1.45,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C2D12),
                ),
                children: [
                  TextSpan(
                    text: 'PENTING: ',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text:
                        'Hasil dari aplikasi ini bersifat skrining awal dan bukan merupakan diagnosis medis final. '
                        'Segera konsultasikan dengan tenaga kesehatan profesional.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiTechCard extends StatelessWidget {
  final ColorScheme cs;
  const _AiTechCard({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.settings_suggest_outlined, color: cs.primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Arsitektur Model',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Menggunakan ',
              style: TextStyle(
                height: 1.55,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
                  ),
                  child: Text(
                    'MobileNetV3-Large',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  ' dengan teknik ',
                  style: TextStyle(
                    height: 1.55,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Transfer Learning',
                  style: TextStyle(
                    height: 1.55,
                    color: cs.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  ' yang dioptimalkan.',
                  style: TextStyle(
                    height: 1.55,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(
                  child: _MetricChip(
                    label: 'AKURASI',
                    value: '92.5%',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MetricChip(
                    label: 'RECALL',
                    value: '89.2%',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MetricChip(
                    label: 'F1-SCORE',
                    value: '90.8%',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14, color: cs.onSurfaceVariant.withOpacity(0.75)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Metrik performa model dihitung berdasarkan dataset uji klinis terbaru.',
                    style: TextStyle(
                      height: 1.35,
                      fontSize: 12,
                      color: cs.onSurfaceVariant.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}