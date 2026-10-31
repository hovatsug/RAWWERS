import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/design/components/r_amount_row.dart';
import 'package:rawwers/features/pro/wallet/summary_controller.dart';
import 'package:rawwers/api/models/invoice_summary_view.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/api/models/earnings_entry_status.dart';
import 'package:rawwers/api/models/earnings_ledger_item_view.dart';
import 'package:rawwers/api/models/earnings_source_type.dart';
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
  String pending = '40.00',
  List<EarningsLedgerItemView> ledger = const [],
  PayoutAccountStatus accountStatus = PayoutAccountStatus.active,
}) {
  return WalletData(
    balance: EarningsBalanceView(
      pendingEur: pending,
      availableEur: available,
      heldEur: '10.00',
      requestedEur: '30.00',
      reservedEur: '0.00',
      paidOutEur: '120.00',
      lifetimeEur: '420.00',
      withdrawableEur: withdrawable,
      adjustmentOwedEur: adjustmentOwed,
    ),
    ledger: ledger,
    payouts: const [],
    account: PayoutAccountView(
      proUserId: 'pro',
      payoutMethod: PayoutMethod.stripeConnect,
      status: accountStatus,
      updatedAt: DateTime.utc(2026, 9, 1),
    ),
  );
}

EarningsLedgerItemView _earning(
  String net,
  DateTime availableAt, {
  EarningsEntryStatus status = EarningsEntryStatus.pending,
}) => EarningsLedgerItemView(
  id: 'e-$net',
  sourceType: EarningsSourceType.extraImages,
  sourceId: 'src-$net',
  grossEur: net,
  platformFeeEur: '0.00',
  netEur: net,
  status: status,
  availableAt: availableAt,
  createdAt: availableAt.subtract(const Duration(days: 7)),
);

