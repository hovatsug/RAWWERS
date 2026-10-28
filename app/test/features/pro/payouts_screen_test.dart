import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/connect_status_response.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/api/models/payout_setup_state.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/payouts/payouts_controller.dart';
import 'package:rawwers/features/pro/payouts/payouts_screen.dart';

/// A photographer with money they cannot withdraw is the worst first
/// impression the product can make, so these cover what the screen says
/// about *why* - one state per answer the server gives, each read at
/// normal and large text - and that a hosted link is never reused.
///
/// The screen never works the state out from Stripe's flags: it shows the
/// server's setup_state, which comes from the same function as the stored
/// status that gates Request payout (api: stripe_connect.setup_from_account).

/// The live status, scripted: each build answers with the next entry (an
/// exception is thrown), the last one repeating.
class _FakeStatus extends ConnectStatusController {
  _FakeStatus(List<Object> answers, {this.linkError}) : _answers = answers;

  final List<Object> _answers;
  final String? linkError;
  var builds = 0;
  var linkRequests = 0;

  /// When set, builds after the first wait for it before answering.
  Completer<void>? hold;

  @override
  Future<ConnectStatusResponse> build() async {
    final answer = _answers[builds < _answers.length ? builds : _answers.length - 1];
    builds++;
    if (builds > 1 && hold != null) await hold!.future;
    if (answer is ConnectStatusResponse) return answer;
    throw answer;
  }

  @override
  Future<({String? url, String? error})> onboardingLink() async {
    linkRequests++;
    if (linkError != null) return (url: null, error: linkError);
    return (url: 'https://connect.stripe.test/setup/$linkRequests', error: null);
  }
}

class _FakeBalance extends EarningsBalanceController {
  _FakeBalance(this._answers);

  final List<Object> _answers;
  var builds = 0;

  @override
  Future<EarningsBalanceView> build() async {
    final answer = _answers[builds < _answers.length ? builds : _answers.length - 1];
    builds++;
    if (answer is EarningsBalanceView) return answer;
    throw answer;
  }
}

EarningsBalanceView _balance({
  String pending = '144.00',
  String withdrawable = '0.00',
  String held = '0.00',
}) =>
    EarningsBalanceView(
      pendingEur: pending,
      availableEur: withdrawable,
      heldEur: held,
      reservedEur: '0.00',
      withdrawableEur: withdrawable,
    );

ConnectStatusResponse _status(
  PayoutSetupState state, {
  String? accountStatus,
  bool chargesEnabled = false,
  bool payoutsEnabled = false,
  bool detailsSubmitted = false,
  List<String>? currentlyDue,
  List<String>? pastDue,
}) =>
    ConnectStatusResponse(
      setupState: state,
      accountStatus: accountStatus ??
          switch (state) {
            PayoutSetupState.notStarted => 'not_set',
            PayoutSetupState.ready => 'active',
            PayoutSetupState.disabled => 'disabled',
            _ => 'pending_verification',
          },
      chargesEnabled: chargesEnabled,
      payoutsEnabled: payoutsEnabled,
      detailsSubmitted: detailsSubmitted,
      currentlyDue: currentlyDue,
      pastDue: pastDue,
    );

Widget _wrap({
  _FakeStatus? status,
  _FakeBalance? balance,
  Future<bool> Function(String)? openUrl,
  double textScale = 1.0,
}) =>
    ProviderScope(
      overrides: [
        connectStatusControllerProvider.overrideWith(() => status ?? _FakeStatus([_status(PayoutSetupState.notStarted)])),
        earningsBalanceControllerProvider.overrideWith(() => balance ?? _FakeBalance([_balance()])),
      ],
      child: MaterialApp(
        theme: buildProTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: PayoutsScreen(openUrl: openUrl),
      ),
    );

