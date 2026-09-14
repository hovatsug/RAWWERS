import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/api/models/client_home_row.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/discover/hero_slides.dart';
import 'package:rawwers/features/client/discover/widgets/hero_carousel.dart';

/// The hero at the top of Discover.
///
/// Two things it must never do: invent a slide, and move when someone has
/// asked their device to stop things moving.

ClientDiscoverCard _card(String id, {String? cover, bool noCover = false}) =>
    ClientDiscoverCard(
      proUserId: id,
      displayName: id,
      coverUrl: noCover ? null : (cover ?? 'https://media.example/$id.jpg'),
      currency: 'EUR',
      minPrice: '100.00',
      avgRating: '4.50',
      reviewCount: 3,
      portfolioPhotoCount: 8,
      portfolioVideoCount: 0,
    );

ClientHomeRow _row(String key, String title, List<ClientDiscoverCard> items) =>
    ClientHomeRow(key: key, title: title, items: items);

void main() {
  group('slide selection', () {
    test('only niche rows become slides', () {
      final slides = heroSlidesFrom([
        _row('new_photographers', 'New photographers', [_card('a')]),
        _row('most_experienced', 'Most experienced', [_card('b')]),
        _row('niche:weddings', 'Weddings in Lisbon', [_card('c')]),
      ]);
      expect(slides.map((s) => s.nicheSlug), ['weddings']);
    });

    test('a photographer leading three niches appears once', () {
      // The case that made this rule necessary: in Lisbon one photographer
      // tops weddings, portraits and family, so three of four slides showed
      // the same person under three different labels.
      final star = _card('star');
      final slides = heroSlidesFrom([
        _row('niche:weddings', 'Weddings in Lisbon', [star, _card('second')]),
        _row('niche:portraits', 'Portraits in Lisbon', [star, _card('third')]),
        _row('niche:family', 'Family in Lisbon', [star]),
      ]);

      // weddings takes the star; portraits falls through to its own runner-up
      // rather than repeating them; family has nobody left and drops out.
      expect(slides.map((s) => s.card.proUserId), ['star', 'third']);
      expect(
        slides.length,
        2,
        reason: 'family had nobody left after deduplication and should contribute no slide',
      );
    });

    test('a niche with no photographers contributes nothing rather than an empty slide', () {
      final slides = heroSlidesFrom([
        _row('niche:weddings', 'Weddings in Lisbon', const []),
        _row('niche:food', 'Food in Lisbon', [_card('cook')]),
      ]);
      expect(slides.map((s) => s.nicheSlug), ['food']);
    });

    test('a card with no cover is skipped, because a hero is the photograph', () {
      final slides = heroSlidesFrom([
        _row('niche:weddings', 'Weddings in Lisbon', [_card('nocover', noCover: true), _card('has')]),
      ]);
      expect(slides.single.card.proUserId, 'has');
    });

    test('the slide keeps the niche slug for the page that does not exist yet', () {
      final slides = heroSlidesFrom([
        _row('niche:events_nightlife', 'Events & Nightlife in Porto', [_card('a')]),
      ]);
      expect(slides.single.nicheSlug, 'events_nightlife');
    });
  });

  group('rendering', () {
    Widget wrap(List<HeroSlide> slides, {required bool reduceMotion}) => MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: MaterialApp(
            theme: buildClientTheme(),
            home: Scaffold(body: HeroCarousel(slides: slides, onOpen: (_) {})),
          ),
        );

    testWidgets('renders nothing at all when there are no slides', (tester) async {
      await tester.pumpWidget(wrap(const [], reduceMotion: true));
      await tester.pump();
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('reduced motion leaves the image perfectly still', (tester) async {
      final slides = heroSlidesFrom([
        _row('niche:weddings', 'Weddings in Lisbon', [_card('a')]),
      ]);
      await tester.pumpWidget(wrap(slides, reduceMotion: true));
      await tester.pump();

      // No Transform introduced by the Ken Burns pass. Asserting on the
      // absence of the widget rather than on a zero duration: a zero-length
      // animation still rebuilds every frame to paint the same thing.
      expect(
        find.byKey(kenBurnsTransformKey),
        findsNothing,
        reason: 'the hero is still animating for someone who asked it not to',
      );

      // And still after time passes, which is where a stray timer shows up.
      await tester.pump(const Duration(seconds: 20));
      expect(find.byKey(kenBurnsTransformKey), findsNothing);
    });

    testWidgets('with motion allowed the image is transformed', (tester) async {
      final slides = heroSlidesFrom([
        _row('niche:weddings', 'Weddings in Lisbon', [_card('a')]),
      ]);
      await tester.pumpWidget(wrap(slides, reduceMotion: false));
      await tester.pump();

      expect(
        find.byKey(kenBurnsTransformKey),
        findsWidgets,
        reason: 'the Ken Burns pass never ran, so this test could not fail for the right reason',
      );
      // Leaves the repeating controller running; the widget disposes it.
    });
  });
}
