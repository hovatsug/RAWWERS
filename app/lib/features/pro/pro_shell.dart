import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom tabs only - Dashboard/Requests/Gigs/Wallet, max 4, one navigation
/// system for the whole app. Settings is reached from the dashboard header,
/// not a 5th tab. Today is a section of the dashboard rather than a tab of its
/// own: on most days a photographer has nothing scheduled, and an app that
/// opens on "Nothing scheduled today." is telling them it has nothing for
/// them.
class ProShell extends StatelessWidget {
  const ProShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'You'),
          NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.camera_alt_outlined), selectedIcon: Icon(Icons.camera_alt), label: 'Gigs'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
        ],
      ),
    );
  }
}
