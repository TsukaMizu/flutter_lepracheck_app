import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
  int index = 0;

  final slides = const [
    ('Peringatan', 'Aplikasi ini hanya untuk screening awal, bukan diagnosis dokter.'),
    ('Privasi', 'Gunakan foto yang jelas. Hindari menyertakan wajah/identitas.'),
    ('Tindak Lanjut', 'Jika ada indikasi, segera periksa ke fasilitas kesehatan.'),
  ];

  void _next() {
    if (index < slides.length - 1) {
      controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
        actions: [
          TextButton(onPressed: () => context.go('/home'), child: const Text('Lewati')),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => index = i),
              itemBuilder: (context, i) {
                final (title, body) = slides[i];
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 80, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Text(body, textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (index + 1) / slides.length,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _next,
                  child: Text(index == slides.length - 1 ? 'Masuk' : 'Lanjut'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}