// Confirming a selection: the button that used to do nothing.
//
// These run the real controller against a fake backend and a fake payment
// sheet, so what is asserted is what would actually go over the wire and what
// would actually be handed to Stripe - not that a widget rendered. The
// selection screen's own tests fake the whole controller, which is why none of
// them ever noticed that Continue was `() {}`.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/api_client/proof_galleries_client.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/payments/payment_sheet_launcher.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/gallery/selection_controller.dart';
import 'package:rawwers/features/client/gallery/selection_gallery_screen.dart';

import '../../support/fake_http_client_adapter.dart';

/// Records what it was asked to open, and answers from a script.
class _FakeLauncher implements PaymentSheetLauncher {
  _FakeLauncher(this._results);

  final List<PaymentSheetResult> _results;
  final List<String> presented = [];

  @override
  bool get isConfigured => true;

  @override
  Future<PaymentSheetResult> present(String clientSecret) async {
    presented.add(clientSecret);
    return _results.removeAt(0);
  }
}

/// A backend that prices ten photos or more at [amountDue] and records every
/// mutation it is asked to make, in order.
class _FakeBackend {
  _FakeBackend({this.amountDue = '0.00', List<int> submitStatuses = const [200], List<int> saveStatuses = const [200]})
      : _submitStatuses = List.of(submitStatuses),
        _saveStatuses = List.of(saveStatuses);

  final String amountDue;
  final List<int> _submitStatuses;
  final List<int> _saveStatuses;

  /// "POST /v1/proof-galleries/g1/selections", in the order they arrived.
  /// Reads (the gallery, the quote) are deliberately not recorded: the
  /// question is what the screen changed, not what it looked at.
  final List<String> writes = [];

  int get saves => writes.where((w) => w.endsWith('/selections')).length;
  int get submits => writes.where((w) => w.endsWith('/selections/submit')).length;

  bool get owes => amountDue != '0.00';

  Future<ResponseBody> handle(RequestOptions options) async {
    final path = options.path;
    if (options.method == 'GET' && path == '/v1/proof-galleries/g1') return _ok(_gallery());
    if (options.method == 'GET' && path.endsWith('/selection-quote')) {
      final count = int.parse('${options.queryParameters['selected_count']}');
      return _ok(_quote(count));
    }

    writes.add('${options.method} $path');
    if (path.endsWith('/selections/submit')) {
      final status = _next(_submitStatuses);
      if (status != 200) return _error(status);
      return _ok(_submitted());
    }
    if (path.endsWith('/selections')) {
      final status = _next(_saveStatuses);
      if (status != 200) return _error(status);
      return _ok({'selection_id': 'sel-1', 'version': 1, 'status': 'draft', 'selected_count': 10});
    }
    return jsonResponseBody('{}', 404);
  }

  int _next(List<int> statuses) => statuses.length > 1 ? statuses.removeAt(0) : statuses.first;

  ResponseBody _ok(Map<String, dynamic> body) => jsonResponseBody(jsonEncode(body), 200);

  ResponseBody _error(int status) => jsonResponseBody(
        jsonEncode({
          'error': {'code': 'invalid_state', 'message': 'No draft selection to submit'},
        }),
        status,
      );

  Map<String, dynamic> _gallery() => {
        'gallery': {
          'id': 'g1',
          'gig_id': 'gig-1',
          'pro_user_id': 'pro-1',
          'client_user_id': 'client-1',
          'included_photos': 10,
          'extra_photo_price': '10.00',
          'currency': 'EUR',
          'status': 'published',
          'created_at': '2026-09-12T10:00:00Z',
          'updated_at': '2026-09-12T10:00:00Z',
        },
        'items': [
          for (var i = 0; i < 12; i++)
            {
              'media_asset_id': 'asset-$i',
              'sort_order': i + 1,
              'thumbnail_url': 'https://example.test/$i-thumb.jpg',
              'watermark_preview_url': 'https://example.test/$i-wm.jpg',
            },
        ],
      };

  Map<String, dynamic> _quote(int count) => {
        'selected_count': count,
        'included_photos': 10,
        'minimum_photos': 10,
        'currency': 'EUR',
        'amount_total': '200.00',
        'amount_paid': '150.00',
        'amount_due': count >= 10 ? amountDue : '0.00',
        'next_photo_price': '8.00',
        'extras_count': 0,
        'can_submit': count >= 10,
        'photos_still_needed': count >= 10 ? 0 : 10 - count,
      };

