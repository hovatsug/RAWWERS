import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/features/pro/wallet/summary_controller.dart';
import 'package:rawwers/api/models/invoice_summary_view.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/api/models/payout_account_status.dart';
import 'package:rawwers/api/models/payout_account_view.dart';
import 'package:rawwers/api/models/payout_method.dart';
import 'package:rawwers/design/components/r_band_hero.dart';
import 'package:rawwers/design/components/r_header_band.dart';
import 'package:rawwers/design/components/r_viewfinder_frame.dart';
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
  String available = '250.00',
  String adjustmentOwed = '0.00',
  PayoutAccountStatus accountStatus = PayoutAccountStatus.active,
}) {
  return WalletData(
    balance: EarningsBalanceView(
      pendingEur: '40.00',
      availableEur: available,
      heldEur: '10.00',
      requestedEur: '30.00',
      reservedEur: '0.00',
      paidOutEur: '120.00',
      lifetimeEur: '420.00',
      withdrawableEur: withdrawable,
      adjustmentOwedEur: adjustmentOwed,
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
      overrides: [
        walletControllerProvider.overrideWith(() => _FakeWallet(data)),
        // The all-time summary above the ledger is its own request. Without
        // this override it reaches the network and the test hangs.
        earningsSummaryProvider.overrideWith((ref) async => _summary()),
      ],
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
    expect(find.text('Requested'), findsOneWidget);
    expect(find.text('€30.00'), findsOneWidget);
    expect(find.text('Reserved for payouts'), findsOneWidget);
    expect(find.text('Paid out'), findsOneWidget);
    expect(find.text('€120.00'), findsOneWidget);
    expect(find.text('€250.00'), findsWidgets);
    expect(find.textContaining('Adjustment owed'), findsNothing);
  });

  testWidgets('a negative balance shows 0 to withdraw and the adjustment owed, never the negative', (tester) async {
    await tester.pumpWidget(_wrap(_wallet(withdrawable: '0.00', available: '-21.84', adjustmentOwed: '21.84')));
    await tester.pump();

    expect(find.text('€0.00'), findsWidgets);
    expect(find.textContaining('Adjustment owed: €21.84'), findsOneWidget);
    expect(find.textContaining('-21.84'), findsNothing);
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

  testWidgets('the withdrawable amount is the headline on the band, framed, and only there', (tester) async {
    await tester.pumpWidget(_wrap(_wallet(withdrawable: '250.00')));
    await tester.pump();
    expect(find.descendant(of: find.byType(RHeaderBand), matching: find.byType(RBandHero)), findsOneWidget);
    expect(find.descendant(of: find.byType(RViewfinderFrame), matching: find.text('€250.00')), findsOneWidget);
    expect(find.text('Where your money is'), findsOneWidget);
    expect(find.byType(RViewfinderFrame), findsOneWidget, reason: 'one frame per screen');
  });
}


/// A photographer with no completed work, so the summary card renders nothing
/// and these tests stay about the balance and the payout form.
InvoiceSummaryView _summary() => const InvoiceSummaryView(
      bookings: 0,
      gross: '0.00',
      platformFees: '0.00',
      proRaww: '0.00',
      clientRaww: '0.00',
      proCash: '0.00',
    );
