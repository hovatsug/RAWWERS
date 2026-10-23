// The browsing home screen.
//
// The assertions worth having are about what this screen does NOT do. Row
// membership, ordering and titles are fairness rules that live on the server,
// and the failure mode is the app quietly acquiring a second opinion - a
// client-side sort, a re-ordering, a row filtered for looks. That drift is
// invisible in a screenshot and is exactly how one rule in two places
// disagrees.
//
// Plus the honest-absence rule: "no city chosen" and "no photographers here"
// are different facts and must never render as the same message.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/api/models/client_home_row.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/api/models/niche_banner_image_view.dart';
import 'package:rawwers/api/models/photographer_teaser.dart';
import 'package:rawwers/api/models/teaser_kind.dart';
import 'package:rawwers/features/shared/meet/meet_section.dart';
import 'package:rawwers/api/models/niche_banner_style.dart';
import 'package:rawwers/api/models/niche_banner_view.dart';
import 'package:rawwers/design/components/r_niche_banner.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/discover/home_controller.dart';
import 'package:rawwers/features/client/discover/home_screen.dart';

class _FakeHome extends HomeController {
  _FakeHome(this._state);
  final HomeState _state;
  @override
  Future<HomeState> build() async => _state;
}

class _FailingHome extends HomeController {
  @override
  Future<HomeState> build() async => throw const NetworkError();
}

ClientDiscoverCard _card(
  String name, {
  String? cover,
  String price = '150.00',
  String? entryRate,
  int? entryPhotos,
  List<Map<String, dynamic>>? topNiches,
  PhotographerTeaser? teaser,
}) {
  return ClientDiscoverCard(
    teaser: teaser,
    proUserId: 'pro-$name',
    displayName: name,
    coverUrl: cover ?? 'https://example.test/$name.jpg',
    currency: 'EUR',
    minEntryRate: entryRate,
    minEntryPhotos: entryPhotos,
    topNiches: topNiches,
    minPrice: price,
    avgRating: '4.80',
    reviewCount: 10,
    portfolioPhotoCount: 12,
    portfolioVideoCount: 0,
  );
}

ClientHomeRow _row(String key, String title, List<ClientDiscoverCard> items, {String? subtitle, NicheBannerView? banner}) {
  return ClientHomeRow(key: key, title: title, subtitle: subtitle, items: items, banner: banner);
}

