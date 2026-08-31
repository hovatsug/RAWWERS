import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/config.dart';
import '../data/models/session.dart';
import '../design/tokens.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location, required this.session});

  final Widget child;
  final String location;
  final SessionState session;

  @override
  Widget build(BuildContext context) {
    final items = session.isPro
        ? <({String path, String label, IconData icon})>[
            (path: '/pro/dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined),
            (path: '/pro/leads', label: 'Leads', icon: Icons.inbox_outlined),
            (path: '/pro/gigs', label: 'Gigs', icon: Icons.camera_alt_outlined),
            (path: '/pro/calendar', label: 'Calendar', icon: Icons.calendar_month_outlined),
            (path: '/pro/wallet', label: 'Wallet', icon: Icons.account_balance_wallet_outlined),
          ]
        : <({String path, String label, IconData icon})>[
            (path: '/home', label: 'Home', icon: Icons.home_outlined),
            (path: '/search', label: 'Search', icon: Icons.search_outlined),
            (path: '/bookings', label: 'Bookings', icon: Icons.receipt_long_outlined),
            (path: '/notifications', label: 'Alerts', icon: Icons.notifications_none),
            (path: '/settings', label: 'Settings', icon: Icons.settings_outlined),
          ];

    final selected = items.indexWhere((item) => location.startsWith(item.path));

    return Scaffold(
      backgroundColor: RTokens.glassBg,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: RTokens.glassCardBg,
              surfaceTintColor: Colors.transparent,
              title: Text(
                AppConfig.isProApp ? 'RAWWERS Pro' : 'RAWWERS',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: RTokens.textLg,
                  color: RTokens.textOnDark,
                  letterSpacing: -0.5,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: RTokens.glassCardBorder),
              ),
              actions: [
                if (session.isPro)
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: RTokens.textMutedDark),
                    onPressed: () => context.go('/pro/profile'),
                    tooltip: 'Profile',
                  ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(RTokens.spacingX4, RTokens.spacingX4, RTokens.spacingX4, 0),
          child: child,
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xCC08080F),
              border: Border(top: BorderSide(color: RTokens.glassCardBorder, width: 1)),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
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
          ),
        ),
      ),
    );
  }
}
