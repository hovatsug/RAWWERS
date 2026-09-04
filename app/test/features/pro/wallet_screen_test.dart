import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/api/models/payout_account_status.dart';
import 'package:rawwers/api/models/payout_account_view.dart';
import 'package:rawwers/api/models/payout_method.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/wallet/wallet_controller.dart';
import 'package:rawwers/features/pro/wallet/wallet_screen.dart';

class _FakeWallet extends WalletController {
  _FakeWallet(this._data);

  final WalletData _data;

  @override
  Future<WalletData> build() async => _data;
}

WalletData _wallet({
  String withdrawable = '250.00',
  PayoutAccountStatus accountStatus = PayoutAccountStatus.active,
}) {
  return WalletData(
    balance: EarningsBalanceView(
      pendingEur: '40.00',
      availableEur: '250.00',
      heldEur: '10.00',
      reservedEur: '0.00',
      withdrawableEur: withdrawable,
    ),
    ledger: const [],
    payouts: const [],
    account: PayoutAccountView(
      proUserId: 'pro',
      payoutMethod: PayoutMethod.stripeConnect,
      status: accountStatus,
      updatedAt: DateTime.utc(2026, 9, 1),
    ),
  );
}

Widget _wrap(WalletData data) => ProviderScope(
      overrides: [walletControllerProvider.overrideWith(() => _FakeWallet(data))],
      child: MaterialApp(theme: buildProTheme(), home: const WalletScreen()),
    );

void main() {
  testWidgets('shows every balance bucket, not just the withdrawable figure', (tester) async {
    // Showing only "available to withdraw" makes earnings look like they
    // vanished between a shoot and a payout - the other buckets are where
    // the money actually is while it moves.
    await tester.pumpWidget(_wrap(_wallet()));
    await tester.pump();

    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('On hold'), findsOneWidget);
    expect(find.text('Reserved'), findsOneWidget);
    expect(find.text('€250.00'), findsWidgets);
  });

  testWidgets('states the payout rules up front rather than after a rejection', (tester) async {
    await tester.pumpWidget(_wrap(_wallet()));
    await tester.pump();

    expect(find.textContaining('Minimum €50.00'), findsOneWidget);
    expect(find.textContaining('2 requests every 7 days'), findsOneWidget);
    expect(find.text('Request payout'), findsOneWidget);
  });

  testWidgets('blocks the request below the minimum and says how short you are', (tester) async {
    await tester.pumpWidget(_wrap(_wallet(withdrawable: '12.00')));
    await tester.pump();

    expect(find.textContaining('at least €50.00'), findsOneWidget);
    expect(find.textContaining('You have €12.00'), findsOneWidget);
    expect(find.text('Request payout'), findsNothing, reason: 'offering a button the server will reject wastes a tap');
  });

  testWidgets('an unverified payout account explains itself instead of offering the form', (tester) async {
    await tester.pumpWidget(_wrap(_wallet(accountStatus: PayoutAccountStatus.notSet)));
    await tester.pump();

    expect(find.text('Not set up'), findsOneWidget);
    expect(find.text('Request payout'), findsNothing);
  });

  testWidgets('says the earnings list is bounded rather than faking infinite scroll', (tester) async {
    // The ledger endpoint takes a limit but no cursor, so there is no honest
    // way to page it.
    await tester.pumpWidget(_wrap(_wallet()));
    await tester.pump();

    // Below the fold, so it has to be scrolled into existence - a ListView
    // doesn't build what it hasn't reached.
    await tester.scrollUntilVisible(find.text('Nothing earned yet.'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pump();

    expect(find.text('Nothing earned yet.'), findsOneWidget);
    expect(find.text('Earnings'), findsOneWidget);
  });
}
