import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/notification_view.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/shared/notifications/notification_bell.dart';
import 'package:rawwers/features/shared/notifications/notifications_controller.dart';
import 'package:rawwers/features/shared/notifications/notifications_list.dart';

import '../../support/fake_notifications.dart';

class _Fake extends NotificationsController {
  _Fake(this.items);

  final List<NotificationView> items;
  final read = <String>[];
  var allRead = 0;

  @override
  Future<List<NotificationView>> build() async => items;

  @override
  Future<void> markRead(NotificationView notification) async => read.add(notification.id);

  @override
  Future<String?> markAllRead() async {
    allRead++;
    return null;
  }
}

Future<_Fake> _pump(WidgetTester tester, List<NotificationView> items, {NotificationRoute? routeFor}) async {
  final fake = _Fake(items);
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, _) => NotificationsList(routeFor: routeFor ?? (_) => null)),
    GoRoute(path: '/target', builder: (_, _) => const Scaffold(body: Text('Target screen'))),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [notificationsControllerProvider.overrideWith(() => fake)],
    child: MaterialApp.router(theme: buildProTheme(), routerConfig: router),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('lists them newest first with their time, unread ones marked', (tester) async {
    await _pump(tester, [notification(), notification(id: 'n2', title: 'Delivered', body: 'Card was delivered.', read: true)]);

    expect(find.text('On its way'), findsOneWidget);
    expect(find.text('Card has shipped.'), findsOneWidget);
    expect(find.text('2h'), findsNWidgets(2));
    expect(find.byIcon(Icons.circle), findsOneWidget, reason: 'one unread');
    expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
  });

  testWidgets('tapping one marks it read and opens where it leads', (tester) async {
    final fake = await _pump(tester, [notification()], routeFor: (_) => '/target');

    await tester.tap(find.text('On its way'));
    await tester.pumpAndSettle();

    expect(fake.read, ['n1']);
    expect(find.text('Target screen'), findsOneWidget);
  });

  testWidgets('one with nowhere to go is only marked read', (tester) async {
    final fake = await _pump(tester, [notification()]);

    await tester.tap(find.text('On its way'));
    await tester.pumpAndSettle();

    expect(fake.read, ['n1']);
    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('mark all read, offered only while some are unread', (tester) async {
    final fake = await _pump(tester, [notification()]);
    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();
    expect(fake.allRead, 1);
  });

  testWidgets('no mark all read when everything is read', (tester) async {
    await _pump(tester, [notification(read: true)]);
    expect(find.text('Mark all read'), findsNothing);
  });

  testWidgets('says so when there are none', (tester) async {
    await _pump(tester, []);
    expect(find.text('Nothing yet'), findsOneWidget);
  });

  group('the bell', () {
    Future<void> bell(WidgetTester tester, int count, {VoidCallback? onOpen}) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [unreadCountProvider().overrideWith((ref) async => count)],
        child: MaterialApp(theme: buildProTheme(), home: Scaffold(body: NotificationBell(onOpen: onOpen ?? () {}))),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('shows how many are unread', (tester) async {
      await bell(tester, 3);
      expect(find.text('3'), findsOneWidget);
      expect(find.byTooltip('Notifications, 3 unread'), findsOneWidget);
    });

    testWidgets('shows no number when none are', (tester) async {
      await bell(tester, 0);
      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);
      expect(find.byTooltip('Notifications'), findsOneWidget);
    });

    testWidgets('caps the number at 99+', (tester) async {
      await bell(tester, 150);
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('opens the notifications', (tester) async {
      var opened = 0;
      await bell(tester, 1, onOpen: () => opened++);
      await tester.tap(find.byType(NotificationBell));
      expect(opened, 1);
    });
  });
}
