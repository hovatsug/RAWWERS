// Marketing-use consent, the client's side (closed beta).
//
// After the rating, an optional card, separate from the booking and the
// review: "Let RAWWERS feature your photos? Earn RAW credit." The client picks
// photos one by one (none ticked), a term (12 months unless changed), and
// confirms the people shown are adults who agree or that they are the parent
// or guardian (unticked). Account > Marketing permissions lists every photo
// given, with its end date, a Withdraw for each and for all, and Renew for
// one ending within 30 days.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/api_client/marketing_consent_client.dart';
import 'package:rawwers/api/models/marketing_consent_offer_response.dart';
import 'package:rawwers/api/models/marketing_consent_view.dart';
import 'package:rawwers/api/models/marketing_photo_view.dart';
import 'package:rawwers/api/models/marketing_term_view.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/account/account_screen.dart';
import 'package:rawwers/features/client/marketing/marketing_consent_controllers.dart';
import 'package:rawwers/features/client/marketing/marketing_offer.dart';
import 'package:rawwers/features/client/marketing/marketing_permissions_screen.dart';

import '../../support/fake_http_client_adapter.dart';

const _offer = MarketingConsentOfferResponse(
  offered: true,
  wordingVersion: 'client-draft-1',
  wordingText: 'DRAFT wording shown to the client.',
  terms: [
    MarketingTermView(months: 6, credit: 50, creditEur: '0.50'),
    MarketingTermView(months: 12, credit: 100, creditEur: '1.00'),
    MarketingTermView(months: 24, credit: 150, creditEur: '1.50'),
  ],
  photographerCredit: 'Alex Lens',
  photos: [
    MarketingPhotoView(mediaAssetId: 'a1'),
    MarketingPhotoView(mediaAssetId: 'a2'),
    MarketingPhotoView(mediaAssetId: 'a3'),
  ],
);

class _FakeOffer extends MarketingOfferController {
  _FakeOffer(this.offer, {this.problem, this.creditEur = '1.00'});
  final MarketingConsentOfferResponse offer;
  final String? problem;
  final String creditEur;
  final grants = <({List<String> assetIds, int termMonths, bool peopleConfirmed})>[];

  @override
  Future<MarketingConsentOfferResponse> build(String gigId) async => offer;

  @override
  Future<GrantOutcome> grant({required List<String> assetIds, required int termMonths, required bool peopleConfirmed}) async {
    grants.add((assetIds: assetIds, termMonths: termMonths, peopleConfirmed: peopleConfirmed));
    return (problem: problem, creditEur: problem == null ? creditEur : '0.00');
  }
}

Future<void> _pumpCard(WidgetTester tester, _FakeOffer fake) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [marketingOfferControllerProvider('gig-1').overrideWith(() => fake)],
      child: MaterialApp(theme: buildClientTheme(), home: const Scaffold(body: MarketingOfferCard(gigId: 'gig-1'))),
    ),
  );
  await tester.pumpAndSettle();
}

RButton _allow(WidgetTester tester) => tester.widget<RButton>(find.byType(RButton).last);

MarketingConsentView _consent(String id, {String status = 'active', required DateTime endsAt}) => MarketingConsentView(
      id: id,
      gigId: 'gig-1',
      mediaAssetId: 'asset-$id',
      photographerCredit: 'Alex Lens',
      scope: 'rawwers_organic',
      termMonths: 12,
      grantedAt: DateTime.utc(2026, 11, 2),
      endsAt: endsAt,
      status: status,
      withdrawnAt: status == 'withdrawn' ? DateTime.utc(2026, 11, 3) : null,
    );

class _FakeMine extends MyMarketingConsentsController {
  _FakeMine(this.items);
  final List<MarketingConsentView> items;
  final withdrawn = <List<String>?>[];
  final renewed = <List<String>>[];

  @override
  Future<List<MarketingConsentView>> build() async => items;

  @override
  Future<String?> withdraw(List<String>? consentIds) async {
    withdrawn.add(consentIds);
    return null;
  }

  @override
  Future<String?> renew(List<String> consentIds, {int termMonths = 12}) async {
    renewed.add(consentIds);
    return null;
  }
}

