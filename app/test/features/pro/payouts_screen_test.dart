import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/connect_status_response.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/payouts/payouts_controller.dart';
import 'package:rawwers/features/pro/payouts/payouts_screen.dart';

/// A photographer with money they cannot withdraw is the worst first
/// impression the product can make, so these cover what the screen says
/// about *why* — and that a hosted link is never reused.
class _FakeStatus extends ConnectStatusController {
  _FakeStatus(this._status, {this.linkError});

  final ConnectStatusResponse _status;
  final String? linkError;
  var linkRequests = 0;

  @override
  Future<ConnectStatusResponse> build() async => _status;

  @override
  Future<({String? url, String? error})> onboardingLink() async {
    linkRequests++;
    if (linkError != null) return (url: null, error: linkError);
    return (url: 'https://connect.stripe.test/setup/$linkRequests', error: null);
  }
}

class _FailingStatus extends ConnectStatusController {
  @override
  Future<ConnectStatusResponse> build() async => throw const NetworkError();
}

class _FakeBalance extends EarningsBalanceController {
  _FakeBalance(this._balance);

  final EarningsBalanceView _balance;

  @override
  Future<EarningsBalanceView> build() async => _balance;
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

ConnectStatusResponse _status({
  String accountStatus = 'not_set',
  bool detailsSubmitted = false,
  List<String>? currentlyDue,
  String? disabledReason,
}) =>
    ConnectStatusResponse(
      accountStatus: accountStatus,
      detailsSubmitted: detailsSubmitted,
      currentlyDue: currentlyDue,
      disabledReason: disabledReason,
    );

Widget _wrap({
  ConnectStatusController Function()? status,
  EarningsBalanceView? balance,
  Future<bool> Function(String)? openUrl,
}) =>
    ProviderScope(
      overrides: [
        connectStatusControllerProvider.overrideWith(status ?? () => _FakeStatus(_status())),
        earningsBalanceControllerProvider.overrideWith(() => _FakeBalance(balance ?? _balance())),
      ],
      child: MaterialApp(
        theme: buildProTheme(),
        home: PayoutsScreen(openUrl: openUrl),
      ),
    );

void main() {
  testWidgets('money still settling reads as when, not whether', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.text('€144.00'), findsOneWidget);
    expect(find.textContaining('settles before it can be withdrawn'), findsOneWidget);
  });

  testWidgets('an unset account says plainly that they cannot be paid', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.text('You cannot be paid yet'), findsOneWidget);
    expect(find.widgetWithText(RButton, 'Set up payouts'), findsOneWidget);
  });

  testWidgets('outstanding requirements are named, not left as keys', (tester) async {
    // "individual.id_number" reads as a database schema. The only reason
    // to show these at all is that a photographer can act on them.
    await tester.pumpWidget(_wrap(
      status: () => _FakeStatus(_status(
        accountStatus: 'pending_verification',
        currentlyDue: const ['individual.id_number', 'individual.verification.document'],
      )),
    ));
    await tester.pump();

    expect(find.text('· Your ID number'), findsOneWidget);
    expect(find.text('· A photo of your ID'), findsOneWidget);
    expect(find.textContaining('individual.id_number'), findsNothing);
  });

  testWidgets('an unknown requirement key still reads as words', (tester) async {
    await tester.pumpWidget(_wrap(
      status: () => _FakeStatus(_status(
        accountStatus: 'pending_verification',
        currentlyDue: const ['company.tax_id'],
      )),
    ));
    await tester.pump();

    expect(find.text('· tax id'), findsOneWidget);
  });

  testWidgets('a submitted account says there is nothing left to do', (tester) async {
    await tester.pumpWidget(_wrap(
      status: () => _FakeStatus(_status(accountStatus: 'pending_verification', detailsSubmitted: true)),
    ));
    await tester.pump();

    expect(find.text('Stripe is checking your details'), findsOneWidget);
    expect(find.textContaining('Nothing more to do'), findsOneWidget);
  });

  testWidgets('an active account offers no setup action', (tester) async {
    await tester.pumpWidget(_wrap(
      status: () => _FakeStatus(_status(accountStatus: 'active', detailsSubmitted: true)),
      balance: _balance(pending: '0.00', withdrawable: '144.00'),
    ));
    await tester.pump();

    expect(find.text('Set up'), findsOneWidget);
    expect(find.byType(RButton), findsNothing);
  });

  testWidgets('every attempt asks for a new link', (tester) async {
    // Stripe account links expire in minutes and are single use, so
    // reusing one is how a photographer meets an expired page.
    final status = _FakeStatus(_status());
    final opened = <String>[];
    await tester.pumpWidget(_wrap(
      status: () => status,
      openUrl: (url) async {
        opened.add(url);
        return true;
      },
    ));
    await tester.pump();

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
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(_wrap(openUrl: (_) async => false));
    await tester.pump();

    await tester.tap(find.widgetWithText(RButton, 'Set up payouts'));
    await tester.pumpAndSettle();

    expect(copied.single, contains('connect.stripe.test'));
    expect(find.textContaining('expires in a few minutes'), findsOneWidget);
  });

  testWidgets('a Stripe failure shows the reason it gave', (tester) async {
    // The likely one today is "Connect is not enabled on this account",
    // which is far more use than a generic failure.
    await tester.pumpWidget(_wrap(
      status: () => _FakeStatus(_status(), linkError: 'Connect is not enabled on this account.'),
    ));
    await tester.pump();

    await tester.tap(find.widgetWithText(RButton, 'Set up payouts'));
    await tester.pumpAndSettle();

    expect(find.text('Connect is not enabled on this account.'), findsOneWidget);
  });

  testWidgets('a failed status check offers a retry', (tester) async {
    await tester.pumpWidget(_wrap(status: _FailingStatus.new));
    await tester.pump();

    expect(find.text('Could not check your payout setup.'), findsOneWidget);
  });
}