Future<void> _pump(WidgetTester tester, HomeState state, {void Function(String)? onOpenNiche}) async {
  // A tall surface, because ListView.builder only builds what is on screen
  // and the hero now takes the first 320pt. On the default 600pt viewport the
  // later rows are never constructed, and "every row is shown" would fail on
  // laziness rather than on anything the screen did wrong.
  tester.view.physicalSize = const Size(1170, 7200);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [homeControllerProvider.overrideWith(() => _FakeHome(state))],
      child: MaterialApp(
        theme: buildClientTheme(),
        home: Scaffold(body: ClientHomeScreen(onOpenNiche: onOpenNiche)),
      ),
    ),
  );
  // Not pumpAndSettle: the hero's Ken Burns pass repeats for as long as it is
  // on screen, exactly as RSkeleton's shimmer does, so nothing ever settles.
  // Two pumps is enough - one to flush the fake controller's future, one to
  // lay out what it produced.
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('rows render in the order the server sent them', (tester) async {
    await _pump(
      tester,
      HomeRows([
        _row('new_photographers', 'New photographers', [_card('Newcomer')]),
        _row('most_experienced', 'Most experienced', [_card('Veteran')]),
      ]),
    );

    // Titles appear top to bottom in server order. A client-side sort - by
    // item count, alphabetically, anything - would reverse or shuffle this.
    final newY = tester.getTopLeft(find.text('New photographers')).dy;
    final expY = tester.getTopLeft(find.text('Most experienced')).dy;
    expect(newY, lessThan(expY), reason: 'the screen re-ordered rows the server had already ordered');
  });

  testWidgets('cards render in the order the server sent them', (tester) async {
    await _pump(
      tester,
      HomeRows([
        _row('most_experienced', 'Most experienced', [_card('Many'), _card('Some'), _card('Few')]),
      ]),
    );

    final manyX = tester.getTopLeft(find.text('Many')).dx;
    final someX = tester.getTopLeft(find.text('Some')).dx;
    final fewX = tester.getTopLeft(find.text('Few')).dx;
    expect(manyX, lessThan(someX));
    expect(someX, lessThan(fewX));
  });

  testWidgets('every row the server sent is shown, none dropped', (tester) async {
    await _pump(
      tester,
      HomeRows([
        _row('new_photographers', 'New photographers', [_card('A')]),
        _row('most_experienced', 'Most experienced', [_card('B')]),
        _row('niche:weddings', 'Weddings in Lisbon', [_card('C')]),
      ]),
    );
    expect(find.text('New photographers'), findsOneWidget);
    expect(find.text('Most experienced'), findsOneWidget);
    // Twice, legitimately: the hero shows the leading niche's own row title,
    // and the row itself is still below. Both come from the same server
    // string rather than one of them recomposing it.
    expect(find.text('Weddings in Lisbon'), findsWidgets);
  });

  // -------------------------------------------------------------------------
  // The niche tile.
  // -------------------------------------------------------------------------

  testWidgets('a niche row is headed by its banner, a popularity row is not', (tester) async {
    await _pump(
      tester,
      HomeRows([
        _row('most_experienced', 'Most experienced', [_card('A')]),
        _row('niche:weddings', 'Weddings in Lisbon', [_card('B', cover: 'https://example.test/lead.jpg')]),
      ]),
    );

    final tiles = tester.widgetList<RNicheBanner>(find.byType(RNicheBanner)).toList();
    expect(tiles.length, 1, reason: 'only the niche row gets a banner');
    expect(tiles.first.title, 'Weddings in Lisbon');
    expect(tiles.first.shape, RNicheBannerShape.tile);
  });

  testWidgets('the tile draws the banner the server sent, not a photographer\'s cover', (tester) async {
    const banner = NicheBannerView(
      style: NicheBannerStyle.image,
      name: 'Weddings',
      image: NicheBannerImageView(
        mediaAssetId: 'm',
        tileUrl: 'https://example.test/tile.jpg',
        heroUrl: 'https://example.test/hero.jpg',
        placeholder: '',
        altText: 'A couple',
        focalX: 0.5,
        focalY: 0.5,
        scrimOpacity: 0.4,
        width: 2400,
        height: 1350,
      ),
    );
    await _pump(
      tester,
      HomeRows([
        _row('niche:weddings', 'Weddings in Lisbon', [_card('Top', cover: 'https://example.test/top.jpg')], banner: banner),
      ]),
    );

    final tile = tester.widget<RNicheBanner>(find.byType(RNicheBanner));
    expect(tile.banner, banner);
  });

  testWidgets('the niche slug comes from the key, not the title', (tester) async {
    // Titles are prose for a person and will be translated; the key is the
    // machine-readable fact.
    String? tapped;
    await _pump(
      tester,
      HomeRows([
        _row('niche:events_nightlife', 'Events & Nightlife in Porto', [_card('A')]),
      ]),
      onOpenNiche: (slug) => tapped = slug,
    );

    await tester.tap(find.byType(RNicheBanner));
    // Not pumpAndSettle: the hero animates continuously, so nothing settles.
    await tester.pump();
    expect(tapped, 'events_nightlife');
  });

  // -------------------------------------------------------------------------
  // Honest absence.
  // -------------------------------------------------------------------------

  testWidgets('no city chosen is not reported as no photographers', (tester) async {
    await _pump(tester, const HomeNeedsLocation());
    expect(find.text('Where are you looking?'), findsOneWidget);
    expect(
      find.textContaining('No photographers'),
      findsNothing,
      reason: 'claimed a city is empty when no city was ever chosen',
    );
  });

  testWidgets('an empty city says so plainly', (tester) async {
    await _pump(tester, const HomeRows([]));
    expect(find.text('No photographers here yet'), findsOneWidget);
  });

  testWidgets('a failure is retryable rather than silently empty', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [homeControllerProvider.overrideWith(_FailingHome.new)],
        child: MaterialApp(theme: buildClientTheme(), home: const Scaffold(body: ClientHomeScreen())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not load'), findsOneWidget);
    expect(find.textContaining('No photographers'), findsNothing);
  });

  testWidgets('a card with no price shows no price, never a zero', (tester) async {
    await _pump(
      tester,
      HomeRows([
        _row('most_experienced', 'Most experienced', [
          ClientDiscoverCard(
            proUserId: 'p1',
            displayName: 'No Price',
            coverUrl: 'https://example.test/a.jpg',
            currency: 'EUR',
            avgRating: '0.00',
            reviewCount: 0,
            portfolioPhotoCount: 3,
            portfolioVideoCount: 0,
          ),
        ]),
      ]),
    );
    expect(find.text('No Price'), findsOneWidget);
    expect(find.textContaining('EUR 0'), findsNothing);
    expect(find.textContaining('from'), findsNothing);
  });

  testWidgets('the first row clears the status bar', (tester) async {
    // Without a top inset the first heading is drawn under the clock. The
    // list scrolls beneath the status bar by design, so the inset belongs on
    // the content rather than on a SafeArea, which would clip the scroll.
    tester.view.padding = const FakeViewPadding(top: 118);
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      HomeRows([
        _row('new_photographers', 'New photographers', [_card('A')]),
      ]),
    );

    final headingTop = tester.getTopLeft(find.text('New photographers')).dy;
    expect(
      headingTop,
      greaterThanOrEqualTo(118 / tester.view.devicePixelRatio),
      reason: 'the first heading is drawn under the status bar',
    );
  });

  // ---------------------------------------------------------------------
  // The placeholder has to occupy the space its content will occupy.
  // ---------------------------------------------------------------------

  testWidgets('a loading row is the same height and inset as the row it stands in for', (tester) async {
    // The placeholder drew a 148pt row with no side padding while the loaded
    // row is 208pt and runs to the screen edge, so every row grew by 60pt and
    // shifted sideways the instant content arrived. A skeleton that does not
    // reserve the right box is worse than none: it guarantees a reflow.
    //
    // Loaded first, then loading. The reverse order silently measured the
    // placeholder twice, because the fake controller's value had not resolved
    // by the time the second measurement was taken - so the test compared the
    // skeleton with itself and passed against any geometry at all.
    await _pump(
      tester,
      HomeRows([
        _row('new_photographers', 'New photographers', [_card('A'), _card('B'), _card('C')]),
      ]),
    );
    expect(find.text('A'), findsOneWidget, reason: 'the loaded row never rendered');

    final loadedRow = tester.getSize(_firstHorizontalList(tester));
    // The first card's own leading edge, not the list's. A ListView's box is
    // full width whatever its internal padding, so measuring the list made
    // the inset assertion pass with the padding deleted.
    final loadedCardLeft = tester.getTopLeft(find.byType(RNetworkPhoto).first).dx;

    await tester.pumpWidget(
      ProviderScope(
        // A distinct key, so Flutter rebuilds the element instead of updating
        // it. Without this the container survives the pump, the previously
        // resolved rows stay in place, and the "loading" measurement is taken
        // against loaded content.
        key: const ValueKey('loading-scope'),
        overrides: [homeControllerProvider.overrideWith(_NeverLoadingHome.new)],
        child: MaterialApp(
          theme: buildClientTheme(),
          home: const Scaffold(body: ClientHomeScreen()),
        ),
      ),
    );
    // Pumped by hand: RSkeleton repeats forever, so pumpAndSettle can never
    // settle while a placeholder is on screen.
    await tester.pump();
    expect(find.text('A'), findsNothing, reason: 'the placeholder never replaced the loaded rows');

    final loadingRow = tester.getSize(_firstHorizontalList(tester));
    final loadingCardLeft = tester.getTopLeft(
      find.descendant(of: _firstHorizontalList(tester), matching: find.byType(RSkeleton)).first,
    ).dx;

    expect(
      loadingRow.height,
      loadedRow.height,
      reason: 'the row changes height when content arrives, so every row below it jumps',
    );
    expect(
      loadingCardLeft,
      loadedCardLeft,
      reason: 'the first card starts at a different x once content arrives, so the row shifts sideways',
    );
    expect(loadingRow.width, loadedRow.width);
  });
  _cardContentTests();
}

