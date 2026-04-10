import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_prefs.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _opacity = 0.0;
  double _scale = 0.7;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Brief pause before starting animation
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() {
      _opacity = 1.0;
      _scale = 1.0;
    });

    // Wait for animation to finish, then navigate
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final done = await AppPrefs.isOnboardingDone();
    if (!mounted) return;

    context.go(done ? '/home' : '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeIn,
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            child: Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if logo file is not yet added
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 96,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'LepraCheck',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
