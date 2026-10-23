// One niche's page.
//
// Who belongs in which row is decided by the server and tested there
// (api/tests/test_client_home_rows.py). What can go wrong here is the page
// acquiring a second opinion - blending the new-photographer row into the
// experience row, re-sorting, padding a thin niche with an empty shelf - or
// collapsing four different facts into one message: no city, no such niche,
// nobody here yet, and a failure.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/api/models/client_home_niche.dart';
import 'package:rawwers/api/models/client_home_row.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_niche_banner.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/discover/hero_slides.dart';
import 'package:rawwers/features/client/discover/niche_controller.dart';
import 'package:rawwers/features/client/discover/niche_screen.dart';
import 'package:rawwers/features/client/discover/widgets/hero_carousel.dart';
import 'package:rawwers/features/client/discover/widgets/photographer_rows.dart';

class _Fake extends NicheController {
  _Fake(this._state);
  final NicheState _state;
  @override
  Future<NicheState> build(String nicheSlug) async => _state;
}

class _Failing extends NicheController {
  @override
  Future<NicheState> build(String nicheSlug) async => throw const NetworkError();
}

ClientDiscoverCard _card(String name, {String? cover}) => ClientDiscoverCard(
      proUserId: 'pro-$name',
      displayName: name,
      coverUrl: cover ?? 'https://example.test/$name.jpg',
      currency: 'EUR',
      minPrice: '150.00',
      avgRating: '4.80',
      reviewCount: 10,
      portfolioPhotoCount: 12,
      portfolioVideoCount: 0,
    );

const _weddings = ClientHomeNiche(slug: 'weddings', name: 'Weddings');

ClientHomeRow _row(String key, String title, List<String> names) =>
    ClientHomeRow(key: key, title: title, items: [for (final n in names) _card(n)]);

NichePage _page(List<ClientHomeRow> rows) => NichePage(niche: _weddings, rows: rows);

Future<void> _pump(WidgetTester tester, NicheController Function() controller, {void Function(String)? onOpenPro}) async {
  tester.view.physicalSize = const Size(1170, 7200);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [nicheControllerProvider('weddings').overrideWith(controller)],
      child: MaterialApp(
        theme: buildClientTheme(),
        home: NicheScreen(nicheSlug: 'weddings', onOpenPro: onOpenPro),
      ),
    ),
  );
  // Not pumpAndSettle: the hero pans for as long as it is on screen.
  await tester.pump();
  await tester.pump();
}

/// Within the rows, not the hero - a slide carries its row's title too.
Finder _inRows(Finder finder) => find.descendant(of: find.byType(PhotographerRow), matching: finder);

/// The names shown in the row the server keyed [key], in the order shown.
List<String> _namesIn(WidgetTester tester, String key) {
  final row = find.byKey(ValueKey('row:$key'));
  expect(row, findsOneWidget, reason: 'no $key row on the page');
  return tester.widget<PhotographerRow>(row).row.items!.map((c) => c.displayName!).toList()
    ..retainWhere((name) => find.descendant(of: row, matching: find.text(name)).evaluate().isNotEmpty);
}

