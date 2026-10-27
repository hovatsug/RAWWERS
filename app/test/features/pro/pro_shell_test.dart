// The pro app's tabs: the Contact sheet tab bar, with the Requests and
// Messages badges it always had.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/design/components/r_tab_bar.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/messages/pro_messages_controller.dart';
import 'package:rawwers/features/pro/pro_shell.dart';
import 'package:rawwers/features/pro/requests/requests_controller.dart';

class _Pending extends PendingRequestsController {
  @override
  Future<PendingRequests> build() async => const PendingRequests(2);
}

class _Unread extends ProUnreadController {
  @override
  Future<int> build() async => 3;
}

void main() {
  testWidgets('five tabs on the Contact sheet bar, badges intact, and a tap changes tab', (tester) async {
    final router = GoRouter(
      initialLocation: '/you',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => ProShell(navigationShell: shell),
          branches: [
            for (final name in ['you', 'requests', 'messages', 'gigs', 'wallet'])
              StatefulShellBranch(routes: [GoRoute(path: '/$name', builder: (context, state) => Text('page $name'))]),
          ],
        ),
      ],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        pendingRequestsControllerProvider.overrideWith(_Pending.new),
        proUnreadControllerProvider.overrideWith(_Unread.new),
      ],
      child: MaterialApp.router(theme: buildProTheme(), routerConfig: router),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byType(RTabBar), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    for (final label in ['You', 'Requests', 'Messages', 'Gigs', 'Wallet']) {
      expect(find.descendant(of: find.byType(RTabBar), matching: find.text(label)), findsOneWidget);
    }
    expect(find.descendant(of: find.byType(RTabBar), matching: find.text('2')), findsOneWidget, reason: 'requests badge');
    expect(find.descendant(of: find.byType(RTabBar), matching: find.text('3')), findsOneWidget, reason: 'messages badge');

    await tester.tap(find.text('Wallet'));
    await tester.pump();
    await tester.pump();
    expect(find.text('page wallet'), findsOneWidget);
    expect(tester.widget<RTabBar>(find.byType(RTabBar)).selectedIndex, 4);
  });
}
