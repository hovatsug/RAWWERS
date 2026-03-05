import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/session.dart';
import '../design/tokens.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location, required this.session});

  final Widget child;
  final String location;
  final SessionState session;

  @override
  Widget build(BuildContext context) {
    final items = <({String path, String label, IconData icon})>[
      (path: '/discover', label: 'Discover', icon: Icons.explore_outlined),
      (path: '/notifications', label: 'Alerts', icon: Icons.notifications_none),
      if (session.isPro) (path: '/pro/onboarding', label: 'Onboarding', icon: Icons.checklist_rtl),
    ];

    final selected = items.indexWhere((item) => location.startsWith(item.path));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RTokens.spacingX4),
          child: child,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected < 0 ? 0 : selected,
        onDestinationSelected: (index) => context.go(items[index].path),
        destinations: [
          for (final item in items)
            NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}
