// "Available now" on the photographer's side: the dashboard card and the
// per-package short-notice switch in Pricing.
//
// The card never shows a toggle that books nothing: switching on with no
// package that may be booked at short notice asks which should, saves them,
// then switches on. Every package write sends the whole package - the update
// route refuses one without its niche, and a write that dropped the price
// would be refused or, worse, change it.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/available_now_client.dart';
import 'package:rawwers/api/api_client/pro_onboarding_client.dart';
import 'package:rawwers/api/models/me_response.dart';
import 'package:rawwers/api/models/pro_package_view.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/available_now/available_now_card.dart';
import 'package:rawwers/features/pro/pricing/pricing_screen.dart';

import '../../support/fake_http_client_adapter.dart';

const _me = 'pro-me';

class _SignedIn extends AuthController {
  @override
  Future<AuthState> build() async => const AuthAuthenticated(MeResponse(userId: _me, status: 'active'));
}

class _Backend {
  _Backend({bool shortNoticeOk = false})
      : packages = [
          ProPackageView(
            id: 'pkg-1',
            proUserId: _me,
            nicheId: 'niche-portraits',
            title: 'Mini session',
            durationMinutes: 60,
            price: '12.00',
            currency: 'EUR',
            includedPhotos: 10,
            extraPhotoPrice: '8.00',
            proofsSlaDays: 3,
            finalsSlaDays: 7,
            addons: const [],
            isActive: true,
            shortNoticeOk: shortNoticeOk,
          ).toJson(),
        ];

  final List<Map<String, dynamic>> packages;
  final packageWrites = <Map<String, dynamic>>[];
  final toggles = <Map<String, dynamic>>[];
  bool switchedOn = false;

  /// How many of the next loads fail, as a dropped connection or a 500 would.
  int failLoads = 0;
  int loads = 0;
  int prepMinutes = 120;

  Map<String, dynamic> _view() => {
        'switched_on': switchedOn,
        'available_until': switchedOn ? '2026-10-13T18:00:00Z' : null,
        'effective': switchedOn,
        'prep_minutes': prepMinutes,
        'prep_options_minutes': [90, 120, 180, 240, 360],
        'eligible_package_ids': [
          for (final p in packages)
            if (p['short_notice_ok'] == true) p['id'],
        ],
        'lasts_hours': 4,
      };

  Map<String, dynamic> _body(RequestOptions o) =>
      (o.data is String ? jsonDecode(o.data as String) : o.data) as Map<String, dynamic>;

  Future<ResponseBody> handle(RequestOptions o) async {
    final path = o.uri.path;
    if (path == '/v1/pro/available-now' && o.method == 'GET') {
      loads++;
      if (failLoads > 0) {
        failLoads--;
        return jsonResponseBody('{"error":{"code":"internal_error","message":"boom"}}', 500);
      }
      return jsonResponseBody(jsonEncode(_view()), 200);
    }
    if (path == '/v1/pro/available-now' && o.method == 'PUT') {
      final body = _body(o);
      toggles.add(body);
      if (body['switched_on'] == true && (_view()['eligible_package_ids'] as List).isEmpty) {
        return jsonResponseBody(
          jsonEncode({'error': {'code': 'no_short_notice_packages', 'message': 'Choose at least one package first.'}}),
          409,
        );
      }
      switchedOn = body['switched_on'] as bool;
      if (body['prep_minutes'] case final int minutes) prepMinutes = minutes;
      return jsonResponseBody(jsonEncode(_view()), 200);
    }
    if (path == '/v1/pro/$_me/packages' && o.method == 'GET') {
      return jsonResponseBody(jsonEncode(packages), 200);
    }
    final put = RegExp(r'^/v1/pro/me/packages/([^/]+)$').firstMatch(path);
    if (put != null && o.method == 'PUT') {
      final body = _body(o);
      packageWrites.add(body);
      // The real route's own refusal: no niche, no update.
      if (body['niche_id'] == null && body['niche_slug'] == null) {
        return jsonResponseBody(
          jsonEncode({'error': {'code': 'validation_error', 'message': 'niche_id or niche_slug is required'}}),
          400,
        );
      }
      final package = packages.firstWhere((p) => p['id'] == put.group(1));
      body.forEach((k, v) {
        if (v != null) package[k] = v;
      });
      return jsonResponseBody(jsonEncode(package), 200);
    }
    return jsonResponseBody('{"error":{"code":"not_found","message":"no route in fake"}}', 404);
  }
}

