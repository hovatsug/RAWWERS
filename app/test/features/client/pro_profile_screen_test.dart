import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/client_portfolio_item.dart';
import 'package:rawwers/api/models/client_pro_profile_response.dart';
import 'package:rawwers/api/models/client_profile_package.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/pro_profile/pro_profile_controller.dart';
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
      overrides: [override],
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
}
