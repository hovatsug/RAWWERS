// Screenshots of the Payouts screen in each setup state the server reports,
// for docs/STAGE1_LOOP.md - for a person to look at, not goldens. Skipped
// unless SCREENSHOT_DIR is set:
//
//   SCREENSHOT_DIR=/tmp/shots flutter test test/screenshots/payouts_screenshot_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/connect_status_response.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/api/models/payout_setup_state.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/payouts/payouts_controller.dart';
import 'package:rawwers/features/pro/payouts/payouts_screen.dart';

import 'screenshot_support.dart';

class _Status extends ConnectStatusController {
  _Status(this._answer);

  final Object _answer;

  @override
  Future<ConnectStatusResponse> build() async {
    if (_answer is ConnectStatusResponse) return _answer;
    throw _answer;
  }
}

class _Balance extends EarningsBalanceController {
  _Balance(this._balance);

  final EarningsBalanceView _balance;

  @override
  Future<EarningsBalanceView> build() async => _balance;
}

EarningsBalanceView _money({required String withdrawable, required String pending}) => EarningsBalanceView(
      pendingEur: pending,
      availableEur: withdrawable,
      heldEur: '0.00',
      reservedEur: '0.00',
      withdrawableEur: withdrawable,
    );

/// What Stripe listed for the gate run's fresh account (2026-10-28), in
/// currently_due and again in past_due.
const _fresh = [
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

Widget _app(Object status, EarningsBalanceView balance) => ProviderScope(
      overrides: [
        connectStatusControllerProvider.overrideWith(() => _Status(status)),
        earningsBalanceControllerProvider.overrideWith(() => _Balance(balance)),
      ],
      child: MaterialApp(theme: buildProTheme(), debugShowCheckedModeBanner: false, home: const PayoutsScreen()),
    );

void main() {
  setUpAll(() async {
    if (screenshotDir != null) await loadScreenshotFonts();
  });
  setUp(() => TestWidgetsFlutterBinding.instance.platformDispatcher.localeTestValue = const Locale('en', 'GB'));
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.clearLocaleTestValue());

  final none = _money(withdrawable: '0.00', pending: '0.00');
  final shots = <String, Widget Function()>{
    'payouts-not-started': () => _app(
          const ConnectStatusResponse(accountStatus: 'not_set', setupState: PayoutSetupState.notStarted),
          none,
        ),
    'payouts-in-progress': () => _app(
          const ConnectStatusResponse(
            accountStatus: 'pending_verification',
            setupState: PayoutSetupState.inProgress,
            currentlyDue: _fresh,
            pastDue: _fresh,
          ),
          none,
        ),
    'payouts-under-review': () => _app(
          const ConnectStatusResponse(
            accountStatus: 'pending_verification',
            setupState: PayoutSetupState.underReview,
            detailsSubmitted: true,
          ),
          none,
        ),
    'payouts-ready-earning-settling': () => _app(
          const ConnectStatusResponse(
            accountStatus: 'active',
            setupState: PayoutSetupState.ready,
            chargesEnabled: true,
            payoutsEnabled: true,
            detailsSubmitted: true,
          ),
          _money(withdrawable: '0.00', pending: '41.95'),
        ),
    'payouts-ready-to-withdraw': () => _app(
          const ConnectStatusResponse(
            accountStatus: 'active',
            setupState: PayoutSetupState.ready,
            chargesEnabled: true,
            payoutsEnabled: true,
            detailsSubmitted: true,
          ),
          _money(withdrawable: '41.95', pending: '0.00'),
        ),
    'payouts-error': () => _app(const NetworkError(), none),
  };

  for (final MapEntry(key: name, value: build) in shots.entries) {
    testWidgets('screenshot $name', (tester) async {
      await shoot(tester, name, build());
    }, skip: screenshotDir == null);
  }
}
