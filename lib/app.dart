import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class LepraCheckApp extends StatelessWidget {
  const LepraCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LepraCheck',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      routerConfig: router,
    );
  }
}