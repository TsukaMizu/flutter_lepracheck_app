import 'package:flutter/material.dart';
import 'router.dart';

class LepraCheckApp extends StatelessWidget {
  const LepraCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cek Kusta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1F6FEB),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      routerConfig: router,
    );
  }
}