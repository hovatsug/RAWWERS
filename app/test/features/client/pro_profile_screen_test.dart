import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_reviews_response.dart';
import 'package:rawwers/features/shared/reviews/pro_reviews_controller.dart';
import 'package:rawwers/api/models/client_portfolio_item.dart';
import 'package:rawwers/api/models/client_pro_profile_response.dart';
import 'package:rawwers/api/models/client_profile_niche.dart';
import 'package:rawwers/api/models/client_profile_package.dart';
import 'package:rawwers/api/models/skill_tier.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/pro_profile/availability_controller.dart';
import 'package:rawwers/features/client/pro_profile/pro_profile_controller.dart';
import 'package:rawwers/design/components/r_online_dot.dart';
import 'package:rawwers/features/client/pro_profile/message_button.dart';
import 'package:rawwers/features/client/pro_profile/pro_profile_screen.dart';


/// Renders the real ProProfileScreen against fixture data.
///
/// The portfolio assertions are the point: a profile whose photos silently
/// vanish is the failure this screen exists to avoid, and it is invisible in
/// a test that only checks the name rendered.
const _proId = 'pro-1';

ClientProProfileResponse _profile({
  String? coverUrl = 'https://media.example/cover.jpg',
  List<ClientPortfolioItem>? portfolio,
  List<ClientProfilePackage>? packages,
  List<ClientProfileNiche>? niches,
  bool online = false,
}) =>
    ClientProProfileResponse(
      proUserId: _proId,
      displayName: 'Alex Lens',
      headline: 'Portraits specialist',
      coverUrl: coverUrl,
      bio: 'Twelve years shooting people who hate being photographed.',
      city: 'New York',
      country: 'US',
      styles: const ['editorial', 'natural-light'],
      avgRating: '4.80',
      reviewCount: 12,
      online: online,
      portfolioPhotoCount: 3,
      portfolioVideoCount: 1,
      packages: packages ??
          const [
            ClientProfilePackage(
              id: 'pkg-1',
              nicheSlug: 'portraits',
              title: 'Portrait session',
              description: 'An hour in your neighbourhood.',
              durationMinutes: 90,
              price: '180.00',
              currency: 'EUR',
              includedPhotos: 15,
              entryRate: '180.00',
              minimumPhotos: 15,
              // Not 180 x 15. Portraits decay past the tenth photo, so the
              // server's figure is lower than the multiplication - which is
              // the whole reason this comes from the server.
              startingTotal: '2405.88',
              extraPhotoPrice: '7.00',
              proofsSlaDays: 3,
              finalsSlaDays: 7,
            ),
          ],
      niches: niches ?? const [],
      portfolioPreview: portfolio ??
          const [
            ClientPortfolioItem(mediaAssetId: 'a', kind: 'photo', thumbnailUrl: 'https://media.example/1.jpg'),
            ClientPortfolioItem(mediaAssetId: 'b', kind: 'photo', thumbnailUrl: 'https://media.example/2.jpg'),
            // A Mux video: the backend cannot resolve a poster frame for it
            // yet, so it arrives with a null URL and must not break the grid.
            ClientPortfolioItem(mediaAssetId: 'c', kind: 'video'),
          ],
    );

Widget _wrap(Override override) => ProviderScope(
      overrides: [
        override,
        // The profile's reviews section loads its own list; these tests are
        // about the rest of the profile, so it has nothing to show.
        proReviewsProvider(_proId).overrideWith((ref) async => const ProReviewsResponse(total: 0, items: [])),
        // Likewise the calendar, answered directly: these tests pump once
        // and are about the rest of the profile. The calendar's own
        // behaviour is in availability_calendar_test.dart.
        availabilityTodayProvider.overrideWithValue(DateTime.utc(2030, 6, 12)),
        proAvailabilityProvider(_proId, 'pkg-1', DateTime.utc(2030, 6)).overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: buildClientTheme(),
        home: const ProProfileScreen(proUserId: _proId),
      ),
    );

Override _data(ClientProProfileResponse profile) =>
    proProfileProvider(_proId).overrideWith((ref) async => profile);

