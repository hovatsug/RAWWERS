// Every way into a niche lands on the same page.
//
// Driven through the real client router rather than by checking a callback
// fired: the bug this replaces was never in a widget - RNicheTile took an
// onTap all along - it was the router not passing one through. A test that
// hands the screen its own callback would have passed the whole time the
// tiles did nothing.
//
// On the home screen a niche row's heading *is* its tile, so "tile" and "row
// header" are one tap target there; the hero slide is the other.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/api/models/client_home_niche.dart';
import 'package:rawwers/api/models/client_home_row.dart';
import 'package:rawwers/api/models/me_response.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/core/router/app_router_client.dart';
import 'package:rawwers/design/components/r_niche_tile.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/discover/home_controller.dart';
import 'package:rawwers/features/client/discover/niche_controller.dart';
import 'package:rawwers/features/client/discover/niche_screen.dart';
import 'package:rawwers/features/client/discover/widgets/hero_carousel.dart';

class _SignedIn extends AuthController {
  @override
  Future<AuthState> build() async => const AuthAuthenticated(MeResponse(userId: 'client-1', status: 'active'));
}

class _Home extends HomeController {
  @override
  Future<HomeState> build() async => HomeRows([
        ClientHomeRow(key: 'new_photographers', title: 'New photographers', items: [_card('Ana')]),
        ClientHomeRow(key: 'niche:weddings', title: 'Weddings in Lisbon', items: [_card('Bea'), _card('Cai')]),
        ClientHomeRow(key: 'niche:portraits', title: 'Portraits in Lisbon', items: [_card('Dan')]),
      ]);
}

ClientDiscoverCard _card(String name) => ClientDiscoverCard(
      proUserId: 'pro-$name',
      displayName: name,
      coverUrl: 'https://example.test/$name.jpg',
      currency: 'EUR',
      minPrice: '150.00',
      avgRating: '4.80',
      reviewCount: 10,
      portfolioPhotoCount: 12,
      portfolioVideoCount: 0,
    );

const _weddings = '/discover/niche/weddings';

Future<GoRouter> _pumpApp(WidgetTester tester, List<Override> extra) async {
  // Reduced motion stops the hero's endless Ken Burns pass, so the tree can
  // settle and a navigation can be waited on properly.
  tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = const Size(1170, 5400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(_SignedIn.new),
      homeControllerProvider.overrideWith(_Home.new),
      ...extra,
    ],
  );
  addTearDown(container.dispose);
  // The router provider rebuilds whenever auth changes, so reading it before
  // auth resolves hands back a router left behind on the launch screen.
  await tester.runAsync(() => container.read(authControllerProvider.future));
  final router = container.read(clientRouterProvider);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: buildClientTheme(), routerConfig: router),
    ),
  );
  await _settle(tester);
  expect(router.routerDelegate.currentConfiguration.uri.path, '/discover', reason: 'did not reach the home screen');
  return router;
}

/// Bounded, not pumpAndSettle: network photos keep a loading indicator
/// spinning in tests, so the tree never settles on its own. Long enough for a
/// page transition to finish.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Where the screen on top actually is. Not `currentConfiguration.uri`: a
/// `push` leaves that at the page underneath, so it read "/discover" whether or
/// not anything had been opened.
String _at(GoRouter router) => router.state.matchedLocation;

class _Niche extends NicheController {
  @override
  Future<NicheState> build(String nicheSlug) async => NichePage(
        niche: ClientHomeNiche(slug: nicheSlug, name: nicheSlug == 'weddings' ? 'Weddings' : 'Portraits'),
        rows: [ClientHomeRow(key: 'niche_ranked', title: 'In Lisbon', items: [_card('Bea')])],
      );
}

final nicheOverrides = <Override>[
  for (final slug in ['weddings', 'portraits']) nicheControllerProvider(slug).overrideWith(_Niche.new),
];

/// On the niche page for [slug] - the URL, and the screen actually built there.
void _expectNichePage(WidgetTester tester, GoRouter router, String slug) {
  expect(_at(router), '/discover/niche/$slug');
  final screen = tester.widget<NicheScreen>(find.byType(NicheScreen));
  expect(screen.nicheSlug, slug);
}

void main() {
  testWidgets('the niche tile - which is also the row heading - opens the niche page', (tester) async {
    final router = await _pumpApp(tester, nicheOverrides);

    await tester.tap(find.widgetWithText(RNicheTile, 'Weddings in Lisbon'));
    await _settle(tester);

    _expectNichePage(tester, router, 'weddings');
  });

  testWidgets('a hero slide opens its niche page, not the photographer', (tester) async {
    final router = await _pumpApp(tester, nicheOverrides);

    // The first slide is the first niche row's leader: Bea, for weddings.
    await tester.tap(find.byType(HeroCarousel));
    await _settle(tester);

    _expectNichePage(tester, router, 'weddings');
  });

  testWidgets('tile and hero slide for one niche arrive at the same place', (tester) async {
    final router = await _pumpApp(tester, nicheOverrides);

    await tester.tap(find.widgetWithText(RNicheTile, 'Weddings in Lisbon'));
    await _settle(tester);
    final fromTile = _at(router);

    router.go('/discover');
    await _settle(tester);

    await tester.tap(find.byType(HeroCarousel));
    await _settle(tester);
    final fromHero = _at(router);

    expect(fromTile, fromHero);
    expect(fromTile, _weddings);
  });

  testWidgets('each niche opens its own page', (tester) async {
    final router = await _pumpApp(tester, nicheOverrides);

    await tester.tap(find.widgetWithText(RNicheTile, 'Portraits in Lisbon'));
    await _settle(tester);

    _expectNichePage(tester, router, 'portraits');
  });
}
