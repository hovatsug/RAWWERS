// The You tab in Contact sheet: a dark band with the money, a light body with
// what to do next. Everything shown is read from the sources the other
// screens use; nothing about money, bookings or availability changes here.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gig_status.dart';
import 'package:rawwers/api/models/payout_account_status.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_exposure_scale.dart';
import 'package:rawwers/design/components/r_header_band.dart';
import 'package:rawwers/design/components/r_switch.dart';
import 'package:rawwers/design/components/r_viewfinder_frame.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/dashboard/needs_you.dart';
import 'package:rawwers/features/pro/dashboard/you_band.dart';
import 'package:rawwers/features/pro/wallet/wallet_controller.dart';
import 'package:rawwers/core/format/money.dart';

import 'you_tab_fixtures.dart';

Future<void> _pump(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(1170, 2532 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  // Not pumpAndSettle: blocks this test does not fake show a loading
  // skeleton that never settles. A second is ample for the faked ones.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('the band', () {
    testWidgets('carries the brand, the label and the withdrawable amount, framed', (tester) async {
      await _pump(tester, youTab());
      expect(find.descendant(of: find.byType(RHeaderBand), matching: find.text('RAWWERS')), findsOneWidget);
      expect(find.descendant(of: find.byType(RHeaderBand), matching: find.text('PRO')), findsOneWidget);
      expect(find.text('AVAILABLE TO WITHDRAW'), findsOneWidget);
      expect(find.descendant(of: find.byType(RViewfinderFrame), matching: find.text('€41.95')), findsOneWidget);
    });

    testWidgets('the amount is what can be withdrawn - never a negative balance', (tester) async {
      await _pump(tester, youTab(walletData: wallet(withdrawable: '0.00', available: '-21.84')));
      expect(find.text('€0.00'), findsOneWidget);
      expect(find.textContaining('-21.84'), findsNothing);
    });

    testWidgets('the amount is the hero size, tabular, in the band\'s light text', (tester) async {
      await _pump(tester, youTab());
      final text = tester.widget<Text>(find.byKey(YouBand.amountKey));
      expect(text.style!.fontSize, RType.hero);
      expect(text.style!.fontFeatures, RType.tabularFigures);
      expect(text.style!.color, RInk.i050);
    });

    testWidgets('the meta line is the Wallet\'s own pending and on-hold figures', (tester) async {
      await _pump(tester, youTab(walletData: wallet(pending: '120.00', held: '15.96')));
      expect(find.text('€120.00 pending · €15.96 on hold'), findsOneWidget);
    });

    testWidgets('Request payout appears when a payout is possible, in the band\'s button colours, and opens the Wallet', (tester) async {
      await _pump(tester, youTab(walletData: wallet(withdrawable: '250.00')));
      final button = find.widgetWithText(ElevatedButton, 'Request payout');
      expect(button, findsOneWidget);
      final fill = tester.widget<Material>(find.descendant(of: button, matching: find.byType(Material)).first);
      expect(fill.color, RAccent.meter500Band);
      await tester.tap(button);
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('The Wallet'), findsOneWidget);
    });

    testWidgets('below the minimum: no Request payout, and one line saying why, from the Wallet\'s own minimum', (tester) async {
      await _pump(tester, youTab(walletData: wallet(withdrawable: '12.00')));
      expect(find.text('Request payout'), findsNothing);
      expect(find.text('Payouts start at ${RMoney.ofDevice().format(PayoutRules.minimum.toStringAsFixed(2))}.'), findsOneWidget);
    });

    testWidgets('any other refusal: the Wallet\'s own message, word for word', (tester) async {
      final data = walletWithRecentPayouts(withdrawable: '250.00', count: PayoutRules.requestsPer7Days);
      await _pump(tester, youTab(walletData: data));
      expect(find.text('Request payout'), findsNothing);
      expect(find.text(data.payoutBlockedReason!), findsOneWidget);
    });

    testWidgets('no Request payout without a verified payout account, and it says where to set one up', (tester) async {
      await _pump(tester, youTab(walletData: wallet(withdrawable: '250.00', account: PayoutAccountStatus.notSet)));
      expect(find.text('Request payout'), findsNothing);
      expect(find.text('Payouts need a verified account. Set it up in the Wallet.'), findsOneWidget);
    });

    testWidgets('the frame is the full content width and never changes size with the amount', (tester) async {
      await _pump(tester, youTab(walletData: wallet(withdrawable: '41.95')));
      final short = tester.getRect(find.byKey(RViewfinderFrame.bracketsKey));
      final amount = tester.getRect(find.byKey(YouBand.amountKey));
      final band = tester.getRect(find.byType(RHeaderBand));
      expect(short.width, band.width - 2 * RSpace.s16, reason: 'the frame spans the band\'s content width');
      expect(amount.left, short.left + RSpace.s12, reason: 'the amount sits left, inside the frame\'s padding');

      expect(short.height, closeTo(RType.hero * RType.lineHeightDisplay + 2 * RSpace.s12, 0.01));
    });

    testWidgets('a long amount keeps the same frame and scales the number down', (tester) async {
      await _pump(tester, youTab(walletData: wallet(withdrawable: '123456789.00')));
      final frame = tester.getRect(find.byKey(RViewfinderFrame.bracketsKey));
      final band = tester.getRect(find.byType(RHeaderBand));
      expect(frame.width, band.width - 2 * RSpace.s16);
      expect(frame.height, closeTo(RType.hero * RType.lineHeightDisplay + 2 * RSpace.s12, 0.01), reason: 'a long amount resized the frame');
      expect(tester.getRect(find.byKey(YouBand.amountKey)).right, lessThanOrEqualTo(frame.right));
    });

    testWidgets('the balance retry has a 44px target', (tester) async {
      await _pump(tester, youTab(walletFails: true));
      final retry = find.descendant(of: find.byType(RHeaderBand), matching: find.widgetWithText(TextButton, 'Retry'));
      expect(tester.getSize(retry).height, greaterThanOrEqualTo(rMinTouchTarget));
      expect(tester.getSize(retry).width, greaterThanOrEqualTo(rMinTouchTarget));
    });

    testWidgets('a balance that fails to load says so and offers a retry, never a zero', (tester) async {
      await _pump(tester, youTab(walletFails: true));
      expect(find.text('Could not load your balance.'), findsOneWidget);
      expect(find.text('Retry'), findsWidgets);
      expect(find.textContaining('€0.00'), findsNothing);
    });

    testWidgets('a screen reader hears the amount, then the payout action, then the rest', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(tester, youTab(walletData: wallet(withdrawable: '250.00')));
      final order = tester.semantics
          .simulatedAccessibilityTraversal(startNode: find.semantics.byLabel('Available to withdraw, €250.00'))
          .map((n) => n.label)
          .where((l) => l.isNotEmpty)
          .toList();
      expect(order.first, 'Available to withdraw, €250.00');
      expect(order[1], 'Request payout');
      final all = tester.semantics.simulatedAccessibilityTraversal().map((n) => n.label).where((l) => l.isNotEmpty).toList();
      final wordmark = all.indexWhere((l) => l.contains('RAWWERS'));
      expect(wordmark, greaterThanOrEqualTo(0));
      expect(all.indexOf('Available to withdraw, €250.00'), lessThan(wordmark), reason: 'the amount comes before the wordmark');
      semantics.dispose();
    });

    testWidgets('at text scale 1.3 a long amount scales down instead of clipping', (tester) async {
      await _pump(tester, youTab(walletData: wallet(withdrawable: '123456.78'), textScale: 1.3));
      expect(tester.takeException(), isNull);
      final amount = tester.getRect(find.byKey(YouBand.amountKey));
      final band = tester.getRect(find.byType(RHeaderBand));
      expect(amount.right, lessThanOrEqualTo(band.right));
      expect(find.ancestor(of: find.byKey(YouBand.amountKey), matching: find.byType(FittedBox)), findsOneWidget);
    });
  });

  group('the body', () {
    testWidgets('is paper, and Available now uses the rectangular switch', (tester) async {
      await _pump(tester, youTab());
      expect(find.byType(RSwitch), findsOneWidget);
      expect(Theme.of(tester.element(find.byType(RSwitch))).scaffoldBackgroundColor, RPaper.paper);
    });

    testWidgets('the tier score is an exposure scale that says what it measures', (tester) async {
      await _pump(tester, youTab());
      final scale = tester.widget<RExposureScale>(find.byType(RExposureScale));
      expect(scale.semanticLabel, matches(RegExp(r'^Score \d+ out of 100$')));
    });

    testWidgets('Available now still shows its retry state when it fails to load', (tester) async {
      await _pump(tester, youTab(availableNowFails: true));
      expect(find.textContaining('Could not load whether you are available now'), findsOneWidget);
    });

    testWidgets('the next shoot is shown', (tester) async {
      await _pump(tester, youTab(next: gig(id: 'g1', status: GigStatus.scheduled, start: DateTime.utc(2026, 11, 2, 10))));
      expect(find.text('Alfama, Lisbon'), findsOneWidget);
    });

    testWidgets('no next shoot is said plainly', (tester) async {
      await _pump(tester, youTab());
      expect(find.text('No shoots booked yet.'), findsOneWidget);
    });

    testWidgets('Needs you: requests soonest-deadline first, then proofs to send; the first is marked', (tester) async {
      await _pump(
        tester,
        youTab(
          pending: [
            request(id: 'later', secondsLeft: 20 * 3600, start: DateTime.utc(2026, 11, 9, 15)),
            request(id: 'sooner', secondsLeft: 2 * 3600, start: DateTime.utc(2026, 11, 3, 9)),
          ],
          gigs: [gig(id: 'shot', status: GigStatus.shootDone, start: DateTime.utc(2026, 10, 20, 10))],
        ),
      );
      final items = find.descendant(of: find.byType(NeedsYou), matching: find.text('Booking request'));
      expect(items, findsNWidgets(2));
      expect(find.text('Proofs to send'), findsOneWidget);
      final edge = find.byKey(needsYouFirstKey);
      expect(edge, findsOneWidget, reason: 'exactly one item is marked');
      expect((tester.widget<DecoratedBox>(edge).decoration as BoxDecoration).color, RAccent.meter700);
      expect(tester.getSize(edge).width, RMotif.attentionEdge);
      final card = find.ancestor(of: edge, matching: find.byType(Stack)).first;
      expect(find.descendant(of: card, matching: find.textContaining('2h 00m')), findsOneWidget,
          reason: 'the request that runs out first leads');
      expect(tester.getSize(edge).height, tester.getSize(card).height, reason: 'the edge runs the height of the card');
      final markedCard = find.descendant(of: card, matching: find.byType(RCard)).first;
      expect(tester.getSize(markedCard).width, tester.getSize(find.byType(NeedsYou)).width, reason: 'the marked card keeps the full width');
      expect(
        tester.getTopLeft(find.text('Proofs to send')).dy,
        greaterThan(tester.getTopLeft(items.last).dy),
        reason: 'proofs come after the requests',
      );
    });

    testWidgets('Needs you with nothing waiting says so', (tester) async {
      await _pump(tester, youTab());
      expect(find.text('Nothing is waiting on you.'), findsOneWidget);
    });
  });

  testWidgets('the order of the body: Available now, tier, next shoot, needs you', (tester) async {
    await _pump(tester, youTab());
    double y(String text) => tester.getTopLeft(find.text(text).first).dy;
    expect(y('Available now'), lessThan(y('WHERE YOU STAND')));
    expect(y('WHERE YOU STAND'), lessThan(y('NEXT SHOOT')));
    expect(y('NEXT SHOOT'), lessThan(y('NEEDS YOU')));
  });
}
