import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/features/pro/messages/pro_messages_controller.dart';

/// Bottom tabs only - one navigation system for the whole app. Settings is
/// reached from the dashboard header, not a tab. Today is a section of the
/// dashboard rather than a tab of its own: on most days a photographer has
/// nothing scheduled, and an app that opens on "Nothing scheduled today." is
/// telling them it has nothing for them.
///
/// Five tabs since Messages, which was a deliberate exception to the earlier
/// limit of four: a client's message went unseen until it had a place, and a
/// badge only works on something always in view.
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
          NavigationDestination(
            icon: MessagesTabIcon(Icons.chat_bubble_outline),
            selectedIcon: MessagesTabIcon(Icons.chat_bubble),
            label: 'Messages',
          ),
          NavigationDestination(icon: Icon(Icons.camera_alt_outlined), selectedIcon: Icon(Icons.camera_alt), label: 'Gigs'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
        ],
      ),
    );
  }
}

/// The Messages tab's icon, carrying how many conversations have something
/// unread. Nothing at zero - a "0" badge is noise.
class MessagesTabIcon extends ConsumerWidget {
  const MessagesTabIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(proUnreadControllerProvider).valueOrNull ?? 0;
    return Semantics(
      label: unread > 0 ? '$unread unread' : null,
      child: Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: Icon(icon)),
    );
  }
}
