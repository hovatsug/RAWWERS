// Every screen a photographer or client can walk into must have a way out.
//
// The bug this exists to prevent: Settings destinations were declared as
// sibling top-level routes with hierarchical paths (`/settings/gear` next to
// `/settings`, not inside it) and navigated with `context.go`, which replaces
// the stack. Nothing to pop to means Material's AppBar draws no back arrow,
// and because those routes also sit outside the shell there is no bottom nav
// either. Verified on a device before this test existed: "Your listing" was a
// dead end reachable in two taps, escapable only by force-quitting.
//
// The invariant asserted here is structural, and deliberately stronger than
// "has a back path today". A route that works only because its one call site
// happens to use `push` is one edit away from being a trap again, and a source
// scan cannot follow the path indirection (screens take `portfolioPath` as a
// constructor argument, not `ProRoute.portfolio`). So: every non-root route
// must resolve to a match list with more than one page in it, which is true
// only when it is genuinely nested under a parent.
//
// A full-screen child that should cover the shell still nests - it declares
// `parentNavigatorKey: rootNavigatorKey` - so presentation and stack depth stay
// independent decisions.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/core/router/app_router_client.dart';
import 'package:rawwers/core/router/app_router_pro.dart';

/// Routes allowed to be the bottom of the stack, each for a stated reason.
/// Anything not listed here must be reachable with a back path.
const _proRoots = <String, String>{
  '/launch': 'transient; only ever a redirect target while auth resolves',
  '/auth': 'the unauthenticated root; register/forgot/reset are its children',
  '/upgrade-to-pro': 'a gate - a back button would defeat it',
  '/dashboard': 'shell branch root',
  '/requests': 'shell branch root',
  '/gigs': 'shell branch root',
  '/wallet': 'shell branch root',
};

const _clientRoots = <String, String>{
  '/launch': 'transient; only ever a redirect target while auth resolves',
  '/auth': 'the unauthenticated root; register/forgot/reset are its children',
  '/discover': 'shell branch root',
  '/bookings': 'shell branch root',
  '/messages': 'shell branch root',
  '/account': 'shell branch root',
};

/// Concrete values for path parameters, so `/discover/pro/:proUserId` can be
/// matched. The value is irrelevant; only the shape of the match matters.
const _paramSamples = <String, String>{
  'proUserId': 'p1',
  'nicheSlug': 'weddings',
  'bookingId': 'b1',
  'threadId': 't1',
};

int _pageCount(RouteMatchBase match) {
  if (match is ShellRouteMatch) {
    return match.matches.fold<int>(0, (sum, child) => sum + _pageCount(child));
  }
  return 1;
}

/// Every page the router would build, in the order it stacks them. The last
/// entry is the one on top - the screen a photographer is actually looking at.
List<String> _pagesInOrder(RouteMatchBase match) {
  if (match is ShellRouteMatch) {
    return [for (final child in match.matches) ..._pagesInOrder(child)];
  }
  if (match is RouteMatch) return [match.matchedLocation];
  return const [];
}

/// Every location the router can match, built by walking the declared tree
/// rather than by hand. A hand-written list would silently stop covering a
/// route the moment someone added one - the check would keep passing and mean
/// less every time.
List<String> _allLocations(List<RouteBase> routes, [String prefix = '']) {
  final found = <String>[];
  for (final route in routes) {
    if (route is GoRoute) {
      final path = route.path.startsWith('/')
          ? route.path
          : '$prefix/${route.path}'.replaceAll('//', '/');
      var location = path;
      _paramSamples.forEach((name, value) {
        location = location.replaceAll(':$name', value);
      });
      if (!location.contains(':')) found.add(location);
      found.addAll(_allLocations(route.routes, path));
    } else {
      found.addAll(_allLocations(route.routes, prefix));
    }
  }
  return found;
}

void _assertEveryRouteCanGoBack(
  GoRouter router,
  Map<String, String> roots,
  String flavor,
) {
  final locations = _allLocations(router.configuration.routes);
  expect(
    locations,
    isNotEmpty,
    reason: 'walked the $flavor route tree and found nothing, so a pass here would mean nothing',
  );

  // Every allowlisted root must actually exist. A stale entry - a route
  // renamed, the exemption left behind - would quietly excuse a route that no
  // longer needs excusing, or mask one that does.
  for (final root in roots.keys) {
    expect(
      locations,
      contains(root),
      reason: '$flavor exempts $root but no such route is declared; the exemption is stale',
    );
  }

  final trapped = <String>[];
  for (final location in locations) {
    if (roots.containsKey(location)) continue;
    final matches = router.configuration.findMatch(Uri.parse(location));
    final pages = matches.matches.fold<int>(0, (sum, m) => sum + _pageCount(m));
    if (pages < 2) trapped.add(location);
  }

  expect(
    trapped,
    isEmpty,
    reason: 'These $flavor routes build a single page, so there is nothing to '
        'pop to and no back arrow is drawn:\n  ${trapped.join('\n  ')}',
  );

  // Depth is not enough. A route can stack three pages and still put the wrong
  // one on top: declaring a parent with parentNavigatorKey: rootNavigatorKey
  // while its children render on the shell navigator makes the parent draw
  // *above* its own child. That shipped, and this check is what would have
  // caught it - navigating to an editor opened the settings menu instead.
  final wrongScreen = <String>[];
  for (final location in locations) {
    final matches = router.configuration.findMatch(Uri.parse(location));
    final pages = [for (final m in matches.matches) ..._pagesInOrder(m)];
    if (pages.isEmpty) continue;
    if (pages.last != location) wrongScreen.add('$location -> lands on ${pages.last} (stack: ${pages.join(' > ')})');
  }

  expect(
    wrongScreen,
    isEmpty,
    reason: 'Navigating to these $flavor routes leaves a different screen on '
        'top, so the photographer does not arrive where they tapped:\n  ${wrongScreen.join('\n  ')}',
  );
}

