import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_prefs.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;
  int _index = 0;

  final _slides = const <_OnboardingSlide>[
    _OnboardingSlide(
      title: 'Peringatan',
      body: 'Aplikasi ini hanya untuk screening awal, bukan diagnosis dokter.',
      icon: Icons.warning_amber_rounded,
    ),
    _OnboardingSlide(
      title: 'Privasi',
      body: 'Gunakan foto yang jelas. Hindari menyertakan wajah/identitas.',
      icon: Icons.privacy_tip_outlined,
    ),
    _OnboardingSlide(
      title: 'Tindak Lanjut',
      body: 'Jika ada indikasi, segera periksa ke fasilitas kesehatan.',
      icon: Icons.local_hospital_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goHome() async {
  await AppPrefs.setOnboardingDone(true);
  if (!mounted) return;
  context.go('/home');
}

void _next() {
  if (_index < _slides.length - 1) {
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  } else {
    _goHome();
  }
}

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
        actions: [
          TextButton(
            onPressed: _goHome,
            child: const Text('Lewati'),
          ),
        ],
      ),

      // Body: hanya PageView (biar tidak bentrok constraint Row tombol bawah)
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: _slides.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            final s = _slides[i];

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Icon(s.icon, size: 44, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    s.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s.body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (dot) {
                      final active = dot == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? cs.primary : cs.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      // Bottom bar: tombol dibungkus Expanded agar tidak kena constraint w=Infinity dari FilledButtonTheme
bottomNavigationBar: SafeArea(
  top: false,
  child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (_index + 1) / _slides.length,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _next,
            child: Text(_index == _slides.length - 1 ? 'Masuk' : 'Lanjut'),
          ),
        ),
      ],
    ),
  ),
),
      
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String body;
  final IconData icon;

  const _OnboardingSlide({
    required this.title,
    required this.body,
    required this.icon,
  });
}