void _usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('shows the cover and every portfolio thumbnail', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_data(_profile())));
    await tester.pump();

    final urls = tester
        .widgetList<RNetworkPhoto>(find.byType(RNetworkPhoto))
        .map((photo) => photo.url)
        .toList();

    expect(urls, contains('https://media.example/cover.jpg'));
    expect(urls, contains('https://media.example/1.jpg'));
    expect(urls, contains('https://media.example/2.jpg'));
  });

  testWidgets('says "Online" next to the name only while the photographer is', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_data(_profile(online: true))));
    await tester.pump();
    expect(find.text('Online'), findsOneWidget);
  });

  testWidgets('no "Online" while the photographer is not', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_data(_profile())));
    await tester.pump();
    expect(find.byType(ROnlineDot), findsNothing);
  });

  testWidgets('a client can message the photographer before booking', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_data(_profile())));
    await tester.pump();

    // Asking a question first is how most people decide; the button is there
    // whether or not the photographer's assistant is switched on.
    expect(find.byType(MessageButton), findsOneWidget);
    expect(find.textContaining('Message '), findsOneWidget);
  });

  testWidgets('a video with no poster frame still occupies its grid cell', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_data(_profile())));
    await tester.pump();

    // Three portfolio items plus the cover, one of which has no URL.
    final photos = tester.widgetList<RNetworkPhoto>(find.byType(RNetworkPhoto)).toList();
    expect(photos.length, 4);
    expect(photos.where((photo) => photo.url == null).length, 1);
  });

  testWidgets('shows what a package costs and what it includes', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_data(_profile())));
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Portrait session'), 200);

    // The per-photo rate leads, and the starting total is the server's
    // figure. This test previously asserted a bare "€180.00" - the entry rate
    // rendered as the package price, which is the bug.
    expect(find.textContaining('/photo'), findsOneWidget);
    expect(find.text('minimum 15 photos · from €2405.88'), findsOneWidget);
    expect(find.text('1 hour 30 min · 15 photos included'), findsOneWidget);
    expect(find.text('Proofs in 3 days, finals in 7'), findsOneWidget);
  });

  testWidgets('the per-photo rate is never shown as the package price', (tester) async {
    // The bug, precisely: package.price is the per-photo entry rate, and
    // every client-facing screen rendered it as the price of the package. A
    // real seeded package advertised €243 for work that charges €6,075, above
    // a "Request this package" button.
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_data(_profile())));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Portrait session'), 200);

    expect(
      find.text('€180.00'),
      findsNothing,
      reason: 'the entry rate is rendered bare, with nothing saying it is per photo',
    );
  });

  testWidgets('every figure comes from the server, none multiplied locally', (tester) async {
    // 180.00 x 15 = 2700.00. The server says 2405.88, because portraits decay
    // past the tenth photo. A screen that multiplies would overstate this
    // package by nearly €300 and would look entirely correct on a flat-curve
    // niche like real estate.
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_data(_profile())));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Portrait session'), 200);

    expect(find.textContaining('2405.88'), findsOneWidget);
    expect(find.textContaining('2700'), findsNothing, reason: 'the total was computed locally');
  });

  testWidgets('the curve is stated before anyone requests a booking', (tester) async {
    // Nothing previously told a client the eleventh photo costs less than the
    // first. Discovering that mid-selection is too late to affect the choice
    // of photographer.
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_data(_profile())));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Portrait session'), 200);

    expect(find.textContaining('drops as you choose more'), findsOneWidget);
  });

  testWidgets('a pro with no packages says so instead of showing nothing', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_data(_profile(packages: const []))));
    await tester.pump();

    await tester.scrollUntilVisible(find.textContaining('no packages listed'), 200);
    expect(find.textContaining('no packages listed'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry rather than a blank page', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(
      _wrap(proProfileProvider(_proId).overrideWith((ref) async => throw const NetworkError())),
    );
    await tester.pump();

    expect(find.text('Retry'), findsOneWidget);
  });
  _multiNicheTests();
}

// ---------------------------------------------------------------------------
// A multi-niche portfolio, split by the niche it belongs to.
// ---------------------------------------------------------------------------

const _weddings = ClientProfileNiche(
  slug: 'weddings',
  name: 'Weddings',
  tier: SkillTier.elite,
  photoCount: 2,
  description: 'Long days, shot quietly.',
);

const _portraits = ClientProfileNiche(
  slug: 'portraits',
  name: 'Portraits',
  tier: SkillTier.rookie,
  photoCount: 1,
);

