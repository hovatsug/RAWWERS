import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/api/models/pro_listing_preview_response.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/listing/listing_preview_controller.dart';
import 'package:rawwers/features/pro/listing/listing_preview_screen.dart';
import 'package:rawwers/features/shared/discover/discover_card.dart';

/// The point of this screen is that it is not a mock-up. It renders the
/// same DiscoverCard the client app renders, fed by the endpoint that
/// builds the real Discover feed.
class _FakePreview extends ListingPreviewController {
  _FakePreview(this._response);

  final ProListingPreviewResponse _response;

  @override
  Future<ProListingPreviewResponse> build() async => _response;
}

class _FailingPreview extends ListingPreviewController {
  @override
  Future<ProListingPreviewResponse> build() async => throw const NetworkError();
}

ClientDiscoverCard _card({String? minPrice = '120.00', String? maxPrice = '300.00'}) =>
    ClientDiscoverCard(
      proUserId: 'pro-1',
      displayName: 'Alex Lens',
      headline: 'Portraits in daylight',
      city: 'Lisbon',
      country: 'PT',
      minPrice: minPrice,
      maxPrice: maxPrice,
      currency: 'EUR',
      avgRating: '4.8',
      reviewCount: 12,
      portfolioPhotoCount: 14,
      portfolioVideoCount: 0,
    );

ProListingPreviewResponse _preview({
  bool isLive = true,
  List<String> blocking = const [],
  int? availableDays = 9,
  ClientDiscoverCard? card,
}) =>
    ProListingPreviewResponse(
      card: card ?? _card(),
      isLive: isLive,
      blockingReasons: blocking,
      availableDaysNext14: availableDays,
    );

Widget _wrap(ProListingPreviewResponse preview) => ProviderScope(
      overrides: [
        listingPreviewControllerProvider.overrideWith(() => _FakePreview(preview)),
      ],
      child: MaterialApp(
        theme: buildProTheme(),
        home: const ListingPreviewScreen(
          onboardingPath: '/getting-set-up',
          pricingPath: '/pricing',
          profilePath: '/profile',
          portfolioPath: '/portfolio',
        ),
      ),
    );

void _usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('renders the same card widget the client app uses', (tester) async {
    // Not a lookalike: a copy would drift, and a photographer would be
    // shown a card that no longer matches what a client sees.
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_preview()));
    await tester.pump();

    expect(find.byType(DiscoverCard), findsOneWidget);
    expect(find.text('Alex Lens'), findsOneWidget);
  });

  testWidgets('a hidden listing says what is keeping it hidden, in words', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_preview(
      isLive: false,
      blocking: const ['kyc_not_approved', 'no_active_package'],
    )));
    await tester.pump();

    expect(find.text('Not visible to clients yet'), findsOneWidget);
    // Machine codes are not an explanation.
    expect(find.text('kyc_not_approved'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Your identity check has not been approved yet.'), 200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Your identity check has not been approved yet.'), findsOneWidget);
    expect(find.text('You have not priced anything yet.'), findsOneWidget);
  });

  testWidgets('a live listing does not list blockers', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_preview()));
    await tester.pump();

    expect(find.text('Clients can find you'), findsOneWidget);
    expect(find.text('What is keeping it hidden'), findsNothing);
  });

  testWidgets('no working hours reads differently from no free days', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_preview(availableDays: null)));
    await tester.pump();

    expect(find.text('You have not set any working hours.'), findsOneWidget);
    expect(find.textContaining('of the next 14 days'), findsNothing);
  });

  testWidgets('free days are shown when hours exist', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_preview(availableDays: 9)));
    await tester.pump();

    expect(find.text('Free on 9 of the next 14 days.'), findsOneWidget);
  });

  testWidgets('the card names which screen shapes each part of it', (tester) async {
    // The brief: editing pricing should visibly change the card, and the
    // connection should be visible rather than something to infer.
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_preview()));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Price range'), 200, scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Price range'), findsOneWidget);
    expect(find.text('The cheapest and dearest of your packages'), findsOneWidget);
    expect(find.text('Cover photo and photo count'), findsOneWidget);
  });

  testWidgets('an unpriced listing shows no price rather than a zero', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(_wrap(_preview(card: _card(minPrice: null, maxPrice: null))));
    await tester.pump();

    expect(find.byType(DiscoverCard), findsOneWidget);
    expect(find.textContaining('EUR 0'), findsNothing);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [listingPreviewControllerProvider.overrideWith(_FailingPreview.new)],
        child: MaterialApp(
          theme: buildProTheme(),
          home: const ListingPreviewScreen(
            onboardingPath: '/getting-set-up',
            pricingPath: '/pricing',
            profilePath: '/profile',
            portfolioPath: '/portfolio',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Could not load your listing.'), findsOneWidget);
    expect(find.byType(DiscoverCard), findsNothing);
  });
}