Future<void> _pump(WidgetTester tester, _Backend backend, Widget home) async {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))..httpClientAdapter = FakeHttpClientAdapter(backend.handle);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_SignedIn.new),
        availableNowClientProvider.overrideWithValue(AvailableNowClient(dio)),
        proOnboardingClientProvider.overrideWithValue(ProOnboardingClient(dio)),
      ],
      child: MaterialApp(theme: buildProTheme(), home: Scaffold(body: SingleChildScrollView(child: home))),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('switching on with no short-notice package asks which, saves the whole package, then switches on',
      (tester) async {
    final backend = _Backend();
    await _pump(tester, backend, const AvailableNowCard());

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Which packages can be booked at short notice?'), findsOneWidget);
    await tester.tap(find.text('Mini session'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save and switch on'));
    await tester.pumpAndSettle();

    final [write] = backend.packageWrites;
    expect(write['short_notice_ok'], isTrue);
    expect(write['niche_id'], 'niche-portraits');
    expect(write['price'], '12.00', reason: 'the price is sent as it is, never dropped');
    expect(backend.toggles.map((t) => t['switched_on']), [true, true], reason: 'refused once, then switched on');
    expect(backend.switchedOn, isTrue);
    expect(find.textContaining(listedOnlyWhileOpen), findsOneWidget);
  });

  testWidgets('choosing nothing leaves it off and sends nothing', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend, const AvailableNowCard());

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    // The button stays disabled with nothing chosen; dismiss the sheet.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(backend.packageWrites, isEmpty);
    expect(backend.toggles, hasLength(1));
    expect(backend.switchedOn, isFalse);
    expect(find.textContaining(listedOnlyWhileOpen), findsNothing);
  });

  testWidgets('with a short-notice package it switches straight on and says it lasts only while the app is open',
      (tester) async {
    final backend = _Backend(shortNoticeOk: true);
    await _pump(tester, backend, const AvailableNowCard());
    expect(find.textContaining(listedOnlyWhileOpen), findsNothing);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Which packages can be booked at short notice?'), findsNothing);
    expect(backend.toggles, [
      {'switched_on': true, 'prep_minutes': null},
    ]);
    expect(find.textContaining(listedOnlyWhileOpen), findsOneWidget);
  });

  testWidgets('the package switch in Pricing sends the whole package with the new flag', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend, const SizedBox(height: 2000, child: PricingScreen()));

    await tester.tap(find.widgetWithText(SwitchListTile, 'Can be booked at short notice'));
    await tester.pumpAndSettle();

    final [write] = backend.packageWrites;
    expect(write['short_notice_ok'], isTrue);
    expect(write['niche_id'], 'niche-portraits');
    expect(write['price'], '12.00');
    expect(write['title'], 'Mini session');
  });

  test('preparation times read as hours', () {
    expect([90, 120, 180, 240, 360].map(prepLabel), ['1.5 hours', '2 hours', '3 hours', '4 hours', '6 hours']);
    expect(prepLabel(60), '1 hour');
  });

  testWidgets('the preparation choices are the server\'s, and choosing one sends its minutes', (tester) async {
    final backend = _Backend(shortNoticeOk: true);
    await _pump(tester, backend, const AvailableNowCard());

    await tester.tap(find.text('2 hours'));
    await tester.pumpAndSettle();
    for (final label in ['1.5 hours', '3 hours', '4 hours', '6 hours']) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    await tester.tap(find.text('1.5 hours').last);
    await tester.pumpAndSettle();

    expect(backend.toggles.last['prep_minutes'], 90);
    expect(find.text('1.5 hours'), findsOneWidget, reason: 'the card shows what the server now holds');
  });

  // --- A load that fails is shown, never a card that silently disappears. ---

  testWidgets('a load error shows a visible retry state, not nothing', (tester) async {
    final backend = _Backend()..failLoads = 1;
    await _pump(tester, backend, const AvailableNowCard());

    expect(find.text('Available now'), findsOneWidget, reason: 'the card must say what failed to load');
    expect(find.textContaining('Could not load'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.getSize(find.byType(AvailableNowCard)).height, greaterThan(0), reason: 'the card vanished');
  });

  testWidgets('retry loads it again, and the switch comes back', (tester) async {
    final backend = _Backend()..failLoads = 1;
    await _pump(tester, backend, const AvailableNowCard());
    expect(find.byType(SwitchListTile), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(backend.loads, 2);
    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });
}