void main() {
  testWidgets('the page is titled with the niche the server named', (tester) async {
    await _pump(tester, () => _Fake(_page([_row('niche_ranked', 'Weddings in Lisbon', ['Ana'])])));
    expect(find.widgetWithText(AppBar, 'Weddings'), findsOneWidget);
  });

  testWidgets('rows render in the order the server sent them, titled as sent', (tester) async {
    await _pump(
      tester,
      () => _Fake(_page([
            _row('new_photographers', 'New in Weddings', ['Nia']),
            _row('most_experienced', 'Most experienced in Weddings', ['Vic']),
            _row('niche_ranked', 'Weddings in Lisbon', ['Vic', 'Nia']),
          ])),
    );
    final keys = tester.widgetList<PhotographerRow>(find.byType(PhotographerRow)).map((r) => r.row.key).toList();
    expect(keys, ['new_photographers', 'most_experienced', 'niche_ranked']);
    for (final title in ['New in Weddings', 'Most experienced in Weddings', 'Weddings in Lisbon']) {
      expect(_inRows(find.text(title)), findsOneWidget);
    }
  });

  testWidgets('new photographers stay in their own row and are never blended into experience', (tester) async {
    // The server keeps these disjoint. The page must show each row's members
    // exactly - not merge the rows, top up one from the other, or re-sort.
    await _pump(
      tester,
      () => _Fake(_page([
            _row('new_photographers', 'New in Weddings', ['Nia', 'Noa']),
            _row('most_experienced', 'Most experienced in Weddings', ['Vic', 'Val']),
          ])),
    );
    final newcomers = _namesIn(tester, 'new_photographers');
    final experienced = _namesIn(tester, 'most_experienced');

    expect(newcomers, ['Nia', 'Noa']);
    expect(experienced, ['Vic', 'Val'], reason: 'the experience row was re-sorted or topped up');
    expect(newcomers.toSet().intersection(experienced.toSet()), isEmpty, reason: 'the two rows were blended');
  });

  testWidgets('the page leads with its own banner, and no row is a niche tile linking to it', (tester) async {
    await _pump(tester, () => _Fake(_page([_row('niche_ranked', 'Weddings in Lisbon', ['Ana'])])));
    final banners = tester.widgetList<RNicheBanner>(find.byType(RNicheBanner)).toList();
    expect(banners.length, 1, reason: 'one hero, and no tile in the rows');
    expect(banners.single.shape, RNicheBannerShape.hero);
    expect(banners.single.title, 'Weddings');
  });

  group('the hero', () {
    testWidgets("leads with the niche's top photographers, in the server's order", (tester) async {
      await _pump(tester, () => _Fake(_page([_row('niche_ranked', 'Weddings in Lisbon', ['A', 'B', 'C'])])));
      final hero = tester.widget<HeroCarousel>(find.byType(HeroCarousel));
      expect(hero.slides.map((s) => s.card.displayName), ['A', 'B', 'C']);
      expect(hero.slides.every((s) => s.nicheSlug == 'weddings'), isTrue);
    });

    testWidgets('a slide opens its photographer, not this page again', (tester) async {
      String? opened;
      await _pump(
        tester,
        () => _Fake(_page([_row('niche_ranked', 'Weddings in Lisbon', ['Ana'])])),
        onOpenPro: (id) => opened = id,
      );
      await tester.tap(find.byType(HeroCarousel));
      await tester.pump();
      expect(opened, 'pro-Ana');
    });

    test('takes at most five, each photographer once, none without a cover', () {
      final slides = nicheHeroSlidesFrom(
        [
          ClientHomeRow(key: 'niche_ranked', title: 'Weddings in Lisbon', items: [
            _card('A'),
            _card('NoCover', cover: ''),
            _card('A'),
            for (final n in ['B', 'C', 'D', 'E', 'F']) _card(n),
          ]),
        ],
        nicheSlug: 'weddings',
      );
      expect(slides.map((s) => s.card.displayName), ['A', 'B', 'C', 'D', 'E']);
    });
  });

  group('a thin or empty niche', () {
    testWidgets('only the rows the server sent - no empty shelves', (tester) async {
      // One brand-new photographer: the server sends a new row and the ranked
      // row, and no experience row at all.
      await _pump(
        tester,
        () => _Fake(_page([
              _row('new_photographers', 'New in Weddings', ['Solo']),
              _row('niche_ranked', 'Weddings in Lisbon', ['Solo']),
            ])),
      );
      expect(find.byType(PhotographerRow), findsNWidgets(2));
      expect(find.textContaining('Most experienced'), findsNothing);
      expect(find.byType(RErrorState), findsNothing);
      // One slide, and it still shows - a thin niche is not a broken one.
      expect(tester.widget<HeroCarousel>(find.byType(HeroCarousel)).slides, hasLength(1));
    });

    testWidgets('a row that arrives empty is left out rather than drawn blank', (tester) async {
      await _pump(
        tester,
        () => _Fake(_page([
              _row('new_photographers', 'New in Weddings', []),
              _row('niche_ranked', 'Weddings in Lisbon', ['Solo']),
            ])),
      );
      expect(find.text('New in Weddings'), findsNothing);
      expect(_inRows(find.text('Weddings in Lisbon')), findsOneWidget);
    });

    testWidgets('nobody here says so plainly, naming the niche', (tester) async {
      await _pump(tester, () => _Fake(_page(const [])));
      expect(find.text('No photographers here yet'), findsOneWidget);
      expect(find.textContaining('Weddings'), findsWidgets);
      expect(find.byType(RErrorState), findsNothing, reason: 'an honest absence is not a failure');
    });
  });

  testWidgets('an unknown niche is not reported as an empty one', (tester) async {
    await _pump(tester, () => _Fake(const NicheNotFound()));
    expect(find.text("This category isn't available"), findsOneWidget);
    expect(find.text('No photographers here yet'), findsNothing);
    expect(find.byType(RErrorState), findsNothing, reason: 'retrying a missing niche gets the same answer');
  });

  testWidgets('no city chosen is not reported as no photographers', (tester) async {
    await _pump(tester, () => _Fake(const NicheNeedsLocation()));
    expect(find.text('Where are you looking?'), findsOneWidget);
    expect(find.text('No photographers here yet'), findsNothing);
  });

  testWidgets('a failure is retryable rather than silently empty', (tester) async {
    await _pump(tester, _Failing.new);
    expect(find.byType(RErrorState), findsOneWidget);
    expect(find.text('No photographers here yet'), findsNothing);
  });
}