void main() {
  group('the card after the rating', () {
    testWidgets('not shown unless the server offers it', (tester) async {
      await _pumpCard(tester, _FakeOffer(const MarketingConsentOfferResponse(offered: false, reason: 'photographer_not_opted_in')));
      expect(find.textContaining('Let RAWWERS feature your photos'), findsNothing);
    });

    testWidgets('offered: optional, credited to the photographer, with the credit', (tester) async {
      await _pumpCard(tester, _FakeOffer(_offer));
      expect(find.text('Let RAWWERS feature your photos? Earn credit.'), findsOneWidget);
      expect(find.textContaining('Optional'), findsOneWidget);
      expect(find.textContaining('up to €1.00 credit'), findsOneWidget);
      expect(find.textContaining(RegExp(r'\bRAWW?\b')), findsNothing, reason: 'client credit is never called RAW or RAWW');
      expect(find.textContaining('Credited to Alex Lens'), findsOneWidget);
    });

    testWidgets('when this month\'s budget is used up it says so before anything is chosen', (tester) async {
      await _pumpCard(tester, _FakeOffer(_offer.copyWith(creditAvailable: false, creditUnavailableReason: 'budget')));
      expect(find.text('Let RAWWERS feature your photos?'), findsOneWidget);
      expect(find.text('No credit is available this month. You can still give permission.'), findsOneWidget);
      expect(find.textContaining('up to'), findsNothing);
    });

    testWidgets('and the monthly limit is said plainly too', (tester) async {
      await _pumpCard(tester, _FakeOffer(_offer.copyWith(creditAvailable: false, creditUnavailableReason: 'monthly_cap')));
      expect(find.textContaining('3 permissions this month'), findsOneWidget);
    });

    testWidgets('nothing is chosen until the client chooses, and the confirmation is required', (tester) async {
      final fake = _FakeOffer(_offer);
      await _pumpCard(tester, fake);
      await tester.tap(find.text('Choose photos'));
      await tester.pumpAndSettle();

      expect(find.text('DRAFT wording shown to the client.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing, reason: 'no photo ticked by default');
      expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value, isFalse);
      expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '12 months · €1.00')).selected, isTrue);
      expect(_allow(tester).onPressed, isNull);

      await tester.tap(find.byKey(const ValueKey('marketing-photo-a2')));
      await tester.pump();
      expect(_allow(tester).onPressed, isNull, reason: 'not yet confirmed');

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(_allow(tester).onPressed, isNotNull);
    });

    testWidgets('sends the photos, the term and the confirmation, and says what was earned', (tester) async {
      final fake = _FakeOffer(_offer, creditEur: '1.50');
      await _pumpCard(tester, fake);
      await tester.tap(find.text('Choose photos'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('marketing-photo-a1')));
      await tester.tap(find.byKey(const ValueKey('marketing-photo-a3')));
      await tester.tap(find.widgetWithText(ChoiceChip, '24 months · €1.50'));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.widgetWithText(RButton, 'Allow 2 photos'));
      await tester.pumpAndSettle();

      expect(fake.grants.single.assetIds.toSet(), {'a1', 'a3'});
      expect((fake.grants.single.termMonths, fake.grants.single.peopleConfirmed), (24, true));
      expect(find.text('Thank you. €1.50 credit added.'), findsOneWidget);
    });

    testWidgets('after credit is earned, "See my credit" opens it', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final router = GoRouter(routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold(body: MarketingOfferCard(gigId: 'gig-1', creditPath: '/credit'))),
        GoRoute(path: '/credit', builder: (_, _) => const Scaffold(body: Text('My credit page'))),
      ]);
      await tester.pumpWidget(ProviderScope(
        overrides: [marketingOfferControllerProvider('gig-1').overrideWith(() => _FakeOffer(_offer))],
        child: MaterialApp.router(theme: buildClientTheme(), routerConfig: router),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose photos'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('marketing-photo-a1')));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.widgetWithText(RButton, 'Allow 1 photo'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('See my credit'));
      await tester.pumpAndSettle();
      expect(find.text('My credit page'), findsOneWidget);
    });

    testWidgets('a refusal is shown in the form', (tester) async {
      await _pumpCard(tester, _FakeOffer(_offer, problem: 'Choose from your own photos of this booking that are not already shared'));
      await tester.tap(find.text('Choose photos'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('marketing-photo-a1')));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.widgetWithText(RButton, 'Allow 1 photo'));
      await tester.pumpAndSettle();

      expect(find.text('Choose from your own photos of this booking that are not already shared'), findsOneWidget);
    });
  });

  group('Account > Marketing permissions', () {
    final today = DateTime.utc(2026, 11, 2);

    Future<_FakeMine> pumpScreen(WidgetTester tester, List<MarketingConsentView> items) async {
      final fake = _FakeMine(items);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [myMarketingConsentsControllerProvider.overrideWith(() => fake)],
          child: MaterialApp(theme: buildClientTheme(), home: MarketingPermissionsScreen(now: () => today)),
        ),
      );
      await tester.pumpAndSettle();
      return fake;
    }

    testWidgets('each photo with its end date, withdrawn ones without buttons', (tester) async {
      await pumpScreen(tester, [
        _consent('c1', endsAt: DateTime.utc(2027, 11, 2)),
        _consent('c2', status: 'withdrawn', endsAt: DateTime.utc(2027, 11, 2)),
      ]);
      expect(find.textContaining('Until'), findsOneWidget);
      expect(find.textContaining('Withdrawn'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Withdraw'), findsOneWidget);
      expect(find.text('Photo by Alex Lens'), findsNWidgets(2));
    });

    testWidgets('withdraw one, or all', (tester) async {
      final fake = await pumpScreen(tester, [
        _consent('c1', endsAt: DateTime.utc(2027, 11, 2)),
        _consent('c2', endsAt: DateTime.utc(2027, 11, 2)),
      ]);

      await tester.tap(find.widgetWithText(TextButton, 'Withdraw').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(RButton, 'Withdraw all'));
      await tester.pumpAndSettle();

      expect(fake.withdrawn, [['c1'], null]);
    });

    testWidgets('renew is offered only within 30 days of the end', (tester) async {
      final fake = await pumpScreen(tester, [
        _consent('soon', endsAt: today.add(const Duration(days: 20))),
        _consent('later', endsAt: today.add(const Duration(days: 200))),
      ]);
      expect(find.widgetWithText(TextButton, 'Renew'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Renew'));
      await tester.pumpAndSettle();

      expect(fake.renewed, [['soon']]);
    });
  });

  testWidgets('Account links to Marketing permissions', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const AccountScreen(verifyEmailPath: '/v', marketingPermissionsPath: '/m')),
      GoRoute(path: '/m', builder: (_, _) => const Text('permissions page')),
      GoRoute(path: '/v', builder: (_, _) => const Text('verify')),
    ]);
    await tester.pumpWidget(ProviderScope(child: MaterialApp.router(theme: buildClientTheme(), routerConfig: router)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Marketing permissions'));
    await tester.pumpAndSettle();

    expect(find.text('permissions page'), findsOneWidget);
  });

  group('the controllers, against a fake server', () {
    (ProviderContainer, List<(String, Map<String, dynamic>)>) container() {
      final sent = <(String, Map<String, dynamic>)>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
        ..httpClientAdapter = FakeHttpClientAdapter((o) async {
          if (o.method == 'POST') sent.add((o.uri.path, Map<String, dynamic>.from(jsonDecode(jsonEncode(o.data)) as Map)));
          if (o.uri.path.endsWith('/withdraw')) return jsonResponseBody(jsonEncode({'withdrawn': 1}), 200);
          if (o.uri.path.endsWith('/marketing-consent')) return jsonResponseBody(jsonEncode({'items': [], 'credit': 100, 'credit_eur': '1.00'}), 200);
          if (o.uri.path.endsWith('/offer')) return jsonResponseBody(jsonEncode({'offered': false}), 200);
          return jsonResponseBody(jsonEncode({'items': []}), 200);
        });
      final c = ProviderContainer(overrides: [marketingConsentClientProvider.overrideWithValue(MarketingConsentClient(dio))]);
      addTearDown(c.dispose);
      return (c, sent);
    }

    test('a grant sends the photos, the term and the confirmation', () async {
      final (c, sent) = container();
      final outcome = await c
          .read(marketingOfferControllerProvider('gig-1').notifier)
          .grant(assetIds: ['a1', 'a2'], termMonths: 6, peopleConfirmed: true);

      expect(outcome, (problem: null, creditEur: '1.00'));
      expect(sent.single.$1, '/v1/gigs/gig-1/marketing-consent');
      expect(sent.single.$2, {'media_asset_ids': ['a1', 'a2'], 'term_months': 6, 'people_confirmed': true});
    });

    test('withdraw all says all; withdraw one names it; renew names them', () async {
      final (c, sent) = container();
      final mine = c.read(myMarketingConsentsControllerProvider.notifier);

      await mine.withdraw(null);
      await mine.withdraw(['c1']);
      await mine.renew(['c2'], termMonths: 24);

      expect(sent[0].$2['all'], isTrue);
      expect(sent[1].$2['all'], isFalse);
      expect(sent[1].$2['consent_ids'], ['c1']);
      expect(sent[2].$1, '/v1/me/marketing-consents/renew');
      expect(sent[2].$2, {'consent_ids': ['c2'], 'term_months': 24});
    });
  });
}