GoRouter _twoLevelRouter({required bool nested}) => GoRouter(
      initialLocation: nested ? '/parent/child' : '/parent/child',
      routes: nested
          ? [
              GoRoute(
                path: '/parent',
                builder: (context, state) => const _Screen('parent'),
                routes: [GoRoute(path: 'child', builder: (context, state) => const _Screen('child'))],
              ),
            ]
          : [
              GoRoute(path: '/parent', builder: (context, state) => const _Screen('parent')),
              GoRoute(path: '/parent/child', builder: (context, state) => const _Screen('child')),
            ],
    );

/// The path constants the app actually navigates with, read out of the router
/// source and resolved through their own interpolation.
///
/// Walking the declared route tree is not enough on its own: the tree and the
/// `ProRoute`/`ClientRoute` constants are two separate lists, and when the
/// routes were reparented under the dashboard while the constants still said
/// `$settings/...`, every guard here passed while the app itself answered
/// "no routes for location: /dashboard/settings/portfolio". A test that walks
/// only one of the two lists cannot see them disagree.
Map<String, String> _declaredPaths(String source, String className) {
  final classBody = RegExp('abstract final class $className \\{(.*?)\\n\\}', dotAll: true).firstMatch(source);
  expect(classBody, isNotNull, reason: 'could not find $className in the router source');
  final resolved = <String, String>{};
  for (final match in RegExp(r"static const (\w+) = '([^']+)';").allMatches(classBody!.group(1)!)) {
    var value = match.group(2)!;
    // Constants are written in terms of each other ('$dashboard/settings').
    for (final entry in resolved.entries) {
      value = value.replaceAll('\$${entry.key}', entry.value);
    }
    resolved[match.group(1)!] = value;
  }
  return resolved;
}

void _assertEveryDeclaredPathResolves(GoRouter router, String source, String className, String flavor) {
  final declared = _declaredPaths(source, className);
  expect(declared, isNotEmpty, reason: 'found no $className constants, so this check would prove nothing');

  final broken = <String>[];
  for (final entry in declared.entries) {
    if (entry.value.contains(r'$')) {
      broken.add('${entry.key} = ${entry.value} (unresolved interpolation)');
      continue;
    }
    final matches = router.configuration.findMatch(Uri.parse(entry.value));
    final pages = [for (final m in matches.matches) ..._pagesInOrder(m)];
    if (pages.isEmpty) broken.add('${entry.key} = ${entry.value} (no route matches it)');
  }

  expect(
    broken,
    isEmpty,
    reason: 'These $flavor path constants do not resolve to a declared route, so navigating with '
        'them lands on Page Not Found:\n  ${broken.join('\n  ')}',
  );
}

void main() {
  testWidgets('a nested route draws a back arrow and a flat sibling does not', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: _twoLevelRouter(nested: true)));
    await tester.pumpAndSettle();
    expect(find.text('child'), findsOneWidget);
    expect(
      find.byType(BackButton),
      findsOneWidget,
      reason: 'a child route must give Material something to pop back to',
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: _twoLevelRouter(nested: false)));
    await tester.pumpAndSettle();
    expect(find.text('child'), findsOneWidget);
    expect(
      find.byType(BackButton),
      findsNothing,
      reason: 'the flat-sibling shape is the bug; if this ever draws a back '
          'arrow, the page-count guard above has stopped meaning anything',
    );
  });

  test('every pro path constant resolves to a real route', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    _assertEveryDeclaredPathResolves(
      container.read(proRouterProvider),
      File('lib/core/router/app_router_pro.dart').readAsStringSync(),
      'ProRoute',
      'pro',
    );
  });

  test('every client path constant resolves to a real route', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    _assertEveryDeclaredPathResolves(
      container.read(clientRouterProvider),
      File('lib/core/router/app_router_client.dart').readAsStringSync(),
      'ClientRoute',
      'client',
    );
  });

  test('every pro route can be navigated back out of', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    _assertEveryRouteCanGoBack(container.read(proRouterProvider), _proRoots, 'pro');
  });

  test('every client route can be navigated back out of', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    _assertEveryRouteCanGoBack(container.read(clientRouterProvider), _clientRoots, 'client');
  });
}

/// The guard above asserts our routes build more than one page. That only
/// means what it should if "more than one page" is in fact what makes Material
/// draw a back arrow - so this pins the semantics the guard leans on, in both
/// directions, against the go_router and Flutter versions actually in use.
/// If an upgrade ever changed that relationship, the guard would keep passing
/// while every screen quietly lost its way out; this test is what would fail.
class _Screen extends StatelessWidget {
  const _Screen(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: const SizedBox());
}
