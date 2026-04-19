import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/detect/custom_camera_page.dart';
import 'features/detect/generated_page.dart';
import 'features/detect/image_validation_page.dart';
import 'features/detect/patient_form_page.dart';
import 'features/detect/result_page.dart';
import 'features/about/about_page.dart';
import 'features/education/education_page.dart';
import 'features/history/history_page.dart';
import 'features/home/home_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/shell/app_shell.dart';
import 'features/welcome/welcome_page.dart';
import 'features/splash/splash_page.dart';

// Kunci navigator root (digunakan untuk navigasi di luar ShellRoute).
final _rootKey = GlobalKey<NavigatorState>();
// Kunci navigator shell (digunakan oleh bottom navigation bar).
final _shellKey = GlobalKey<NavigatorState>();

/// Konfigurasi routing utama aplikasi menggunakan go_router.
///
/// Struktur rute:
///   /splash      → SplashPage   (animasi logo + cek status onboarding)
///   /welcome     → WelcomePage  (layar selamat datang pertama kali)
///   /onboarding  → OnboardingPage (penjelasan fitur untuk pengguna baru)
///
///   Alur deteksi (di luar ShellRoute agar tampil penuh layar tanpa bottom nav):
///   /detect           → CustomCameraPage  (ambil foto kamera / galeri)
///   /detect/validate  → ImageValidationPage (pratinjau & validasi kualitas foto)
///   /detect/generated → GeneratedPage (proses inferensi ML + loading screen)
///   /detect/result    → ResultPage (tampilkan hasil Indikasi / Tidak Ada Indikasi)
///   /detect/form      → PatientFormPage (form data pasien + GPS sebelum simpan)
///
///   Tab utama (di dalam ShellRoute, memiliki bottom navigation bar):
///   /home       → HomePage
///   /education  → EducationPage
///   /history    → HistoryPage
///   /about      → AboutPage
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
    // tanpa gangguan bottom navigation bar.
    GoRoute(
      path: '/detect',
      builder: (context, state) => const CustomCameraPage(),
    ),
    GoRoute(
      path: '/detect/validate',
      builder: (context, state) {
        // Path gambar dikirim melalui query parameter setelah foto diambil.
        final imagePath = state.uri.queryParameters['path'] ?? '';
        return ImageValidationPage(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/detect/generated',
      builder: (context, state) {
        // Path gambar diteruskan ke GeneratedPage untuk diproses oleh model ML.
        final imagePath = state.uri.queryParameters['path'] ?? '';
        return GeneratedPage(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/detect/result',
      builder: (context, state) {
        // Label ('indikasi'/'tidak_indikasi') dan nilai confidence
        // dikirim sebagai query parameter dari GeneratedPage.
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
    GoRoute(
      path: '/detect/form',
      builder: (context, state) {
        // Data hasil deteksi diteruskan ke PatientFormPage untuk dilengkapi
        // dengan data pasien (NIK, Nama, Alamat, dan koordinat GPS).
        final imagePath = state.uri.queryParameters['path'] ?? '';
        final label = state.uri.queryParameters['label'] ?? 'tidak_indikasi';
        final confidence =
            double.tryParse(state.uri.queryParameters['conf'] ?? '') ?? 0.0;
        return PatientFormPage(
          imagePath: imagePath,
          label: label,
          confidence: confidence,
        );
      },
    ),
    // ShellRoute membungkus halaman-halaman tab utama dengan AppShell
    // yang menyediakan bottom navigation bar.
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
