import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const tabs = <_TabItem>[
    _TabItem('/home', 'Beranda', Icons.home_outlined),
    _TabItem('/education', 'Edukasi', Icons.menu_book_outlined),
    _TabItem('/detect', 'Deteksi', Icons.document_scanner_outlined),
    _TabItem('/history', 'Riwayat', Icons.history),
    _TabItem('/about', 'Tentang', Icons.info_outline),
  ];

  int _indexFromLocation(String location) {
    final idx = tabs.indexWhere((t) => location.startsWith(t.location));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(tabs[i].location),
        destinations: [
          for (final t in tabs) NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}

class _TabItem {
  final String location;
  final String label;
  final IconData icon;
  const _TabItem(this.location, this.label, this.icon);
}