/// A home controller whose first load never completes, so the screen stays in
/// its loading state for as long as the test needs it.
class _NeverLoadingHome extends HomeController {
  @override
  Future<HomeState> build() => Completer<HomeState>().future;
}

/// The horizontal carousel inside the first row, in either state.
Finder _firstHorizontalList(WidgetTester tester) {
  return find
      .byWidgetPredicate((w) => w is ListView && w.scrollDirection == Axis.horizontal)
      .first;
}

// ---------------------------------------------------------------------------
// What a card says about price, and what it claims about a photographer.
// ---------------------------------------------------------------------------

void _cardContentTests() {
  testWidgets('the per-photo rate leads and the total follows', (tester) async {
    await _pump(
      tester,
      HomeRows([
        _row('most_experienced', 'Most experienced', [
          _card('Rated', price: '310.64', entryRate: '18.70', entryPhotos: 20),
        ]),
      ]),
    );

    final rate = find.textContaining('18.70');
    final total = find.textContaining('310.64');
    expect(rate, findsOneWidget, reason: 'the card shows a total with no per-photo rate');
    expect(total, findsOneWidget);

    // Hierarchy, not just presence. A rate printed no larger than the total
    // repeats this bug in a different arrangement, so this measures what is
    // actually painted rather than trusting the styles named in the source.
    final rateHeight = tester.getSize(rate).height;
    final totalHeight = tester.getSize(total).height;
    expect(
      rateHeight,
      greaterThan(totalHeight),
      reason: 'the rate is painted at ${rateHeight}px against the total at ${totalHeight}px, '
          'so the total still reads as the headline figure',
    );
  });

  testWidgets('a card with no rate yet still shows its total rather than nothing', (tester) async {
    // Every index row is null here until it has been recomputed since the
    // column landed. Falling back to the total is what the card showed
    // before; falling back to nothing would hide the price entirely.
    await _pump(
      tester,
      HomeRows([
        _row('most_experienced', 'Most experienced', [_card('NoRate', price: '310.64')]),
      ]),
    );
    expect(find.textContaining('310.64'), findsOneWidget);
  });

  testWidgets('a tier backed by real work is shown on the card', (tester) async {
    await _pump(
      tester,
      HomeRows([
        _row('most_experienced', 'Most experienced', [
          _card('Veteran', topNiches: [
            {'slug': 'weddings', 'tier': 'master', 'score': 100},
          ]),
        ]),
      ]),
    );
    expect(find.text('Master'), findsOneWidget);
  });

  testWidgets('a zero-score tier row is not stamped on a new photographer', (tester) async {
    // recompute_pro_niche_skills writes a row for every active niche, so a
    // brand-new photographer arrives carrying a rookie entry scoring zero in
    // a niche they have never worked in. Reading it would label exactly the
    // people the "New photographers" row exists to protect.
    await _pump(
      tester,
      HomeRows([
        _row('new_photographers', 'New photographers', [
          _card('Newcomer', topNiches: [
            {'slug': 'weddings', 'tier': 'rookie', 'score': 0},
          ]),
        ]),
      ]),
    );
    expect(
      find.text('Rookie'),
      findsNothing,
      reason: 'a photographer with no completed work was labelled by the filler skill row',
    );
  });

  // -------------------------------------------------------------------------
  // "Meet the photographer" on the card: only where it exists.
  // -------------------------------------------------------------------------

  testWidgets('a card shows one line of the interview, a play badge for a video, and nothing otherwise', (tester) async {
    await _pump(
      tester,
      HomeRows([
        _row('most_experienced', 'Most experienced', [
          _card('Talks', teaser: const PhotographerTeaser(kind: TeaserKind.interview, line: "I'm Marco, a wedding photographer.")),
          _card('Films', teaser: const PhotographerTeaser(kind: TeaserKind.video)),
          _card('Quiet'),
        ]),
      ]),
    );

    expect(find.text('“I\'m Marco, a wedding photographer.”'), findsOneWidget);
    expect(find.byKey(const ValueKey('card-teaser')), findsOneWidget, reason: 'only the card with an interview has a line');
    expect(find.byType(VideoPlayBadge), findsOneWidget, reason: 'only the card with a video has a badge');
  });
}