Widget _wrap(WalletData data, {InvoiceSummaryView? summary, DateTime Function()? clock}) => ProviderScope(
      overrides: [
        walletControllerProvider.overrideWith(() => _FakeWallet(data)),
        // The all-time summary above the ledger is its own request. Without
        // this override it reaches the network and the test hangs.
        earningsSummaryProvider.overrideWith((ref) async => summary ?? _summary()),
      ],
      child: MaterialApp(theme: buildProTheme(), home: WalletScreen(clock: clock ?? DateTime.now)),
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
  testWidgets('both money cards use one row: 15 on both sides, tabular amounts, only the total heavier', (tester) async {
    tester.view.physicalSize = const Size(390, 2400) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    const summary = InvoiceSummaryView(
      bookings: 3,
      gross: '2310.00',
      platformFees: '462.00',
      proRaww: '46.20',
      clientRaww: '23.10',
      proCash: '1824.90',
    );
    await tester.pumpWidget(_wrap(_wallet(), summary: summary));
    await tester.pumpAndSettle();

    final rows = {for (final row in tester.widgetList<RAmountRow>(find.byType(RAmountRow))) row.label: row};
    for (final label in ['Pending', 'On hold', 'Requested', 'Paid out', 'Booked', 'Platform fees', 'Given to clients', 'Cash earned']) {
      expect(rows, contains(label), reason: '$label is not on the shared row');
      final row = find.byWidget(rows[label]!);
      final labelStyle = tester.widget<Text>(find.descendant(of: row, matching: find.text(label))).style!;
      final amountStyle = tester.widget<Text>(find.descendant(of: row, matching: find.text(rows[label]!.amount))).style!;
      expect(labelStyle.fontSize, RType.body, reason: label);
      expect(amountStyle.fontSize, RType.body, reason: label);
      expect(amountStyle.fontFeatures, RType.tabularFigures, reason: label);
      final heavy = label == 'Cash earned';
      expect(amountStyle.fontVariations, [heavy ? RType.weightSemibold : RType.weightRegular], reason: label);
      expect(labelStyle.fontVariations, [heavy ? RType.weightSemibold : RType.weightRegular], reason: label);
    }
  });

  testWidgets('pulling the Wallet down reloads the All time card too', (tester) async {
    // A booking completes while the Wallet is open: the balance reloaded on a
    // pull, the All time card kept its first answer.
    var fetches = 0;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        walletControllerProvider.overrideWith(() => _FakeWallet(_wallet())),
        earningsSummaryProvider.overrideWith((ref) async {
          fetches++;
          return fetches == 1
              ? const InvoiceSummaryView(bookings: 1, gross: '52.43', platformFees: '10.48', proRaww: '2.62', clientRaww: '0.00', proCash: '41.95')
              : const InvoiceSummaryView(bookings: 2, gross: '139.26', platformFees: '27.84', proRaww: '6.96', clientRaww: '0.00', proCash: '111.42');
        }),
      ],
      child: MaterialApp(theme: buildProTheme(), home: const WalletScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('1 completed booking'), findsOneWidget);

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(fetches, 2);
    expect(find.text('2 completed bookings'), findsOneWidget);
    expect(find.text('€139.26'), findsOneWidget);
  });

  group('when pending money can be withdrawn', () {
    // Noon UTC, so the calendar day is the same in any likely time zone.
    final booking1 = _earning('69.47', DateTime.utc(2026, 11, 6, 12));
    final booking2 = _earning('75.20', DateTime.utc(2026, 11, 7, 12));
    WalletData twoPending() => _wallet(pending: '144.67', ledger: [booking2, booking1]);

    Future<void> scrollTo(WidgetTester tester, Finder finder) async {
      await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
      await tester.pump();
    }

    testWidgets('the Pending row says which earning comes next, and from when', (tester) async {
      await tester.pumpWidget(_wrap(twoPending(), clock: () => DateTime.utc(2026, 10, 31, 12)));
      await tester.pump();
      expect(find.text('Next: €69.47 available from 6 Nov.'), findsOneWidget);
    });

    testWidgets('each pending earning in the list says its own date', (tester) async {
      await tester.pumpWidget(_wrap(twoPending(), clock: () => DateTime.utc(2026, 10, 31, 12)));
      await tester.pump();
      await scrollTo(tester, find.text('Pending · available from 7 Nov'));
      expect(find.text('Pending · available from 7 Nov'), findsOneWidget);
      expect(find.text('Pending · available from 6 Nov'), findsOneWidget);
    });

    testWidgets('under a day it counts in hours', (tester) async {
      await tester.pumpWidget(_wrap(twoPending(), clock: () => DateTime.utc(2026, 11, 6, 7)));
      await tester.pump();
      expect(find.text('Next: €69.47 available in about 5 hours.'), findsOneWidget);
    });

    testWidgets('after the time and before a refresh it says so, rather than a date gone by', (tester) async {
      await tester.pumpWidget(_wrap(twoPending(), clock: () => DateTime.utc(2026, 11, 6, 13)));
      await tester.pump();
      expect(find.text('Next: €69.47 is being released. Pull down to refresh.'), findsOneWidget);
      await scrollTo(tester, find.text('Pending · being released - pull down to refresh'));
      expect(find.text('Pending · being released - pull down to refresh'), findsOneWidget);
    });

    testWidgets('coming back to the app works the time out again', (tester) async {
      var now = DateTime.utc(2026, 10, 31, 12);
      await tester.pumpWidget(_wrap(twoPending(), clock: () => now));
      await tester.pump();
      expect(find.text('Next: €69.47 available from 6 Nov.'), findsOneWidget);

      now = DateTime.utc(2026, 11, 6, 9);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('Next: €69.47 available in about 3 hours.'), findsOneWidget);
    });

    testWidgets('no ticking: the screen settles', (tester) async {
      await tester.pumpWidget(_wrap(twoPending(), clock: () => DateTime.utc(2026, 10, 31, 12)));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('an earning on hold or available gets no date', (tester) async {
      final held = _earning('10.00', DateTime.utc(2026, 11, 1, 12), status: EarningsEntryStatus.held);
      final settled = _earning('41.95', DateTime.utc(2026, 10, 20, 12), status: EarningsEntryStatus.available);
      await tester.pumpWidget(
        _wrap(_wallet(pending: '0.00', ledger: [held, settled]), clock: () => DateTime.utc(2026, 10, 31, 12)),
      );
      await tester.pump();
      expect(find.textContaining('Next:'), findsNothing);
      await scrollTo(tester, find.text('available'));
      expect(find.text('held'), findsOneWidget);
      expect(find.textContaining('available from'), findsNothing);
    });

    testWidgets('no next date when the list cannot hold every pending earning', (tester) async {
      await tester.pumpWidget(
        _wrap(_wallet(pending: '500.00', ledger: [booking2]), clock: () => DateTime.utc(2026, 10, 31, 12)),
      );
      await tester.pump();
      expect(find.textContaining('Next:'), findsNothing);
    });

    testWidgets('the payout minimum and the weekly limit still read as before', (tester) async {
      await tester.pumpWidget(_wrap(_wallet(withdrawable: '12.00', pending: '144.67', ledger: [booking1, booking2])));
      await tester.pump();
      expect(find.textContaining('at least €50.00'), findsOneWidget);
      expect(find.textContaining('You have €12.00'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_wrap(_wallet(pending: '144.67', ledger: [booking1, booking2])));
      await tester.pump();
      expect(find.textContaining('Minimum €50.00'), findsOneWidget);
      expect(find.textContaining('2 requests every 7 days'), findsOneWidget);
    });
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
