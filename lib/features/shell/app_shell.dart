import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  // Sesuaikan label biar mirip desain: Beranda | Edukasi | (FAB Deteksi) | Riwayat | Profil(About)
  static const leftTabs = <_TabItem>[
    _TabItem('/home', 'Beranda', Icons.home_outlined),
    _TabItem('/education', 'Edukasi', Icons.school_outlined),
  ];

  static const rightTabs = <_TabItem>[
    _TabItem('/history', 'Riwayat', Icons.history_outlined),
    _TabItem('/about', 'Tentang', Icons.info_outline),
  ];

  static const fabTab = _TabItem('/detect', 'Deteksi', Icons.document_scanner_outlined);

  int _indexFromLocation(String location) {
    if (location.startsWith(leftTabs[0].location)) return 0;
    if (location.startsWith(leftTabs[1].location)) return 1;
    if (location.startsWith(fabTab.location)) return 2;
    if (location.startsWith(rightTabs[0].location)) return 3;
    if (location.startsWith(rightTabs[1].location)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);

    final cs = Theme.of(context).colorScheme;
    final selectedColor = cs.primary;
    final unselectedColor = cs.onSurfaceVariant;

    Widget navItem({
      required _TabItem tab,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab.icon, color: selected ? selectedColor : unselectedColor),
                const SizedBox(height: 4),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? selectedColor : unselectedColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(fabTab.location),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.document_scanner_outlined),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          children: [
            navItem(
              tab: leftTabs[0],
              selected: index == 0,
              onTap: () => context.go(leftTabs[0].location),
            ),
            navItem(
              tab: leftTabs[1],
              selected: index == 1,
              onTap: () => context.go(leftTabs[1].location),
            ),
            const SizedBox(width: 56), // ruang untuk FAB tengah
            navItem(
              tab: rightTabs[0],
              selected: index == 3,
              onTap: () => context.go(rightTabs[0].location),
            ),
            navItem(
              tab: rightTabs[1],
              selected: index == 4,
              onTap: () => context.go(rightTabs[1].location),
            ),
          ],
        ),
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