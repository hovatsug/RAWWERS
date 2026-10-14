// Discover's live rows are fetched again when Discover comes back into view
// - the app resumes, the Discover tab is selected, or a page above it is
// popped - and only when what is on screen is older than 15 seconds.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/features/client/client_shell.dart';
import 'package:rawwers/features/client/discover/discover_freshness.dart';

/// A stand-in for the home controller: counts its fetches, and fetches again
/// on the same rule.
var _now = DateTime(2026, 10, 14, 12);
final _fetches = <DateTime>[];
final _rowsProvider = FutureProvider.autoDispose<int>((ref) async {
  _fetches.add(_now);
  refetchWhenDiscoverReturns(ref, fetchedAt: _now, refetch: ref.invalidateSelf, clock: () => _now);
  return _fetches.length;
});

GoRouter _router(ProviderContainer container) => GoRouter(
      initialLocation: '/discover',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => ClientShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(
              observers: [DiscoverPopObserver(() => container.read(discoverReturnsProvider.notifier).bump())],
              routes: [
                GoRoute(
                  path: '/discover',
                  builder: (context, state) => Consumer(
                    builder: (context, ref, _) => TextButton(
                      onPressed: () => context.push('/discover/pro'),
                      child: Text('rows ${ref.watch(_rowsProvider).valueOrNull}'),
                    ),
                  ),
                  routes: [GoRoute(path: 'pro', builder: (context, state) => const Text('a profile'))],
                ),
              ],
            ),
            for (final path in ['/bookings', '/messages', '/account'])
              StatefulShellBranch(routes: [GoRoute(path: path, builder: (context, state) => Text(path))]),
          ],
        ),
      ],
    );

Future<ProviderContainer> _pump(WidgetTester tester) async {
  _fetches.clear();
  _now = DateTime(2026, 10, 14, 12);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: MaterialApp.router(routerConfig: _router(container))));
  await tester.pumpAndSettle();
  expect(_fetches, hasLength(1));
  return container;
}

Future<void> _later(WidgetTester tester, Duration by) async {
  _now = _now.add(by);
}

void main() {
  testWidgets('coming back to the Discover tab fetches again once the rows are stale', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Bookings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    expect(_fetches, hasLength(1), reason: 'five seconds old - still fresh');

    await tester.tap(find.text('Bookings'));
    await tester.pumpAndSettle();
    await _later(tester, discoverStaleAfter);
    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    expect(_fetches, hasLength(2));
  });

  testWidgets('the app resuming fetches again once the rows are stale', (tester) async {
    await _pump(tester);
    await _later(tester, discoverStaleAfter);

    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();

    expect(_fetches, hasLength(2));
  });

  testWidgets('coming back from a profile fetches again once the rows are stale', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('rows 1'));
    await tester.pumpAndSettle();
    expect(find.text('a profile'), findsOneWidget);

    await _later(tester, discoverStaleAfter);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    navigator.pop();
    await tester.pumpAndSettle();

    expect(_fetches, hasLength(2));
    expect(find.text('rows 2'), findsOneWidget);
  });

  testWidgets('fresh rows are not fetched again however often Discover returns', (tester) async {
    final container = await _pump(tester);

    for (var i = 0; i < 5; i++) {
      container.read(discoverReturnsProvider.notifier).bump();
      await tester.pump();
    }

    expect(_fetches, hasLength(1));
  });
}
