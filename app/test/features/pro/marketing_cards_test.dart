// The photographer's marketing-consent controls: the account clause in
// Settings, and each booking's "Allow marketing use" and "Includes children"
// on the delivery screen. Both booking switches are fixed once the client
// has given permission; "Allow" waits for the account opt-in.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/marketing_consent_client.dart';
import 'package:rawwers/api/models/booking_marketing_settings_view.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/marketing/marketing_cards.dart';
import 'package:rawwers/features/pro/marketing/marketing_controllers.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/fake_marketing.dart';

Future<void> _pump(WidgetTester tester, Widget child, List<Override> overrides) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: buildProTheme(), home: Scaffold(body: SingleChildScrollView(child: child))),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('the account clause', () {
    testWidgets('off until turned on, then recorded with its date', (tester) async {
      final fake = FakeMarketingAgreement();
      await _pump(tester, const MarketingAgreementCard(), [marketingAgreementControllerProvider.overrideWith(() => fake)]);
      expect(find.text('Off: your clients are not asked.'), findsOneWidget);
      expect(find.text('DRAFT clause'), findsOneWidget);

      await tester.tap(find.text('Let RAWWERS feature my work'));
      await tester.pumpAndSettle();

      expect(fake.sets, [true]);
      expect(find.textContaining('always credited to you'), findsOneWidget);
      expect(find.textContaining('Last changed'), findsOneWidget);
    });
  });

  group("a booking's switches", () {
    Future<FakeBookingMarketing> pumpBooking(WidgetTester tester, BookingMarketingSettingsView value) async {
      final fake = FakeBookingMarketing(value);
      await _pump(tester, const BookingMarketingCard(gigId: 'gig-1'), [bookingMarketingControllerProvider('gig-1').overrideWith(() => fake)]);
      return fake;
    }

    testWidgets('the photographer turns a booking off, or flags children', (tester) async {
      final fake = await pumpBooking(
        tester,
        const BookingMarketingSettingsView(allowMarketing: true, includesChildren: false, locked: false, optedIn: true),
      );

      await tester.tap(find.text('Allow marketing use'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Includes children'));
      await tester.pumpAndSettle();

      expect(fake.sets, [
        (allowMarketing: false, includesChildren: null),
        (allowMarketing: null, includesChildren: true),
      ]);
    });

    testWidgets('fixed once the client has given permission', (tester) async {
      final fake = await pumpBooking(
        tester,
        const BookingMarketingSettingsView(allowMarketing: true, includesChildren: false, locked: true, optedIn: true),
      );
      expect(find.textContaining('The client has given permission'), findsOneWidget);

      await tester.tap(find.text('Allow marketing use'));
      await tester.tap(find.text('Includes children'));
      await tester.pumpAndSettle();

      expect(fake.sets, isEmpty);
    });

    testWidgets('"Allow" waits for the account opt-in; children can still be flagged', (tester) async {
      final fake = await pumpBooking(
        tester,
        const BookingMarketingSettingsView(allowMarketing: false, includesChildren: false, locked: false, optedIn: false),
      );
      expect(find.textContaining('in Settings for clients to be asked'), findsOneWidget);

      await tester.tap(find.text('Allow marketing use'));
      await tester.tap(find.text('Includes children'));
      await tester.pumpAndSettle();

      expect(fake.sets, [(allowMarketing: null, includesChildren: true)]);
    });
  });

  group('the controllers, against a fake server', () {
    (ProviderContainer, List<Map<String, dynamic>>) container({int status = 200}) {
      final sent = <Map<String, dynamic>>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
        ..httpClientAdapter = FakeHttpClientAdapter((o) async {
          if (o.method == 'PUT') sent.add(Map<String, dynamic>.from(jsonDecode(jsonEncode(o.data)) as Map));
          if (o.method == 'PUT' && status != 200) {
            return jsonResponseBody(
              jsonEncode({'error': {'code': 'invalid_state', 'message': 'The client has already given permission for this booking, so these can no longer change.'}}),
              status,
            );
          }
          if (o.uri.path.endsWith('/marketing-agreement')) {
            return jsonResponseBody(
              jsonEncode({'opted_in': o.method == 'PUT' && sent.last['opted_in'] == true, 'wording_version': 'photographer-draft-1', 'wording_text': 'DRAFT clause', 'recorded_at': null}),
              200,
            );
          }
          return jsonResponseBody(jsonEncode({'allow_marketing': true, 'includes_children': false, 'locked': false, 'opted_in': true}), 200);
        });
      final c = ProviderContainer(overrides: [marketingConsentClientProvider.overrideWithValue(MarketingConsentClient(dio))]);
      addTearDown(c.dispose);
      return (c, sent);
    }

    test('the opt-in is sent and the answer kept', () async {
      final (c, sent) = container();
      c.listen(marketingAgreementControllerProvider, (_, _) {});
      await c.read(marketingAgreementControllerProvider.future);

      expect(await c.read(marketingAgreementControllerProvider.notifier).set(true), isNull);

      expect(sent.single, {'opted_in': true});
      expect(c.read(marketingAgreementControllerProvider).value!.optedIn, isTrue);
    });

    test('only the switch changed is sent', () async {
      final (c, sent) = container();
      c.listen(bookingMarketingControllerProvider('gig-1'), (_, _) {});
      await c.read(bookingMarketingControllerProvider('gig-1').future);

      await c.read(bookingMarketingControllerProvider('gig-1').notifier).set(includesChildren: true);

      expect(sent.single['includes_children'], isTrue);
      expect(sent.single['allow_marketing'], isNull);
    });

    test('a locked booking says why', () async {
      final (c, _) = container(status: 409);
      c.listen(bookingMarketingControllerProvider('gig-1'), (_, _) {});
      await c.read(bookingMarketingControllerProvider('gig-1').future);

      final problem = await c.read(bookingMarketingControllerProvider('gig-1').notifier).set(allowMarketing: false);

      expect(problem, contains('already given permission'));
    });
  });
}