  Map<String, dynamic> _submitted() => {
        'selection_id': 'sel-1',
        'selected_count': 10,
        'included_photos': 10,
        'extras_count': 0,
        'gallery_status': 'published',
        'upsell_required': false,
        'difference_required': owes,
        'difference_amount': owes ? amountDue : null,
        'difference_payment_intent_id': owes ? 'pi_1' : null,
        'difference_payment_intent_client_secret': owes ? 'sec_1' : null,
      };
}

Future<ProviderContainer> _open(
  WidgetTester tester,
  _FakeBackend backend,
  _FakeLauncher launcher,
) async {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
  dio.httpClientAdapter = FakeHttpClientAdapter(backend.handle);

  // A real router, because leaving the screen is part of what is asserted and
  // it leaves through go_router.
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: Center(child: TextButton(onPressed: () => context.push('/gallery'), child: const Text('open'))),
        ),
      ),
      GoRoute(
        path: '/gallery',
        builder: (context, _) => const SelectionGalleryScreen(galleryId: 'g1', bookingId: 'b1'),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        proofGalleriesClientProvider.overrideWithValue(ProofGalleriesClient(dio)),
        paymentSheetLauncherProvider.overrideWithValue(launcher),
      ],
      child: MaterialApp.router(theme: buildClientTheme(), routerConfig: router),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  return ProviderScope.containerOf(tester.element(find.byType(SelectionGalleryScreen)));
}

