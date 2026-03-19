import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_prefs.dart';

class SplashGatePage extends StatefulWidget {
  const SplashGatePage({super.key});

  @override
  State<SplashGatePage> createState() => _SplashGatePageState();
}

class _SplashGatePageState extends State<SplashGatePage> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final done = await AppPrefs.isOnboardingDone();
    if (!mounted) return;

    context.go(done ? '/home' : '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}