Future<void> _pump(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  // A fresh tree each time: a new ProviderScope in the same place would
  // keep the previous one's container and overrides.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

String? _chip(WidgetTester tester) => tester.widget<RStatusChip>(find.byType(RStatusChip)).label;

/// The twelve fields Stripe listed for the gate run's fresh account, as it
/// listed them: every one in currently_due and again in past_due.
const _gateRunDue = [
  'business_profile.url',
  'external_account',
  'individual.address.city',
  'individual.address.line1',
  'individual.address.postal_code',
  'individual.dob.day',
  'individual.dob.month',
  'individual.dob.year',
  'individual.first_name',
  'individual.last_name',
  'tos_acceptance.date',
  'tos_acceptance.ip',
];

typedef _Expect = ({String title, String body, String? action, String chip});

const Map<PayoutSetupState, _Expect> _expected = {
  PayoutSetupState.notStarted: (
    title: 'You can\'t be paid yet',
    body: 'Set up payouts so money from finished shoots can reach your bank. Stripe handles this and asks for your ID.',
    action: 'Set up payouts',
    chip: 'Not ready',
  ),
  PayoutSetupState.inProgress: (
    title: 'Setup isn\'t finished',
    body: 'Stripe still needs a few details. You can pick up where you left off.',
    action: 'Continue setup',
    chip: 'Not ready',
  ),
  PayoutSetupState.underReview: (
    title: 'Stripe is checking your details',
    body: 'This usually takes a few minutes, sometimes a day or two. Nothing to do for now.',
    action: 'Check again',
    chip: 'Not ready',
  ),
  PayoutSetupState.actionNeeded: (
    title: 'Stripe needs something else from you',
    body: 'Open Stripe to add what is missing.',
    action: 'Fix this',
    chip: 'Not ready',
  ),
  PayoutSetupState.ready: (
    title: 'Payouts are set up',
    body: 'Withdrawals go to the bank account you gave Stripe.',
    action: null,
    chip: 'Ready',
  ),
  PayoutSetupState.disabled: (
    title: 'Stripe can\'t pay out to this account',
    body: 'Contact us and we\'ll look into it with Stripe.',
    action: null,
    chip: 'Stopped',
  ),
};

void main() {
  test('every setup state the server can send has its copy here', () {
    expect(_expected.keys.toSet(), PayoutSetupState.values.toSet());
  });

  for (final scale in [1.0, 1.3]) {
    group('at text scale $scale', () {
      for (final MapEntry(key: state, value: expected) in _expected.entries) {
        testWidgets('${state.name}: ${expected.title}', (tester) async {
          await _pump(
            tester,
            _wrap(
              textScale: scale,
              status: _FakeStatus([
                _status(state, currentlyDue: state == PayoutSetupState.actionNeeded ? const ['external_account'] : null),
              ]),
            ),
          );

          expect(tester.takeException(), isNull, reason: 'no overflow');
          expect(find.text(expected.title), findsOneWidget);
          expect(find.text(expected.body), findsOneWidget);
          expect(_chip(tester), expected.chip);
          if (expected.action == null) {
            expect(find.byType(RButton), findsNothing);
          } else {
            expect(find.widgetWithText(RButton, expected.action!), findsOneWidget);
          }
        });
      }

      testWidgets('the setup check failing: the error, with Try again', (tester) async {
        await _pump(tester, _wrap(textScale: scale, status: _FakeStatus([const NetworkError()])));

        expect(tester.takeException(), isNull, reason: 'no overflow');
        expect(find.text('Couldn\'t check your payout setup. Check your connection and try again.'), findsOneWidget);
        expect(find.widgetWithText(RButton, 'Try again'), findsOneWidget);
      });

      testWidgets('the gate run\'s twelve due fields, as rows', (tester) async {
        await _pump(
          tester,
          _wrap(
            textScale: scale,
            status: _FakeStatus([
              _status(PayoutSetupState.inProgress, currentlyDue: _gateRunDue, pastDue: _gateRunDue),
            ]),
          ),
        );
        expect(tester.takeException(), isNull, reason: 'no overflow');
        expect(find.text('Still needed'), findsOneWidget);
      });
    });
  }

  group('what Stripe still needs', () {
    test('the gate run\'s 24 entries make one row per thing to do', () {
      expect(requirementRows([..._gateRunDue, ..._gateRunDue]), [
        'A website or social profile',
        'Your bank account',
        'Your home address',
        'Your date of birth',
        'Your name',
        'Accepting Stripe\'s terms',
      ]);
    });

    test('no row is a Stripe field name, and every row starts with a capital', () {
      for (final key in [
        ..._gateRunDue,
        'individual.id_number',
        'individual.verification.document',
        'individual.verification.additional_document',
        'individual.email',
        'individual.phone',
        'individual.address.state',
        'business_profile.mcc',
        'company.tax_id',
        'settings.payments.statement_descriptor',
      ]) {
        final label = requirementLabel(key);
        expect(label, isNot(contains('.')), reason: key);
        expect(label, isNot(contains('_')), reason: key);
        expect(label[0], label[0].toUpperCase(), reason: key);
        expect(label.toLowerCase(), isNot(key.split('.').last.replaceAll('_', ' ')),
            reason: '$key: not just the field name in words');
      }
    });

    test('keys we do not know share one plain row', () {
      expect(requirementRows(['company.tax_id', 'settings.payments.statement_descriptor']), [
        'Other details in Stripe\'s form',
      ]);
    });

    testWidgets('shown on screen once each, in Stripe\'s order', (tester) async {
      await _pump(
        tester,
        _wrap(status: _FakeStatus([_status(PayoutSetupState.inProgress, currentlyDue: _gateRunDue, pastDue: _gateRunDue)])),
      );

      expect(find.textContaining('· '), findsNWidgets(6));
      expect(find.text('· Your date of birth'), findsOneWidget);
      expect(find.text('· Your name'), findsOneWidget);
      expect(find.textContaining('individual'), findsNothing);
    });

    testWidgets('listed when there is something to do, not otherwise', (tester) async {
      for (final state in PayoutSetupState.values) {
        await _pump(tester, _wrap(status: _FakeStatus([_status(state, currentlyDue: const ['external_account'])])));
        final shown = state == PayoutSetupState.inProgress || state == PayoutSetupState.actionNeeded;
        expect(find.text('· Your bank account'), shown ? findsOneWidget : findsNothing, reason: state.name);
      }
    });
  });

  group('ready, and only ready', () {
    testWidgets('"Payouts are set up" appears for ready and for no other state', (tester) async {
      for (final state in PayoutSetupState.values) {
        await _pump(tester, _wrap(status: _FakeStatus([_status(state)])));
        expect(find.text('Payouts are set up'), state == PayoutSetupState.ready ? findsOneWidget : findsNothing,
            reason: state.name);
      }
    });

    testWidgets('payouts enabled without charges is ready, as the server says', (tester) async {
      // The screen does not look at charges_enabled: the server's state is
      // the answer.
      await _pump(
        tester,
        _wrap(
          status: _FakeStatus([
            _status(PayoutSetupState.ready, chargesEnabled: false, payoutsEnabled: true, detailsSubmitted: true),
          ]),
        ),
      );
      expect(find.text('Payouts are set up'), findsOneWidget);
      expect(_chip(tester), 'Ready');
    });

    testWidgets('the screen follows setup_state, not the Stripe flags beside it', (tester) async {
      // Flags that look ready, a state that is not: the state wins.
      await _pump(
        tester,
        _wrap(
          status: _FakeStatus([
            _status(PayoutSetupState.underReview,
                chargesEnabled: true, payoutsEnabled: true, detailsSubmitted: true, accountStatus: 'pending_verification'),
          ]),
        ),
      );
      expect(find.text('Payouts are set up'), findsNothing);
      expect(find.text('Stripe is checking your details'), findsOneWidget);
    });
  });

  group('buttons', () {
    testWidgets('Check again asks the server again; it does not open Stripe', (tester) async {
      final status = _FakeStatus([_status(PayoutSetupState.underReview)]);
      final opened = <String>[];
      await _pump(tester, _wrap(status: status, openUrl: (url) async {
        opened.add(url);
        return true;
      }));
      final before = status.builds;

      await tester.tap(find.widgetWithText(RButton, 'Check again'));
      await tester.pumpAndSettle();

      expect(status.builds, before + 1);
      expect(status.linkRequests, 0);
      expect(opened, isEmpty);
    });

    for (final (state, label) in [
      (PayoutSetupState.notStarted, 'Set up payouts'),
      (PayoutSetupState.inProgress, 'Continue setup'),
      (PayoutSetupState.actionNeeded, 'Fix this'),
    ]) {
      testWidgets('$label opens a fresh Stripe link', (tester) async {
        final status = _FakeStatus([_status(state)]);
        final opened = <String>[];
        await _pump(tester, _wrap(status: status, openUrl: (url) async {
        opened.add(url);
        return true;
      }));

        await tester.tap(find.widgetWithText(RButton, label));
        await tester.pumpAndSettle();

        expect(status.linkRequests, 1);
        expect(opened.single, startsWith('https://connect.stripe.test/setup/'));
      });
    }

    testWidgets('every attempt asks for a new link', (tester) async {
      // Stripe account links expire in minutes and are single use, so
      // reusing one is how a photographer meets an expired page.
      final status = _FakeStatus([_status(PayoutSetupState.notStarted)]);
      final opened = <String>[];
      await _pump(tester, _wrap(status: status, openUrl: (url) async {
        opened.add(url);
        return true;
      }));

      await tester.tap(find.widgetWithText(RButton, 'Set up payouts'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(RButton, 'Set up payouts'));
      await tester.pumpAndSettle();

      expect(status.linkRequests, 2);
      expect(opened.toSet().length, 2, reason: 'a fresh link each time, never the cached one');
    });

    testWidgets('a link that cannot be opened is copied, with the expiry said out loud', (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied.add(call.arguments['text'] as String);
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

      await _pump(tester, _wrap(openUrl: (_) async => false));
      await tester.tap(find.widgetWithText(RButton, 'Set up payouts'));
      await tester.pumpAndSettle();

      expect(copied.single, contains('connect.stripe.test'));
      expect(find.textContaining('expires in a few minutes'), findsOneWidget);
    });

    testWidgets('a Stripe failure shows the reason it gave', (tester) async {
      await _pump(
        tester,
        _wrap(status: _FakeStatus([_status(PayoutSetupState.notStarted)], linkError: 'Connect is not enabled on this account.')),
      );
      await tester.tap(find.widgetWithText(RButton, 'Set up payouts'));
      await tester.pumpAndSettle();

      expect(find.text('Connect is not enabled on this account.'), findsOneWidget);
    });
  });

  group('asking again', () {
    testWidgets('Try again re-reads the earnings as well as the setup', (tester) async {
      final status = _FakeStatus([const NetworkError(), _status(PayoutSetupState.ready)]);
      final balance = _FakeBalance([const NetworkError(), _balance(withdrawable: '41.95', pending: '0.00')]);
      await _pump(tester, _wrap(status: status, balance: balance));
      expect(find.text('Could not load your earnings.'), findsOneWidget);

      await tester.tap(find.widgetWithText(RButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Could not load your earnings.'), findsNothing);
      expect(find.text('€41.95'), findsOneWidget);
      expect(find.text('Payouts are set up'), findsOneWidget);
    });

    testWidgets('pull to refresh re-reads the earnings as well as the setup', (tester) async {
      // What the owner saw on 2026-10-28: the setup recovered, the
      // earnings error stayed, because only the setup was asked again.
      final status = _FakeStatus([_status(PayoutSetupState.inProgress)]);
      final balance = _FakeBalance([const NetworkError(), _balance(withdrawable: '41.95', pending: '0.00')]);
      await _pump(tester, _wrap(status: status, balance: balance));
      expect(find.text('Could not load your earnings.'), findsOneWidget);
      final before = status.builds;

      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Could not load your earnings.'), findsNothing);
      expect(find.text('€41.95'), findsOneWidget);
      expect(status.builds, before + 1);
    });

    testWidgets('a re-read that fails shows the error, not the last answer', (tester) async {
      // Coming back from Stripe with no connection: yesterday's "Continue
      // setup" must not stay on screen as if it were current.
      final status = _FakeStatus([_status(PayoutSetupState.inProgress), const NetworkError()]);
      await _pump(tester, _wrap(status: status));
      expect(find.text('Setup isn\'t finished'), findsOneWidget);

      final container = ProviderScope.containerOf(tester.element(find.byType(PayoutsScreen)));
      container.invalidate(connectStatusControllerProvider);
      await tester.pumpAndSettle();

      expect(find.text('Setup isn\'t finished'), findsNothing);
      expect(find.widgetWithText(RButton, 'Continue setup'), findsNothing);
      expect(find.widgetWithText(RButton, 'Try again'), findsOneWidget);
    });

    testWidgets('nothing can be started while the status is being asked again', (tester) async {
      // On 2026-10-28 a setup link was minted while the re-read was still
      // waiting on Stripe: the old "Continue setup" was live on screen.
      final status = _FakeStatus([_status(PayoutSetupState.inProgress), _status(PayoutSetupState.ready)])
        ..hold = Completer<void>();
      await _pump(tester, _wrap(status: status));

      final container = ProviderScope.containerOf(tester.element(find.byType(PayoutsScreen)));
      container.invalidate(connectStatusControllerProvider);
      await tester.pump();
      await tester.pump();

      final buttons = tester.widgetList<RButton>(find.byType(RButton));
      for (final button in buttons) {
        expect(button.onPressed, isNull, reason: '${button.label} must wait for the answer');
      }
      if (buttons.isNotEmpty) {
        await tester.tap(find.byType(RButton), warnIfMissed: false);
        await tester.pump();
      }
      expect(status.linkRequests, 0);

      status.hold!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Payouts are set up'), findsOneWidget);
    });
  });

  testWidgets('money still settling reads as when, not whether', (tester) async {
    await _pump(tester, _wrap());

    expect(find.text('€144.00'), findsOneWidget);
    expect(find.textContaining('settles before it can be withdrawn'), findsOneWidget);
  });
}