/// Ticks [count] photos and waits out the quote debounce, as a person
/// tapping and then pausing would.
Future<void> _choose(WidgetTester tester, ProviderContainer container, int count) async {
  final controller = container.read(selectionControllerProvider('g1').notifier);
  for (var i = 0; i < count; i++) {
    controller.toggle('asset-$i');
  }
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

Finder _barButton(String label) => find.widgetWithText(ElevatedButton, label);

Finder _dialogAction(String label) => find.descendant(of: find.byType(AlertDialog), matching: find.text(label));

Future<void> _confirmInDialog(WidgetTester tester, String label) async {
  await tester.tap(_dialogAction(label));
  await tester.pumpAndSettle();
}

bool _stillOnGallery() => find.byType(SelectionGalleryScreen).evaluate().isNotEmpty;

void main() {
  testWidgets('confirming saves the selection, then submits it', (tester) async {
    final backend = _FakeBackend();
    final container = await _open(tester, backend, _FakeLauncher([]));
    await _choose(tester, container, 10);

    await tester.tap(_barButton('Confirm selection'));
    await tester.pumpAndSettle();
    await _confirmInDialog(tester, 'Confirm selection');

    expect(
      backend.writes,
      ['POST /v1/proof-galleries/g1/selections', 'POST /v1/proof-galleries/g1/selections/submit'],
      reason: 'the button did not drive save then submit',
    );
  });

  testWidgets('when a charge is owed the button says how much and the dialog agrees', (tester) async {
    final backend = _FakeBackend(amountDue: '48.00');
    final container = await _open(tester, backend, _FakeLauncher([]));
    await _choose(tester, container, 10);

    // The number being committed to is on the button before it is tapped.
    await tester.tap(_barButton('Pay EUR 48.00'));
    await tester.pumpAndSettle();

    expect(find.textContaining('10 photos chosen'), findsOneWidget);
    expect(find.textContaining('You will be charged EUR 48.00'), findsOneWidget);
    expect(find.textContaining('cannot change your selection'), findsOneWidget);
  });

  testWidgets('a difference charge opens the payment sheet on the intent submit returned', (tester) async {
    final launcher = _FakeLauncher([const PaymentSheetCompleted()]);
    final backend = _FakeBackend(amountDue: '48.00');
    final container = await _open(tester, backend, launcher);
    await _choose(tester, container, 10);

    await tester.tap(_barButton('Pay EUR 48.00'));
    await tester.pumpAndSettle();
    await _confirmInDialog(tester, 'Pay EUR 48.00');

    expect(launcher.presented, ['sec_1']);
    expect(_stillOnGallery(), isFalse, reason: 'a completed payment should leave the screen');
    expect(find.textContaining('Payment sent'), findsOneWidget);
  });

  testWidgets('nothing owed: no payment sheet, and the screen is left', (tester) async {
    final launcher = _FakeLauncher([]);
    final backend = _FakeBackend();
    final container = await _open(tester, backend, launcher);
    await _choose(tester, container, 10);

    await tester.tap(_barButton('Confirm selection'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No charge'), findsOneWidget);
    await _confirmInDialog(tester, 'Confirm selection');

    expect(launcher.presented, isEmpty, reason: 'a sheet was shown for a booking that owes nothing');
    expect(backend.submits, 1);
    expect(_stillOnGallery(), isFalse);
    expect(find.text('Your selection is confirmed.'), findsOneWidget);
  });

  testWidgets('declining the dialog changes nothing', (tester) async {
    final backend = _FakeBackend(amountDue: '48.00');
    final container = await _open(tester, backend, _FakeLauncher([]));
    await _choose(tester, container, 10);

    await tester.tap(_barButton('Pay EUR 48.00'));
    await tester.pumpAndSettle();
    await _confirmInDialog(tester, 'Not yet');

    expect(backend.writes, isEmpty, reason: 'backing out of the dialog still wrote something');
    expect(_stillOnGallery(), isTrue);
  });

  testWidgets('a failed submit keeps the selection, says why, and can be retried', (tester) async {
    final backend = _FakeBackend(submitStatuses: [409, 200]);
    final container = await _open(tester, backend, _FakeLauncher([]));
    await _choose(tester, container, 10);

    await tester.tap(_barButton('Confirm selection'));
    await tester.pumpAndSettle();
    await _confirmInDialog(tester, 'Confirm selection');

    expect(_stillOnGallery(), isTrue);
    expect(find.text('No draft selection to submit'), findsOneWidget);
    expect(container.read(selectionControllerProvider('g1')).requireValue.selectedCount, 10,
        reason: 'the choices were lost when the submit failed');
    expect(find.text('10 chosen'), findsOneWidget);

    // Same button, second attempt.
    await tester.tap(_barButton('Confirm selection'));
    await tester.pumpAndSettle();
    await _confirmInDialog(tester, 'Confirm selection');

    expect(backend.submits, 2);
    expect(_stillOnGallery(), isFalse);
  });

  testWidgets('a failed save stops before submit', (tester) async {
    final backend = _FakeBackend(saveStatuses: [409, 200]);
    final container = await _open(tester, backend, _FakeLauncher([]));
    await _choose(tester, container, 10);

    await tester.tap(_barButton('Confirm selection'));
    await tester.pumpAndSettle();
    await _confirmInDialog(tester, 'Confirm selection');

    expect(backend.submits, 0, reason: 'submit ran against a selection that never saved');
    expect(_stillOnGallery(), isTrue);
    expect(find.text('10 chosen'), findsOneWidget);
  });

  testWidgets('a declined card retries the same intent without saving or submitting again', (tester) async {
    final launcher = _FakeLauncher([const PaymentSheetFailed('Your card was declined.'), const PaymentSheetCompleted()]);
    final backend = _FakeBackend(amountDue: '48.00');
    final container = await _open(tester, backend, launcher);
    await _choose(tester, container, 10);

    await tester.tap(_barButton('Pay EUR 48.00'));
    await tester.pumpAndSettle();
    await _confirmInDialog(tester, 'Pay EUR 48.00');

    expect(_stillOnGallery(), isTrue);
    expect(find.text('Your card was declined.'), findsOneWidget);

    // The selection is now what the charge was computed from: it must not be
    // editable, or a retry would pay for photos other than the ones chosen.
    container.read(selectionControllerProvider('g1').notifier).toggle('asset-11');
    expect(container.read(selectionControllerProvider('g1')).requireValue.selectedCount, 10);

    // Retry: no second dialog, no second save, no second submit.
    await tester.tap(_barButton('Pay EUR 48.00'));
    await tester.pumpAndSettle();

    expect(launcher.presented, ['sec_1', 'sec_1']);
    expect(backend.saves, 1);
    expect(backend.submits, 1);
    expect(_stillOnGallery(), isFalse);
  });

  testWidgets('closing the payment sheet is not an error and leaves the payment owed', (tester) async {
    final launcher = _FakeLauncher([const PaymentSheetCancelled()]);
    final backend = _FakeBackend(amountDue: '48.00');
    final container = await _open(tester, backend, launcher);
    await _choose(tester, container, 10);

    await tester.tap(_barButton('Pay EUR 48.00'));
    await tester.pumpAndSettle();
    await _confirmInDialog(tester, 'Pay EUR 48.00');

    expect(_stillOnGallery(), isTrue);
    expect(container.read(selectionControllerProvider('g1')).requireValue.confirmError, isNull);
    expect(find.text('Your selection is locked in'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(_barButton('Pay EUR 48.00')).onPressed, isNotNull);
  });

  testWidgets('the button is dead while the quote is out of date', (tester) async {
    final backend = _FakeBackend(amountDue: '48.00');
    final container = await _open(tester, backend, _FakeLauncher([]));
    await _choose(tester, container, 10);
    expect(tester.widget<ElevatedButton>(_barButton('Pay EUR 48.00')).onPressed, isNotNull);

    // A tap that has not yet been priced. The label still shows the previous
    // total; committing to it would be committing to a stale number.
    container.read(selectionControllerProvider('g1').notifier).toggle('asset-10');
    await tester.pump();

    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  });
}