const _mixedPortfolio = [
  ClientPortfolioItem(
    mediaAssetId: 'w1',
    kind: 'photo',
    thumbnailUrl: 'https://media.example/wedding-1.jpg',
    nicheSlugs: ['weddings'],
  ),
  ClientPortfolioItem(
    mediaAssetId: 'w2',
    kind: 'photo',
    thumbnailUrl: 'https://media.example/wedding-2.jpg',
    nicheSlugs: ['weddings'],
  ),
  ClientPortfolioItem(
    mediaAssetId: 'p1',
    kind: 'photo',
    thumbnailUrl: 'https://media.example/portrait-1.jpg',
    nicheSlugs: ['portraits'],
  ),
];

List<String?> _photoUrls(WidgetTester tester) =>
    tester.widgetList<RNetworkPhoto>(find.byType(RNetworkPhoto)).map((p) => p.url).toList();

void _multiNicheTests() {
  testWidgets('choosing a niche shows only that niche\'s photos', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(
      _wrap(_data(_profile(portfolio: _mixedPortfolio, niches: const [_weddings, _portraits]))),
    );
    await tester.pump();

    // Opens on everything, so nothing is hidden behind a control nobody has
    // touched yet.
    expect(_photoUrls(tester), contains('https://media.example/portrait-1.jpg'));
    expect(_photoUrls(tester), contains('https://media.example/wedding-1.jpg'));

    await tester.tap(find.text('Weddings'));
    await tester.pump();

    final urls = _photoUrls(tester);
    expect(urls, contains('https://media.example/wedding-1.jpg'));
    expect(
      urls,
      isNot(contains('https://media.example/portrait-1.jpg')),
      reason: 'the grid still shows work from a niche the client filtered away',
    );
  });

  testWidgets('a single-niche photographer gets no selector at all', (tester) async {
    _usePhoneSurface(tester);
    // The server sends an empty list for a one-niche photographer, which is
    // the signal. A one-option tab bar is clutter on a profile with nothing
    // to choose between.
    await tester.pumpWidget(_wrap(_data(_profile(portfolio: _mixedPortfolio, niches: const []))));
    await tester.pump();

    expect(find.text('All'), findsNothing, reason: 'a one-niche profile was given a niche selector');
    expect(find.text('Weddings'), findsNothing);
  });

  testWidgets('a niche with a description shows it instead of the general bio', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(
      _wrap(_data(_profile(portfolio: _mixedPortfolio, niches: const [_weddings, _portraits]))),
    );
    await tester.pump();

    expect(find.textContaining('Twelve years shooting people'), findsOneWidget);

    await tester.tap(find.text('Weddings'));
    await tester.pump();

    expect(find.text('Long days, shot quietly.'), findsOneWidget);
    expect(find.textContaining('Twelve years shooting people'), findsNothing);
  });

  testWidgets('a niche with no description falls back to the bio, never to nothing', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(
      _wrap(_data(_profile(portfolio: _mixedPortfolio, niches: const [_weddings, _portraits]))),
    );
    await tester.pump();

    await tester.tap(find.text('Portraits'));
    await tester.pump();

    // An empty section under a tab reads as a loading failure.
    expect(
      find.textContaining('Twelve years shooting people'),
      findsOneWidget,
      reason: 'an undescribed niche rendered no description at all',
    );
  });

  testWidgets('the tier shown is the one held in the selected niche', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(
      _wrap(_data(_profile(portfolio: _mixedPortfolio, niches: const [_weddings, _portraits]))),
    );
    await tester.pump();

    // The whole-portfolio view names the niche alongside the tier. A bare
    // tier there would be the flat claim the per-niche model replaces, but
    // showing nothing at all was worse: tier was invisible on every profile.
    expect(find.text('Elite in Weddings'), findsOneWidget);
    expect(find.text('Rookie'), findsNothing);

    await tester.tap(find.text('Weddings'));
    await tester.pump();
    expect(find.text('Elite'), findsOneWidget);

    await tester.tap(find.text('Portraits'));
    await tester.pump();
    expect(find.text('Rookie'), findsOneWidget, reason: 'the tier did not follow the selected niche');
    expect(find.text('Elite'), findsNothing, reason: 'the previous niche\'s tier is still on screen');
  });

  testWidgets('a single-niche photographer still shows their tier, with no selector', (tester) async {
    // The server used to send an empty niche list for these photographers as
    // a signal not to draw a selector, and the tier rides on that list - so
    // 32 of 42 profiles carried no tier at all. The server now always sends
    // it, and the decision not to draw a selector lives here.
    _usePhoneSurface(tester);
    await tester.pumpWidget(
      _wrap(_data(_profile(portfolio: _mixedPortfolio, niches: const [_weddings]))),
    );
    await tester.pump();

    expect(find.text('All'), findsNothing, reason: 'a one-niche profile was given a selector');
    expect(
      find.text('Elite in Weddings'),
      findsOneWidget,
      reason: 'the tier is invisible on a single-niche profile',
    );
  });

  // --- Full screen. ---

  const viewerPortfolio = [
    ClientPortfolioItem(
      mediaAssetId: 'a',
      kind: 'photo',
      thumbnailUrl: 'https://media.example/1.jpg',
      previewUrl: 'https://media.example/1_web.jpg',
      nicheSlugs: ['weddings'],
    ),
    // A video sits in the grid but has nothing to open full screen.
    ClientPortfolioItem(mediaAssetId: 'v', kind: 'video'),
    ClientPortfolioItem(
      mediaAssetId: 'b',
      kind: 'photo',
      thumbnailUrl: 'https://media.example/2.jpg',
      previewUrl: 'https://media.example/2_web.jpg',
      nicheSlugs: ['portraits'],
    ),
    // Still waiting for its web copy: the thumbnail rather than nothing.
    ClientPortfolioItem(mediaAssetId: 'c', kind: 'photo', thumbnailUrl: 'https://media.example/3.jpg'),
  ];
  const viewerNiches = [
    ClientProfileNiche(slug: 'weddings', name: 'Weddings', photoCount: 1, tier: SkillTier.pro),
    ClientProfileNiche(slug: 'portraits', name: 'Portraits', photoCount: 1, tier: SkillTier.pro),
  ];

  Future<void> openAt(WidgetTester tester, String thumbnailUrl) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_data(_profile(portfolio: viewerPortfolio, niches: viewerNiches))));
    await tester.pump();
    final tile = find.byWidgetPredicate((w) => w is RNetworkPhoto && w.url == thumbnailUrl);
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  testWidgets('tapping a portfolio photo opens it full screen, on that photo', (tester) async {
    await openAt(tester, 'https://media.example/2.jpg');

    final viewer = tester.widget<RPhotoViewer>(find.byType(RPhotoViewer));
    expect(viewer.urls, ['https://media.example/1_web.jpg', 'https://media.example/2_web.jpg', 'https://media.example/3.jpg'],
        reason: 'photos only, each on its web copy, the thumbnail only where there is none');
    expect(viewer.initialIndex, 1, reason: 'opened on a different photo from the one tapped');
    expect(find.text('2 of 3'), findsOneWidget);
    expect(viewer.title, 'Alex Lens');
  });

  testWidgets('each photo is captioned with its niche, by the server\'s name for it', (tester) async {
    await openAt(tester, 'https://media.example/1.jpg');
    final viewer = tester.widget<RPhotoViewer>(find.byType(RPhotoViewer));
    expect(viewer.captions, ['Weddings', 'Portraits', '']);
    expect(find.descendant(of: find.byType(RPhotoViewer), matching: find.text('Weddings')), findsOneWidget);
  });

  testWidgets('a video tile opens nothing', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_data(_profile(portfolio: viewerPortfolio, niches: viewerNiches))));
    await tester.pump();
    final video = find.byWidgetPredicate((w) => w is RNetworkPhoto && w.url == null && w.semanticLabel != null);
    await tester.ensureVisible(video);
    await tester.tap(video, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(RPhotoViewer), findsNothing);
  });

  testWidgets('the close button and a swipe down both return to the profile', (tester) async {
    await openAt(tester, 'https://media.example/1.jpg');
    await tester.tap(find.byTooltip('Close photo viewer'));
    await tester.pumpAndSettle();
    expect(find.byType(RPhotoViewer), findsNothing);
    expect(find.byType(ProProfileScreen), findsOneWidget);

    final tile = find.byWidgetPredicate((w) => w is RNetworkPhoto && w.url == 'https://media.example/1.jpg');
    await tester.tap(tile);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.byType(RPhotoViewer), findsNothing);
  });
}
