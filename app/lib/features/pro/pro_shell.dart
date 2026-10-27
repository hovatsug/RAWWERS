import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/design/components/r_tab_bar.dart';
import 'package:rawwers/features/pro/messages/pro_messages_controller.dart';
import 'package:rawwers/features/pro/requests/requests_controller.dart';

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
      bottomNavigationBar: RTabBar(
        selectedIndex: navigationShell.currentIndex,
        onSelected: (index) => navigationShell.goBranch(index),
        items: [
          const RTabItem(label: 'You', icon: Icons.person_outline, selectedIcon: Icons.person),
          RTabItem(
            label: 'Requests',
            icon: Icons.inbox_outlined,
            selectedIcon: Icons.inbox,
            iconBuilder: (context, selected) => RequestsTabIcon(selected ? Icons.inbox : Icons.inbox_outlined),
          ),
          RTabItem(
            label: 'Messages',
            icon: Icons.chat_bubble_outline,
            selectedIcon: Icons.chat_bubble,
            iconBuilder: (context, selected) => MessagesTabIcon(selected ? Icons.chat_bubble : Icons.chat_bubble_outline),
          ),
          const RTabItem(label: 'Gigs', icon: Icons.camera_alt_outlined, selectedIcon: Icons.camera_alt),
          const RTabItem(label: 'Wallet', icon: Icons.account_balance_wallet_outlined, selectedIcon: Icons.account_balance_wallet),
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

/// The Requests tab's icon, carrying how many requests are waiting on an
/// answer. Nothing at zero.
class RequestsTabIcon extends ConsumerWidget {
  const RequestsTabIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingRequestsControllerProvider).valueOrNull ?? const PendingRequests(0);
    final waiting = pending.count > 0;
    return Semantics(
      label: waiting ? '${pending.label} waiting' : null,
      child: Badge(isLabelVisible: waiting, label: Text(pending.label), child: Icon(icon)),
    );
  }
}
