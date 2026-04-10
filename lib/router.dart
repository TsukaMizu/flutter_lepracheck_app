import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/detect/custom_camera_page.dart';
import 'features/detect/generated_page.dart';
import 'features/detect/image_validation_page.dart';
import 'features/detect/result_page.dart';
import 'features/about/about_page.dart';
import 'features/education/education_page.dart';
import 'features/history/history_page.dart';
import 'features/home/home_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/shell/app_shell.dart';
import 'features/welcome/welcome_page.dart';
import 'features/splash/splash_page.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    // Halaman deteksi di luar ShellRoute agar kamera tampil penuh layar
    GoRoute(
      path: '/detect',
      builder: (context, state) => const CustomCameraPage(),
    ),
    GoRoute(
      path: '/detect/validate',
      builder: (context, state) {
        final imagePath = state.uri.queryParameters['path'] ?? '';
        return ImageValidationPage(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/detect/generated',
      builder: (context, state) {
        final imagePath = state.uri.queryParameters['path'] ?? '';
        return GeneratedPage(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/detect/result',
      builder: (context, state) {
        final imagePath = state.uri.queryParameters['path'] ?? '';
        final label = state.uri.queryParameters['label'] ?? 'tidak_indikasi';
        final confidence =
            double.tryParse(state.uri.queryParameters['conf'] ?? '') ?? 0.0;
        return ResultPage(
          imagePath: imagePath,
          label: label,
          confidence: confidence,
        );
      },
    ),
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/education',
          builder: (context, state) => const EducationPage(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryPage(),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutPage(),
        ),
      ],
    ),
  ],
);
